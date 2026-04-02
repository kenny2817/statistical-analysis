library(tidyverse)
library(car)
library(lmtest)

# Import “airplane price data set” to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.


# ------------------------------------------ A ------------------------------------------
# Consider the numerical variables in the data set and find the best SIMPLE linear regression 
# model to predict the prices. Test the assumptions and use transformations if it is required.
# Explain why the model you find is the best simple linear regression model and interpret the model coefficients.
# ---------------------------------------------------------------------------------------

air_data <- read.csv("./data/airplane_price_dataset.csv", sep=",", stringsAsFactors=TRUE)
air_data <- air_data |>
  rename(
    FC = FuelConsumption.L.h.,
    HM = HourlyMaintenance...,
    RangeKm = Range.km.,
    Price = Price...
  )
air_data$EngineType <- as.factor(air_data$EngineType)
# Price is generally right-skewed data; a log() transformation helps to normalize the data
# air_data$Price <- log(air_data$Price)

# Numerical vars only
num_vars <- names(air_data)[sapply(air_data, is.numeric)]
numeric_air_data <- air_data[, num_vars]

str(numeric_air_data)
plot(numeric_air_data)

# From the plot, we can see that RangeKm and Capacity are the variables with the highest correlation vs Price
# Next, we use the Correlation Matrix to confirm our assumption

# Correlation Matrix
cor_matrix <- cor(numeric_air_data)
cor_matrix
# Correlation with Price variable (Highest to Lowest)
sort(cor_matrix[, "Price"], decreasing = TRUE)

# Linear Models
slr.range <- lm(Price ~ RangeKm, data = numeric_air_data)
slr.capacity <- lm(Price ~ Capacity, data = numeric_air_data)

# Plot both models
par(mfrow = c(1, 2))
plot(numeric_air_data$RangeKm, numeric_air_data$Price, 
     main="Price vs RangeKm", xlab="RangeKm", ylab="Price")
abline(slr.range, col="red", lwd=2)

plot(numeric_air_data$Capacity, numeric_air_data$Price, 
     main="Price vs Capacity", xlab="Capacity", ylab="Price")
abline(slr.capacity, col="red", lwd=2)
par(mfrow = c(1, 1))


# Testing Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(slr.range))
qqnorm(residuals(slr.capacity))
# Using Histogram
hist(residuals(slr.range))
hist(residuals(slr.capacity), breaks=6)

# Homogeneity of Variance
plot(residuals(slr.range))
plot(residuals(slr.capacity))
# Breusch Pagan
bptest(slr.range)
bptest(slr.capacity)

# Independence of errors
dwtest(slr.range, alternative = "two.sided")
dwtest(slr.capacity, alternative = "two.sided")


# Both models pass all assumptions 

# Compare R-squared
summary(slr.range)$r.squared
summary(slr.capacity)$r.squared


# We select `slr.range` model, and therefore, RangeKm as the best predictor for Price 
# because it has the highest Correlation vs Price and the highest R-squared value,
# meaning it explains the highest proportion of the variance in airplane prices compared to other single-variable models

summary(slr.range)

# Intercept ($\beta_0$): Estimated baseline Price of an airplane. Just for mathematically purposes
# Slope for RangeKm ($\beta_1$): Estimated change in the dependent variable for every 1-unit increase in the independent variable. 
# In this case, the value is positive so for every additional 1 kilometer of range, 
# the price of the airplane is expected to increase by 38480


# ------------------------------------------ B ------------------------------------------
# Fit a multivariate linear regression model with the most important two (numerical) variables.
# Use transformations if it is needed and test all the assumptions. Then compare this model to
# the simple linear regression model that you fit in (a). Which one is a better model? Why? 
# ---------------------------------------------------------------------------------------

str(air_data)



# ------------------------------------------ C ------------------------------------------
# Encode the variable model into three categories considering whether the plane is “Airbus”,
# “Boeing” or “Other”. Now add this model factor to the regression model you have chosen in
# section (b). Interpret the coefficients and overall summary of the model. Compare the model
# in section (b) with the model that has an additional factor. Which one would you choose? Why?
# ---------------------------------------------------------------------------------------

cutoff = median(air_data$ProductionYear)
air_data$year_cat <- as.factor(ifelse(air_data$ProductionYear < cutoff, "Older", "Newer"))
str(air_data)


# ------------------------------------------ D ------------------------------------------
# Test the validity of the final model that you choose.
# ---------------------------------------------------------------------------------------





