
data {
  int<lower=0> N;
  vector<lower=0>[N] I_f_meas;
  vector<lower=0>[N] I_a_meas;
  real<lower=0> sigma_I_a; 
  real<lower=0> sigma_I_f; 
}

transformed data {

}

parameters {
  vector<lower=0>[N] E_g;
  //real<lower=0> sigma_E_g;
  real<lower=0> Z_d;
  
}

transformed parameters {
  
}

model {
  for (i in 1:N){
    I_f_meas[i] ~ normal(E_g[i], sigma_I_f); // I_f is the estimate of E_g. Assume Ohms law is true. 
    I_a_meas[i] ~ normal(E_g[i]/Z_d, sigma_I_a); 
  }
    
  
  // Priors
  Z_d ~ gamma(20, 2); 
  //sigma_E_g ~ gamma(1, 1); 
}

