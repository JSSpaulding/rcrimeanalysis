## kde_int_comp
## Jamie Spaulding

#' Comparison of KDE Maps Across Specified Time Intervals
#' @description This function calculates and compares the kernel density estimate
#'     (heat maps) of crime incident locations from two given intervals. The
#'     function returns a net difference raster which illustrates net changes
#'     between the spatial crime distributions across the specified intervals.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param start1 Beginning date for the first interval of comparison
#' @param end1 Final date for the first interval of comparison
#' @param start2 Beginning date for the second interval of comparison
#' @param end2 Final date for the second interval of comparison
#' @return Returns a \emph{RasterLayer} object of the net differences between
#'     kernel density estimates (heat maps) of each specified interval.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial methods hplot
#' @examples
#' \donttest{
#' #Using provided dataset from Chicago Data Portal:
#' crimes <- rcrimeanalysis:::crimes
#' int_out <- kde_int_comp(crimes, start1="1/1/2017", end1="3/1/2017",
#'                                 start2="1/1/2018", end2="3/1/2018")
#' raster::plot(int_out) #plot of KDE differences
#' raster::hist(int_out) #histogram of plot level differences}
#' @importFrom graphics plot.new
#' @importFrom grDevices contourLines
#' @importFrom grDevices dev.off
#' @importFrom grDevices gray.colors
#' @importFrom grDevices png
#' @importFrom stats bw.nrd0
#' @importFrom KernSmooth bkde2D
#' @importFrom sp Polygons
#' @importFrom sp Polygon
#' @importFrom sp SpatialPolygons
#' @import raster
#' @import stats
#' @export
kde_int_comp <- function(data, start1, end1, start2, end2){
  # Date Transformation and Interval Creation -----
  data$date <- as.Date(data$date, "%m/%d/%Y %H:%M") #ensure column is in Date format
  interval1 <- subset(data, data$date >= as.Date(start1, "%m/%d/%Y") &
                        data$date <= as.Date(end1, "%m/%d/%Y"))
  interval2 <- subset(data, data$date >= as.Date(start2, "%m/%d/%Y") &
                        data$date <= as.Date(end2, "%m/%d/%Y"))

  # Interval 1 KDE Contours -----
  lat1 <- as.numeric(interval1$latitude)
  lon1 <- as.numeric(interval1$longitude)
  bwlat1 <- bw.nrd0(lat1) #calculate bandwidth (lat) for KDE function
  bwlon1 <- bw.nrd0(lon1) #calculate bandwidth (lon) for KDE function
  kde1 <- bkde2D(cbind(lon1, lat1), #KDE using calculated bandwidths
                 bandwidth=c(bwlon1, bwlat1), gridsize = c(100, 100))
  CL1 <- contourLines(kde1$x1, kde1$x2, kde1$fhat) #uses KDE to create contour lines
  LEVS1 <- as.factor(sapply(CL1, `[[`, "level")) #extract contour line levels
  NLEV1 <- length(levels(LEVS1)) #number of contour levels

  # Convert Contour Lines To Polygons -----
  pgons1 <- lapply(1:length(CL1), function(i)
    Polygons(list(Polygon(cbind(CL1[[i]]$x, CL1[[i]]$y))), ID = i))
  spgons1 = SpatialPolygons(pgons1)

  # Interval 2 KDE Contours -----
  lat2 <- as.numeric(interval2$latitude)
  lon2 <- as.numeric(interval2$longitude)
  bwlat2 <- bw.nrd0(lat2)
  bwlon2 <- bw.nrd0(lon2)
  kde2 <- bkde2D(cbind(lon2,lat2),
                 bandwidth = c(bwlon2, bwlat2), gridsize = c(100, 100))
  CL2 <- contourLines(kde2$x1 , kde2$x2 , kde2$fhat)
  LEVS2 <- as.factor(sapply(CL2, `[[`, "level"))
  NLEV2 <- length(levels(LEVS2))
  pgons2 <- lapply(1:length(CL2), function(i)
    Polygons(list(Polygon(cbind(CL2[[i]]$x, CL2[[i]]$y))), ID = i))
  spgons2 = SpatialPolygons(pgons2)

  # Create Raster of Each Heatmap Interval -----
  if(length(unique(LEVS1)) > length(unique(LEVS2))){
    grad <- gray.colors(length(unique(LEVS1)))
  } else(grad <- gray.colors(length(unique(LEVS2))))
  tmp <- tempfile()
  png(tmp, bg = "transparent")
  plot.new()
  plot(spgons1, stroke = TRUE, col = grad[LEVS1], border = grad[LEVS1])
  dev.off() #temp plot of spgons1
  tmp2 <- tempfile()
  png(tmp2, bg = "transparent")
  plot.new()
  plot(spgons2, stroke = TRUE, col = grad[LEVS2], border = grad[LEVS2])
  dev.off() #temp plot of spgons2

  # Net Difference Plot -----
  p1 <- raster(tmp) #read in tmp images as raster
  p2 <- raster(tmp2)
  diff <- p1 - p2 #diff between rasters
  return(diff)

}
