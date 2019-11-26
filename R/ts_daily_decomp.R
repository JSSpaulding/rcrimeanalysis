## ts_daily_decomp
## Jamie Spaulding

#' Time Series Forecast and Decomposition for Daily Crime Data
#' @description Plot the components of forecast generated using the \pkg{prophet}
#'     which includes the overall crime trend and the daily, weekly, and yearly
#'     seasonality components. Holt Winters exponential smoothing is also
#'     performed to the seasonality component for inproved trend resolution since
#'     the data is in a daily format.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param start Start date for the time series being analyzed. The format is as
#'     follows: c('year', 'month', 'day'). See example below for reference.
#' @return Returns a list of four plots: the overall crime trend with forecast;
#'     the daily seasonality; the weekly seasonality; and the yearly seasonality
#'     components.
#' @author Jamie Spaulding, Keith Morris
#' @keywords ts
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' test <- ts_month_decomp(data = crimes, start = c(2017, 1, 1))
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
