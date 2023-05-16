library("rstan")
library("writexl")
#Simulate some data
I_a_base = 5.25; 
I_f_base = 0.8549; 
V_base = 220;

V_data = (325.55+327.28+327.84)/3/V_base; 
I_f_data = 2.7605 / I_f_base; 
I_a_data = 5.25/I_a_base; 
I_f_SC = 0.9376/I_f_base; 

I_f_std = 0.3/100 * I_f_data;
I_a_std = 0.3/100 * I_a_data; 
V_std = 0.3/100 * V_data; 

k_mean = 0.9558854490470637; 
k_std = 0.00625287324629327; 
c_m_mean = 0.03476376338462048; 
c_m_std = 0.0025212335718612033; 
m_mean = 7.087564368248801; 
m_std = 0.1037736041577671; 

rstan_options(auto_write = T) 
model = stan_model("test_5_model.stan");

stan_data = list(I_f_meas=I_f_data, V_t_meas=V_data, I_SC_meas=I_f_SC, I_a_meas=I_a_data, 
                 I_f_std=I_f_std, I_a_std=I_a_std, V_t_std=V_std, k_mean=k_mean, k_std=k_std, 
                 c_m_mean=c_m_mean, c_m_std=c_m_std, m_mean=m_mean, m_std=m_std); 

stan_controls = list(adapt_delta=0.8, max_treedepth=15); 

options(mc.cores = 16)
fit = sampling(model, stan_data, iter=20000, chains=16, warmup=10000, control=stan_controls);

library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('x_l')));
write.csv(posterior_samples, "test_5_result_data.csv", row.names=FALSE)
