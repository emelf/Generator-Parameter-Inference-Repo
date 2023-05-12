library("rstan")
library("writexl")
library("shinystan")

# Obtain parameter distributions from other tests: 
k_mean = 0.9558854490470637; 
k_std = 0.00625287324629327; 
c_m_mean = 0.03476376338462048; 
c_m_std = 0.0025212335718612033; 
m_mean = 7.087564368248801; 
m_std = 0.1037736041577671; 
y_d_mean = 0.8872318330311988; 
y_d_std = 0.015971490973935982; 

data = read.csv("test_5_data.csv", header = TRUE, sep = ",", dec=".");
I_f_meas = data$If; 
I_w1 = data$Ia_w1; 
I_w2 = data$Ia_w2; 
I_w3 = data$Ia_w3; 
V_w1 = data$Vt_w1; 
V_w2 = data$Vt_w2; 
V_w3 = data$Vt_w3; 

I_f_base = 0.8549; 
I_a_base = 5.25;
V_base = 220/sqrt(3); 
I_f_std = 1*1.6/100/I_f_base; 
I_a_std = 5*1.6/100/I_a_base; 
V_t_std = 150*1.6/100/V_base; 

# Collect values for stan:
I_a_meas <- (I_w1+I_w2+I_w3)/ (3*I_a_base); 
I_f_meas <- I_f_meas/I_f_base; 
V_t_meas <- (V_w1+V_w2+V_w3)/(3*V_base); 
N = length(I_a_meas); 

rstan_options(auto_write = T) 
model = stan_model("test_5_model.stan")

stan_data = list(N=N, I_f_meas=I_f_meas, V_t_meas=V_t_meas, I_a_meas=I_a_meas, 
                 I_f_std=I_f_std, V_t_std=V_t_std, I_a_std=I_a_std, y_d_mean=y_d_mean, 
                 y_d_std=y_d_std, k_mean=k_mean, k_std=k_std, c_m_mean=c_m_mean, 
                 c_m_std=c_m_std, m_mean=m_mean, m_std=m_std); 

stan_controls = list(adapt_delta=0.999, max_treedepth=15); 

options(mc.cores = 12)
fit = sampling(model, stan_data, iter=20000, chains=12, warmup=10000, control=stan_controls);

aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('t', 'E_g','x_l')));
write.csv(posterior_samples, "test_5_result_data.csv", row.names=FALSE)
