# The Influence of Seasonal Variation in the Transmission Rate on the Recurring Pattern and Magnitude of Measles Outbreak in London and Liverpool Between 1944 and 1994

It is an epidemioligic project achieved in context of the [MMED 2024](https://www.ici3d.org/MMED),  a 2­‐week modeling clinic that emphasizes the use of data in understanding infectious disease dynamics. 

## Overview

In this project, we highlight the impact of seasonal variation in the transmission rate on the recurring pattern and magnitude of measles outbreaks in London between 1944 and 1967. Using the SEIR (Susceptible-Exposed-Infectious-Recovered) model, which includes birth and death rates, along with a sinusoidal function to represent the seasonal transmission rate, we simulate the number of infectious individuals over time.

## Key Features

- **Seasonal Transmission Rate**: The transmission rate is modeled as a sinusoidal function whose amplitude and magnitude vary as a function of the mean transmission rate $\beta_0$.

- **SEIR Model Parameters**: The model incorporates birth and death rates to provide a realistic simulation of measles dynamics.


- **Basic Reproduction Number (R_0)**: We explore different values for the basic reproduction number $R_0$ ranging from 12 to 18, and study their impact on the measles outbreak patterns.

## Objectives

- To understand the impact of seasonal variation in the transmission rate on measles outbreak patterns.
- To evaluate how different values of the basic reproduction number $ R_0 $ influence the magnitude and recurrence of outbreaks.

## Methodology

- **SEIR Model**: We use the SEIR model to simulate the dynamics of measles outbreaks. The model equations are extended to include birth and death rates.

![SEIR model](images/SEIR model with more details.png)

- **Sinusoidal Transmission Rate**: The transmission rate $ \beta(t) $ is modeled as:
  $$
  \beta(t) = \beta_0 \left(1 + 0.03 \sin(\frac{2\pi t}{365})\right)
  $$
  where $\beta_0$ is the mean transmission rate, $A$ is the amplitude, and $ \phi $ is the phase.
- **Simulation**: We run simulations for different values of $R_0$ and analyze the resulting outbreak patterns.

## Results

The plots below illustrate the fit of the SEIR model to observed measles case data for different values of the transmission rate parameter $ \beta $. Each plot shows both observed (red) and simulated (blue) cases over time.

![SEIR Model Fit for Liverpool dataset](images/Liverpool/LPool_betachange.png)
![SEIR Model Fit for London dataset](images/London/Ldn_betachange.png)

## Conclusion

The SEIR model with the three(3) varying mean transmission rates(β), which were different due to the different values of reproduction rates, provides a useful structure for

the patterns and understanding the peaks of measles outbreaks in Liverpool and London from 1945 to 1967. Higher transmission rates during the studied periods were evident,
and the model’s fit improved with the increased Beta values.
These insights are crucial for public health because it shows
that if our sample space are children, having them attend
school during weathers of low humidity exposes them to
the danger of contracting measles.

## Repository Contents

- `src/`: Contains the source code for the SEIR model simulations.
- `data/`: Contains the dataset of measles cases in London from 1944 to 1967.
- `images/`: Contains images of the simulations.
- `mmed_report.pdf`: Contains the results of the simulations, including plots and analysis.

## Usage

- Clone the repository:
   ```bash
   git clone https://github.com//cathyessuman/2CST-MeaslesModel/
