using Optim, LinearAlgebra, Distributions, Random
using QuadGK, FastGaussQuadrature
using BenchmarkTools
using XLSX, JLD2, FileIO

# Configuration
cluster = 0 # 0: local; 1: cluster
xlsx_path = if cluster == 0
    "/Users/henryma/Dropbox/Research/Decentralize/02_data/CS_MA_IND_LEVEL.xlsx"
else
    "/work/zm59/Decen_Pref/data/CS_MA_IND_LEVEL.xlsx"
end

# Load data
sheet = XLSX.readxlsx(xlsx_path)["Sheet1"]
data = sheet[:]

# Parse data
P = data[2:end, 2:3]   # High, Low
AD = data[2:end, 4:5]  # High, Low
X = data[2:end, 6:7] .- mean(data[2:end, 6:7], dims=1) # De-mean (GPA, GRE)
N = size(X, 1)

# Parameters
dist = Normal(0,1)
tol = 1e-2
gauss_n = 50
rng = if cluster == 0 1 else Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"]) end

# Function: Gaussian quadrature integration
function gaussian_quad_integrate(f, a, b, n)
    x, w = gausslegendre(n)
    t = 0.5 * ((b - a) * x .+ (b + a)) # Transform interval from [-1,1] to [a,b]
    return 0.5 * (b - a) * sum(w .* f.(t))
end

# Function: Compute integrand for LH_AD
function integrand(eps_ZC, a, S_Q, beta_X, sigma_X, sigma_ZQI, sigma_ZC, X, AD, P, Q, dist)
    sigma_ZQ = sqrt.(sigma_ZQI.^2 .+ sigma_ZC^2)
    alpha = [beta_X ./ sigma_X.^2; (1 ./ sigma_ZQ.^2)]
    phi_eps_ZC = pdf(dist, eps_ZC / sigma_ZC) / sigma_ZC
    Phi = ones(size(X,1))

    for q in 1:Q
        cdf_val = cdf(dist, 
            (alpha[3, q] * (a + eps_ZC)
             + alpha[1, q] * (X[:, 1] / beta_X[1])
             + alpha[2, q] * (X[:, 2] / beta_X[2])
             - (1 + sum(alpha[:, q])) * S_Q[q]) 
            / (alpha[3, q] * sigma_ZQI[q])
        )
        Phi .*= cdf_val .^ AD[:, q] .* (1 .- cdf_val) .^ (P[:, q] .- AD[:, q])
    end
    return Phi .* phi_eps_ZC
end

# Function: Compute likelihood of AD
function LH_AD(b, b_X, X, AD, P, a, dist)
    Q = size(AD, 2)
    K = size(X, 2)

    # Parse parameters
    beta_X = exp.(b_X[1:K])
    sigma_X = exp.(b_X[K+1:2K])
    sigma_ZC = exp(b[1])
    sigma_ZQI = exp.(b[2:Q+1])
    S_Q = b[Q+2:2Q+1]

    return gaussian_quad_integrate(
        eps_ZC -> integrand(eps_ZC, a, S_Q, beta_X, sigma_X, sigma_ZQI, sigma_ZC, X, AD, P, Q, dist), 
        -4, 4, gauss_n
    )
end

# Function: Compute likelihood of X
function LH_X(b, X, a, dist)
    K = size(X, 2)
    f_x = ones(N)

    for k in 1:K
        beta, sigma = exp(b[k]), exp(b[K+k])
        f_x .*= pdf(dist, (X[:, k] .- beta * a) / sigma) ./ sigma
    end

    return f_x
end

# Initialize parameters
Random.seed!(rng)
global theta_old = zeros(9)
global theta_new = [0, 0, -1, 2, 0, 0, 0, 0, 0] + randn(9)

# Compute denominator
global denom_0 = gaussian_quad_integrate(
    a -> LH_X(theta_new[1:4], X, a, dist) .* LH_AD(theta_new[5:end], theta_new[1:4], X, AD, P, a, dist) .* pdf(dist, a), 
    -5, 5, gauss_n
)

# Ensure valid starting point
while any(denom_0 .== 0)
    println("NaN detected, resampling starting point, rng = $rng")
    rng *= 1234
    global theta_new = [0, 0, -1, 2, 0, 0, 0, 0, 0] + randn(9)
    global denom_0 = gaussian_quad_integrate(
        a -> LH_X(theta_new[1:4], X, a, dist) .* LH_AD(theta_new[5:end], theta_new[1:4], X, AD, P, a, dist) .* pdf(dist, a), 
        -5, 5, gauss_n
    )
end

# EM Algorithm
while norm(theta_new - theta_old) > tol
    println("Current Conv. Gap: ", abs(norm(theta_new - theta_old)))
    global theta_old = theta_new
    theta_x_old, theta_ad_old = theta_old[1:4], theta_old[5:end]

    # E-Step: Compute posterior probabilities
    denom = gaussian_quad_integrate(
        a -> LH_X(theta_x_old, X, a, dist) .* LH_AD(theta_ad_old, theta_x_old, X, AD, P, a, dist) .* pdf(dist, a), 
        -5, 5, gauss_n
    )

    global f = a -> LH_X(theta_x_old, X, a, dist) .* LH_AD(theta_ad_old, theta_x_old, X, AD, P, a, dist) .* pdf(dist, a) ./ denom

    # M-Step: Update θ^X
    result_x = optimize(
        params -> -sum(gaussian_quad_integrate(a -> log.(LH_X(params, X, a, dist)) .* f(a), -4, 4, gauss_n)), 
        theta_x_old, BFGS(), Optim.Options(show_trace=true)
    )
    theta_x_new = Optim.minimizer(result_x)
    println("Current theta_x: ", theta_x_new)

    # M-Step: Update θ^AD
    result_ad = optimize(
        params -> -sum(gaussian_quad_integrate(a -> log.(LH_AD(params, theta_x_new, X, AD, P, a, dist)) .* f(a), -4, 4, gauss_n)), 
        theta_ad_old, BFGS(), Optim.Options(show_trace=true)
    )
    theta_ad_new = Optim.minimizer(result_ad)
    println("Current theta_ad: ", theta_ad_new)

    global theta_new = [theta_x_new; theta_ad_new]
    global LLH = Optim.minimum(result_x) + Optim.minimum(result_ad)
    println("Current LLH: ", LLH)
end

# Extract final parameters
Beta_X = exp.(theta_x_new[1:2])
Sigma_X = exp.(theta_x_new[3:4])
Sigma_ZC = exp(theta_new[5])
Sigma_ZQI = exp.(theta_new[6:7])
S_Q = theta_new[8:9]

# Save results (only if running on cluster)
if cluster == 1
    cd("/work/zm59/Decen_Pref/Est_AD")
    @save "Est_AD_$(rng).jld2" rng
end
