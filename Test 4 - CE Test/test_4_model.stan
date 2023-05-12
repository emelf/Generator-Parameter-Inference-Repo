data {
  int<lower=0> N_tests; // Number of distinct points 
  int<lower=0> N_points; // Number of distinct points 
  vector[N_points] P_meas[N_tests];
  vector[N_points] Q_meas[N_tests];
  vector[N_points] V_meas[N_tests];
  vector[N_tests] P_priors;
  vector[N_tests] Q_priors;
  vector[N_tests] V_priors;
  real<lower=0> x_d_mean;
  real<lower=0> x_d_std;
}

parameters {
  real<lower=0.1, upper=3.0> y_q;   
  vector<lower=0.1, upper=1.5>[N_tests] P_g; 
  vector<lower=-2, upper=2>[N_tests] Q_g; 
  vector<lower=0.8, upper=1.2>[N_tests] V_t; 
  //vector<lower=0.01, upper=1.5>[N_tests] delta; 
  //vector<lower=0.5, upper=1.5>[N_tests] E_g; 
  vector<lower=0>[N_tests] P_std; 
  vector<lower=0>[N_tests] Q_std;
  vector<lower=0>[N_tests] V_std; 
  real b_avg; 
  real<lower=0, upper=1> b_std; 
  real<lower=0, upper=10> x_d; 
}

transformed parameters {
  vector<lower=0.01, upper=1.5>[N_tests] delta = atan(P_g ./ (Q_g + V_t .* V_t * y_q)); 
  //vector<lower=0.1, upper=1.5>[N_tests] P_g = E_g .* V_t / x_d .* sin(delta); 
  //vector<lower=-2, upper=2>[N_tests] Q_g = E_g .* V_t / x_d .* cos(delta) - pow(V_t, 2)/x_d; 
  
  vector[N_tests] b_good = (P_g ./ sin(delta) - V_t .* V_t .*cos(delta)*(y_q - 1/x_d)) ./ V_t;
  //real b_avg = mean(b_good); 
  real objective = -sqrt( sum((b_avg - b_good).*(b_avg - b_good)) );
}

model {
  for (i in 1:N_tests) {
    P_meas[i] ~ normal(P_g[i], P_std[i]); 
    Q_meas[i] ~ normal(Q_g[i], Q_std[i]); 
    V_meas[i] ~ normal(V_t[i], V_std[i]); 
  }
  
  //target += objective; 
  b_good ~ normal(b_avg, b_std); 
  target += b_std; 
  //target += -b_good; 
  //x_q ~ normal(0.5, 0.3); 
  
  for (i in 1:N_tests) {
    P_g[i] ~ normal(P_priors[i], 0.1); 
    Q_g[i] ~ normal(Q_priors[i], 0.1); 
    V_t[i] ~ normal(V_priors[i], 0.1); 
  }
  b_std ~ beta(0.5, 0.5); 
  x_d ~ normal(x_d_mean, x_d_std); 
  y_q ~ gamma(5, 2); 
}


generated quantities {
  real x_q = 1/y_q; 
}

