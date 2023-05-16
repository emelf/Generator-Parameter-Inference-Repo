// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] I_DC;
  vector[N] V_DC;
  real sigma_i;
  real sigma_v;
  real<lower=0> alpha;
}

parameters {
  real<lower=0,upper=1> R20;     //Resistor value at 20 degree
  real<lower=0,upper=20> delta_t;  // temperature noise 
  vector<lower=0,upper=6>[N] I;    //DC current
  //real<lower=0> sigma;
}

transformed parameters {
  real<lower=0,upper=1> R_DC = (alpha*delta_t+1)*R20; 
}

model {
  
  //Likelihood
  V_DC ~ normal(R_DC*I, sigma_v);
  I_DC ~ normal(I,sigma_i);
  
  R20 ~ uniform(0,1);
  delta_t ~ gamma(10,2);
}

generated quantities {
  real R_20_sq = pow(R20,2);
}


