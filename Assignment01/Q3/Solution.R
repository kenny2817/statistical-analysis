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
hist(air_data$Price)
air_data$Price <- log(air_data$Price)
hist(air_data$Price)

# Numerical vars only
num_vars <- names(air_data)[sapply(air_data, is.numeric)]
par(mfrow = c(3, 3))
for (var in num_vars) {
    plot(air_data[[var]], air_data$Price, 
         xlab = var, ylab = "Price", 
         main = paste("Price vs", var),
         pch = 19, col = "lightgreen")
    # Add regression line
    abline(lm(air_data$Price ~ air_data[[var]]), col = "red", lwd = 2)
}
par(mfrow = c(1, 1))

# According to plot analysis, we are selecting variables NumberOfEngines, Capacity, and RangeKm
# as best candidates for the linear model bc those show the most linear relationship with Price

numeric_air_data <- air_data[, num_vars]
str(numeric_air_data)

# Next, we use the Correlation Matrix to confirm our assumption
# Correlation with Price variable (Highest to Lowest)
cor_matrix <- cor(numeric_air_data)
cor_matrix
sort(cor_matrix[, "Price"], decreasing = TRUE)

# Correlation Matrix tell us indeed that NumberofEngines, Capacity and RangeKm are the top 3 
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
# - NumberofEngines is showing a nearly linear relationship with Price
# - In the case of Capacity and RangeKm, the model may need to include a quadratic term


#Capacity2 <- (numeric_air_data$Capacity) ^ 2
#slr.capacity_2 <- lm(Price ~ Capacity + Capacity2, data = numeric_air_data)
#summary(slr.capacity_2)
#RangeKm2 <- (numeric_air_data$RangeKm) ^ 2
#slr.range_2 <- lm(Price ~ RangeKm + RangeKm2, data = numeric_air_data)
#summary(slr.range_2)

#par(mfrow = c(1, 2))
#plot(slr.capacity_2, which = 1, main = "Capacity")
#plot(slr.range_2, which = 1, main = "RangeKm")
#par(mfrow = c(1, 1))

# Breusch Pagan with quadratic terms
# TODO: BPTests keep failing after adding a quadratic term :(
#bptest(slr.capacity_2)
#bptest(slr.range_2)

# Compare R-squared
#summary(slr.range_2)$r.squared
#summary(slr.capacity_2)$r.squared


# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(slr.engines))
# Using Histogram
hist(residuals(slr.engines))

# Homogeneity of Variance
plot(residuals(slr.engines))
# Breusch Pagan
bptest(slr.engines)

# After running BP test, the model show significant heteroscedasticity

# Independence of errors
dwtest(slr.engines, alternative = "two.sided")


# We select `slr.engines` model, and therefore, NumberofEngines as the best single predictor
# because it shows a linear high correlation vs Price, and also high R-squared value,
# meaning it alone explains the highest proportion of the variance in airplane prices

summary(slr.engines)
# Selecting NumberofEngines for now with R2 = 0.7792

# Intercept ($\beta_0$): Estimated baseline Price of an airplane
# Slope for RangeKm ($\beta_1$): Estimated change in the dependent variable for every 1-unit increase in the independent variable
# Quadratic term (): ...


# ------------------------------------------ B ------------------------------------------
# Fit a multivariate linear regression model with the most important two (numerical) variables.
# Use transformations if it is needed and test all the assumptions. Then compare this model to
# the simple linear regression model that you fit in (a). Which one is a better model? Why? 
# ---------------------------------------------------------------------------------------

regmodel.b1 <- lm(Price ~ NumberofEngines + Capacity, data = numeric_air_data)
summary(regmodel.b1)
regmodel.b2 <- lm(Price ~ NumberofEngines + RangeKm, data = numeric_air_data)
summary(regmodel.b2)

# model b1 yields R2 = 0.9815 vs model b2 yields R2 = 0.9699

# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(regmodel.b1))
# Using Histogram
hist(residuals(regmodel.b1))

# Homogeneity of Variance
plot(residuals(regmodel.b1))
# Breusch Pagan
bptest(regmodel.b1)

# Independence of errors
dwtest(regmodel.b1, alternative = "two.sided")


# Compare model b with model a
anova(slr.engines, regmodel.b1)
summary(regmodel.b1)

# Adding Capacity to the model decreases significantly the Residual Sum of Squares,
# meaning the model improves by adding this new variable


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

regmodel.c1 <- lm(Price ~ NumberofEngines + Capacity + ModelCat, data = numeric_air_data)
summary(regmodel.c1)
regmodel.c2 <- lm(Price ~ NumberofEngines + RangeKm + ModelCat, data = numeric_air_data)
summary(regmodel.c2)

# Compare model c to models in b
anova(regmodel.b1, regmodel.c1)
anova(regmodel.b2, regmodel.c2)

bptest(regmodel.c1)
bptest(regmodel.c2)


# ------------------------------------------ D ------------------------------------------
# Test the validity of the final model that you choose.
# ---------------------------------------------------------------------------------------

# Choosing model c2, lm(Price ~ NumberofEngines + RangeKm + ModelCat)


# Regression Assumptions

# Normality of the Error Term
qqnorm(residuals(regmodel.c2))
# Using Histogram
hist(residuals(regmodel.c2))

# Homogeneity of Variance
plot(residuals(regmodel.c2))
# Breusch Pagan
bptest(regmodel.c2)

# Independence of errors
dwtest(regmodel.c2, alternative = "two.sided")

summary(regmodel.c2)

