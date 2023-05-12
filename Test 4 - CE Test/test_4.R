library("rstan")
library("writexl")
library("shinystan")

data = read.csv("test_4_data.csv", header = TRUE, sep = ",", dec=".");

P_meas <- list(); 
P_meas[[1]] = data$P_0; 
P_meas[[2]] = data$P_1; 
P_meas[[3]] = data$P_2; 
P_meas[[4]] = data$P_3; 
P_meas[[5]] = data$P_4; 

Q_meas <- list(); 
Q_meas[[1]] = data$Q_0; 
Q_meas[[2]] = data$Q_1; 
Q_meas[[3]] = data$Q_2; 
Q_meas[[4]] = data$Q_3; 
Q_meas[[5]] = data$Q_4; 

V_meas <- list(); 
V_meas[[1]] = data$V_0; 
V_meas[[2]] = data$V_1; 
V_meas[[3]] = data$V_2; 
V_meas[[4]] = data$V_3; 
V_meas[[5]] = data$V_4; 

P_priors = list(); 
Q_priors = list(); 
V_priors = list(); 
for (i in 1:5) {
  P_priors[i] <- mean(P_meas[[i]])
  Q_priors[i] <- mean(Q_meas[[i]])
  V_priors[i] <- mean(V_meas[[i]])
}
P_priors = unlist(P_priors);
Q_priors = unlist(Q_priors);
V_priors = unlist(V_priors);

x_d_mean = 1.1270787783546914; 
x_d_std = 0.019912930337001665; 
N_tests = 5; 
N_points = length(data$V_0); 

rstan_options(auto_write = T) 
model = stan_model("test_4_model.stan")
stan_data = list(N_tests=N_tests, N_points=N_points, P_meas=P_meas, Q_meas=Q_meas, V_meas=V_meas, 
                 P_priors=P_priors, Q_priors=Q_priors, V_priors=V_priors, 
                 x_d_mean=x_d_mean, x_d_std=x_d_std); 
stan_control = list(adapt_delta=0.99, max_treedepth=15);

options(mc.cores = 12)
fit = sampling(model,stan_data, iter=40000,chains=12, warmup=20000, control=stan_control, thin=5);

aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('y_q', 'x_q')));
write.csv(posterior_samples, "test_4_result_data.csv", row.names=FALSE)
