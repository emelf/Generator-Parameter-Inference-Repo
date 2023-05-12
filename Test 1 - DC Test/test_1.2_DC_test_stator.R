library("rstan")
library("writexl")
#Simulate some data
data = read.csv("DC_test_stator_data.csv", header = TRUE, sep = ";", dec=".");
I_ph1 = data$i_ph1_A; 
I_ph2 = data$i_ph2_A; 
I_ph3 = data$i_ph3_A; 
V_ph1 = data$v_ph1_V;
V_ph2 = data$v_ph2_V;
V_ph3 = data$v_ph3_V;
alpha = 0.00394;
sigma_i = 0.0051; 
sigma_v = 0.018;

I_DC <- c(I_ph1, I_ph2, I_ph3); 
V_DC <- c(V_ph1, V_ph2, V_ph3); 

N = length(I_DC);
N_ph1 = length(I_ph1);
N_ph2 = length(I_ph2);
N_ph3 = length(I_ph3);

options(mc.cores = 4)

#Compile the Stan model
rstan_options(auto_write = T) # save the compiled version to the working dir
model = stan_model("test_1.2_DC_test_stator.stan") # compile the Stan model

#Infer mu and sigma using Stan model
fit = sampling(model,list(N=N,I_DC=I_DC,V_DC=V_DC,sigma_i=sigma_i,sigma_v=sigma_v,
                          alpha=alpha),
               iter=10000,warmup =5000,chains=4,
               control = list(adapt_delta = 0.99,max_treedepth = 15)); 

# Short presentation of the results in R
#print(fit)

# Advanced web-based presentation using Shinystan. Useful for diagnostics
library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('R20','delta_t', 'R_DC')));
write.csv(posterior_samples, "Experiment 1/test_1_stator_result_data.csv", row.names=FALSE)
