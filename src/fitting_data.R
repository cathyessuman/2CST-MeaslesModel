library(deSolve)
library(ggplot2)


data <- read.csv("data_measles.csv")
head(data)
length(data$cases)
#Define beta as function of R_0
beta_calc <- function(
    R_0, mu = 0.02 / 365.25, sigma = 1 / 8, gamma = 1 / 5
) {
  R_0 / ((sigma / (mu + sigma)) * (1 / (mu + gamma)))
}

#
N0 = 50000
#Define the model
seir <- function(t, y, params) {
  S <- y[1]
  E <- y[2]
  I <- y[3]
  R <- y[4]
  
  beta <- params["beta"]
  N <- params["N"]
  mu <- params["mu"]
  sigma <- params["sigma"]
  gamma <- params["gamma"]
  nu <- mu * N
  
  dSdt <- nu - (beta * S * I / N) - (mu * S)
  dEdt <- (beta * S * I / N) - (mu * E) - (sigma * E)
  dIdt <- (sigma * E) - (mu * I) - (gamma * I)
  dRdt <- (gamma * I) - (mu * R)
  
  return(list(c(dSdt, dEdt, dIdt, dRdt)))
}


#Models parameters
param_vals <- c(
  beta = beta_calc(18), N = N0, mu = 0.02 / 365.25, sigma = 1 / 8, gamma = 1 / 5
)

#Set the time
times <- 1:nrow(data)

#Initial conditions
S0 <- 20000
E0 <- 152
I0 <- 120



init <- c(sus = S0, exp = E0, inf = I0, rec = N0 - S0 - E0 -I0)
#Loss
loss_func <- function(parameters){
  output <- data.frame(lsoda(init, times, seir, parameters))
  return(sum(data$cases- output$inf))
}

#Fitting with 
fit <- optim(par = init, fn=loss_func, parms = param_vals)


#Solve
tc <- data.frame(lsoda(init, times, seir, param_vals))

