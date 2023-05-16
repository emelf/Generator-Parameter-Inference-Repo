// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] R20_sq_mea;
  vector[N] Z_sq_mea;
}

parameters {
  real<lower=0,upper=1> sigma_z;
  real<lower=0,upper=1> sigma_r;
  real<lower=0,upper=1.5> Xd_sq;
  real<lower=0,upper=1> R20_sq;
}

transformed parameters {
  real R20pu_sq = R20_sq/((220/sqrt(3))/5.25);
}

model {
  
  //Likelihood
  Z_sq_mea ~ normal(Xd_sq + R20pu_sq, sigma_z);
  
  // Priors
  R20_sq_mea ~ normal(R20_sq, sigma_r);
}

generated quantities {
  real Xd = sqrt(Xd_sq);
}

