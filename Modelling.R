library(forecast)
library(plotly)
library(tsoutliers)
source("modelling_function.R")
debug(modelling_function)

sales <- read.csv("SalesWithCRD_1.csv", header= TRUE)
sales <- sales[(sales$STATUS== "IN" & sales$DELIVERY_QTY_GB_EQUIVS>0),]

# trying to get the product_groups having all 31 months present
sales$SHIP_FISCAL_PERIOD_SORT <- as.factor(sales$SHIP_FISCAL_PERIOD_SORT)
sales_monthly <-aggregate(formula= DELIVERY_QTY_GBYTE_EQUIVS ~ SHIP_FISCAL_PERIOD_SORT+ PRODUCT_GROUP,data=sales,FUN=sum)
uniquecount(sales_monthly$PRODUCT_GROUP)
data <- cutoff30(sales_monthly$PRODUCT_GROUP)
sales_monthly <-sales_monthly[(sales_monthly$PRODUCT_GROUP %in% data$x ),]
sales_monthly$PRODUCT_GROUP <- as.factor(sales_monthly$PRODUCT_GROUP)
uniquecount(sales_monthly$PRODUCT_GROUP)

for(i in 1:2)
  {
    sales_new <- sales_monthly[which(sales_monthly$PRODUCT_GROUP == data$x[i]),]
    sales_new <- sales_new[order(sales_new$SHIP_FISCAL_PERIOD_SORT),]
    sales_new$SHIP_FISCAL_PERIOD_SORT <- NULL
    sales_new$PRODUCT_GROUP <- NULL
    
    #Calender month conversion based on Fiscal Calender basis
    myts <- ts(data= sales_new,start=c(2013,12), end=c(2016,07), frequency=12)
    time(myts)
    ce <- calendar.effects(myts,trading.day = TRUE)
    mytsTrain <- window(myts,end= 2015.833)
    mytsTest <- window(myts,start = 2015.917)
    forecastmonths = 3
    trainPoints= 24
    a1 <-modelling_function(mytsTrain,mytsTest,"arima",forecastmonths,trainPoints) #
    a2 <-modelling_function(mytsTrain,mytsTest,"ets",forecastmonths,trainPoints) #Simple Exponential Smoothing
    # a3 <-modelling_function(mytsTrain,mytsTest,"Mean",forecastmonths,trainPoints)
    # a4 <-modelling_function(mytsTrain,mytsTest,"Random Walk Forest",forecastmonths,trainPoints)
    # a5 <-modelling_function(mytsTrain,mytsTest,"Random Walk Forest with Drift",forecastmonths,trainPoints)
    # a6 <-modelling_function(mytsTrain,mytsTest,"Croston",forecastmonths,trainPoints)
    #a7 <-modelling_function(mytsTrain,mytsTest,"Spline",forecastmonths,trainPoints)
    a8 <-modelling_function(mytsTrain,mytsTest,"tbats",forecastmonths,trainPoints)
    #a1
    #a2
    #a3
    #a4
    #a5
    #a6
}
averageError <- sumval/nrow(data)
print(averageError)
averageError2 <- sumval2/nrow(data)
print(averageError2)
averageError3 <- sumval3/nrow(data)
print(averageError3)
# averageError8 <- sumval8/nrow(data)
# print(averageError8)

