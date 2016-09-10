# DemandForecasting

#One-Stop Source to Learn and Build ‘Demand Forecasting Model For Commodity Products in the Semiconductor Industry’

Target audience of this publication:
-To understand demand forecasting challenges in the semiconductor sector.
-To acquire knowledge of time series forecasting in R for beginners
Brief on semiconductor industry and its market demand:

The analytics has been growingly playing a significant role in every domain of the industry. The semiconductor industry is not escape to it. As the technology is rapidly growing in semiconductor line of business, products developed today can go obsolete in lifespan of 2 - 3 years, according to recent industry trend. Therefore, it is quite a big challenge to forecast the demand for memory products. There are various kinds of products on the basis of which demand of the product might vary.

1.   Legacy Products - Products that are in the market for a longer time and they follow much more gradual price trend. As there are many producers of such memories, they are being treated as Commodity Products and also, follow the demand principles of the commodity market. As demand is dependent on market demand as well as competitors’ supply ability, products typically face huge fluctuation in price points.

2.   Specialty Products - Products that are produced in small quantity for special needs of various consumers and therefore, their demand and pricing are relatively steady.

3.   New Products - Innovative Memory Products based on the enabler of the market to support demanding applications like graphics and networking. For example, as Intel brings up new CPU architecture, the need for efficient memory product that is compatible with new CPU is demanding.

Data collection and challenges:

Generally, sales team forecasts the demand on the basis of knowledge of sales representative and external forecasts. The objective of the current project is to develop statistical techniques for demand forecasting and analyze the results.
The data about delivery quantity at various levels of granularity and other significant information such as sales region and delivery time period are collected.
As an initial approach, I considered to utilize the forecast demand for products by sales team for benchmarking the accuracy of new method over the traditional approach. However, as the customer level of granularity for demand forecasting is different compared to customers defined for actual shipments, there is no easy way to cross-check the accuracy. The process of collecting data from two different sources (Sales and Demand Planning teams) and attempt to merge the data together took significant time of the project.

Demand data analysis:
It is important that one should know the answers of following questions to analyze the data in a better way.

Why statistical forecast?
Traditional forecasts are based on the knowledge of the sales representatives who, most of the times, consider the past quarter and current quarter while making decision about the sales
Sales representatives tend to forecast the demand optimistically
Although semiconductor industry is based on dynamic changes in the technology, historical data collected over period of time can help to improve forecast
External forecast can cost thousands of dollars to purchase
What is the scope of demand forecasting?

There are three important forecasts determined at different levels:
Environmental Forecast - Broad demand forecast of memory based on economic factors such as inflation, unemployment rate, government expenditure, et cetera
Industry Forecast - Survey of consumers as well as competitors’ market share
Company Sales Forecast - Forecasting based on past revenue shipment data
In this project, the scope is limited to Company Sales Forecast based on the easy availability of data and requirement.

Can we forecast the lowest level of product hierarchy based on the data available?
Mostly, the limitation of the number of data points might not allow to forecast at the lowest level of the product hierarchy.  For example, product structure might look as follows:

Marketing Part Number (MPN) > Product group > Die revision > Part technology

Every MPN belongs to only one Product Group. However, there could be multiple product groups that are part of same Die Revision. As there are thousands of MPN categories available, it was a critical step to decide the right level of product hierarchy for which demand needs to be estimated.

What is the Product Life Cycle stage of the products to be forecast?
The use of right forecasting technique can vary based on the life cycle stage of the product.
For example, the forecasting demand for completely new product might need to use different forecasting approach as compared to forecasting demand of the stable product. I have considered the stable products as historical data.

Time series forecasting techniques using R for beginners:
There are many packages in R using which one can apply various time series forecasting techniques. I have applied quite a few models on the cleaned data to forecast the future demand. I will be trying to introduce some of functions and main differences between them.

There are four steps to apply any algorithm over data:

-Develop a model using forecasting technique
-Apply forecasting function
-Look out for random error test
-Predict the forecast and check for accuracy
{Forecast} Package

Model 1: ARIMA Modeling

One can use auto.arima() function which would automatically adjust the p, d, q parameters and return the best model for the data.

If you want to locate the best model by yourself by applying various p ,d ,q values, the best choice is to use Arima() method which is the wrapper class for arima()

Model 2: Exponential Time Series Modeling

Exponential Smoothing can come up with various variations based on additive or multiplicative trend and seasonality factor that data represents.  Holt-Winters (hw() function in R) is specialized method that implements some of these combinations but not all.

So, ets() function is good to use as it will apply all possible combinations of Trend and Season and return the best model based on Error measure.

Model 3: Random Walk Forecast and Averaging Model

The methods called using these techniques.() and meanf() would help develop modelrwf

Model 4: Croston Model

Croston method can be useful when there is intermittent demand for the products. It’s easy as following command to apply croston function in R:

forecast <- croston (train,h=forecastmonths,alpha = 0.1)

Model 5: tbats Model

Tbats uses Exponential Smoothing with State Space Model along with automatic application of Box-Cox Transformation and ARIMA errors.

Model <- tbats(train)

Validation methods for developed models

Box-Jenkins method can be applied on the residuals of the developed model and it will signify if the model still needs to be tuned to have only random error present in the time series model.

l= min(10,T/5)

Box.test(residuals(fit1), lag=l, fitdf=l-train.p-train.q, type="Ljung")

Here, T signifies the number of total training points.

train.p and train.q are the ‘order’ generated through auto.arima()

The ideal values for lag and fitdf should be calculated based on above mentioned formula as per the author of {forecast} package.

Outlier analysis in time series data: {tsoutliers} package
The below method proved to be very useful in order to detect the outliers, remove them, and refit the model:

outlierResult <-tso(train, cval = NULL, delta = 0.7, n.start = 50,

         types = c("AO", "LS", "TC"),

         maxit = 1, maxit.iloop = 4, cval.reduce = 0.14286,

         remove.method = "en-masse",

         remove.cval = NULL,

         tsmethod = "auto.arima",

         args.tsmethod = list(xreg= ce))

forecast <-forecast(outlierResult$fit,xreg= outlierResult$fit$xreg,h=forecastmonths)

When dealing with monthly data, as some months have 5 weeks and others have 4 weeks, the time series data might represent false seasonality within the dataset.  Calendar.effects () function can be used to neutralize such effects. This function would return external regressor variables that one needs to include while developing model and forecasting the results.

ce <- calendar.effects(train,trading.day = TRUE)

fit1 <- auto.arima(train,xreg = ce)

How to choose the best model and the best error measure method?
As the forecasts for the product should be developed at the lowest level of product hierarchy, I have applied all forecasting techniques on all product groups and displayed the forecast error for every forecasting technique and for each error measure. Based on the result, one can choose the most stable method with minimal error.

Assumptions of the model:
The model doesn’t consider the change in demand due to economic factors or sudden events that might occur in future.

Limitations:
Only past two years of data is available. Ideally, one needs to have at least 3 years of data for time series analysis.
The relationships and trends in the data are not stable and clear. Outlier detection is the biggest challenge as it is not properly documented.

Future scope:
Incorporate the industrial and economic factors within the model to improve the accuracy of the statistical forecasts
Utilize the forecasts provided by sales representatives to predict statistical forecasts for the future

Challenges:
-Product Life Cycles are getting shorter day by day. As most of the products face end-of-life in short period of time and some other products get ramped up in place of that, it’s important to document this change effectively and include in the analysis.
-Existing forecasts are based on customers’ forecast accuracy. For example, Apple forecasts the future demand for their products. Based on Apple’s forecast, sales representative will forecast the memory demand.

References:

http://robjhyndman.com/hyndsight/

https://hbr.org/1971/07/how-to-choose-the-right-forecasting-technique



Share
