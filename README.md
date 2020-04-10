# rcrimeanalysis: An Implementation of Crime Analysis Methods <a><img src='../master/images/rcrimeanalysis-hex.png' align="right" height="139" /></a>

<!-- badges: start -->
![CRAN Version](https://www.r-pkg.org/badges/version-ago/rcrimeanalysis)
![CRAN Downloads](https://cranlogs.r-pkg.org/badges/last-month/rcrimeanalysis)
![Build Status](https://travis-ci.org/JSSpaulding/rcrimeanalysis.svg?branch=master)
<!-- badges: end -->

## Overview

**rcrimeanalysis** is a package containing various functions for the analysis of crime incident or records management system (RMS) data. The package implements analysis algorithms scaled for city or regional crime analysis units including kernel density estimation for crime heat maps, geocoding using the 'Google Maps' API, identification of repeat crime incidents, spatio-temporal map comparison across time intervals, time series analysis (forecasting and decomposition), detection of optimal parameters for the identification of near repeat incidents, and near repeat analysis with crime network linkage. The package also contains an example dataset of Chicago crime incident data. The incidents were acquired from the [Chicago Data Portal](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2). From these data, the set was subset to 25000 incidents of various primary types from 2017 to 2019.

**Keywords**: Crime Analysis, Geographic Information Systems (GIS), Spatio-Temporal, Near Repeat Analysis, Open Source

## Getting Started

These instructions will allow any user to install the R package on your local machine for development and testing purposes. 

### Installing

Begin by installing the package from either CRAN or the GitHub repo:

```
install.packages('rcrimeanalysis') #CRAN version
devtools::install_github('JSSpaulding/rcrimeanalysis') #Dev version
```

After installation, load and attach the package

```
library(rcrimeanalysis)
```

The following will call the example Chicago Data Portal crime incident data from the package. Inspection of the data is crucial because the package functions are designed for use of this data structure.

```
data(crimes)
```

## Usage

The following examples illustrate the usage of the functions within the **rcrimeanalysis** package.

### geocode_address

The *geocode_address* function leverages the utilities of the **ggmap** package for the batch geocoding of physical addresses. Geocoding is an essential element of crime analysis where locations are converted into grid coordinates for mapping and other analysis. Note that this function uses the Google Maps API which requires Google Cloud Credentials (available at [https://cloud.google.com/maps-platform/](https://cloud.google.com/maps-platform/). Also see the [ggmap package](https://github.com/dkahle/ggmap) for details.

```
library(ggmap)
register_google("**Google Cloud Credentials Here**")
addresses <- c("Milan Puskar Stadium, Morgantown, WV","Woodburn Hall, Morgantown, WV")
test1 <- geocode_address(addresses)

```

### id_repeat
This function identifies crime incidents which occur at the same location and returns a list of such incidents where each data frame in the list contains the RMS data for the repeat crime incidents. The data is based on the Chicago Police Department RMS structure.

```
repeat_out <- id_repeat(crimes)
repeat_out[[1]] #prints first repeat crime incident table
```

### kde_int_comp

The *kde_int_comp* function calculates and compares the kernel density estimate (heat maps) of crime incident locations from two given intervals. The function returns a net difference raster illustrating changes between the spatial crime distributions across the specified intervals for comparion. This is also useful in identifying crime displacement. Additionally, a shiny.tag.list object which contains three leaflet widgets: a widget with the calculated KDE from interval 1, a widget with the calculated KDE from interval 2, and a widget with a raster of the net differences between the KDE (heat maps) of each specified interval is returned for interactive visualization of the results. The net difference object utilizes an implementation of the parula color pallete for optimal visualization.

```
int_out <- kde_int_comp(crimes, start1="1/1/2017", end1="3/1/2017",
                                start2="1/1/2018", end2="3/1/2018")
int_out
```

An example of the shiny.tag.list object is given below for the above example.

<a><img src='../master/images/kde-interval1.PNG' align="center" height="400" /></a>

### kde_map

The *kde_map* function computes a kernel density estimate of crime incident locations and returns a **Leaflet** map of the incidents. The input data structure is based on the Chicago Police Department RMS (example data) and populates pop-up windows with the incident location for each incident. The resultant map has three layers: an ESRI base-map, all crime incidents plotted (with incident info pop-up windows), and a kernel density estimate of those points. The user can also specify the 'pts' parameter which controls whether the crime incidents are plotted.

```
library(leaflet) #needed to install basemap providers
library(leafsync) #creates plot of both maps
crime_sample <- head(crimes, n = 1000)
# Plot without Points
p1 <- crime_sample %>% kde_map(pts = FALSE)
# Plot with Incident Points
p2 <- crime_sample %>% kde_map()
leafsync::sync(p1,p2)
```

An example of the resultant map is given below. A zoomed in portion is also shown (right) to illustrate the incident data pop-up. 

<a><img src='../master/images/kde-map1.png' align="center" height="400" /></a>

### near_repeat_analysis

The **near_repeat_analysis** function performs near repeat analysis on a set of incident locations. The user specifies distance and time thresholds which are utilized to search all other incidents and find other incidents within these parameters. The function returns a list of all identified near repeat series within the input data as **igraph** graph objects. The output list can be used to render linkage plots of each series and to discern the near repeat linkages between the crime incidents. The function extends traditional near repeat analysis to also provide linkages which identify potential series of incidents. Note that this function is dependent on the memory of the system, it may be necessary to subset datasets prior to use. 

```
nr_data <- head(crimes, n = 5000) #truncate dataset for near repeat analysis
out <- near_repeat_analysis(data = nr_data, tz = "America/Chicago", epsg = "32616")
path <- paste0(getwd(), "/netout") #path for iGraph networks out
name <- 1
# Save Image of Each igraph Network to Netpath Directory
library(igraph)
for(i in out){
    png(file = paste(path, "/series", name, ".png", sep = ""))
    plot(i, layout = layout_with_lgl, edge.color="orange",
    vertex.color = "orange", vertex.frame.color = "#ffffff",
    vertex.label.color = "black")
    dev.off()
    name <- name + 1
}
```

### near_repeat_eval
This function performs an evaluation of given crime incidents to reccomend parameters for near repeat analysis. A series of time and distance parameters are tested using a full factorial design using the set of incident locations to determine the frequency of occurrence given each set of parameters. The results of the full factorial assessment are then modeled through interpolation and the second derivative is calculated to determine the inflection point. The inflection point represents the change in frequency of detected incidents which near repeat. Determination of the inflection point is completed for both the time and distance domains.

```
data(crimes)
nr_dat <- subset(crimes, crimes$primary_type == "BURGLARY")
pars <- near_repeat_eval(data=nr_dat, tz="America/Chicago", epsg="32616")
pars
```

### ts_daily_decomp

The **ts_daily_decomp** function transforms daily crime count data and plots the resultant components of a time series which has been decomposed into seasonal, trend, and irregular components using Loess smoothing. Holt Winters exponential smoothing is also performed for inproved trend resolution since data is in a daily format. This is valuable to understand changes in crime frequency over time for policy evaluation, tactical effectiveness, and detection of potential influx of organized crime activities.

```
test <- ts_daily_decomp(crimes, start = c(2017, 1, 1))
plot(test)
```

### ts_forecast

The **ts_forecast** function transforms traditional crime data into a time series and forecasts future incident counts based on the input data over a specified duration. The forecast is computed using simple exponential smoothing with additive errors. Returned is a plot of the time series, trend, and the upper and lower prediction limits for the forecast. Such a prediciton is useful for administrative planning and allocation of resources. 

```
library(prophet)
ts_forecast(crimes, start = c(2017, 1, 1))
```

An example forecast plot is given below for the above example.

<a><img src='../master/images/ts-forecast.png' align="center" height="500" /></a>


### ts_monthly_decomp

The **ts_monthly_decomp** function transforms traditional crime data and plots the resultant components of a time series which has been decomposed into seasonal, trend and irregular components using Loess smoothing.

```
test <- ts_month_decomp(crimes, 2017)
plot(test)
```

An example decomposition plot is given below for homicides from the *crimes* dataset.

<a><img src='../master/images/homicide-ts.png' align="center" height="500" /></a>

## Built With

* [ggmap](https://github.com/dkahle/ggmap) - Integration of Google Maps API
* [igraph](https://igraph.org/r/) - Package used for plotting near repeat network series
* [leaflet](https://github.com/Leaflet/Leaflet) - JavaScript library for mobile-friendly interactive maps


## Authors

* **Jamie Spaulding** - *Author, Contributor*

* **Keith Morris** - *Contributor*
