## near_repeat_eval
## Jamie Spaulding

#' Identification of Optimal Time and Distance Parameters for Near Repeat Analysis
#' @description This function performs an evaluation of given crime incidents to
#'     reccomend parameters for near repeat analysis. A series of time and distance
#'     parameters are tested using a full factorial design using the set of
#'     incident locations to determine the frequency of occurrence given each
#'     set of parameters. The results of the full factorial assessment are then
#'     modeled through interpolation and the second derivative is calculated to
#'     determine the inflection point. The inflection point represents the
#'     change in frequency of detected incidents which near repeat. Determination
#'     of the inflection point is completed for both the time and distance domains.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param epsg The EPSG Geodetic Parameter code for the area being considered.
#'     The EPSG code is used for identifying projections and performing coordinate
#'     transformations. If needed, the EPSG for an area can be found at
#'     \url{https://spatialreference.org}.
#' @param tz Time zone for which the area being examined. By default this value
#'     is assigned as the same time zone of the system. For more information
#'     about time zones within R, see \url{https://www.rdocumentation.org/packages/base/versions/3.6.1/topics/timezones}.
#' @return Returns a data frame with one instance (row) of two fields (columns).
#'     The fields are: distance and time. The instance indicates the optimal
#'     near repeat parameters for each. Note that distance is given in meters
#'     and time is given as days.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial
#' @examples
#' \dontshow{
#' data(crimes)
#' nr_dat <- head(subset(crimes, crimes$primary_type == "BURGLARY"), n = 100)
#' pars <- near_repeat_eval(data=nr_dat, tz="America/Chicago", epsg="32616")
#' }
#' \donttest{
#' data(crimes)
#' nr_dat <- subset(crimes, crimes$primary_type == "BURGLARY")
#' pars <- near_repeat_eval(data=nr_dat, tz="America/Chicago", epsg="32616")
#' pars
#' }
#' @importFrom igraph graph_from_adjacency_matrix
#' @importFrom igraph components
#' @importFrom sp SpatialPoints
#' @importFrom sp CRS
#' @importFrom sp spTransform
#' @importFrom stats approx
#' @importFrom stats complete.cases
#' @importFrom stats dist
#' @importFrom utils txtProgressBar
#' @importFrom utils setTxtProgressBar
#' @export
near_repeat_eval <- function(data, epsg, tz=NULL){
  # Set Run Sequence of Parameters to Evaluate -----
  day_interval <- c(0, 0.25, 0.5, 1, 2, 3, 4, 5, 6, 7, 10, 14, 21, 28, 180, 365)
  dist_interval <- c(0, 1, 5, 10, 50, 100, 250, 500, 750, 1000, 2000, 5000)
  run_seq <- expand.grid(day_interval,dist_interval)
  names(run_seq) <- c("TimeThresh", "DistThresh")

  # Set Defaults -----
  if (is.null(tz)) {tz <- Sys.timezone(location = TRUE)} #default: system location
  crs <- paste0("+init=epsg:", as.character(epsg))

  # Date Formats -----
  data$datetime <- as.POSIXct(data$date, tz = tz, "%m/%d/%Y %H:%M") #date-time object
  data$date <- as.Date(data$date, "%m/%d/%Y %H:%M") #ensure date column is in Date format
  crime <- data[stats::complete.cases(data), ] #only complete cases

  # Parameter Evaluation -----
  series_num <- NULL
  jj <- 1
  pb = utils::txtProgressBar(min = 0, max = nrow(run_seq), initial = 0, style = 3)
  for(i in 1:nrow(run_seq)) {
    utils::setTxtProgressBar(pb,i)
    a <- run_seq[i,]
    DistThresh <- a[,1]
    TimeThresh <- a[,2]
    cord.dec = sp::SpatialPoints(cbind(crime$longitude, crime$latitude),
                               proj4string = sp::CRS("+proj=longlat"))

    # Transform Coordinates to UTM using EPSG -----
    cord.UTM <- sp::spTransform(cord.dec, sp::CRS(crs)) #(lat,lon) to coordinate
    coordsout <- as.data.frame(cord.UTM@coords) #makes df of coordinates
    crime$x1 <- coordsout$coords.x1 #bind coordinate 1 to crime data
    crime$x2 <- coordsout$coords.x2 #bind coordinate 2 to crime data

    # Near Repeat Analysis using Threshold Parameters -----
    SpatDist <- as.matrix(stats::dist(crime[,c('x1','x2')])) < DistThresh
    TimeDist <- as.matrix(stats::dist(crime$date)) < TimeThresh
    AdjMat <- SpatDist * TimeDist #under both distance and under time
    row.names(AdjMat) <- crime$case_number #case numbers for labels in igraph
    colnames(AdjMat) <- crime$case_number #case numbers for labels in igraph

    # igraph network from adjacency matrix -----
    G <- igraph::graph_from_adjacency_matrix(AdjMat, mode="undirected", diag = FALSE)
    CompInfo <- igraph::components(G) #assigning the connected components
    out <- data.frame(CompId=CompInfo$membership, CompNum=CompInfo$csize[CompInfo$membership])
    out <- out[out$CompNum!=1, ] #remove any series consisting of 1 incident
    series_num[jj] <- nrow(out)
    jj <- jj+1
  }

  eval_out <- cbind(run_seq,series_num)

  # Interpolate Evaluation Results -----
  x1_interp <- stats::approx(eval_out$TimeThresh, eval_out$series_num, ties = mean)
  datx1 <- data.frame(x1 = x1_interp[[1]], y = x1_interp[[2]])

  x2_interp <- stats::approx(eval_out$DistThresh, eval_out$series_num, ties = mean)
  datx2 <- data.frame(x2 = x2_interp[[1]], y = x2_interp[[2]])

  # Calculate Time First Derivative -----
  dy <- NULL
  dx <- NULL
  for (i in 2:nrow(datx1)) {
    dy[i] <- datx1$y[i] - datx1$y[i - 1]
    dx[i] <- datx1$x1[i] - datx1$x1[i - 1]
  }
  first <- dy/dx
  datx1.1 <- data.frame(x = datx1$x1, y = first)

  # Calculate Time Second Derivative -----
  datx1.1[1,2] <- 0
  dy2 <- NULL
  dx2 <- NULL
  for (i in 2:nrow(datx1.1)) {
    dy2[i] <- datx1.1$y[i] - datx1.1$y[i - 1]
    dx2[i] <- datx1.1$x[i] - datx1.1$x[i - 1]
  }
  second <- dy2/dx2

  data <- data.frame(x = datx1.1$x, y = second)
  time_out <- floor(data[which.min(data$y),1]) #Optimal Distance Parameter

  # Calculate Distance First Derivative -----
  dy <- NULL
  dx <- NULL
  for (i in 2:nrow(datx2)) {
    dy[i] <- datx2$y[i] - datx2$y[i - 1]
    dx[i] <- datx2$x2[i] - datx2$x2[i - 1]
  }
  first <- dy/dx
  datx2.1 <- data.frame(x = datx2$x2, y = first)

  # Calculate Distance Second Derivative -----
  datx2.1[1,2] <- 0
  dy2 <- NULL
  dx2 <- NULL
  for (i in 2:nrow(datx2.1)) {
    dy2[i] <- datx2.1$y[i] - datx2.1$y[i - 1]
    dx2[i] <- datx2.1$x[i] - datx2.1$x[i - 1]
  }
  second <- dy2/dx2
  data2 <- data.frame(x = datx2.1$x, y = second)
  dist_out <- floor(data2[which.min(data2$y),1]) #Optimal Dist Parameter

  results <- data.frame(distance = dist_out, time = time_out)
  return(results)
}
