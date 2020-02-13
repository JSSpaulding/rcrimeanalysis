## ts_daily_decomp
## Jamie Spaulding

#' Time Series Forecast and Decomposition for Daily Crime Data
#' @description This function transforms daily crime count data and plots the
#'     resultant components of a time series which has been decomposed into
#'     seasonal, trend, and irregular components using Loess smoothing. Holt
#'     Winters exponential smoothing is also performed for inproved trend
#'     resolution since data is in a daily format.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param start Start date for the time series being analyzed. The format is as
#'     follows: c('year', 'month', 'day'). See example below for reference.
#' @return Returns an object of class "stl" with the following components:
#'
#' time.series: a multiple time series with columns seasonal, trend and remainder.
#'
#' weights: the final robust weights (all one if fitting is not done robustly).
#'
#' call: the matched call.
#'
#' win: integer (length 3 vector) with the spans used for the "s", "t", and "l" smoothers.
#'
#' deg: integer (length 3) vector with the polynomial degrees for these smoothers.
#'
#' jump: integer (length 3) vector with the 'jumps' (skips) used for these smoothers.
#'
#' inner: number of inner iterations
#' @author Jamie Spaulding, Keith Morris
#' @keywords ts
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' test <- ts_daily_decomp(data = crimes, start = c(2017, 1, 1))
#' plot(test)
#' @importFrom lubridate parse_date_time
#' @importFrom stats HoltWinters
#' @importFrom stats stl
#' @importFrom stats ts
#' @export
ts_daily_decomp <- function(data, start){
  data$date <- as.Date(data$date, "%m/%d/%Y %H:%M")
  dates <- unique(data$date) #get unique dates
  z <- as.data.frame(table(data$date))
  z$Var1 <- lubridate::parse_date_time(z$Var1, orders = "%Y-%m-%d") #parses an z into POSIXct date-time object
  z$Var1 <- z[order(as.Date(z$Var1)),] #order by date
  dat <- z[,1]
  dataseries <- stats::ts(dat$Freq, frequency=365, start=c(start,1)) #frequency=12 months, specify start date and that data is monthly (2001,1)

  ## Decomposition -----
  ds_decomposed <- stats::stl(dataseries, "per") #plot decomposed times series

  ## Holt winters Exponsntial Smoothing of Seasonality -----
  tssmooth <- stats::HoltWinters(ds_decomposed$time.series[,1], beta=FALSE, gamma=FALSE)
  ds_decomposed$time.series[2:nrow(ds_decomposed$time.series),1] <- tssmooth$fitted[,1]
  return(ds_decomposed)
}
