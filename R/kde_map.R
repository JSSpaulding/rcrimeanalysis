## kde_map
## Jamie Spaulding

#' Kernel Density Estimation and Heat Map Generation for Crime Incidents
#' @description This function computes a kernel density estimate of crime
#'     incident locations and returns a Leaflet map of the incidents. The data
#'     is based on the Chicago Police Department RMS structure and populates
#'     pop-up windows with the incident location for each incident.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @return A \pkg{Leaflet} map with three layers: an ESRI base-map, all crime
#'     incidents plotted (with incident info pop-up windows), and a kernel
#'     density estimate of those points.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial methods hplot dynamic
#' @examples
#' \donttest{
#' #Using provided dataset from Chicago Data Portal:
#' crimes <- rcrimeanalysis:::crimes
#' library("leaflet") # needed to install basemap providers
#' kde_map(crimes)}
#' @importFrom grDevices contourLines
#' @importFrom grDevices heat.colors
#' @importFrom stats bw.nrd0
#' @importFrom KernSmooth bkde2D
#' @importFrom sp Polygons
#' @importFrom sp Polygon
#' @importFrom sp SpatialPolygons
#' @import leaflet
#' @import htmltools
#' @import stats
#' @export
kde_map <- function(data){
  lat <- as.numeric(data$latitude)
  lon <- as.numeric(data$longitude)
  bwlat <- bw.nrd0(lat) #calculate bandwidth (lat) for KDE function
  bwlon <- bw.nrd0(lon) #calculate bandwidth (lon) for KDE function
  kde <- bkde2D(cbind(lon, lat), # calculates the KDE using calculated bandwidths
                bandwidth=c(bwlon, bwlat), gridsize = c(100, 100))
  CL <- contourLines(kde$x1 , kde$x2 , kde$fhat) #uses KDE to create contour lines

  # Extract Contour Line Levels -----
  LEVS <- as.factor(sapply(CL, `[[`, "level"))
  NLEV <- length(levels(LEVS))

  # Convert Contour Lines To Polygons -----
  pgons <- lapply(1:length(CL), function(i)
    Polygons(list(Polygon(cbind(CL[[i]]$x, CL[[i]]$y))), ID = i))
  spgons = SpatialPolygons(pgons)
  map <- leaflet(data) %>% addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
        addScaleBar(position = "bottomright") %>%
        addPolygons(data = spgons, color = heat.colors(NLEV, NULL)[LEVS]) %>%
        addCircles(lon, lat, popup = paste("Case Number:", data$case_number, "<br/>"
                                          ,"Description:", data$description, "<br/>"
                                          ,"District:", data$district, "<br/>"
                                          ,"Beat:", data$beat, "<br/>"
                                          ,"Date:", data$date), color ="purple")
  return(map)
}
