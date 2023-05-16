library("rstan")
library("writexl")
#Simulate some data
data = read.csv("DC_test_rotor_data.csv", header = TRUE, sep = ",", dec=".");
I_r = data$i_r; 
V_r = data$v_r; 
N = length(I_r);
alpha = 0.00394;
sigma_i = 0.0051; 
sigma_v = 0.018; 

options(mc.cores = 4)

#Compile the Stan model
rstan_options(auto_write = T) # save the compiled version to the working dir
model = stan_model("test_1.1_DC_test_rotor.stan") # compile the Stan model

#Infer mu and sigma using Stan model
fit = sampling(model,list(N=N,I_DC=I_r,V_DC=V_r,sigma_i=sigma_i,
                          sigma_v=sigma_v,alpha=alpha),
               iter=10000,warmup =5000,chains=4,
               control = list(adapt_delta = 0.99,max_treedepth = 15))

# Short presentation of the results in R
#print(fit)

# Advanced web-based presentation using Shinystan. Useful for diagnostics
library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

#posterior_samples <- data.frame(extract(fit,pars = c('R20','delta_t', 'R_DC')));
#write.csv(posterior_samples, "Experiment 1/test_1_rotor_result_data.csv", row.names=FALSE)


posterior_samples <- data.frame(extract(fit,pars = c('R20','delta_t', 'R_DC')));
write.csv(posterior_samples, "test_1_rotor_result_data.csv", row.names=FALSE)


V_pred = apply(posterior_samples,1,function(x){
  rnorm(18,mean = x[1]*(1+alpha*x[2])*I_r, sd = sigma_v)
}
)


#posterior_samples <- data.frame(extract(fit,pars = c('logR','mu', 'sigma')));
#V_pred = apply(posterior_samples,1,function(x){
#  exp(rnorm(18,mean = x[1]+x[2]+log(I_r), sd = x[3]))
#}
#)

library(bayesplot)
ppc_dens_overlay(y = V_r, yrep = t(V_pred),n_dens = 20)
