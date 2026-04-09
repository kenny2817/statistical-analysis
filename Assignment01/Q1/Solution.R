library(tidyverse)
library(car)

# Import "airplane price data set" to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.


# ------------------------------------------ A ------------------------------------------
# Import data set into R, assigning the type of each variable correctly.
# ---------------------------------------------------------------------------------------

set.seed(42)
air_data <- read.csv("./data/airplane_price_dataset.csv", sep=",", stringsAsFactors=TRUE)
air_data <- air_data |>
  rename(
    FC = FuelConsumption.L.h.,
    HM = HourlyMaintenance...,
    Price = Price...
  )
air_data$EngineType <- as.factor(air_data$EngineType)
air_data$NumberofEngines <- as.factor(air_data$NumberofEngines) # only 2 different amount of engines
air_data$ProductionYear <- as.factor(air_data$ProductionYear)

str(air_data)


# ------------------------------------------ B ------------------------------------------
# Summarize the variables Price, Fuel Consumption first for the all data and then
# for the groups of Engine Type.
# ---------------------------------------------------------------------------------------

# Overall summary
summary(air_data$Price)
summary(air_data$FC)

# Summary by Engine Type
air_data |>
  group_by(EngineType) |>
  summarise(
    Price_Mean = mean(Price),
    Price_SD = sd(Price),
    Price_Median = median(Price),
    Price_Min = min(Price),
    Price_Max = max(Price),
    FC_Mean = mean(FC),
    FC_SD = sd(FC),
    FC_Median = median(FC),
    FC_Min = min(FC),
    FC_Max = max(FC),
    n = n()
  )

par(mfrow = c(1,2))
hist(air_data$Price, 
     main = "Histogram of Price", 
     xlab = "Price", 
     col = "lightblue")
hist(air_data$FC, 
     main = "Histogram of Fuel Consumption", 
     xlab = "Fuel Consumption (L/h)", 
     col = "lightgreen")
par(mfrow = c(1,1))

divided_data = split(air_data, air_data$EngineType)
Turbofan_data <- divided_data[["Turbofan"]]
Piston_data <- divided_data[["Piston"]]

par(mfrow = c(2,2))
# Price Histograms
hist(Piston_data$Price,
     main = "Piston: Price", 
     xlab = "Price",
     col = "lightblue")
hist(Turbofan_data$Price,
     main = "Turbofan: Price", 
     xlab = "Price",
     col = "lightblue")

# Fuel Consumption Histograms
hist(Piston_data$FC,
     main = "Piston: Fuel Consumption", 
     xlab = "Fuel Consumption",
     col = "lightgreen")
hist(Turbofan_data$FC,
     main = "Turbofan: Fuel Consumption", 
     xlab = "Fuel Consumption",
     col = "lightgreen")
par(mfrow = c(1,1))

# ------------------------------------------ C ------------------------------------------
# Test whether Fuel Consumption is affected from the Engine Type of the plane. Check the
# assumptions and visualize the relationship between these two characteristics.
# ---------------------------------------------------------------------------------------

dens_turbo <- density(Turbofan_data$FC, na.rm = TRUE)
dens_piston <- density(Piston_data$FC, na.rm = TRUE)

plot(dens_turbo, col = "red",
     main = "Fuel Consumption by Engine Type",
     xlab = "Fuel Consumption",
     xlim = range(c(dens_turbo$x, dens_piston$x)), 
     ylim = range(c(dens_turbo$y, dens_piston$y)))
lines(dens_piston, col = "blue")
legend("topright", legend = levels(air_data$EngineType), col = c("blue", "red"), lty = 1)

# Boxplot is best for comparing a continuous variable across categories
boxplot(FC ~ EngineType, data = air_data,
        main = "Fuel Consumption by Engine Type",
        xlab = "Engine Type", ylab = "Fuel Consumption",
        col="lightgreen")

# Normality test
shapiro.test(Turbofan_data$FC)
shapiro.test(Piston_data$FC) # Error, data size > 5000

qqnorm(Piston_data$FC, main = "Q-Q Plot: Piston Fuel") # Don't follow normal distribution
qqline(Piston_data$FC)
qqnorm(Turbofan_data$FC, main = "Q-Q Plot: Turbofan Fuel") # Don't follow normal distribution
qqline(Turbofan_data$FC) 

# Variance test
var.test(FC ~ EngineType, data = air_data) # No resilient against non normal distributions
leveneTest(FC ~ EngineType, data = air_data)

# Welch's t-test (does not assume equal variances)
t.test(FC ~ EngineType, data = air_data)

# p-value < 2.2e-16, alternative hypothesis: true difference in means between group 
# Piston and group Turbofan is not equal to 0
# 95 percent confidence interval:
#  21.09784 22.11459

# ------------------------------------------ D ------------------------------------------
# Construct 95% confidence intervals for the mean of two groups and interpret them.
# ---------------------------------------------------------------------------------------

# 95% Confidence Intervals for the mean of each group
t.test(Piston_data$FC)$conf.int
t.test(Turbofan_data$FC)$conf.int
t.test(FC ~ EngineType, data = air_data, conf.level = 0.95)$conf.int # Do not contain 0

# Interpretation:
# We are 95% confident that the true population mean of FC for Piston engines 
# lies within that interval (29.61919, 30.62560)
# Similarly, the 95% CI for Turbofan is (8.443816, 8.588554)
# The two intervals do NOT overlap, this provides visual evidence that the mean
# Fuel Consumption differs significantly between the two engine types.


# ------------------------------------------ E ------------------------------------------
# Check the association between Model and Sales Region in the whole sample using proper
# method and interpret your findings.
# ---------------------------------------------------------------------------------------

# Association between two categorical variables (Chi-Square)
table_model_region <- table(air_data$Model, air_data$SalesRegion)
chisq_result <- chisq.test(table_model_region)
print(chisq_result)
any(chisq_result$expected < 5) # There is not freq. below 5

# Interpretation:
# The p-value > 0.05 (0.73), so we fail to reject H0 and conclude there is no statistically
# significant association between Model and Sales Region. The airplane models are
# distributed similarly across sales regions.
# A mosaic plot could visually confirms whether the proportions of models vary across regions.


# ------------------------------------------ F ------------------------------------------
# Filter your data only considering Bombardier CRJ200 and Cessna 172 model airplanes.
# ---------------------------------------------------------------------------------------

filtered_air_data <- air_data |>
  filter(Model %in% c("Bombardier CRJ200", "Cessna 172")) |>
  droplevels()

str(filtered_air_data)
summary(filtered_air_data)

divided_data = split(filtered_air_data, filtered_air_data$EngineType)
Turbofan_data <- divided_data[["Turbofan"]]
Piston_data <- divided_data[["Piston"]]

# ------------------------------------------ G ------------------------------------------
# Check the distribution of Price across two categories of Engine type. (You can apply
# transformation if you think it is required)
# ---------------------------------------------------------------------------------------

par(mfrow = c(1,2))
# Histograms
hist(log(Turbofan_data$Price))
hist(log(Piston_data$Price))

par(mfrow = c(1,1))
# Plot of Price by Engine Type
dens_turbo <- density(log(Turbofan_data$Price), na.rm = TRUE)
dens_piston <- density(log(Piston_data$Price), na.rm = TRUE)

plot(dens_turbo, col = "red",
     main = "Price by Engine Type",
     xlab = "Log. Price",
     xlim = range(c(dens_turbo$x, dens_piston$x)), 
     ylim = range(c(dens_turbo$y, dens_piston$y)))
lines(dens_piston, col = "blue")
legend("topright", legend = levels(air_data$EngineType), col = c("blue", "red"), lty = 1)

# ------------------------------------------ H ------------------------------------------
# Categorize the variable Price into two categories as "Low" and "High" by cutting from the
# median and save it as a new variable into your data frame.
# ---------------------------------------------------------------------------------------

median_price <- median(filtered_air_data$Price, na.rm = TRUE)
# Create the new categorical variable "Price_Category"
filtered_air_data$Price_Category <- factor(
  ifelse(filtered_air_data$Price > median_price, "High", "Low")
)

str(filtered_air_data$Price_Category)


# ------------------------------------------ I ------------------------------------------
# Cross classify model and price categories and interpret the conditional probabilities.
# ---------------------------------------------------------------------------------------

cross_model_price <- table(filtered_air_data$Model, filtered_air_data$Price_Category)
print(cross_model_price)
# Conditional probabilities: P(PriceCategory | Model) - row proportions
print(prop.table(cross_model_price, margin = 1))
# Conditional probabilities: P(Model | PriceCategory) - column proportions
print(prop.table(cross_model_price, margin = 2))

# Interpretation:
# Row proportions P(PriceCategory | Model) show, for each model, what proportion of its
# airplanes fall into "Low" vs "High" price. Since Bombardier CRJ200 (Turbofan) has much
# higher prices than Cessna 172 (Piston), we expect nearly all Bombardier CRJ200 to be
# in the "High" category and nearly all Cessna 172 to be in the "Low" category.
#
# Column proportions P(Model | PriceCategory) show, for each price category, what
# proportion belongs to each model. The "Low" category is dominated by Cessna 172 and
# the "High" category by Bombardier CRJ200, so it confirms a strong association between
# airplane model and price level.


# ------------------------------------------ J ------------------------------------------
# Is there an association between the model of the airplane and its price level.
# Analyze it by using proper statistical method.
# ---------------------------------------------------------------------------------------

# Test association between Model and Price Level using Chi-Square
test_model_price <- chisq.test(cross_model_price)
print(test_model_price)

# Interpretation:
# The p-value < 0.05, so we reject H0 and conclude there is a statistically significant
# association between airplane model and price level. Given that Bombardier CRJ200
# (Turbofan) costs millions while Cessna 172 (Piston) costs hundreds of thousands,
# we expect a very small p-value, confirming a strong association.


# ------------------------------------------ K ------------------------------------------
# Cross classify the variables Model and Sales region. Interpret the conditional probabilities
# and then test whether there is an association between these two characteristics.
# ---------------------------------------------------------------------------------------

# Cross-classification table
cross_model_region <- table(filtered_air_data$Model, filtered_air_data$SalesRegion)
print(cross_model_region)

# Conditional probabilities: P(SalesRegion | Model)
print(prop.table(cross_model_region, margin = 1))
# Conditional probabilities: P(Model | SalesRegion)
print(prop.table(cross_model_region, margin = 2))

# Interpretation of conditional probabilities:
# P(SalesRegion | Model) (row proportions): shows the distribution of sales regions
# for each model. Both models have similar proportions across regions, so we conclude
# that the sales region is independent of the model.
# P(Model | SalesRegion) (column proportions): shows, within each region, what share
# belongs to each model. Both models appear in roughly equal proportions within
# every region, so this supports our independence assumption.

# Test for association
test_model_region <- chisq.test(cross_model_region)
print(test_model_region)
print(test_model_region$residuals)

# Interpretation:
# As expected, p-value > 0.05 (~0.29), so we fail to reject H0 and conclude there is no significant
# association — the two models are sold in similar proportions across regions.
