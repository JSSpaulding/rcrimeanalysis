## ts_month_decomp
## Jamie Spaulding

#' Time Series Decomposition for Monthly Crime Data
#' @description This function transforms traditional crime data and plots the
#'     resultant components of a time series which has been decomposed into
#'     seasonal, trend and irregular components using Loess smoothing.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param start The year in which the time series data starts. The time series
#'     is assumed to be composed of solely monthly count data
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
#' test <- ts_month_decomp(crimes, 2017)
#' plot(test)
#' @importFrom lubridate parse_date_time
#' @importFrom stats stl
#' @importFrom stats ts
#' @export
ts_month_decomp <- function(data,start){
  ## Transform Data into Time Series ----
  data$date <- as.Date(data$date, "%m/%d/%Y")
  data$my <- format(as.Date(data$date), "%m/%Y") #Add Month/Year Column
  dates <- unique(data$my) #get unique dates
  z <- as.data.frame(table(data$my))
  z$Var1 <- lubridate::parse_date_time(z$Var1, orders = "%m/%Y") #parses an z into POSIXct date-time object
  z$Var1 <- z[order(as.Date(z$Var1)),] #order by date
  dat <- z[,1]
  dataseries <- stats::ts(dat$Freq, frequency=12, start=c(start,1)) #frequency=12 months, specify start date and that data is monthly (2001,1)

  ## Decomposition -----
  ds_decomposed <- stats::stl(dataseries, "per") #plot decomposed times series
  return(ds_decomposed)
}
