library(tidyverse)
library(car)
library(lmtest)
library(agricolae)

# Import "airplane price data set" to R.
# The data set consists of following variables: Model, Production Year, Number of 
# Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, 
# age, Sales Region and Price of different airplanes.


# ------------------------------------------ A ------------------------------------------
# Create a new data frame only including "Airbus A320", "Airbus A350", "Boeing 737" and
# "Boeing 777" models of airplanes. Checked the distribution of Price first for the observations
# in this sample and then for each model in the data frame. Interpret your findings.
# ---------------------------------------------------------------------------------------

set.seed(42)
air_data <- read.csv("./data/airplane_price_dataset.csv", sep=",", stringsAsFactors=TRUE)
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
# Price is generally right-skewed data; a log() transformation helps to normalize the data
air_data$Price <- log(air_data$Price)

str(air_data)

hist(air_data$Price, 
     main = "Histogram of Price (Models: Airbus A320, Airbus A350, Boeing 737, Boeing 777)", 
     xlab = "Price", 
     col = "lightblue")

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

# Interpretation:
# After the log transformation, Price is approximately normally distributed overall.
# Per model, Boeing 777 and Airbus A350 have higher mean log(Price) values reflecting
# their larger capacity and longer range. Boeing 737 and Airbus A320 cluster at lower
# price levels. Within each model, the log(Price) distribution is roughly symmetric,
# confirming that log transformation was appropriate for subsequent ANOVA analysis.


# ------------------------------------------ B ------------------------------------------
# Analyze the numerical variables that are affected by the "Model". Test the assumptions of
# the statistical method, for the cases that you have found a significant association, by using
# corresponding tests and plots. Write your conclusions. 
# ---------------------------------------------------------------------------------------

# Numerical vars only
num_vars <- names(air_data)[sapply(air_data, is.numeric)]
par(mfrow = c(3, 3))
for (var in num_vars) {
  boxplot(air_data[[var]] ~ air_data$Model,
          main = paste(var, "by Model"),
          xlab = "Model", 
          ylab = var)
}
par(mfrow = c(1, 1))

# Based on the boxplots, variables **Price**, **Capacity**, and **RangeKm** are the ones affected by Model.

# ANOVA and analysis, only on Price as it is the only one that shows within-group variation
aov_price <- aov(Price ~ Model, data = air_data)
summary(aov_price)

# Assumptions of ANOVA
# Populations from which the samples are selected must be normal
qqnorm(aov_price$residuals, main = "Price Q-Q Plot")
shapiro.test(residuals(aov_price))

# Observations within each sample must be independent
dwtest(aov_price, alternative ="two.sided")

# Populations from which the samples are selected must have equal variances (homogeneity of variance)
bptest(aov_price)

# Residuals vs Fitted plot
plot(aov_price, which = 1)

# Post-hoc: Tukey HSD to identify which models differ
tukey_price <- TukeyHSD(aov_price)
tukey_price
plot(tukey_price, las = 1)

# Interpretation:
# The ANOVA p-value for Price is < 0.05, so at least one model has a significantly
# different mean log(Price). The Tukey HSD test shows which specific pairs differ.
# We expect Boeing 777 and Airbus A350 (wide-body, long-range) to have significantly
# higher prices than Boeing 737 and Airbus A320 (narrow-body, short/medium-range).
# FC, HM, and Age are likely NOT significantly different across models since all four
# are Turbofan jets and the dataset appears to have similar distributions for these.


# ------------------------------------------ C ------------------------------------------
# Apply a two-way ANOVA including Sales Region to the model. Interpret your findings.
# ---------------------------------------------------------------------------------------

# Two-Way ANOVA and analysis
aov2_price <- aov(Price ~ Model * SalesRegion, data = air_data)
summary(aov2_price)

# Assumptions of ANOVA
# Populations from which the samples are selected must be normal
qqnorm(aov2_price$residuals, main = "Price Q-Q Plot")
shapiro.test(residuals(aov2_price))

# Observations within each sample must be independent
dwtest(aov2_price, alternative ="two.sided")

# Populations from which the samples are selected must have equal variances (homogeneity of variance)
bptest(aov2_price)

# Residuals vs Fitted plot
plot(aov2_price, which = 1)

# Interpretation:
# The SalesRegion is not significant, it means price differences are driven by the model
# type, not the geographic market.


# ------------------------------------------ D ------------------------------------------
# Convert the variable Production Year to a categorical variable with two levels as "Older" and
# "Newer" and save it as a new variable named "year_cat" in the data frame.
# ---------------------------------------------------------------------------------------

cutoff = median(air_data$ProductionYear)
air_data$year_cat <- as.factor(ifelse(air_data$ProductionYear < cutoff, "Older", "Newer"))
str(air_data)


# ------------------------------------------ E ------------------------------------------
# Analyze the effect of Model and year ("year_cat") together on the price. Analyze whether the
# interaction of two term is significant. Interpret your findings.
# ---------------------------------------------------------------------------------------

# Plots
densityNewer <- density(air_data$Price[air_data$year_cat == "Newer"], na.rm = TRUE)
densityOlder <- density(air_data$Price[air_data$year_cat == "Older"], na.rm = TRUE)

plot(densityNewer, col = "red",
     main = "Price by Year Category",
     xlab = "Price",
     xlim = range(c(densityNewer$x, densityOlder$x)),
     ylim = range(c(densityNewer$y, densityOlder$y)))
lines(densityOlder, col = "green")
legend("topright", legend = levels(air_data$year_cat), col = c("red", "green"), lty = 1)

# Two-Way ANOVA and analysis
aov2_price <- aov(Price ~ Model * year_cat, data = air_data)
summary(aov2_price)

# Interaction Plot
interaction.plot(air_data$Model, air_data$year_cat, air_data$Price, fun=mean,
                 type="l", legend=TRUE)

# Test normality assumption for Two-Way ANOVA
qqnorm(aov2_price$residuals)
qqline(residuals(aov2_price), col = "red")
# shapiro.test(residuals(aov2_price))
# Observations within each sample must be independent
dwtest(aov2_price, alternative ="two.sided")
# Populations from which the samples are selected must have equal variances (homogeneity of variance)
bptest(aov2_price)

# Post-hoc tests
tukey_result <- TukeyHSD(aov2_price, which="Model")
print(tukey_result)

bonferroni_result <- pairwise.t.test(air_data$Price, air_data$Model, p.adjust.method = "bonferroni")
print(bonferroni_result)

LSD_result <- LSD.test(aov2_price, "Model", p.adj = "bonferroni", console = TRUE)

# Interpretation:
# The two-way ANOVA with interaction tests three effects:
#   1. Main effect of Model: Do different models have different mean prices?
#   2. Main effect of year_cat: Do newer planes have different prices than older ones?
#   3. Interaction (Model:year_cat): Does the effect of age on price vary by model?
# Based on the two-way ANOVA results, both the airplane Model and the categorized 
# production year (`year_cat`) have a significant independent effect on the Price. 
# However, the interaction between the Model and the production year is not statistically 
# significant, indicating that the price difference between newer and older airplanes 
# remains consistent regardless of the specific airplane model.
