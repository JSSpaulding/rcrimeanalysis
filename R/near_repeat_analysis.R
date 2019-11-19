## near_repeat_analysis
## Jamie Spaulding

#' Near Repeat Analysis of Crime Incidents with Crime Linkage Output
#' @description This function performs near repeat analysis for a set of incident
#'     locations. The user specifies distance and time thresholds which are utilized
#'     to search all other incidents and find other near repeat incidents. From this
#'     an adjacency matrix is created for incidents which are related under the
#'     thresholds. The adjacency matrix is then used to create an igraph graph which
#'     illustrates potentially related or linked incidents (under the near repeat
#'     thresholds).
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param epsg The EPSG Geodetic Parameter code for the area being considered.
#'     The EPSG code is used for identifying projections and performing coordinate
#'     transformations. If needed, the EPSG for an area can be found at
#'     \url{https://spatialreference.org}.
#' @param dist_thresh The spatial distance (in meters) which defines a near repeat
#'     incident. By default this value is set to 1000 meters.
#' @param time_thresh The temporal distance (in days) which defines a near repeat
#'     incident. By default this value is set to 7 days.
#' @param tz Time zone for which the area being examined. By default this value
#'     is assigned as the same time zone of the system. For more information
#'     about time zones within R, see \url{https://www.rdocumentation.org/packages/base/versions/3.6.1/topics/timezones}.
#' @return Returns a list of all near repeat series identified within the input
#'     data as \pkg{igraph} graph objects. This list can be used to generate plots
#'     of each series and to discern the near repeat linkages between the crime
#'     incidents.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial
#' @examples
#' data(crimes)
#' nr_data <- head(crimes, n = 1000) #truncate dataset for near repeat analysis
#' out <- near_repeat_analysis(data=nr_data,tz="America/Chicago",epsg="32616")
#'
#' @importFrom sp SpatialPoints
#' @importFrom sp CRS
#' @importFrom sp spTransform
#' @importFrom igraph graph_from_adjacency_matrix
#' @importFrom igraph components
#' @importFrom stats complete.cases
#' @importFrom stats dist
#' @export
near_repeat_analysis <- function(data, epsg, dist_thresh=NULL, time_thresh=NULL, tz=NULL){
  # Set Defaults -----
  if (is.null(tz)) {tz <- Sys.timezone(location = TRUE)} #default: system location
  if (is.null(dist_thresh)) {dist_thresh <- 1000} #default: 1000 meters
  if (is.null(time_thresh)) {time_thresh <- 7} #default: 7 days
  crs <- paste0("+init=epsg:", as.character(epsg))

  # Date Formats -----
  data$datetime <- as.POSIXct(data$date, tz = tz, "%m/%d/%Y %H:%M") #date-time object
  data$date <- as.Date(data$date, "%m/%d/%Y %H:%M") #ensure date column is in Date format
  crime <- data[stats::complete.cases(data), ] #only complete cases
  cord.dec = sp::SpatialPoints(cbind(crime$longitude, crime$latitude),
                               proj4string = sp::CRS("+proj=longlat")) #object of spatial points class

  # Transform Coordinates to UTM using EPSG -----
  cord.UTM <- sp::spTransform(cord.dec, sp::CRS(crs)) #(lat,lon) to coordinate system in EPSG
  coordsout <- as.data.frame(cord.UTM@coords) #makes df of coordinates
  crime$x1 <- coordsout$coords.x1 #bind coordinate 1 to crime data
  crime$x2 <- coordsout$coords.x2 #bind coordinate 2 to crime data

  # Near Repeat Analysis using Threshold Parameters -----
  SpatDist <- as.matrix(stats::dist(crime[,c('x1','x2')])) < dist_thresh  #1 if under distance
  TimeDist <- as.matrix(stats::dist(crime$date)) < time_thresh #1 if incident under time
  AdjMat <- SpatDist * TimeDist #under both distance and under time
  row.names(AdjMat) <- crime$case_number #case numbers for labels in igraph
  colnames(AdjMat) <- crime$case_number #case numbers for labels in igraph

  # igraph network from adjacency matrix -----
  G <- igraph::graph_from_adjacency_matrix(AdjMat, mode="undirected", diag = FALSE)
  CompInfo <- igraph::components(G) #assigning the connected components
  out <- data.frame(CompId=CompInfo$membership, CompNum=CompInfo$csize[CompInfo$membership])
  out <- out[out$CompNum!=1, ] #remove any series consisting of 1 incident
  #NOTES for `out':
  #The CompId field is a unique Id for every string of events
  #The CompNum field states how many events are within the string

  # Create iGraph for Each Near Repeat Series -----
  datalist <- split(out , f = out$CompId) #create list of each identified series
  nr_out <- NULL
  jj <- 1
  for (i in datalist) {
    cases <- rownames(i) #get case numbers of series
    a <- crime[crime$case_number %in% cases,] #incident information of case numbers
    SpatDist <- as.matrix(stats::dist(a[,c('x1', 'x2')])) < dist_thresh
    TimeDist <- as.matrix(stats::dist(a$date)) < time_thresh
    AdjMat <- SpatDist * TimeDist
    row.names(AdjMat) <- a$case_number
    colnames(AdjMat) <- a$case_number
    #create network of cases from each series
    nr_out[[jj]] <- igraph::graph_from_adjacency_matrix(AdjMat, mode="undirected", diag = FALSE)
    jj <- jj+1
  }
  return(nr_out)
}
