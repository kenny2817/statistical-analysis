library(tidyverse)
library(car)
library(lmtest)

# Import “airplane price data set” to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.

# We aim to reduce dimension, obtain new independent variables to predict price of airplanes by using
# linear regression.


# ------------------------------------------ A ------------------------------------------
# Apply PCA analysis on airplane data and interpret the results of the analysis.
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
numeric_air_data <- air_data[, num_vars]
str(numeric_air_data)

pca_features <- numeric_air_data[, names(numeric_air_data) != "Price"]
planes_pc <- princomp(pca_features, cor = TRUE) 
summary(planes_pc)

eigs <- planes_pc$sdev^2
eigs
plot(eigs, type = "b")

planes_pc$loadings
biplot(planes_pc)
plot(planes_pc)

# We are selecting the first 4 components as they account for the ~97 percent of the 
# data variation


# ------------------------------------------ B ------------------------------------------
# Find the best linear model to predict price on the principal components. Do not forget to test
# the assumptions and the validity of the model.
# ---------------------------------------------------------------------------------------

planes_pc$loadings[, 1:4]
pca_data <- as.data.frame(planes_pc$scores[, 1:4])
# Combine original Price with the first 4 components
final_model_data <- cbind(Price = air_data$Price, pca_data)

regmodel.pca <- lm(Price ~ ., data = final_model_data)
summary(regmodel.pca)


# VIF shows no multicollinearity among the predictors
vif(regmodel.pca)


# Regression Assumptions
par(mfrow = c(1, 3))
# Normality of the Error Term
qqnorm(residuals(regmodel.pca))
# Using Histogram
hist(residuals(regmodel.pca))

# Homogeneity of Variance
plot(residuals(regmodel.pca))
# Breusch Pagan
bptest(regmodel.pca)
# BP test in this new mode it shows homescedasticy!!!

# Independence of errors
dwtest(regmodel.pca, alternative = "two.sided")
par(mfrow = c(1, 1))


# ------------------------------------------ C ------------------------------------------
# Would you prefer the linear model that you fit in the final step of question 3 or this one?
# Explain why.
# ---------------------------------------------------------------------------------------

numeric_air_data$ModelCat <- as.factor(
  ifelse(grepl("Airbus", air_data$Model, ignore.case = TRUE), "Airbus",
         ifelse(grepl("Boeing", air_data$Model, ignore.case = TRUE), "Boeing", "Other"))
)
summary(numeric_air_data)

regmodel.c <- lm(Price ~ NumberofEngines + RangeKm + ModelCat, data = numeric_air_data)
summary(regmodel.c)

# Compare this model to previous model c
anova(regmodel.pca, regmodel.c)
# This new model decreases the Residual Sum of Squares, meaning the model improves


