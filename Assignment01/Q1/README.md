## Q1 Solutions

Import “airplane price data set” into R. The data set consists of following variables: Model, Production Year, Number of Engines, Engine Type, Capacity, Range (km), Fuel Consumption, Hourly Maintenance, age, Sales Region and Price of different airplanes.

#### Libraries

```r
library(tidyverse)
library(dplyr)
library(car)
```


#### Import data set to R assigning the type of each variable correctly

```r
air_data <- read.csv("../data/airplane_price_dataset.csv", sep=",", stringsAsFactors=TRUE)

air_data <- air_data %>%
  rename(
    FC = FuelConsumption.L.h.,
    HM = HourlyMaintenance...,
    Price = Price...
  )
air_data$EngineType <- as.factor(air_data$EngineType)

str(air_data)
```


#### Summarize the variables Price, Fuel Consumption first for the all data and then for the groups of Engine Type

```r
air_data[, c("Price", "FC")] %>%
  summarize(
    Mean_Price = mean(Price, na.rm = TRUE),
    Median_Price = median(Price, na.rm = TRUE),
    SD_Price = sd(Price, na.rm = TRUE),
    Mean_Fuel = mean(FC, na.rm = TRUE),
    Median_Fuel = median(FC, na.rm = TRUE),
    SD_Fuel = sd(FC, na.rm = TRUE)
  )
hist(air_data$Price)
hist(air_data$FC)
```

|     | Mean_Price | Median_Price | SD_Price  | Mean_Fuel | Median_Fuel | SD_Fuel  |     |
| --- | ---------- | ------------ | --------- | --------- | ----------- | -------- | --- |
|     | 198833650  | 83921914     | 229039179 | 12.07562  | 9.82        | 9.905418 |     |

![summary-all-data](./summary-all-data.png)
*Figure 01*

```r
air_data %>%
  group_by(EngineType) %>%
  summarize(
    Mean_Price = mean(Price, na.rm = TRUE),
    Median_Price = median(Price, na.rm = TRUE),
    SD_Price = sd(Price, na.rm = TRUE),
    Mean_Fuel = mean(FC, na.rm = TRUE),
    Median_Fuel = median(FC, na.rm = TRUE),
    SD_Fuel = sd(FC, na.rm = TRUE)
  )
```

| EngineType | Mean_Price  | Median_Price | SD_Price    | Mean_Fuel | Median_Fuel | SD_Fuel |
| ---------- | ----------- | ------------ | ----------- | --------- | ----------- | ------- |
| Piston     | 279405.0    | 251474.0     | 77369.0     | 30.1      | 29.9        | 11.6    |
| Turbofan   | 237995200.0 | 108876395.0  | 231292861.0 | 8.52      | 8.53        | 3.75    |

```r
divided_data = split(air_data, air_data$EngineType)
Turbofan_data <- divided_data[[1]]
Piston_data <- divided_data[[2]]
```
![summary-by-type.png](./summary-by-type.png)
*Figure 02*

![summary-by-type2.png](./summary-by-type2.png)
*Figure 03*


#### Test whether Fuel Consumption is affected from the Engine Type of the plane. Check the assumptions and visualize the relationship between these two characteristics

```r
# Boxplot is best for comparing a continuous variable across categories
boxplot(FC ~ EngineType, data = air_data,
        main = "Fuel Consumption by Engine Type",
        xlab = "Engine Type", ylab = "Fuel Consumption",
        col = "lightgreen")
```
![boxplot-by-type.png](./boxplot-by-type.png)
![ttest-by-engine.png](./ttest-by-engine.png)
*Figure 04: p-value < 0.05 so we are rejecting Ho*


#### Construct 95% confidence intervals for the mean of two groups and interpret them

```r
cat("\n95% CI for Turbofan Fuel Consumption:\n")
t.test(Turbofan_data$FC)$conf.int
cat("\n95% CI for Piston Fuel Consumption:\n")
t.test(Piston_data$FC)$conf.int
```

**95% CI for Turbofan Fuel Consumption**: (8.443816, 8.588554)
- *We are 95% confident that the true population mean of fuel consumption for TurboFan falls between (8.443816, 8.588554)*
**95% CI for Piston Fuel Consumption**: (29.61919, 30.62560)
- *We are 95% confident that the true population mean of fuel consumption for Piston falls between (29.61919, 30.62560)*


#### Check the association between Model and Sales Region in the whole sample using proper method and interpret your findings

```r
table_model_region <- table(air_data$Model, air_data$SalesRegion)
chisq_result <- chisq.test(table_model_region)
print(chisq_result)
# p-value = 0.7 so no association.
```


#### Filter your data only considering Bombardier CRJ200 and Cessna 172 model airplanes

```r
filtered_air_data <- air_data %>%
  filter(Model %in% c("Bombardier CRJ200", "Cessna 172")) %>%
  droplevels()
  
filtered_air_data  %>%
summarize(
  Mean_Price = mean(Price, na.rm = TRUE),
  Median_Price = median(Price, na.rm = TRUE),
  SD_Price = sd(Price, na.rm = TRUE),
  Mean_Fuel = mean(FC, na.rm = TRUE),
  Median_Fuel = median(FC, na.rm = TRUE),
  SD_Fuel = sd(FC, na.rm = TRUE)
)
```

| Mean_Price | Median_Price | SD_Price  | Mean_Fuel | Median_Fuel | SD_Fuel |
| ---------- | ------------ | --------- | --------- | ----------- | ------- |
| 8033685.0  | 9221878.0    | 8374538.0 | 19.24929  | 13.655      | 13.8377 |


#### Check the distribution of Price across two categories of Engine type (You can apply transformation if you think it is required)

![boxplot-logprice-by-type.png](./boxplot-logprice-by-type.png)
*Figure 05*


#### Categorize the variable Price into two categories as “Low” and “High” by cutting from the median and save it as a new variable into your data frame

```r
median_price <- median(filtered_air_data$Price, na.rm = TRUE)
# Create the new categorical variable "Price_Category"
filtered_air_data$Price_Category <- factor(
  ifelse(filtered_air_data$Price > median_price, "High", "Low")
)
```


#### Cross classify model and price categories and interpret the conditional probabilities

```r
# Cross classify model and price categories
cross_model_price <- table(filtered_air_data$Model, filtered_air_data$Price_Category)

cat("\nCross Classification Table (Counts):\n")
print(cross_model_price)
cat("\nConditional Probabilities (Row proportions):\n")
print(prop.table(cross_model_price, margin = 1))
```

| Model             | High Price Prob    | Low Price Prob |
| ----------------- | ------------------ | -------------- |
| Bombardier CRJ200 | 279405.00.99707459 | 0.002925402    |
| Cessna 172        | 0                  | 1              |


#### Is there an association between the model of the airplane and its price level. Analyze it by using proper statistical method

```r
# Test association between Model and Price Level using Chi-Square
test_model_price <- chisq.test(cross_model_price)
print(test_model_price)
# p-value < 2.2e-16 so there is a significant association between the airplane model and its price level.
```


#### Cross classify the variables Model and Sales region. Interpret the conditional probabilities and then test whether there is an association between these two characteristics

```r
cat("\nCross Classification - Model and Sales Region:\n")
cross_model_region <- table(filtered_air_data$Model, filtered_air_data$SalesRegion)
print(cross_model_region)

cat("\nConditional Probabilities (Row proportions):\n")
print(prop.table(cross_model_region, margin = 1))
# Interpretation: Shows the probability of an airplane being sold in a specific region GIVEN its Model.

# Test for association
test_model_region <- chisq.test(cross_model_region)
print(test_model_region)
```

