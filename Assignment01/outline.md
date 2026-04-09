# Assignment Outline

- Q1 Solutions
  - Import data set to R assigning the type of each variable correctly
  - Summarize the variables Price, Fuel Consumption first for the all data and then for the groups of Engine Type
  - Test whether Fuel Consumption is affected from the Engine Type of the plane. Check the assumptions and visualize the relationship between these two characteristics
  - Construct 95% confidence intervals for the mean of two groups and interpret them
  - Check the association between Model and Sales Region in the whole sample using proper method and interpret your findings
  - Filter your data only considering Bombardier CRJ200 and Cessna 172 model airplanes
  - Check the distribution of Price across two categories of Engine type (You can apply transformation if you think it is required)
  - Categorize the variable Price into two categories as “Low” and “High” by cutting from the median and save it as a new variable into your data frame
  - Cross classify model and price categories and interpret the conditional probabilities
  - Is there an association between the model of the airplane and its price level. Analyze it by using proper statistical method
  - Cross classify the variables Model and Sales region. Interpret the conditional probabilities and then test whether there is an association between these two characteristics

- Q2 Solutions
  - Create a new data frame only including “Airbus A320”, “Airbus A350”, “Boeing 737” and “Boeing 777” models of airplanes. Check the distribution of Price: first for the observations in this sample and then for each model in the data frame. Interpret your findings.
  - Analyze the numerical variables that are affected by the “Model”. Test the assumptions of the statistical method, for the cases that you have found a significant association, by using corresponding tests and plots. Write your conclusions.
  - Apply a two-way ANOVA including Sales Region to the model. Interpret your findings.
  - Convert the variable Production Year to a categorical variable with two levels as “Older” and “Newer” and save it as a new variable named “year_cat” in the data frame.
  - Analyze the effect of Model and year (“year_cat”) together on the price. Analyze whether the interaction of two term is significant. Interpret your findings.

<div style="page-break-after: always;"></div>

- Q3 Solutions
  - Consider the numerical variables in the data set and find the best SIMPLE linear regression model to predict the prices. Test the assumptions and use transformations if it is required. Explain why the model you find is the best simple linear regression model and interpret the model coefficients.
  - Fit a multivariate linear regression model with the most important two (numerical) variables. Use transformations if it is needed and test all the assumptions. Then compare this model to the simple linear regression model that you fit in (a). Which one is a better model? Why?
  - Encode the variable model into three categories considering whether the plane is “Airbus”, “Boeing” or “Other”. Now add this model factor to the regression model you have chosen in section (b). Interpret the coefficients and overall summary of the model. Compare the model in section (b) with the model that has an additional factor. Which one would you choose? Why?
  - Test the validity of the final model that you choose.

- Q4 Solutions
  - Apply PCA analysis on airplane data and interpret the results of the analysis.
  - Find the best linear model to predict price on the principal components. Do not forget to test the assumptions and the validity of the model.
  - Would you prefer the linear model that you fit in the final step of question 3 or this one? Explain why.