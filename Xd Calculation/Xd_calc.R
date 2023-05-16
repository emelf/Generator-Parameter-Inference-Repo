library("writexl")
library("rstan")
data = read.csv("test_1_stator_result_data.csv", header = TRUE, sep = ",", dec=".");
R20 = data$R_20_sq;
data = read.csv("test_3_result_data.csv", header = TRUE, sep = ",", dec=".");
Z = data$z_d_sq;

N = length(Z);

options(mc.cores = 4)

#Compile the Stan model
rstan_options(auto_write = T) # save the compiled version to the working dir
model = stan_model("Xd_calc.stan") # compile the Stan model

#Infer mu and sigma using Stan model
fit = sampling(model,list(N=N,R20_sq_mea=R20,Z_sq_mea=Z),
               iter=10000,warmup =5000,chains=4,
               control = list(adapt_delta = 0.99,max_treedepth = 15)); 

# Short presentation of the results in R
#print(fit)

# Advanced web-based presentation using Shinystan. Useful for diagnostics
library("shinystan")
aFit <- as.shinystan(fit)
launch_shinystan(aFit)

posterior_samples <- data.frame(extract(fit,pars = c('Xd')));
Xd_mean = mean(posterior_samples$Xd);
Xd_std = sd(posterior_samples$Xd)
write.csv(posterior_samples, "Xd_calculation.csv", row.names=FALSE)

#hist(Xd, main = "Histogram Xd element-wise", xlab = "Data", col = "lightblue", border = "black", breaks = 50)

