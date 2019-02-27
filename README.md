# MATLAB Time Series Forecast Calculator
This is a simple time series forecasting calculator for making first-cut forecasts of accounting data.

-----------------------------------------------------------------------------------------------------------------
To use this function, you might collect accounting data from a financial model in Excel. These data could be Revenue,
Cost of Goods Sold, or other major recurring items. Using MATLAB [Spreadsheet Link](https://www.mathworks.com/products/excellink.html), these data could be imported as
named variables into an instance of MATLAB.

Within MATLAB this function can be used to produce first-cut forecasts of these major financial model value drivers.

Example function call syntax could be,

```
Forecast(RevenueEW,2);
```

or

```
ForecastSimple(RevenueEW,2);
```

where, depending on the version of the function used, you can produce an output consisting of historical- and
projected data, or just the projected data, rounded to 1 decimal place, as you see fit. The full version of the
function presents projected data in unrounded form, while the simple version rounds.

-----------------------------------------------------------------------------------------------------------------

![](Images/Forecast(RevenueEW,2).png)

What is time series forecasting? Time series forecasting is a method of predicting the behavior of regular
time series data. These data are characterized by being able to be collected at a regular interval, such that
they're assumed to be evenly spaced in time, and they're also expected to consist of seasonality and a general trend.

In the classical models of time series forecasting, seasonality can take either an additive or multiplicative form.
These methods use moving averages coupled with a seasonality term describing the characteristic level of
additive or multiplicative variation about the moving average trend of the data.

The idea behind time series forecasting is that we can extract from the historical time series data, elements
of a multiplicative or additive model that describes the interaction between the different components of the signal.

In the multiplicative model, using a moving average, we can extract the centered moving average of the data.
By dividing each matching element of data by the centered moving average, we can calculate for the seasonality.

Using the calculated seasonality terms for each quarter, we can deseasonalize the data provided, then extract the trend
component of the time series using linear regression. Finally, the forecasted data consist of the row-wise
multiplication of the seasonality vector times the trend vector. Historically the actual data are kept,
while into the future, the projected data are appended to the matrix.

Finally this last vector is output as either the combined historical- and projected data row- or column vector, 
or as simply a projected data vector, in our case, depending on the version of the function used. Here, horizontal data
will be re-converted to horizontal form, but the calculations are performed using a matrix of column vectors.

(The additive model makes use of a very similar technique, where seasonality is taken to consist of the values
of the actual data minus the trend, and then having projected the trend forward, the projected time series is
taken to consist of the trend term plus the additive seasonalities, corresponding to each quarter in our case.)
