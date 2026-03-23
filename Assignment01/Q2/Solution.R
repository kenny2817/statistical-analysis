library(tidyverse)
library(dplyr)
library(car)

# Import “airplane price data set” to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.


# ------------------------------------------ A ------------------------------------------
# Create a new data frame only including “Airbus A320”, “Airbus A350”, “Boeing 737” and
# “Boeing 777” models of airplanes. Checked the distribution of Price first for the observations
# in this sample and then for each model in the data frame. Interpret your findings.
# ---------------------------------------------------------------------------------------

air_data <- read.csv("../data/airplane_price_dataset.csv", sep=",", stringsAsFactors=TRUE)
air_data <- air_data |>
  filter(Model %in% c("Airbus A320", "Airbus A350", "Boeing 737", "Boeing 777")) |>
  droplevels()
air_data <- air_data |>
  rename(
    FC = FuelConsumption.L.h.,
    HM = HourlyMaintenance...,
    RangeKm = Range.km.,
    Price = Price...
  )
air_data$EngineType <- as.factor(air_data$EngineType)

str(air_data)


hist(air_data$Price, 
     main = "Histogram of Price (Models: Airbus A320, Airbus A350, Boeing 737, Boeing 777)", 
     xlab = "Price", 
     col = "lightblue")

# TODO: revisit this (use log)
densityA320 <- density(air_data$Price[air_data$Model == "Airbus A320"], na.rm = TRUE)
densityA350 <- density(air_data$Price[air_data$Model == "Airbus A350"], na.rm = TRUE)
densityB737 <- density(air_data$Price[air_data$Model == "Boeing 737"], na.rm = TRUE)
densityB777 <- density(air_data$Price[air_data$Model == "Boeing 777"], na.rm = TRUE)

plot(densityA320, col = "red",
     main = "Price by Model",
     xlab = "Price",
     xlim = range(c(densityA320$x, densityA350$x, densityB737$x, densityB777$x)),
     ylim = range(c(densityA320$y, densityA350$y, densityB737$y, densityB777$y)))
lines(densityA350, col = "blue")
lines(densityB737, col = "green")
lines(densityB777, col = "purple")
legend("topright", legend = levels(air_data$Model), col = c("red", "blue", "green", "purple"), lty = 1)


# ------------------------------------------ B ------------------------------------------
# Analyze the numerical variables that are affected by the “Model”. Test the assumptions of
# the statistical method, for the cases that you have found a significant association, by using
# corresponding tests and plots. Write your conclusions. 
# ---------------------------------------------------------------------------------------

str(air_data)

# Numerical vars only
num_vars <- names(air_data)[sapply(air_data, is.numeric)]
par(mfrow = c(3, 3))
for (var in num_vars) {
  boxplot(air_data[[var]] ~ air_data$Model,
          main = paste(var, "by Model"),
          xlab = "Model", 
          ylab = var,
          col = "lightgreen")
}
par(mfrow = c(1, 1))

# Based on the boxplots, variables **Capacity**, **RangeKm** and **Price** are the ones affected by Model.

# ANOVA and analysis
aov_price <- aov(Price ~ Model, data = air_data)
summary(aov_price)

# Q-Q Plot
qqPlot(aov_price$residuals, main="Q-Q Plot for Residuals")
# Shapiro-Wilk test
shapiro.test(aov_price$residuals)

leveneTest(Price ~ Model, data = air_data)





