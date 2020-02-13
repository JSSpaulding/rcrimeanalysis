## ts_forecast
## Jamie Spaulding

#' Time Series Forecast for Daily Crime Data
#' @description This function transforms traditional crime data into a time
#'     series and forecasts future incident counts based on the input data
#'     over a specified duration. The forecast is computed using simple exponential
#'     smoothing with additive errors. Returned is a plot of the time series, trend,
#'     and the upper and lower prediction limits for the forecast.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param start Start date for the time series being analyzed. The format is as
#'     follows: c('year', 'month', 'day'). See example below for reference.
#' @param duration Number of days for the forecast. If \code{NULL}, the default
#'     duration for the forecast is 365 days.
#' @return Returns a plot of the time series entered (black), a forecast over the
#'     specified duration (blue), the exponentially smoothed trend for both the
#'     input data (red) and forecast (orange), and the upper and lower bounds for
#'     the prediction interval (grey).
#' @author Jamie Spaulding, Keith Morris
#' @keywords ts
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' ts_forecast(crimes, start = c(2017, 1, 1))
#' @importFrom graphics plot
#' @importFrom graphics lines
#' @importFrom grDevices dev.control
#' @importFrom grDevices pdf
#' @importFrom grDevices recordPlot
#' @importFrom forecast forecast
#' @importFrom lubridate parse_date_time
#' @importFrom graphics plot
#' @importFrom stats HoltWinters
#' @importFrom stats ts
#' @export
ts_forecast <- function(data, start, duration = NULL){
  if (is.null(duration)) {duration <- 365} #default forecast is one year
  data$date <- as.Date(data$date, "%m/%d/%Y %H:%M")
  dates <- unique(data$date) #get unique dates
  z <- as.data.frame(table(data$date))
  z$Var1 <- lubridate::parse_date_time(z$Var1, orders = "%Y-%m-%d") #parses an z into POSIXct date-time object
  z$Var1 <- z[order(as.Date(z$Var1)), ] #order by date
  dat <- z[ ,1]
  dataseries <- stats::ts(dat$Freq, frequency = 365, start = c(start, 1))
  yr_fcast <- forecast::forecast(dataseries, duration) #forecast over duration

  ## Holt winters Exponential Smoothing of Time Series and Forecast -----
  tssmooth <- stats::HoltWinters(yr_fcast$fitted, beta = FALSE, gamma = FALSE)
  fcastsmooth <- stats::HoltWinters(yr_fcast$mean, beta = FALSE, gamma = FALSE)

  ## Plot Result -----
  grDevices::pdf(NULL)
  grDevices::dev.control(displaylist = "enable")
  graphics::plot(forecast::forecast(dataseries, 365))
  graphics::lines(tssmooth$fitted[ ,1], col = "red")
  graphics::lines(fcastsmooth$fitted[,1], col = "orange")
  fcast <- grDevices::recordPlot()
  invisible(grDevices::dev.off())
  return(fcast)
}
