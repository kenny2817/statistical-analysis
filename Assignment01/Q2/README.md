# Q2 Solutions

## Create a new data frame only including “Airbus A320”, “Airbus A350”, “Boeing 737” and “Boeing 777” models of airplanes. Check the distribution of Price: first for the observations in this sample and then for each model in the data frame. Interpret your findings.

![figure01](./01-summary-price-all.png)
*Figure 01*

![figure02](./02-summary-price-by-model.png)
*Figure 02*

#### Conclusion

After the log transformation, Price is approximately normally distributed overall. Per model, Boeing 777 and Airbus A350 have higher mean log(Price) values reflecting their larger capacity and longer range. Boeing 737 and Airbus A320 cluster at lower price levels. Within each model, the log(Price) distribution is roughly symmetric, confirming that log transformation was appropriate for subsequent ANOVA analysis.


## Analyze the numerical variables that are affected by the “Model”. Test the assumptions of the statistical method, for the cases that you have found a significant association, by using corresponding tests and plots. Write your conclusions.

![figure03](./03-boxplot-of-numerics.png)
*Figure 03*

> The boxplots show that your four models fall into two sub-groups: cheaper and more expensive models.

#### Variables Affected by Model

- **Price**: The A350 and B777 (expensive sub-group) are in a different wealth bracket compared to the A320 and B737 (cheaper sub-group).
- **Capacity & RangeKm**: These are affected by the model, though there is almost zero variation within groups in the dataset. This means Model, Capacity, and RangeKm are all telling the model the same thing (high multicollinearity).
- Lastly, **FC, HM, and Age** are NOT significantly different across models since all four are Turbofan jets and the dataset appears to have similar distributions for these.

#### Assumption analysis

![figure04](./04-qqplot-numerical-all.png)
*Figure 04*

- The appearance of a "horizontal flat line" in the QQ-plots for **Capacity** and **RangeKm** occurs because these are fixed specifications for a given airplane model. Consequently, there is near-zero variance within each model group.
- For the case of **Price** the QQ-plot looks a bit curved with respect to the line meaning it might not be normally distributed. However, both Independence test and Homoscedasticity test show a p-vale > 0.05 so we are assuming Normality, Independence and Homoscedasticity.

#### Conclusion

 The ANOVA p-value for Price is < 0.05, so at least one model has a significantly different mean log(Price). The Tukey HSD test shows which specific pairs differ. We expect Boeing 777 and Airbus A350 (wide-body, long-range) to have significantly higher prices than Boeing 737 and Airbus A320 (narrow-body/medium-range). 


## Apply a two-way ANOVA including Sales Region to the model. Interpret your findings.

![figure05](./05-anova-price-region.png)
*Figure 05*

#### Conclusion

There is no significant interaction since the p-value is much higher than 0.05, so we can conclude that the relationship between the aircraft Model and its Price does not change based on the Sales Region. Also, while there might be a tiny hint of a regional difference, statistically speaking, Region does not significantly affect Price.


## Convert the variable Production Year to a categorical variable with two levels as “Older” and “Newer” and save it as a new variable named “year_cat” in the data frame.

```r
cutoff = median(air_data$ProductionYear)
air_data$year_cat <- as.factor(ifelse(air_data$ProductionYear < cutoff, "Older", "Newer"))
str(air_data)
```


## Analyze the effect of Model and year (“year_cat”) together on the price. Analyze whether the interaction of two term is significant. Interpret your findings.

![figure06](./06-plot-by-year-cat.png)
*Figure 06*

> This first plot aligns with previous analysis, there are two cheaper plane models and two expensive ones, and now we observe that there are older and newer models also which are a bit more expensive (shifted to the right) in each case.

![figure07](./07-anova-price-model-year.png)
*Figure 7*

![figure08](./08-anova-interaction-plot.png)
*Figure 8*

#### Conclusion

The two-way ANOVA with interaction tests three effects:
- Main effect of Model: Do different models have different mean prices?
- Main effect of year_cat: Do newer planes have different prices than older ones?
- Interaction (Model:year_cat): Does the effect of age on price vary by model?

Based on the two-way ANOVA results, both the airplane Model and the categorized production year (`year_cat`) have a significant independent effect on the Price. However, the interaction between the Model and the production year is not statistically significant, indicating that the price difference between newer and older airplanes remains consistent regardless of the specific airplane model.

#### Post-hoc tests

All three post-hoc tests (Tukey, Bonferroni, and LSD) confirm significant price differences between the "cheaper" models (A320, B737) and the "expensive" models (A350, B777). However, there is likely no significant price difference *between* the two cheaper models themselves, or *between* the two expensive models. The results are consistent across the different penalty methods.
