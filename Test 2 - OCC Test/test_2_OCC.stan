
data {
  int<lower=0> N;
  vector[N] V_t_meas;
  vector[N] I_f_meas;
  real<lower=0> V_std; 
  real<lower=0> I_std; 
}

parameters {
  real<lower=0> k;
  real<lower=0> c_m;
  real<lower=0> m; 
  vector<lower=0>[N] V_t; 
}

model {
  vector[N] V_t_pow_m = pow(V_t, m);
  for (i in 1:N) {
    V_t_meas[i] ~ normal(V_t[i], V_std); 
    I_f_meas[i] ~ normal(k*(V_t[i]+c_m*V_t_pow_m[i]), I_std);
  }
  
  
  k ~ gamma(1, 1); 
  c_m ~ gamma(1, 1); 
  m ~ gamma(18, 2); 
}

