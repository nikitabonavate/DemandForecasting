# create time series object for delivery qty based on the timeperiod
createTimeSeriesObject <- function(joint)
{
  joint$CUSTOMER_REQUEST_DATE <- as.factor(joint$CUSTOMER_REQUEST_DATE)
  jointnew <-aggregate(formula= DELIVERY_QTY_GB_EQUIVS ~ CUSTOMER_REQUEST_DATE,data=joint,FUN=sum)
  jointnew  <- jointnew [order(jointnew $CUSTOMER_REQUEST_DATE),]
  jointnew$DELIVERY_QTY_GB_EQUIVS <- jointnew$DELIVERY_QTY_GB_EQUIVS
  jointnew$CUSTOMER_REQUEST_DATE =NULL
  return (jointnew)
}

#create time series object for delivery qty for every product group 
createTimeSeries <- function(sales)
{
  sales <- sales [sales$STATUS == "IN",]
  sales_monthly <-aggregate(formula= DELIVERY_QTY_GBYTE_EQUIVS ~ SHIP_FISCAL_PERIOD_SORT+ PRODUCT_GROUP,data=sales,FUN=sum)
  sales_monthly <- sales_monthly[order(sales_monthly$SHIP_FISCAL_PERIOD_SORT),]
  sales_monthly$SHIP_FISCAL_PERIOD_SORT <- NULL
  return (sales_monthly)
}

# run the model,generate the forecast for requested forecastmonths
modelling_function <- function(train,test,methodName,forecastmonths,T)
{
  #scale the data
  train <- log(train) # Converting into million dollars scale
  #lambdaParam <- BoxCox.lambda(train)
  #ts.plot(train)
  if(methodName == "arima")
    {
      ce <- calendar.effects(train,trading.day = TRUE)
      fit1 <- auto.arima(train,xreg = ce)
      p<- arimaorder(fit1)
      train.p <- p[1]
      train.d <- p[2]
      train.q <- p[3]
      fit1
      #Acf(residuals(fit1)) # if everything falls inside blue lines, means the noise is random
      #hist(residuals(fit1),100)
      l= min(10,T/5)
      Box.test(residuals(fit1), lag=l, fitdf=l-train.p-train.q, type="Ljung") #lag= 10 as its non-seasonal data if p value is less than 0.05 it means that residuals are not random
      
      print(fit1$aic)      
      outlierResult <-tso(train, cval = NULL, delta = 0.7, n.start = 50,
          types = c("AO", "LS", "TC"), 
          maxit = 1, maxit.iloop = 4, cval.reduce = 0.14286, 
          remove.method = "en-masse",
          remove.cval = NULL, 
          tsmethod = "auto.arima", 
          args.tsmethod = list(xreg= ce))
      print(outlierResult$fit$aic)
      forecast<-forecast(outlierResult$fit,xreg= outlierResult$fit$xreg,h=forecastmonths)
    }
  else if (methodName == "ets")
  {
    fit <- ets(train)
    #Acf(residuals(fit)) # if everything falls inside blue lines, means the noise is random
    #hist(residuals(fit),100)
    l= min(10,T/5)
    Box.test(residuals(fit), lag=l, fitdf=4, type="Ljung")
    forecast <- forecast(fit,h=forecastmonths)
  } 
  else if (methodName == "Mean")
  {
        forecast <- meanf(train,h=forecastmonths)
  }
  else if (methodName == "Random Walk Forest")
  {
    forecast <- rwf(train,h=forecastmonths)
  }
  else if (methodName == "Random Walk Forest with Drift")
  {
    forecast <- rwf(train,h=forecastmonths,drift = TRUE)
  }
  else if (methodName == "Croston")
  {
    forecast <- croston(train,h=forecastmonths,alpha = 0.1)
  }
  else if (methodName == "Spline")
  {
    forecast <- splinef(train)
  }
  else if (methodName == "tbats")
  {
    fo <- tbats(train)
    forecast <- forecast(fo)
  }
 plot.forecast(forecast)
 result <- exp(as.data.frame(forecast$mean))
 testerror <- (abs(mytsTest-result$x)/abs(mytsTest))*100
 return(testerror)
}

#plot the graph
group_data_level<- function(listis1,listis2,graphName1,graphName2,xaxis,yaxis,print =TRUE)
{
  result <- do.call("aggregate", args= listis1)
  colnames(result) <- c('l1','q1')
  result <- head(result[order(-result$q1),],25)
  x <- list(title = xaxis)
  y <- list(title = yaxis)
  p<-plot_ly(
    x= result$l1,
    y= result$q1,
    name= graphName1,
    type ="bar") %>%
    layout(xaxis = x, yaxis = y)
  
  if (!is.null(listis2))
  {
    result2 <- do.call("aggregate", args= listis2)
    colnames(result2) <- c('l2','q2')
    result2 <- head(result2[order(result2$l2),],20)
    p <- add_trace(
      p,
      x= result2$l2,
      y= result2$q2,
      name= graphName2,
      type ="bar") 
    p
  }
  p
}
# Number of Unique observations of specific column
uniquecount <-function(x, print= TRUE)
{
  col1 <-data.frame(table(x))
  col1[order(col1$Freq),] 
}

#return the values having frequency greater than 30
cutoff30 <- function(x,print =TRUE)
{
  col1 <-data.frame(table(x))
  nrow(col1[(col1$Freq>30),])
  col1 <- col1[(col1$Freq>30),]
}

Contact GitHub 
