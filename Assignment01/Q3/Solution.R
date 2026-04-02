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
# Also in linear regression we want to keep homoscedasticity  ???
air_data$Price <- log(air_data$Price)

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

# Correlation Matrix tell us that NumberofEngines, Capacity and RangeKm are the top 3 
# with the highest correlation

# Linear Models
slr.engines <- lm(Price ~ NumberofEngines, data = numeric_air_data)
slr.capacity <- lm(Price ~ Capacity, data = numeric_air_data)
slr.range <- lm(Price ~ RangeKm, data = numeric_air_data)

par(mfrow = c(1, 3))
plot(slr.engines, which = 1, main = "No. Engines")
plot(slr.capacity, which = 1, main = "Capacity")
plot(slr.range, which = 1, main = "RangeKm")
par(mfrow = c(1, 1))


# The plots suggest that:
# - NumberofEngines is showing heteroscedasticity, meaning the linear model is not working
# good for higher prices
# In the case of Capacity and RangeKm, the model may need to include a quadratic term

# Breusch Pagan to confirm this!
bptest(slr.engines)
bptest(slr.capacity)
bptest(slr.range)

# After running BP test, the 3 models show significant heteroscedasticity
# We decided to discard the first one. The other 2 suggest a quadratic relation

Capacity2 <- (numeric_air_data$Capacity) ^ 2
slr.capacity_2 <- lm(Price ~ Capacity + Capacity2, data = numeric_air_data)
summary(slr.capacity_2)
RangeKm2 <- (numeric_air_data$RangeKm) ^ 2
slr.range_2 <- lm(Price ~ RangeKm + RangeKm2, data = numeric_air_data)
summary(slr.range_2)

par(mfrow = c(1, 2))
plot(slr.capacity_2, which = 1, main = "Capacity")
plot(slr.range_2, which = 1, main = "RangeKm")
par(mfrow = c(1, 1))

# Breusch Pagan with quadratic terms
# TODO: BPTests keep failing after adding a quadratic term :(
bptest(slr.capacity_2)
bptest(slr.range_2)

# Compare R-squared
summary(slr.range_2)$r.squared
summary(slr.capacity_2)$r.squared
# Selecting RangeKm for now as it yields the higher R2

# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(slr.range_2))
# Using Histogram
hist(residuals(slr.range_2))

# Homogeneity of Variance
plot(residuals(slr.range_2))
# Breusch Pagan
bptest(slr.range_2)

# Independence of errors
dwtest(slr.range_2, alternative = "two.sided")


# We select `slr.range_2` model, and therefore, RangeKm as the best predictor for Price 
# because it has hight Correlation vs Price and the highest R-squared value,
# meaning it explains the highest proportion of the variance in airplane prices

summary(slr.range_2)

# Intercept ($\beta_0$): Estimated baseline Price of an airplane
# Slope for RangeKm ($\beta_1$): Estimated change in the dependent variable for every 1-unit increase in the independent variable
# Quadratic term (): ...


# ------------------------------------------ B ------------------------------------------
# Fit a multivariate linear regression model with the most important two (numerical) variables.
# Use transformations if it is needed and test all the assumptions. Then compare this model to
# the simple linear regression model that you fit in (a). Which one is a better model? Why? 
# ---------------------------------------------------------------------------------------

regmodel.b <- lm(Price ~ Capacity + RangeKm, data = numeric_air_data)
summary(regmodel.b)

# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(regmodel.b))
# Using Histogram
hist(residuals(regmodel.b))

# Homogeneity of Variance
plot(residuals(regmodel.b))
# Breusch Pagan
bptest(regmodel.b)

# Independence of errors
dwtest(regmodel.b, alternative = "two.sided")


# ------------------------------------------ C ------------------------------------------
# Encode the variable model into three categories considering whether the plane is “Airbus”,
# “Boeing” or “Other”. Now add this model factor to the regression model you have chosen in
# section (b). Interpret the coefficients and overall summary of the model. Compare the model
# in section (b) with the model that has an additional factor. Which one would you choose? Why?
# ---------------------------------------------------------------------------------------

numeric_air_data$ModelCat <- as.factor(
  ifelse(grepl("Airbus", air_data$Model, ignore.case = TRUE), "Airbus",
  ifelse(grepl("Boeing", air_data$Model, ignore.case = TRUE), "Boeing", "Other"))
)
summary(numeric_air_data)

regmodel.c <- lm(Price ~ Capacity + RangeKm + ModelCat, data = numeric_air_data)
summary(regmodel.c)


# ------------------------------------------ D ------------------------------------------
# Test the validity of the final model that you choose.
# ---------------------------------------------------------------------------------------

# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(regmodel.c))
# Using Histogram
hist(residuals(regmodel.c))

# Homogeneity of Variance
plot(residuals(regmodel.c))
# Breusch Pagan
bptest(regmodel.c)

# Independence of errors
dwtest(regmodel.c, alternative = "two.sided")


