
data {
  real I_f_meas;
  real V_t_meas;
  real<lower=0> I_SC_meas;
  real<lower=0> I_a_meas; 
  
  real<lower=0> I_f_std; 
  real<lower=0> I_a_std; 
  real<lower=0> V_t_std;
  
  real<lower=0> k_mean; 
  real<lower=0> k_std; 
  real<lower=0> c_m_mean; 
  real<lower=0> c_m_std; 
  real<lower=0> m_mean; 
  real<lower=0> m_std; 
}

transformed data {
  real k = normal_rng(k_mean, k_std); 
  real c_m = normal_rng(c_m_mean, c_m_std); 
  real m = normal_rng(m_mean, m_std); 
}

parameters {
  real<lower=0, upper=1> t; 
  real<lower=0, upper=10> V_t; 
  //real<lower=0, upper=10> I_f; 
  real<lower=0.8, upper=1.2> I_a; 
  real<lower=0.9, upper=1.2> I_SC; 
  //real<lower=0.8, upper=1.2> k; 
  //real<lower=0, upper=0.1> c_m; 
  //real<lower=5, upper=10> m; 
}

transformed parameters {
  real<lower=0> E_g = V_t + t; 
  real<lower=0> I_f = I_SC - t + k*(E_g + c_m*pow(E_g, m)); 
}

model {
  // Sampling from previous distributions 
  //k ~ normal(k_mean, k_std); 
  c_m ~ normal(c_m_mean, c_m_std); 
  m ~ normal(m_mean, m_std); 
  
  // Account for measurement uncertainty 
  V_t_meas ~ normal(V_t, V_t_std); 
  I_f_meas ~ normal(I_f, I_f_std); 
  I_SC_meas ~ normal(I_SC, I_f_std); 
  I_a_meas ~ normal(I_a, I_a_std); 
}

generated quantities  {
  real x_l = t/I_a; 
}

