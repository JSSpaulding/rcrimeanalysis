## geocode_address
## Jamie S Spaulding

#' Batch Geocoding of Physical Addresses using the Google Maps API
#' @description Geocodes a location (determines latitude and longitude from
#'     physical address) using the Google Maps API. Note that the Google Maps
#'     API requires registered credentials (Google Cloud Platform), see the
#'     ggmap package for more details at \url{https://github.com/dkahle/ggmap}.
#'     Note that when using this function you are agreeing to the Google Maps
#'     API Terms of Service at \url{https://developers.google.com/maps/terms}.
#' @param location a character vector of physical addresses (e.g. 1600 University Ave., Morgantown, WV)
#' @return Returns a two column matrix with the latitude and longitude of each location queried.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial
#' @examples
#' \dontshow{
#' library(ggmap) #needed to register Google Cloud Credentials
#' register_google("AIzaSyB29FxQZBTC3K8kVOG29KZJPvjbFVDhRFU")
#' addresses <- c("Milan Puskar Stadium, Morgantown, WV","Woodburn Hall, Morgantown, WV")
#' geocode_address(addresses)}
#' \donttest{
#' library(ggmap) #needed to register Google Cloud Credentials
#' register_google("**Google Cloud Credentials Here**")
#' addresses <- c("Milan Puskar Stadium, Morgantown, WV","Woodburn Hall, Morgantown, WV")
#' geocode_address(addresses)}
#'
#' @importFrom ggmap geocode
#' @export
geocode_address <- function(location){
  out <- geocode(location)
  return(out)
}
