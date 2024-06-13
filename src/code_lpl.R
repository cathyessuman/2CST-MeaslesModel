library(readxl)
library(deSolve)
library(dplyr)
library(lubridate)

# Read dataset and process
dataset <- read_excel("C:/Users/HP/Downloads/dataset.xls")
dataset <- dataset[1:1252,]  

# Convert Year, Month, Day to Date
dataset <- dataset %>%
  mutate(t = ymd(paste(Year, Month, Day, sep = "-"))) %>%
  arrange(t) %>%
  mutate(time = as.numeric(t - min(t)))

# Define beta_calc function
beta_calc <- function(R_0, mu = 0.02 / 365.25, sigma = 1 / 8, gamma = 1 / 5) {
  R_0 / ((sigma / (mu + sigma)) * (1 / (mu + gamma)))
}

# Define SEIR model
seir.seasonal <- function(t, y, params) {
  S <- y[1]
  E <- y[2]
  I <- y[3]
  R <- y[4]
  
  r0 <- params["r0"]
  beta <- sine_wave(t %% 365, r0)
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

# Define sine_wave function
sine_wave <- function(vec, R0) {  
  return(beta_calc(R0) + 0.03 * beta_calc(R0) * sin(2 * pi * vec / 365))
}

# Initial conditions and parameters
N0 <- 500000
S0 <- 20000
E0 <- 200
I0 <- 125
R0 <- N0 - S0 - E0 - I0

times <- dataset$time

# Define r0 values for simulations
rnot_values <- c(12, 15, 18)
mu <- 0.02 / 365.25
sigma <- 1 / 8
gamma <- 1 / 5

# Adjust layout and margins for more space
par(mfrow = c(3, 1), mar = c(4, 4, 2, 2), oma = c(1, 1, 4, 1))

max_y <- max(dataset$Cases, na.rm = TRUE) * 1.1  # Adding 10% padding

for (r0 in rnot_values) {
  # Calculate the beta value for the given R0
  beta <- beta_calc(r0, mu, sigma, gamma)
  
  param_vals <- c(N = N0, mu = mu, sigma = sigma, gamma = gamma, r0 = r0)
  
  out <- lsoda(c(S = S0, E = E0, I = I0, R = R0), times, seir.seasonal, param_vals, rtol = 1e-3, atol = 1e-3)
  
  # Ensure the output is in the correct format
  colnames(out) <- c("time", "S", "E", "I", "R")
  
  years <- dataset$Year[1] + out[, "time"] / 365.25
  
  max_y <- max(max_y, max(out[, "I"] + out[, "E"]) * 1.1)
  max_y_sqrt <- sqrt(max_y)
  
  sqrt_observed_cases <- sqrt(dataset$Cases)
  sqrt_simulated_cases <- sqrt(out[, "I"] + out[, "E"])
  
  plot(years, sqrt_observed_cases, type = "l", col = "red", xlab = "Time (years)", ylab = "Sqrt(Infections)",
       ylim = c(0, max_y_sqrt), main = paste("Beta =", round(beta, 5), ", R_0 =", r0))
  
  lines(years, sqrt_simulated_cases, col = "blue")
}

# Add overall title for the entire plot
mtext("SEIR Model Fit for Varying Transmission Rates in London (1945 - 1967)", outer = TRUE, font = 2)

# Add a single legend for all plots
par(fig = c(0, 1, 0, 1), oma = c(0, 0, 2, 8), mar = c(0, 0, 0, 0), new = TRUE)
plot(0, type = "n", xlab = "", ylab = "", xaxt = 'n', yaxt = 'n', bty = 'n')
legend("topright", legend = c("Observed", "Simulated"), col = c("red", "blue"), lty = 1, bty = "n", xpd = TRUE)
