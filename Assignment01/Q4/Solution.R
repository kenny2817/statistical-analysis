library(tidyverse)
library(car)
library(lmtest)
library(FactoMineR)
library(psych)
library(HSAUR)

# Import "airplane price data set" to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.

# We aim to reduce dimension, obtain new independent variables to predict price of airplanes by using
# linear regression.


# TODO: Missing cross-validation or out-of-sample test. Neither Q3 nor Q4 validates the models on held-out data. 
# Even a simple train/test split or k-fold CV would substantially strengthen the analysis.
# No outlier analysis. None of the questions check for influential outliers (Cook's distance, leverage).


# ------------------------------------------ A ------------------------------------------
# Apply PCA analysis on airplane data and interpret the results of the analysis.
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
air_data$ProductionYear <- as.factor(air_data$ProductionYear)
air_data$NumberofEngines <- as.factor(air_data$NumberofEngines)

# Price is generally right-skewed data; a log() transformation helps to normalize the data
hist(air_data$Price)
air_data$Price <- log(air_data$Price) # execute only
hist(air_data$Price)

# Numerical vars only (exclude Price since it is the response)
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
biplot(planes_pc, xlabs = rep("", nrow(air_data)))
plot(planes_pc)

# We are selecting the first 3 components as they account for the ~85 percent of the 
# data variation and also have eigenvalues > 1

# PCA visualization
PCA.air <- PCA(numeric_air_data, quanti.sup = 6)
summary(PCA.air)

### Explained Variation ###
PCA.air$eig
plot(PCA.air$eig[,1], type="o", main="Scree Plot")

## Component Loadings ## 
PCA.air$var$coord
PCA.air$var$coord[,1:2]

# Scores of PC1 and PC2
PCA.air$ind$coord[,1:2]
summary(PCA.air)

# Assumptions
R<-cor(numeric_air_data[, names(numeric_air_data) != "Price"])
n <- nrow(numeric_air_data[, names(numeric_air_data) != "Price"])
cortest.bartlett(R, n) # 

###### Kaiser-Meyer-Olkin (KMO) Test ###
kmo <- function(x)
{
  x <- subset(x, complete.cases(x))       # Omit missing values
  r <- cor(x)                             # Correlation matrix
  r2 <- r^2                               # Squared correlation coefficients
  i <- solve(r)                           # Inverse matrix of correlation matrix
  d <- diag(i)                            # Diagonal elements of inverse matrix
  p2 <- (-i/sqrt(outer(d, d)))^2          # Squared partial correlation coefficients
  diag(r2) <- diag(p2) <- 0               # Delete diagonal elements
  KMO <- sum(r2)/(sum(r2)+sum(p2))
  MSA <- colSums(r2)/(colSums(r2)+colSums(p2))
  return(list(KMO=KMO, MSA=MSA))
}

#KMO index
kmo(numeric_air_data[, names(numeric_air_data) != "Price"]) # Only Age and FC are above 0.6

# Normality: All variables and their linear combinations should be normally distributed.

# Linearity: The relationships among pairs of variables should be linear.

# Absence of outliers among individuals: Outliers on individuals could have more influence on the factor solution than the other cases.

# Absence of outliers among variables:The variables that are unrelated to other variables in the data set effect the factor results (A variable with a low correlation with other variables and the important factors is an outlier among variables.).

# Factorability: A factorable data set should include several sizeable correlations (the correlations should exceed 0.30)

# Interpretation:
# PCA reduces the dimensionality of the numerical predictors into uncorrelated principal components.
# - The scree plot and cumulative variance help decide how many PCs to retain (> 80%)
# - The loadings show how each original variable contributes to each PC.
#   PC1 captures airplane size (Capacity, RangeKm, FC)
#   PC2 and PC3 captures age-related variation (HM, Age)
# - The biplot visualizes observations and variable contributions simultaneously.


# ------------------------------------------ B ------------------------------------------
# Find the best linear model to predict price on the principal components. Do not forget to test
# the assumptions and the validity of the model.
# ---------------------------------------------------------------------------------------

pca_3comps <- as.data.frame(planes_pc$scores[, 1:3])
# Combine original Price with the first 3 components
final_model_data <- cbind(Price = air_data$Price, pca_3comps)
regmodel.pca3 <- lm(Price ~ ., data = final_model_data)
summary(regmodel.pca3)

# Compare  model with 3 PC vs model with 2 PC
pca_2comps <- as.data.frame(planes_pc$scores[, 1:2])
final_model_data <- cbind(Price = air_data$Price, pca_2comps)
regmodel.pca2 <- lm(Price ~ ., data = final_model_data)
summary(regmodel.pca2)

anova(regmodel.pca3, regmodel.pca2)

# Comparing the models choosing 2 PC vs 3 PC show us that the first two components
# are enough to predict Price with the same prediction power R2
plot(regmodel.pca2, which = 1, main = "2 PC")
regmodel.b <- regmodel.pca2


# Regression Assumptions
par(mfrow = c(1, 3))
# Normality of the Error Term
qqnorm(residuals(regmodel.b))
qqline(residuals(regmodel.b), col = "red")
# Using Histogram
hist(residuals(regmodel.b))

# Homogeneity of Variance
plot(residuals(regmodel.b))
# Breusch Pagan
bptest(regmodel.b)

# Independence of errors
dwtest(regmodel.b, alternative = "two.sided")
par(mfrow = c(1, 1))


# Test model
n <- nrow(final_model_data)
train.sample <- sample(1:n, round(0.8*n))
train.set <- final_model_data[train.sample, ] 
test.set <- final_model_data[-train.sample, ]

train.model <- lm(Price ~ ., data = train.set)
summary(train.model)

yhat <- predict(train.model, test.set, interval="prediction")

y <- test.set$Price

error <- cbind(yhat[,1,drop=FALSE], y, (y-yhat[,1])^2)
sqr_err <- error[, 3]
mse <- mean(sqr_err) 
print(mse)

plot(y, yhat[,1], xlab = "Actual Price", ylab = "Predicted Price", 
     main = "Predicted vs. Actual")
abline(a = 0, b = 1, col = "red")


# ------------------------------------------ C ------------------------------------------
# Would you prefer the linear model that you fit in the final step of question 3 or this one?
# Explain why.
# ---------------------------------------------------------------------------------------

numeric_air_data$ModelCat <- as.factor(
  ifelse(grepl("Airbus", air_data$Model, ignore.case = TRUE), "Airbus",
         ifelse(grepl("Boeing", air_data$Model, ignore.case = TRUE), "Boeing", "Other"))
)
summary(numeric_air_data)

RangeKm_2 <- (numeric_air_data$RangeKm)^2
regmodel.q3 <- lm(Price ~ RangeKm_2 * ModelCat + RangeKm, data = numeric_air_data)
summary(regmodel.q3)

# Compare model b vs previous model in Q3
anova(regmodel.b, regmodel.q3)
# Model Q3 decreases the Residual Sum of Squares, meaning the model improves

# Interpretation:
