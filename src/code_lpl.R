library(deSolve)
library(dplyr)
library(lubridate)
library(readxl)

# Define beta_calc function
beta_calc <- function(R_0, mu = 0.02 / 365.25, sigma = 1 / 8, gamma = 1 / 5) {
  R_0 / ((sigma / (mu + sigma)) * (1 / (mu + gamma)))
}

# Define sine_wave function
sine_wave <- function(vec, R0) {  
  return(1 + 0.08 * (sin(2 * pi * vec / 53)))
}

# Step function for baseline school term
step_func_baseschterm <- function(beta_min, beta_max, vec) {
  init <- numeric(length(vec))
  for (i in seq_along(vec)) {
    week_of_year <- vec[i] %% 52  
    if (week_of_year >= 44 | week_of_year < 4) {
      init[i] <- beta_min  
    } else {
      init[i] <- beta_max  
    }
  }
  return(init)
}

# Step function for intervention school term
step_func_interschterm <- function(beta_min, beta_max, vec) {
  init <- numeric(length(vec))
  for (i in seq_along(vec)) {
    week_of_year <- vec[i] %% 52  
    if (week_of_year >= 26 & week_of_year < 40) {
      init[i] <- beta_min  
    } else {
      init[i] <- beta_max  
    }
  }
  return(init)
}

# Function to calculate beta with sine wave modulation and step function
beta_fn <- function(vec, R0, b_min) {
  b_max <- beta_calc(R0)
  ct <- sine_wave(vec, R0)
  pt <- step_func_baseschterm(b_min, b_max, vec)
  return(ct * pt)
}

# Function for intervention scenario
beta_fn2 <- function(vec, R0, b_min) {
  b_max <- beta_calc(R0)
  ct <- sine_wave(vec, R0)
  pt <- step_func_interschterm(b_min, b_max, vec)
  return(ct * pt)
}

# Define SEIR model
seir.seasonal <- function(t, y, params, beta_func) {
  S <- y[1]
  E <- y[2]
  I <- y[3]
  R <- y[4]
 
  r0 <- params["r0"]
  beta <- beta_func(t, r0, b_min = 1)
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

# Initial conditions and parameters
N0 <- 500000
S0 <- 20000
E0 <- 200
I0 <- 125
R0 <- N0 - S0 - E0 - I0

# Define r0 values for simulations
rnot_values <- c(12, 15, 18)
mu <- 0.02 / 365.25
sigma <- 1 / 8
gamma <- 1 / 5

# Read dataset and process
dataset <- read_excel("C:/Users/HP/Downloads/LiPool_Measles44-94.xls")
dataset <- dataset[157:1252,]  

# Convert Year, Month, Day to Date
dataset <- dataset %>%
  mutate(t = ymd(paste(Year, Month, Day, sep = "-"))) %>%
  arrange(t) %>%
  mutate(time = as.numeric(t - min(t)))

# Normalize observed data
dataset$Cases_normalized <- dataset$Cases / max(dataset$Cases)

times <- dataset$time

# Adjust layout and margins for more space
par(mfrow = c(length(rnot_values), 1), mar = c(4, 4, 2, 2), oma = c(1, 1, 4, 1))

for (r0 in rnot_values) {
 
  beta_val <- beta_calc(r0, mu, sigma, gamma)
 
  param_vals <- c(N = N0, mu = mu, sigma = sigma, gamma = gamma, r0 = r0)
 
  out1 <- lsoda(c(S = S0, E = E0, I = I0, R = R0), times, seir.seasonal, param_vals, beta_func = beta_fn)
  out2 <- lsoda(c(S = S0, E = E0, I = I0, R = R0), times, seir.seasonal, param_vals, beta_func = beta_fn2)
 
  colnames(out1) <- c("time", "S", "E", "I", "R")
  colnames(out2) <- c("time", "S", "E", "I", "R")
 
  years <- out1[, "time"] / 365.25 + min(dataset$Year)
 
  simulated_cases1 <- out1[, "I"] + out1[, "E"]
  simulated_cases2 <- out2[, "I"] + out2[, "E"]
 
  # Normalize simulated data
  simulated_cases1_normalized <- simulated_cases1 / max(simulated_cases1)
  simulated_cases2_normalized <- simulated_cases2 / max(simulated_cases2)
 
  max_y <- max(c(max(simulated_cases1_normalized), max(simulated_cases2_normalized), max(dataset$Cases_normalized)))
 
  plot(years, simulated_cases1_normalized, type = "l", col = "blue", xlab = "Year", ylab = "Normalized Infections",
       ylim = c(0, max_y * 1.1), main = paste("R_0 =", r0, ", Beta =", round(beta_val, 4)))
  lines(years, simulated_cases2_normalized, col = "red")
 
  # Overlay normalized observed data as lines
  lines(dataset$time / 365.25 + min(dataset$Year), dataset$Cases_normalized, col = "green")
}

# Add overall title for the entire plot
mtext("SEIR Model Fit for Varying Transmission Rates in Liverpool (1945 - 1967)", outer = TRUE, font = 2)

# Add a single legend for all plots
par(fig = c(0, 1, 0, 1), oma = c(0, 0, 2, 0), mar = c(0, 0, 0, 0), new = TRUE)
plot(0, type = "n", xlab = "", ylab = "", xaxt = 'n', yaxt = 'n', bty = 'n')
legend("topright", legend = c("Baseline Measles Cases", "Intervention Measles Cases", "Observed Measles Cases"),
       col = c("blue", "red", "green"), lty = c(1, 1, 1))
