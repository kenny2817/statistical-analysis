library(tidyverse)
library(car)
library(lmtest)

# Import "airplane price data set" to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.


# ------------------------------------------ A ------------------------------------------
# Consider the numerical variables in the data set and find the best SIMPLE linear regression 
# model to predict the prices. Test the assumptions and use transformations if it is required.
# Explain why the model you find is the best simple linear regression model and interpret the model coefficients.
# ---------------------------------------------------------------------------------------

set.seed(42)
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
         pch = 19)
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
summary(slr.engines)
slr.capacity <- lm(Price ~ Capacity, data = numeric_air_data)
summary(slr.capacity)
slr.range <- lm(Price ~ RangeKm, data = numeric_air_data)
summary(slr.range)

par(mfrow = c(1, 3))
plot(slr.engines, which = 1, main = "No. Engines")
plot(slr.capacity, which = 1, main = "Capacity")
plot(slr.range, which = 1, main = "RangeKm")
par(mfrow = c(1, 1))
# The plots suggest that:
# - NumberofEngines is showing a nearly linear relationship with Price
# - In the case of Capacity and RangeKm, the model may need to include a quadratic term


# ANOVA confirms NumberofEngines yields lower RSS
anova(slr.engines, slr.range)
anova(slr.engines, slr.capacity)

slrmodel.a <- slr.engines


# Regression Assumptions
par(mfrow = c(1, 3))
# Normality of the Error Term
qqnorm(residuals(slrmodel.a))
qqline(residuals(slrmodel.a), col = "red")
hist(residuals(slrmodel.a))

# Homogeneity of Variance
plot(residuals(slrmodel.a))
# Breusch Pagan
bptest(slrmodel.a) # p-value < 0.05 shows heteroscedasticity!!!

# Independence of errors
dwtest(slrmodel.a, alternative = "two.sided")
par(mfrow = c(1, 1))

# We selected NumberofEngines as the best single predictor because it shows a linear high correlation vs Price
# and also high R-squared value, meaning it alone explains the highest proportion of the variance in airplane prices

summary(slrmodel.a)

# Interpretation:
# The best simple linear regression uses NumberofEngines as the predictor because it yields
# the highest R-squared among all numerical variables. This makes sense since larger
# more powerful planes (more engines) cost significantly more.
# Coefficients:
#   Intercept: the expected log(Price) when NumberOfEngines = 0 (theoretical, not meaningful).
#   Slope (NumberOfEngines): for each additional unit of NumberOfEngines, log(Price) increases by
#   this amount. In original scale, a one-unit increase in NumberOfEngines multiplies the
#   price by exp(slope).


# ------------------------------------------ B ------------------------------------------
# Fit a multivariate linear regression model with the most important two (numerical) variables.
# Use transformations if it is needed and test all the assumptions. Then compare this model to
# the simple linear regression model that you fit in (a). Which one is a better model? Why? 
# ---------------------------------------------------------------------------------------

regmodel.all <- lm(Price ~ ., data = numeric_air_data)
summary(regmodel.all)
# The previous lm tell us that predictors NumberofEngines + Capacity + ProductionYear + RangeKm
# do have high significance when predicting the Price

regmodel.best4 <- lm(Price ~ NumberofEngines + Capacity + ProductionYear + RangeKm, data = numeric_air_data)
summary(regmodel.best4)

anova(regmodel.all, regmodel.best4)
# ANOVA confirms that model with all of the predictors is not significantly better
# than the model with the 4 predictors

price.col <- which(colnames(numeric_air_data) == "Price")
plot(numeric_air_data[,-price.col])
cor(numeric_air_data[,-price.col])
vif(regmodel.best4)
# Correlation Matrix and VIF tell us that Capacity and RangeKm are highly correlated
# VIF also tell us that there is a multicollinearity problem within our predictors
# We choose to drop the predictor with the highest VIF: Capacity


regmodel.best3 <- lm(Price ~ NumberofEngines + ProductionYear + RangeKm, data = numeric_air_data)
summary(regmodel.best3)

vif(regmodel.best3)
# Now, VIF shows no multicollinearity among the predictors


regmodel.b1 <- lm(Price ~ NumberofEngines + ProductionYear, data = numeric_air_data)
summary(regmodel.b1)
regmodel.b2 <- lm(Price ~ NumberofEngines + RangeKm, data = numeric_air_data)
summary(regmodel.b2)

anova(regmodel.best3, regmodel.b1)  # Drop RangeKm predictor
anova(regmodel.best3, regmodel.b2)  # Drop ProductionYear predictor
# After comparing both models, dropping each extra predictor, we observe that keeping
# RangeKm predictor leads to higher R2 (prediction power) and a smaller Sum of Square Residuals

# So, we decided to choose NumberofEngines + RangeKm
regmodel.b <- regmodel.b2
summary(regmodel.b)

# Regression Assumptions
par(mfrow = c(1, 3))
# Normality of the Error Term
qqnorm(residuals(regmodel.b))
# Using Histogram
hist(residuals(regmodel.b))

# Homogeneity of Variance
plot(residuals(regmodel.b))
# Breusch Pagan
bptest(regmodel.b) # p-value < 0.05 shows heteroscedasticity!!!

# Independence of errors
dwtest(regmodel.b, alternative = "two.sided")
par(mfrow = c(1, 1))


# Compare model a with model b
anova(slrmodel.a, regmodel.b)

# Adding RangeKm to the model decreases significantly the Residual Sum of Squares,
# meaning the model improves by adding this new variable

# Compare SLR vs MLR using adjusted R-squared, AIC, and ANOVA
cat("\nSLR Adj. R-squared:", summary(regmodel.b)$adj.r.squared, "\n")
cat("MLR Adj. R-squared:", summary(regmodel.b)$adj.r.squared, "\n")
cat("SLR AIC:", AIC(slrmodel.a), "\n")
cat("MLR AIC:", AIC(regmodel.b), "\n")

# Interpretation:
# The MLR model with NumberOfEngines + RangeKm do have a higher adjusted R-squared and
# lower AIC than the SLR with NumberOfEngines alone, indicating a better fit.
# The ANOVA F-test tells us that adding the second variable significantly improves
# the model.


# ------------------------------------------ C ------------------------------------------
# Encode the variable model into three categories considering whether the plane is "Airbus",
# "Boeing" or "Other". Now add this model factor to the regression model you have chosen in
# section (b). Interpret the coefficients and overall summary of the model. Compare the model
# in section (b) with the model that has an additional factor. Which one would you choose? Why?
# ---------------------------------------------------------------------------------------

numeric_air_data$ModelCat <- as.factor(
  ifelse(grepl("Airbus", air_data$Model, ignore.case = TRUE), "Airbus",
  ifelse(grepl("Boeing", air_data$Model, ignore.case = TRUE), "Boeing", "Other"))
)
summary(numeric_air_data)

regmodel.c <- lm(Price ~ NumberofEngines + RangeKm + ModelCat, data = numeric_air_data)
summary(regmodel.c)

# Compare model b to model c
anova(regmodel.b, regmodel.c)

# Adding ModelCat to the model decreases the Residual Sum of Squares,
# meaning the model improves by adding this new variable
summary(regmodel.c)


# Regression Assumptions
par(mfrow = c(1, 3))
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
par(mfrow = c(1, 1))

# Interpretation:



# ------------------------------------------ D ------------------------------------------
# Test the validity of the final model that you choose.
# ---------------------------------------------------------------------------------------

# Choosing model c lm(Price ~ NumberofEngines + RangeKm + ModelCat)
summary(regmodel.c)


# Regression Assumptions
par(mfrow = c(1, 3))
# Normality of the Error Term
qqnorm(residuals(regmodel.c))
qqline(residuals(regmodel.c), col = "red")
# Using Histogram
hist(residuals(regmodel.c))

# Homogeneity of Variance
plot(residuals(regmodel.c))
# Breusch Pagan
bptest(regmodel.c)

# Multicollinearity (VIF)
vif(regmodel.c)

# Independence of errors
dwtest(regmodel.c, alternative = "two.sided")
par(mfrow = c(1, 1))

# Interpretation:
# The final model is valid if:
#   - Residuals vs Fitted shows no clear pattern (linearity holds).
#   - Q-Q plot follows the diagonal (normality holds).
#   - Breusch-Pagan p > 0.05 (constant variance / homoscedasticity holds).
#   - Durbin-Watson statistic is close to 2 (no autocorrelation).
#   - All VIF values < 5 (no severe multicollinearity).
