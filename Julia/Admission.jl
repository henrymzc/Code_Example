cluster = 0 # 0: local; 1: cluster
if cluster == 1
    using Pkg # install packages
    Pkg.add("Optim")
    Pkg.add("LinearAlgebra")
    Pkg.add("XLSX")
    Pkg.add("QuadGK")
    Pkg.add("Distributions")
    Pkg.add("FastGaussQuadrature")
    Pkg.add("BenchmarkTools")
    Pkg.add("JLD2")
    Pkg.add("FileIO")
end

using Optim, LinearAlgebra, Distributions, Random
using QuadGK, FastGaussQuadrature # for numerical integration
using BenchmarkTools # for timing
using XLSX, JLD2, FileIO  # for reading and writing data

# Preload functions
# 1. Numericall integrate using Gaussian quadrature
function gaussian_quad_integrate(f, a, b, n)
    x, w = gausslegendre(n)
    # Change of interval from [-1, 1] to [a, b]
    t = 0.5 * ((b - a) * x .+ (b + a))
    integral = 0.5 * (b - a) * sum(w .* f.(t))
    return integral
end

# 2. Integrand function for LH_AD
function integrand(eps_ZC, a, S_Q, beta_X, sigma_X, sigma_ZQI, sigma_ZC, X, AD, P, Q, dist)
    # Calculate Alpha
    Q = size(AD,2)
    K = size(X,2)
    sigma_ZQ = sqrt.(sigma_ZQI.^2 .+ sigma_ZC^2)

    alpha = zeros(K+1,Q)
    alpha[1,:] .= beta_X[1]/(sigma_X[1]^2)  
    alpha[2,:] .= beta_X[2]/(sigma_X[2]^2)
    alpha[3,:] = (1 ./ sigma_ZQ.^2) 
    
    phi_eps_ZC = pdf(dist, eps_ZC / sigma_ZC) / sigma_ZC
    Phi = ones(size(X,1));
    for qq in 1:Q
        cdf_val = cdf(dist, 
        (alpha[3, qq] * (a + eps_ZC)
            .+ alpha[1, qq] * (X[:,1]/ beta_X[1])
            .+ alpha[2, qq] * (X[:,2]/ beta_X[2])
            .- (1 + alpha[1, qq] + alpha[2, qq] + alpha[3, qq]) * S_Q[qq]) 
        / (alpha[3, qq] * sigma_ZQI[qq]) 
        )
        Phi .*=  cdf_val.^AD[:,qq] .* (1 .- cdf_val).^(P[:,qq] .- AD[:,qq])
    end
    return Phi .* phi_eps_ZC
end

# 3. Likelihood of each individual, N*1 Vector
function LH_AD(b,b_X,X,AD,P,a,dist)
    Q = size(AD,2)
    K = size(X,2)

    # Parse b_X
    beta_X = zeros(K)
    sigma_X = zeros(K)
    for kk = 1:K
        beta_X[kk] = exp(b_X[kk])
        sigma_X[kk] = exp(b_X[K+kk])
    end

    # Parse b
    sigma_ZC = exp(b[1])
    sigma_ZQI = exp.(b[2:Q+1])
    S_Q = b[Q+2:2*Q+1]

    #result = quadgk(eps_ZC -> integrand(eps_ZC, a,  S_Q, alpha, sigma_ZQI, sigma_ZC, X, AD, P, Q), -Inf, Inf,rtol=1e-6)[1] 
    result = gaussian_quad_integrate(eps_ZC -> integrand(eps_ZC, a, S_Q, beta_X, sigma_X, sigma_ZQI, sigma_ZC, X, AD, P, Q, dist), -4, 4, gauss_n)
    return result

end

# 4. Likelihood of each individual, N*1 Vector
function LH_X(b,X,a, dist)
    K = size(X,2)
    f_x = ones(size(X,1));
    for kk = 1:K
        beta = exp(b[kk])
        sigma = exp(b[K+kk])
        f_x .*= pdf(dist, (X[:,kk] .- beta * a) / sigma) ./sigma
    end

    return f_x
end

# Load data
if cluster == 0
    xlsx_file =  XLSX.readxlsx("/Users/henryma/Dropbox/Research/Decentralize/02_data/CS_MA_IND_LEVEL.xlsx")
    rng = 1
else
    xlsx_file =  XLSX.readxlsx("/work/zm59/Decen_Pref/data/CS_MA_IND_LEVEL.xlsx")
    TaskID = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"]) # obtian task ID from SLURM
    #TaskID = parse(Int, ARGS[1]) # need to specific $SLURM_ARRAY_TASK_ID as argument after file name
    rng = TaskID
end

sheet = xlsx_file["Sheet1"] # Access the first sheet
data = sheet[:]

# Parse data
P = data[2:end,2:3] # High, Low
AD = data[2:end,4:5] # High, Low
X = data[2:end,6:7] # (GPA, GRE)
X = X .- mean(X,dims=1) # de-mean
N = size(X,1)

# Initialize parameters
dist = Normal(0,1)
tol = 1e-2;
gauss_n = 50;

# Initialize parameters
global theta_old = zeros(9,1)
Random.seed!(rng)
global theta_new = [0;0;-1;2;0;0;0;0;0] + 1 * randn(9) # [beta_X; sigma_X; sigma_ZC; sigma_ZQI; S_Q]

global denom_0 = gaussian_quad_integrate(a -> LH_X(theta_new[1:4], X, a, dist) .* LH_AD(theta_new[5:end], theta_new[1:4], X, AD, P, a, dist) .* pdf(dist, a), -5, 5, gauss_n);
global nan_flog = any(x -> x == 0, denom_0)
while nan_flog
    println("NaN detected, resample starting point",rng)
    global rng = rng * 1234
    global theta_new = [0;0;-1;2;0;0;0;0;0] + 1 * randn(9) # NEW STARTING POINT
    println("Current theta_new: ", theta_new)
    global denom_0 = gaussian_quad_integrate(a -> LH_X(theta_new[1:4], X, a, dist) .* LH_AD(theta_new[5:end], theta_new[1:4], X, AD, P, a, dist) .* pdf(dist, a), -5, 5, gauss_n);
    global nan_flog = any(x -> x == 0, denom_0)
end

while norm(theta_new - theta_old) > tol
    println("Current Conv. Gap: ", abs(norm(theta_new - theta_old)))
    global theta_old = theta_new
    global theta_x_old = theta_old[1:4];
    global theta_ad_old = theta_old[5:end];
    
    # E step: update posterior probabilities
    @btime begin
    denom = gaussian_quad_integrate(a -> LH_X(theta_x_old, X, a, dist) .* LH_AD(theta_ad_old, theta_x_old, X, AD, P, a, dist) .* pdf(dist, a), -5, 5, gauss_n);
    #global denom_chek = quadgk(a -> LH_X(theta_x_old, X, a, dist) .* LH_AD(theta_ad_old, theta_x_old, X, AD, P, a, dist) .* pdf(dist, a), -5, 5);
    #println("check of accuracy: ", maximum(abs.(denom_chek[1].-denom))) # check if sumup to
    global f = a -> LH_X(theta_x_old, X, a,dist) .* LH_AD(theta_ad_old, theta_x_old, X, AD, P, a,dist) .* pdf(dist, a) ./ denom; # Posterior
    #check = gaussian_quad_integrate(a -> f(a), -5, 5, gauss_n);
    #println("check of sum up to 1: ", maximum(abs.(check.-1))) # check if sumup to
    end

    # M step: update parameters
    # Update θ^x
    result_x = optimize(params -> -sum(gaussian_quad_integrate(a -> log.(LH_X(params,X,a,dist)) .* f(a), -4, 4,gauss_n)), theta_x_old, BFGS(),Optim.Options(show_trace=true));
    theta_x_new = Optim.minimizer(result_x);
    L1 = Optim.minimum(result_x)
    println("Current theta_x: ", theta_x_new)

    # Update θ^AD
    result_ad = optimize(params -> -sum(gaussian_quad_integrate(a -> log.(LH_AD(params,theta_x_new,X,AD,P,a,dist)) .* f(a), -4, 4,gauss_n)), theta_ad_old, BFGS(),Optim.Options(show_trace=true));
    theta_ad_new = Optim.minimizer(result_ad);
    L2 = Optim.minimum(result_ad)
    println("Current theta_ad: ", theta_ad_new)

    global theta_new = [theta_x_new; theta_ad_new];
    global LLH = L1 + L2 # Log-likelihood
    println("Current LLH: ", LLH)
end

Beta_X =  exp.(theta_x_new[1:2])
Sigma_X =  exp.(theta_x_new[3:4])
Sigma_ZC =  exp(theta_new[5])
Sigma_ZQI =  exp.(theta_new[6:7])
S_Q =  theta_new[8:9]

# Save results
if cluster == 1
    cd("/work/zm59/Decen_Pref/Est_AD")
    @save "Est_AD_$TaskID.jld2" TaskID
end