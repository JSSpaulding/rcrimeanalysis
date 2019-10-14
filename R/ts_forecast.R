## ts_forecast
## Jamie Spaulding

#' Time Series Forecast for Daily Crime Data
#' @description This function transforms traditional crime data for forecasting
#'     using the \pkg{prophet} procedure for forecasting time series data with
#'     an additive model where non-linear trends are fit with yearly, weekly,
#'     and daily seasonality. The function generates the forecast for a one
#'     year period with a confidence interval based on historical crime data.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @return Returns a plot which contains: the time series, a fitted confidence
#'     interval, the projected forecast, and the confidence interval for that
#'     forcast.
#' @author Jamie Spaulding, Keith Morris
#' @keywords ts
#' @examples
#' \donttest{
#' #Using provided dataset from Chicago Data Portal:
#' crimes <- rcrimeanalysis:::crimes
#' library(prophet)
#' ts_forecast(crimes)}
#' @importFrom graphics plot
#' @importFrom stats predict
#' @import dplyr
#' @import prophet
#' @import Rcpp
#' @export
ts_forecast <- function(data){
  data$date <- as.Date(data$date, "%m/%d/%Y")
  date_mod <- format(as.Date(data$date), "%Y-%m-%d") #ADD Month/Year Column
  dates <- unique(data$date) #get unique dates
  z <- as.data.frame(table(date_mod)) #frequency per day
  colnames(z) <- c("ds", "y")

  # Forecast with Daily Data -----
  m <- prophet(z,daily.seasonality=TRUE) #performs fitting and returns a model object
  future <- make_future_dataframe(m, periods = 365) #produce suitable dataframe
  forecast <- predict(m, future)  #forecast
  fcast <- plot(m, forecast, xlabel = "Date", ylabel = "Number of Incidents") #plot the forecast
  return(fcast)
}
