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
#' @return Returns a \emph{shiny.tag.list} object which contains three leaflet
#'     widgets: a widget with the calculated KDE from interval 1, a widget with
#'     the calculated KDE from interval 2, and a widget with a raster of the
#'     net differences between the KDE (heat maps) of each specified interval.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial methods hplot dynamic
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' int_out <- kde_int_comp(crimes, start1="1/1/2017", end1="3/1/2017",
#'                                 start2="1/1/2018", end2="3/1/2018")
#' @import rgdal
#' @import leaflet
#' @importFrom graphics plot.new
#' @importFrom grDevices contourLines
#' @importFrom grDevices dev.off
#' @importFrom grDevices gray.colors
#' @importFrom grDevices png
#' @importFrom htmltools tags
#' @importFrom KernSmooth bkde2D
#' @importFrom leafsync sync
#' @importFrom pals parula
#' @importFrom raster crs
#' @importFrom raster plot
#' @importFrom raster raster
#' @importFrom raster values
#' @importFrom sp Polygons
#' @importFrom sp Polygon
#' @importFrom sp SpatialPolygons
#' @importFrom stats bw.nrd0
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
  bwlat1 <- stats::bw.nrd0(lat1) #calculate bandwidth (lat) for KDE function
  bwlon1 <- stats::bw.nrd0(lon1) #calculate bandwidth (lon) for KDE function
  kde1 <- KernSmooth::bkde2D(cbind(lon1, lat1), #KDE using calculated bandwidths
                             bandwidth=c(bwlon1, bwlat1), gridsize = c(100, 100))
  CL1 <- grDevices::contourLines(kde1$x1, kde1$x2, kde1$fhat) #uses KDE to create contour lines
  LEVS1 <- as.factor(sapply(CL1, `[[`, "level")) #extract contour line levels
  NLEV1 <- length(levels(LEVS1)) #number of contour levels

  # Convert Contour Lines To Polygons -----
  pgons1 <- lapply(1:length(CL1), function(i)
    sp::Polygons(list(sp::Polygon(cbind(CL1[[i]]$x, CL1[[i]]$y))), ID = i))
  spgons1 = sp::SpatialPolygons(pgons1)

  # KDE Map 1 -----
  title1 <- htmltools::tags$p(htmltools::tags$style("p {color: black; font-size:18px}"),
                                htmltools::tags$b(paste("Interval 1:", start1, "-", end1)))

  map1 <- leaflet::leaflet(data) %>% leaflet::addProviderTiles(leaflet::providers$Esri.NatGeoWorldMap) %>%
    leaflet::addScaleBar(position = "bottomright") %>%
    leaflet::addControl(title1, position = "topright" ) %>%
    leaflet::addPolygons(data = spgons1, color = grDevices::heat.colors(NLEV1, NULL)[LEVS1])

  # Interval 2 KDE Contours -----
  lat2 <- as.numeric(interval2$latitude)
  lon2 <- as.numeric(interval2$longitude)
  bwlat2 <- bw.nrd0(lat2)
  bwlon2 <- bw.nrd0(lon2)
  kde2 <- KernSmooth::bkde2D(cbind(lon2,lat2),
                             bandwidth = c(bwlon2, bwlat2), gridsize = c(100, 100))
  CL2 <- grDevices::contourLines(kde2$x1 , kde2$x2 , kde2$fhat)
  LEVS2 <- as.factor(sapply(CL2, `[[`, "level"))
  NLEV2 <- length(levels(LEVS2))
  pgons2 <- lapply(1:length(CL2), function(i)
    sp::Polygons(list(sp::Polygon(cbind(CL2[[i]]$x, CL2[[i]]$y))), ID = i))
  spgons2 = sp::SpatialPolygons(pgons2)

  # KDE Map 2 -----
  title2 <- htmltools::tags$p(htmltools::tags$style("p {color: black; font-size:18px}"),
                              htmltools::tags$b(paste("Interval 2:", start2, "-", end2)))

  map2 <- leaflet::leaflet(data) %>% leaflet::addProviderTiles(leaflet::providers$Esri.NatGeoWorldMap) %>%
    leaflet::addScaleBar(position = "bottomright") %>%
    leaflet::addControl(title2, position = "topright" ) %>%
    leaflet::addPolygons(data = spgons2, color = grDevices::heat.colors(NLEV2, NULL)[LEVS2])

  # Create Raster of Each Heatmap Interval -----
  if(length(unique(LEVS1)) > length(unique(LEVS2))){
    grad <- grDevices::gray.colors(length(unique(LEVS1)))
  } else(grad <- grDevices::gray.colors(length(unique(LEVS2))))
  tmp <- tempfile()
  grDevices::png(tmp, bg = "transparent")
  graphics::plot.new()
  raster::plot(spgons1, col = grad[LEVS1], border = grad[LEVS1])
  grDevices::dev.off() #temp plot of spgons1
  tmp2 <- tempfile()
  grDevices::png(tmp2, bg = "transparent")
  graphics::plot.new()
  raster::plot(spgons2, col = grad[LEVS2], border = grad[LEVS2])
  grDevices::dev.off() #temp plot of spgons2

  # Net Difference Plot -----
  p1 <- raster::raster(tmp) #read in tmp images as raster
  p2 <- raster::raster(tmp2)
  diff <- p1 - p2 #diff between rasters
  diff@extent@xmin <- min(map2$x$limits$lng)
  diff@extent@xmax <- max(map2$x$limits$lng)
  diff@extent@ymin <- min(map2$x$limits$lat)
  diff@extent@ymax <- max(map2$x$limits$lat)
  raster::crs(diff) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  raster::plot(diff)
  options(warn = -1)
  pal <- colorNumeric(pals::parula(200), raster::values(diff),
                      na.color = "transparent")
  diff_map <- leaflet::leaflet(data) %>% leaflet::addProviderTiles(leaflet::providers$Esri.NatGeoWorldMap) %>%
    leaflet::addScaleBar(position = "bottomright") %>%
    leaflet::addRasterImage(diff, colors = pal, opacity = 0.8 , project = TRUE) %>%
    leaflet::addLegend(pal = pal, values = raster::values(diff), title = 'Net Difference')
  diff_plot <- leafsync::sync(map1, map2, diff_map)
  return(diff_plot)

}
