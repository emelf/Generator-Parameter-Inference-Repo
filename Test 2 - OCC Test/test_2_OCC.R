library("rstan")
library("writexl")

#Simulate some data
data = read.csv("Experiment 2/test_2_OCC_data.csv", header = TRUE, sep = ";", dec=".");
I_f = data$i_f_A; 
V_ph1 = data$v_ph1_V; 
V_ph2 = data$v_ph2_V; 
V_ph3 = data$v_ph3_V; 

I_f_base = 0.8549; 
V_base = 220/sqrt(3); 
I_std = 0.3/100 * 5/I_f_base; # Approximate standard deviation per measurement. 
V_std = 0.3/100 * 300/V_base; # Approximate standard deviation per measurement. 

# Concatenated stan inputs
I_f_tot <- c(I_f, I_f, I_f)/I_f_base; 
V_ph_tot <- c(V_ph1, V_ph2, V_ph3)/V_base; 

N = length(I_f_tot); 

#Compile the Stan model
rstan_options(auto_write = T) # save the compiled version to the working dir
model = stan_model("Experiment 2/test_2_OCC.stan") # compile the Stan model

options(mc.cores = 4)
fit = sampling(model,list(N=N,V_t_meas=V_ph_tot, I_f_meas=I_f_tot, V_std=V_std, I_std=I_std),
               iter=10000, chains=4, warmup=5000); 

# Short presentation of the results in R
print(fit)

# Advanced web-based presentation using Shinystan. Useful for diagnostics
library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('k','c_m', 'sigma')));
write.csv(posterior_samples, "Experiment 2/test_2_result_data.csv", row.names=FALSE)
