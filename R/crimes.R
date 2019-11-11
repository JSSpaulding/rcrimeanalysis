#' Example data from the Chicago Data Portal
#'
#' A sample dataset of crime incidents in Chicago, IL from 2017-2019.
#'
#' @format A data frame with 25000 rows and 22 variables.
#' \describe{
#'   \item{id}{Unique identifier for the record.}
#'   \item{case_number}{The Chicago Police Department Records Division Number, which is unique to the incident.}
#'   \item{date}{Date when the incident occurred.}
#'   \item{block}{Partially redacted address where the incident occurred.}
#'   \item{iucr}{Illinois Unifrom Crime Reporting code (directly linked to primary_type and description)}
#'   \item{primary_type}{The primary description of the IUCR code.}
#'   \item{description}{The secondary description of the IUCR code, a subcategory of the primary description.}
#'   \item{location_description}{Description of the location where the incident occurred.}
#'   \item{arrest}{Indicates whether an arrest was made.}
#'   \item{domestic}{Indicates whether the incident was domestic-related as defined by the Illinois Domestic Violence Act.}
#'   \item{beat}{Indicates the police beat where the incident occurred.}
#'   \item{district}{Indicates the police district where the incident occurred.}
#'   \item{ward}{The ward (City Council district) where the incident occurred.}
#'   \item{community_area}{Indicates the community area where the incident occurred.}
#'   \item{fbi_code}{Indicates the National Incident-Based Reporting System (NIBRS) crime classification.}
#'   \item{x_coordinate}{X coordinate of the incident location (State Plane Illinois East NAD 1983 projection).}
#'   \item{y_coordinate}{Y coordinate of the incident location (State Plane Illinois East NAD 1983 projection).}
#'   \item{year}{Year the incident occurred.}
#'   \item{updated_on}{Date and time the record was last updated.}
#'   \item{latitude}{The latitude of the location where the incident occurred.}
#'   \item{longitude}{The longitude of the location where the incident occurred.}
#'   \item{location}{Concatenation of latitude and longitude.}
#' }
#'
#' @source \url{https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2/data}
"crimes"



