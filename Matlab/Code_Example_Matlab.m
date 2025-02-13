%% Set Parameters
clearvars; clc;

% Define execution environment (Cluster or Local)
cluster = 1;  
if cluster == 1
    numCPUs = str2double(getenv('SLURM_CPUS_PER_TASK'));
    taskID = str2double(getenv('SLURM_ARRAY_TASK_ID'));
    rng(99 * taskID);
    cd '/hpc/home/zm59/Judge/02_11';
    load('/work/zm59/Judge/Data/D_type_long_short_Z.mat');
else  
    cd '/Users/henryma/Dropbox/Research/Judge_Bail';
    load('Data/D_type_long_short_Z.mat');
    cd '/Users/henryma/Dropbox/Research/Judge_Bail/Code/modelv3';
end

%% Main Loop for Parameter Estimation
N = size(data, 1);
pi_values = 0.6:0.05:0.95;  % Define range of pi values

for pi = pi_values  
    ind_pi = round(pi * 100);
    for spec = 1:4
        % Define Variables and Instruments based on spec
        [X_var, columnNames, initval] = define_specification(spec, data);
        
        % Construct matrices
        X_alpha = [data.black, data.hisp, data.female, data.z1, ones(N,1)];
        X_lambda_zeta = ones(N, 1);
        X_B = [X_var, ones(N, 1)];
        Z = data{:, columnNames};
        Z_sd = normalize_instruments(Z);

        % Discretizing A
        grid = 4;  
        A_deciles = discretize_variable(data.A, grid);
        Z_sd = [ones(N,1), Z_sd, A_deciles];

        % Local PC Test
        if cluster == 0
            [beta_est, fval_new, beta_opt_est, fval_new_opt, omega] = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval, pi);
        end

        % Robust Estimation with Retry Mechanism
        success = false;
        while ~success
            try 
                [beta_est, fval_new, beta_opt_est, fval_new_opt, omega] = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval, pi);
                success = true;
            catch
                warning('Optimization failed, retrying with new initial values...');
                initval = initval + randn(size(initval)); % Modify initialization
            end
        end
        
        % Save Results if running on cluster
        if cluster == 1
            filename = sprintf('/work/zm59/Judge/Result/v3_v4_diff_pi/result_%d_%d_%d.mat', ind_pi, spec, taskID);
            save(filename, 'beta_est', 'fval_new', 'beta_opt_est', 'fval_new_opt', 'omega');
        end
    end
end

%% Function to Define Specification Variables
function [X_var, columnNames, initval] = define_specification(spec, data)
    switch spec
        case 1
            X_var = [data.black, data.hisp];
            columnNames = strcat('zz', string(1:11));
            initval = 4 * randn(1,10);
        case 2
            X_var = [data.black, data.hisp, data.female, data.age, data.age2];
            columnNames = strcat('zz', string(1:20));
            initval = [randn(1,13)];
        case 3
            X_var = [data.black, data.hisp, data.female, data.age, data.age2, ...
                     data.pastcases1, data.pastcases2, data.pastcases_felony1, data.pastcases_felony2, data.pastftas1];
            columnNames = strcat('zz', string(1:35));
            initval = [randn(1,18)];
        case 4
            X_var = [data.black, data.hisp, data.female, data.age, data.age2, ...
                     data.pastcases1, data.pastcases2, data.pastcases_felony1, data.pastcases_felony2, data.pastftas1, ...
                     data.charge2, data.charge_felony, data.charge_felony2, data.charge_drug, data.charge_violent, data.charge_property];
            columnNames = strcat('zz', string(1:53));
            initval = [randn(1,24)];
        otherwise
            error('Invalid specification number.');
    end
end

%% Function to Normalize Instruments
function Z_sd = normalize_instruments(Z)
    Z_sd = bsxfun(@rdivide, Z, std(Z));
end

%% Function to Discretize Variable
function A_deciles = discretize_variable(A, grid)
    N = length(A);
    A_deciles = zeros(N, grid - 1);
    decile_edges = prctile(A, linspace(0, 100, grid + 1));
    for i = 1:grid-1
        A_deciles(:, i) = (A >= decile_edges(i)) & (A < decile_edges(i + 1));
    end
end

%% Main Estimation Function
function [beta_est, fval_new, beta_opt_est, fval_new_opt, omega] = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval, pi)
    R = data.R;
    c_R = data.c_R;
    A = data.A;
    T_j = data.T_j;
    dim_Z = size(Z_sd, 2);

    %% Optimization Settings
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'iter', ...
        'MaxFunctionEvaluations', 1e7, 'OptimalityTolerance', 1e-10, ...
        'MaxIterations', 1e6, 'StepTolerance', 1e-10, 'FunctionTolerance', 1e-10);

    options_fms = optimset('Display', 'final', 'MaxFunEvals', 1e6, 'MaxIter', 1e6, ...
        'TolFun', 1e-8, 'TolX', 1e-8);

    %% First-Step Estimation (Identity Weighting Matrix)
    momentFun = @(b) condExp_cj_pi(b, X_lambda_zeta, X_alpha, X_B, Z_sd, T_j, A, c_R, R, pi, eye(dim_Z));
    [beta_est, ~] = fminunc(momentFun, initval, options);

    fval_new = Inf;
    fval_old = Inf + 1;
    while fval_old - fval_new > 1e-7
        fval_old = fval_new;
        [beta_est, fval_new] = fminsearch(momentFun, beta_est, options_fms);
    end

    %% Compute Optimal Weighting Matrix
    [~, omega] = condExp_cj_pi(beta_est, X_lambda_zeta, X_alpha, X_B, Z_sd, T_j, A, c_R, R, pi, eye(dim_Z));
    W_opt = inv(omega) * 10000;

    %% Second-Step Estimation (Optimal GMM)
    momentFun_opt = @(b) condExp_cj_pi(b, X_lambda_zeta, X_alpha, X_B, Z_sd, T_j, A, c_R, R, pi, W_opt);
    [beta_opt_est, ~] = fminunc(momentFun_opt, beta_est, options);

    fval_new_opt = Inf;
    fval_old_opt = Inf + 1;
    while fval_old_opt - fval_new_opt > 1e-7
        fval_old_opt = fval_new_opt;
        [beta_opt_est, fval_new_opt] = fminsearch(momentFun_opt, beta_opt_est, options_fms);
    end

    disp('Estimation complete.');
end
