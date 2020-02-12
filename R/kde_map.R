## kde_map
## Jamie Spaulding

#' Kernel Density Estimation and Heat Map Generation for Crime Incidents
#' @description This function computes a kernel density estimate of crime
#'     incident locations and returns a 'Leaflet' map of the incidents. The data
#'     is based on the Chicago Police Department RMS structure and populates
#'     pop-up windows with the incident location for each incident.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @param pts Either true or false. Dictates whether the incident points will
#'     be plotted on the map widget. If \code{NULL}, the default value is \code{TRUE}.
#' @return A \pkg{Leaflet} map with three layers: an 'ESRI' base-map, all crime
#'     incidents plotted (with incident info pop-up windows), and a kernel
#'     density estimate of those points.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial methods hplot dynamic
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' crimes <- head(crimes, 1000)
#' library('leaflet') # needed to install basemap providers
#' kde_map(crimes)
#' @importFrom grDevices contourLines
#' @importFrom grDevices heat.colors
#' @importFrom KernSmooth bkde2D
#' @importFrom sp Polygons
#' @importFrom sp Polygon
#' @importFrom sp SpatialPolygons
#' @importFrom stats bw.nrd0
#' @import leaflet
#' @import htmltools
#' @export
kde_map <- function(data, pts = NULL){
  if (is.null(pts)) {pts <- TRUE}
  if (!is.logical(pts)) {
    stop("pts must be specified as boolean: TRUE or FALSE")
  }
  lat <- as.numeric(data$latitude)
  lon <- as.numeric(data$longitude)
  bwlat <- stats::bw.nrd0(lat) #calculate bandwidth (lat) for KDE function
  bwlon <- stats::bw.nrd0(lon) #calculate bandwidth (lon) for KDE function
  kde <- KernSmooth::bkde2D(cbind(lon, lat), # calculates the KDE using calculated bandwidths
                            bandwidth=c(bwlon, bwlat), gridsize = c(100, 100))
  CL <- grDevices::contourLines(kde$x1 , kde$x2 , kde$fhat) #uses KDE to create contour lines

  # Extract Contour Line Levels -----
  LEVS <- as.factor(sapply(CL, `[[`, "level"))
  NLEV <- length(levels(LEVS))

  # Convert Contour Lines To Polygons -----
  pgons <- lapply(1:length(CL), function(i)
    sp::Polygons(list(sp::Polygon(cbind(CL[[i]]$x, CL[[i]]$y))), ID = i))
  spgons = sp::SpatialPolygons(pgons)
  if (isTRUE(pts)){
    map <- leaflet::leaflet(data) %>% leaflet::addProviderTiles(leaflet::providers$Esri.NatGeoWorldMap) %>%
      leaflet::addScaleBar(position = "bottomright") %>%
      leaflet::addPolygons(data = spgons, color = grDevices::heat.colors(NLEV, NULL)[LEVS]) %>%
      leaflet::addCircles(lon, lat, popup = paste("Case Number:", data$case_number, "<br/>"
                                                  ,"Description:", data$description, "<br/>"
                                                  ,"District:", data$district, "<br/>"
                                                  ,"Beat:", data$beat, "<br/>"
                                                  ,"Date:", data$date), color ="purple")
  } else {
    map <- leaflet::leaflet(data) %>% leaflet::addProviderTiles(leaflet::providers$Esri.NatGeoWorldMap) %>%
      leaflet::addScaleBar(position = "bottomright") %>%
      leaflet::addPolygons(data = spgons, color = grDevices::heat.colors(NLEV, NULL)[LEVS])
  }
  return(map)
}
