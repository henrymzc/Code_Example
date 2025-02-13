% Set parameters 
    clear
    clc

    % Location 
    cluster = 1
    if cluster == 1
        numCPUs = str2num(getenv('SLURM_CPUS_PER_TASK'))
        taskID = str2num(getenv('SLURM_ARRAY_TASK_ID'))
        rng(99*taskID)
        cd /hpc/home/zm59/Judge/02_11
        load('/work/zm59/Judge/Data/D_type_long_short_Z.mat')
    else  
        cd  /Users/henryma/Dropbox/Research/Judge_Bail
        %cd D:/Dropbox/Research/Judge_Bail
        %data = readtable("Data/gmm_d_type.xlsx");
        %save ("Data/gmm_d_type.mat")
        load('Data/D_type_long_short_Z.mat')
        cd  /Users/henryma/Dropbox/Research/Judge_Bail/Code/modelv3
    end

    % Main
    N = size(data,1);  
    for pi = 0.6:0.05:0.95        
        ind_pi = pi*100;
        for spec = 1:4
            if spec == 1
                X_var =   [data.black data.hisp ];
                % Instrument
                columnNames = strcat('zz', string(1:11)); % Creates string ["z1", "z2", ..., "z26"]11,26,66,144
                %columnNames = strcat('z', string([1,2,6,7,9,10])); %without A   
                initval = 4 * randn(1,10)  ;
            elseif spec == 2
                X_var =   [data.black data.hisp data.female data.age data.age2];
                columnNames = strcat('zz', string(1:20));         
                %columnNames = strcat(zz', string([1,2,6,7,9,10,12,13,15:18,20:23,25,26])); %without A
                initval = [beta_est(1:8) 0 0 0 beta_est(9:10) ] + 2* randn(1,13);
            elseif spec == 3
                X_var =   [data.black data.hisp data.female data.age data.age2 data.pastcases1 data.pastcases2 data.pastcases_felony1 data.pastcases_felony2 data.pastftas1];
                columnNames = strcat('zz', string(1:35)); % Creates string ["z1", "z2", ..., "z26"]11,26,66,144            
                %columnNames = strcat('z', string([1,2,6,7,9,10,12,13,15:18,20,23,25,26,27,28,30:36,38:44,46:52,54:60,62:66])); %without A
                initval = [beta_est(1:11) 0 0 0 0 0 beta_est(12:13)] + 2* randn(1,18);
            elseif spec == 4
                X_var =   [data.black data.hisp data.female data.age data.age2 data.pastcases1 data.pastcases2 data.pastcases_felony1 data.pastcases_felony2 data.pastftas1 ...
                    data.charge2 data.charge_felony data.charge_felony2 data.charge_drug data.charge_violent data.charge_property];
                columnNames = strcat('zz', string(1:53)); % Creates string ["z1", "z2", ..., "z26"]11,26,66,144                        
                %columnNames = strcat('z', string([1,2,6,7,9,10,12,13,15:18,20:23,25,26,27,28,30:36,38:44,46:52,54:60,62:68,70:81,83:94,96:107,109:120,122:133,135:144])); %without A
                initval = [beta_est(1:16) 0 0 0 0 0 0  beta_est(17:18)] + 2* randn(1,24);
            end
            
                X_alpha  = [data.black data.hisp data.female data.z1  ones(N,1)];
                X_lambda_zeta  = [ones(N,1)];
                X_B = [X_var ones(N,1)];
    
                Z = data{:, columnNames};
                Z_sd = bsxfun(@rdivide, Z, std(Z)); % standardize the instruments (not mean shifter)
             
                A = data.A;
                grid = 4 ; 
                A_deciles = zeros(N, grid - 1);
                decile_edges = prctile(A, linspace(0, 100, grid + 1));
                for i = 1:grid-1
                    A_deciles(:, i) = A >= decile_edges(i) & A < decile_edges(i + 1);
                end
            
                %Z_sd = [ones(N,1) Z_sd];
                Z_sd = [ones(N,1) Z_sd A_deciles ];
               
                % Test on Local PC
            if cluster == 0
              [beta_est,fval_new,beta_opt_est, fval_new_opt]  = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval, pi);
            end
            success = false;
            while ~success
                try 
                    [beta_est,fval_new,beta_opt_est, fval_new_opt,omega]  = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval, pi);
                    success = true;
                catch exception
                    success = false
                    initval = initval + randn(size(initval,1));
                end
            end
            
            if cluster == 1
                filename = sprintf('/work/zm59/Judge/Result/v3_v4_diff_pi/result_%d_%d_%d.mat', ind_pi, spec, taskID); % Create a filename using sprintf
                save(filename,'beta_est','fval_new','beta_opt_est', 'fval_new_opt','omega') ;
            end
        end
    end
%% combine
%{

clear
clc

cd /Users/henryma/Dropbox/Research/Judge_Bail/cluster/result/v3_v4_diff_pi


spec = 4
if spec == 1
    dim_p = 10
elseif spec == 2
    dim_p = 13
elseif spec == 3 
    dim_p = 18
elseif spec == 4
    dim_p = 24
end

N = 200;
beta_est_list = zeros(N,dim_p);
fval1_list = zeros(N,1);
beta_opt_est_list = zeros(N,dim_p);
fval2_list = zeros(N,1);
exclude_list = [78 89 96 112 174 197 ]

for i = 1:N
    if  ismember(i, exclude_list)
        fval1_list(i,:)= 10000000;
    else
        % Construct the file name
        fileName = sprintf('result_%d_%d.mat', spec,i);
        % Load the .mat file
        load(fileName);
        beta_est_list(i,:)= beta_est;
        fval1_list(i,:)= fval_new;
        beta_est_list_opt_gmm(i,:)= beta_opt_est;
        fval2_list(i,:)= fval_new_opt;
    end
end
[a,b] = min(fval1_list)
beta_opt_est = beta_est_list(b,:)
beta_opt_est = beta_est_list_opt_gmm(b,:)

cd  /Users/henryma/Dropbox/Research/Judge_Bail
load('Data/D_type_long_short_Z.mat')
N = size(data,1); 

if spec == 1
    X_var =   [data.black data.hisp ];
elseif spec == 2
    X_var =   [data.black data.hisp data.female data.age data.age2];
elseif spec == 3
    X_var =   [data.black data.hisp data.female data.age data.age2 data.pastcases1 data.pastcases2 data.pastcases_felony1 data.pastcases_felony2 data.pastftas1];
elseif spec == 4
    X_var =   [data.black data.hisp data.female data.age data.age2 data.pastcases1 data.pastcases2 data.pastcases_felony1 data.pastcases_felony2 data.pastftas1 ...
         data.charge2 data.charge_felony data.charge_felony2 data.charge_drug data.charge_violent data.charge_property];
end
    X_alpha  = [data.black data.hisp data.female data.z1  ones(N,1)];
    X_B = [X_var ones(N,1)];
    X_mean = mean(X_alpha);
    X_black = [1,0,X_mean(3:end)];
    X_hisp  = [0,1,X_mean(3:end)];
    X_white = [0,0,X_mean(3:end)];
    X_B_black = [1,0,mean(X_var(:,3:end)),1];
    X_B_hisp  = [0,1,mean(X_var(:,3:end)),1];
    X_B_white = [0,0,mean(X_var(:,3:end)),1 ];


    dim_X_alpha = size(X_mean,2);
    dim_X_B = size(X_B,2);

    % parameters
    beta_est_a = beta_opt_est(1:dim_X_alpha)';
    beta_est_B = beta_opt_est(2+dim_X_alpha:dim_X_alpha+dim_X_B+1)';
    c_j = exp(beta_opt_est(end))
    lambda_zeta = exp(beta_opt_est(1+dim_X_alpha))

        alpha_white = exp(X_white*beta_est_a)
        alpha_black = exp(X_black*beta_est_a)
        alpha_hisp  = exp(X_hisp*beta_est_a)
        
        B_white = X_B_white*beta_est_B
        B_black = X_B_black*beta_est_B
        B_hisp  = X_B_hisp*beta_est_B


%
%
%}

%% Main Estimation Function
function [beta_est,fval_new,beta_opt_est, fval_new_opt,omega] = main(data, X_B, X_lambda_zeta, X_alpha, Z_sd, initval,pi)

    %c_j = 83/1000;
    %pi = 0;
    %pi_tilde = pi*0.9+0.1;
    R = data.R; %recidivism 
    c_R = data.c_R; % K*g

    R_murder_adjust = 0; %percentage of R adjustment, if equal to 0.9, meaning 90% of murder cost
    if R_murder_adjust>0
        c_R = c_R - (c_R>7000)* 7809 * (1-R_murder_adjust);
    end
    A = data.A;
    T_j = data.T_j;
    dim_Z = size(Z_sd,2);
    
    %% Estimate C_j
    
    %without instrument
    %columnNames = strcat('z', string([3,4,6,8,9,11])); %without instrument, race only
    %columnNames = strcat('z', string([3,4,6,8,9,11,12,14:17,19:22,24:26])); %without instrument, race+demo
    %columnNames = strcat('z', string([3,4,6,8,9,11,12,14:17,19:22,24:27,29:35,37:43,45:51,53:58])); %without instrument, race+demo+pastcases
    %columnNames = strcat('z', string([3,4,6,8,9,11,12,14:17,19:22,24:27,29:35,37:43,45:51,53:59,61:71,73:82])); %without instrument, race+demo+pastcases+charge
    
    %%  opt setting
    
    %options for fminunc       
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', ...
            'iter', 'MaxFunctionEvaluations', 1e7,...
            'OptimalityTolerance',1e-10, ...
            'MaxIterations', 1e6,...
            'StepTolerance',1e-10, ...
            'FunctionTolerance',1e-10); 
    %options for fminsearch
    options_fms = optimset('Display','final','MaxFunEvals', 1e6,'MaxIter',1e6 ...
            ,'TolFun',1e-8,'TolX',1e-8); 
    %options for ga
    %{
    init_pop = double(repmat(initval,100,1)+[zeros(1,2*dim_x+3); rand(99,2*dim_x+3)*0.05]);
    options_ga= optimoptions('ga','Display','iter','UseParallel',true,'FunctionTolerance',1e-10 ...
        ,'PopulationSize',100,'InitialPopulationMatrix',init_pop);
    %[beta_est, fval] = ga(momentFun,2*dim_x+3,[],[],[],[],[],[],[],options_ga)
    
    %}

    % initval = initval + randn(1,size_beta) * 0.5;
    %% First-step Estimation: Identity weighting matrix
    momentFun = @(b) (condExp_cj_pi(b, X_lambda_zeta,  X_alpha, X_B, Z_sd, T_j, A, c_R, R ,pi, eye(dim_Z)));
    [beta_est, ~] = fminunc(momentFun, initval,options);
    
    fval_new=1e8;
    fval_old=1e8+1;
    count = 0;
    while fval_old-fval_new>1e-7
        count = count + 1
        fval_old=fval_new;
        init = beta_est;
        [beta_est, fval_new] = fminsearch(momentFun, init ,options_fms)
    end

        
    %% Calculate optimal instrument
    [~ , omega] = condExp_cj_pi(beta_est, X_lambda_zeta,  X_alpha, X_B, Z_sd, T_j, A, c_R, R ,pi, eye(dim_Z));
    %std = sqrt(diag(inv(g*g') * (g*omega*g') * inv(g*g'))/N); %Asym. variance/
    W_opt = inv(omega)*10000;

    %% Second-step Estimation: using GMM efficient matrix
    momentFun_opt = @(b)(condExp_cj_pi(b, X_lambda_zeta,  X_alpha, X_B, Z_sd, T_j, A, c_R, R ,pi, W_opt));
    [beta_opt_est, ~] = fminunc(momentFun_opt, beta_est, options);
    
    fval_new_opt=1e8;
    fval_old_opt=1e8+1;
    count = 0;
    while fval_old_opt-fval_new_opt>1e-7
        count = count + 1
        fval_old_opt=fval_new_opt;
        initval = beta_opt_est;
        [beta_opt_est, fval_new_opt] = fminsearch(momentFun_opt, initval ,options_fms)
    end
     
    display('this is the end of one estimation');
end

 