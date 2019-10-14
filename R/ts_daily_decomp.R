## ts_daily_decomp
## Jamie Spaulding

#' Time Series Forecast and Decomposition for Daily Crime Data
#' @description Plot the components of forecast generated using the \pkg{prophet}
#'     which includes the overall crime trend and the daily, weekly, and yearly
#'     seasonality components.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @return Returns a list of four plots: the overall crime trend with forecast;
#'     the daily seasonality; the weekly seasonality; and the yearly seasonality
#'     components.
#' @author Jamie Spaulding, Keith Morris
#' @keywords ts
#' @examples
#' \donttest{
#' #Using provided dataset from Chicago Data Portal:
#' crimes <- rcrimeanalysis:::crimes
#' library(prophet)
#' ts_daily_decomp(crimes)}
#' @importFrom stats predict
#' @import dplyr
#' @import prophet
#' @import Rcpp
#' @export
ts_daily_decomp <- function(data){
  data$date <- as.Date(data$date, "%m/%d/%Y")
  date_mod <- format(as.Date(data$date), "%Y-%m-%d") #Add Month/Year Column
  dates <- unique(data$date) #get unique dates
  z <- as.data.frame(table(date_mod)) #frequency per day
  colnames(z) <- c("ds", "y")

  # Forecast with Daily Data -----
  m <- prophet(z,daily.seasonality=TRUE) #performs fitting and returns a model object
  future <- make_future_dataframe(m, periods = 365) #produce suitable dataframe
  forecast <- stats::predict(m, future)  #forecast

  # Forecast Broken into Trend, Daily, Weekly, and Yearly seasonality -----
  p_decomp <- prophet_plot_components(m, forecast)
  return(p_decomp)
}
