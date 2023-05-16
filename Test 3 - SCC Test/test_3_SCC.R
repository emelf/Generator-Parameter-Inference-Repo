library("rstan")
library("writexl")
#Simulate some data
data = read.csv("test_3_SCC_data.csv", header = TRUE, sep = ";", dec=".");
I_f_meas = data$i_f_A; 
I_ph1 = data$i_ph1_A; 
I_ph2 = data$i_ph2_A; 
I_ph3 = data$i_ph3_A; 

I_f_base = 0.8549; 
I_a_base = 5.25;
I_f_std = 1*0.3/100; 
I_a_std = 5*1.5/100; 

# Concatenated values of winding currents 
I_a <- c(I_ph1, I_ph2, I_ph3)/I_a_base; 
I_f <- c(I_f_meas, I_f_meas, I_f_meas)/I_f_base; 

N = length(I_a); 

rstan_options(auto_write = T) 
model = stan_model("test_3_SCC.stan")
options(mc.cores = 1)
fit = sampling(model,list(N=N,I_f_meas=I_f, I_a_meas=I_a, sigma_I_a=I_a_std, sigma_I_f=I_f_std),
               iter=10000,chains=4, warmup=5000, control=list(adapt_delta=0.80));

# Short presentation of the results in R
print(fit)

library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('Z_d','E_g','Z_d_sq')));
write.csv(posterior_samples, "test_3_result_data.csv", row.names=FALSE)
