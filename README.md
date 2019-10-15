# rcrimeanalysis: An Implementation of Crime Analysis Tools for R

<!-- badges: start -->
[![Build 
Status](https://travis-ci.org/JSSpaulding/rcrimeanalysis.svg?branch=master)](https://travis-ci.org/JSSpaulding/rcrimeanalysis)
<!-- badges: end -->

## Overview

**rcrimeanalysis** is a package containing various functions for the analysis of crime incident or records management system (RMS) data. The package implements analysis algorithms scaled for city or regional crime analysis units including kernel density estimation for crime heat maps, geocoding using the Google Maps API, spatio-temporal map comparison across time intervals, time series analysis (forecasting and decomposition), and near repeat analysis (with crime network linkage). The package also contains an example dataset of Chicago crime incident data. The incidents were acquired from the [Chicago Data Portal](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2). From these data, the set was subset to 25000 incidents of various primary types from 2017 to 2019.

**Keywords**: Crime Analysis, Geographic Information Systems (GIS), Spatio-Temporal, Near Repeat Analysis, Open Source

## Getting Started

These instructions will allow any user to install the R package on your local machine for development and testing purposes. 

### Installing

Begin by installing the package from the GitHub repository:

```
devtools::install_github('JSSpaulding/rcrimeanalysis')
```

After installation, load and attach the package

```
library(rcrimeanalysis)
```

The following will call the example Chicago Data Portal crime incident data from the package. Inspection of the data is crucial because the package functions are designed for use of this data structure.

```
crimes <- data.frame(rcrimeanalysis:::crimes)
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

### kde_int_comp

The *kde_int_comp* function calculates and compares the kernel density estimate (heat maps) of crime incident locations from two given intervals. The function returns a net difference raster illustrating changes between the spatial crime distributions across the specified intervals for comparion. This is also useful in identifying crime displacement.

```
crimes <- rcrimeanalysis:::crimes
int_out <- kde_int_comp(crimes, start1="1/1/2017", end1="3/1/2017",
                                start2="1/1/2018", end2="3/1/2018")
raster::plot(int_out) #plot of KDE differences
raster::hist(int_out) #histogram of plot level differences}
```

### kde_map

The *kde_map* function computes a kernel density estimate of crime incident locations and returns a **Leaflet** map of the incidents. The input data structure is based on the Chicago Police Department RMS (example data) and populates pop-up windows with the incident location for each incident. The resultant map has three layers: an ESRI base-map, all crime incidents plotted (with incident info pop-up windows), and a kernel density estimate of those points.

```
crimes <- rcrimeanalysis:::crimes
library(leaflet) # needed to install basemap providers
kde_map(crimes)
```

### near_repeat_analysis

The **near_repeat_analysis** function performs near repeat analysis on a set of incident locations. The user specifies distance and time thresholds which are utilized to search all other incidents and find other incidents within these parameters. The function returns a list of all identified near repeat series within the input data as **igraph** graph objects. The output list can be used to render linkage plots of each series and to discern the near repeat linkages between the crime incidents. The function extends traditional near repeat analysis to also provide linkages which identify potential series of incidents. Note that this function is dependent on the memory of the system, it may be necessary to subset datasets prior to use. 

```
crimes <- data.frame(rcrimeanalysis:::crimes)
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

### ts_daily_decomp

The **ts_daily_decomp** function plots the components of forecast generated using the **prophet** algorithm which includes the overall crime trend and the daily, weekly, and yearly seasonality components. This is valuable to understand changes in crime frequency over time for policy evaluation, tactical effectiveness, and detection of potential influx of organized crime activities.

```
crimes <- rcrimeanalysis:::crimes
library(prophet)
ts_daily_decomp(crimes)
```

### ts_forecast

The **ts_forecast** function transforms traditional crime data for forecasting using the **prophet** procedure for forecasting time series data with an additive model where non-linear trends are fit with yearly, weekly, and daily seasonality. The function generates the forecast for a one year period with a confidence interval based on historical crime data. Such a prediciton is useful for administrative planning and allocation of resources. 

```
crimes <- rcrimeanalysis:::crimes
library(prophet)
ts_forecast(crimes)
```

### ts_monthly_decomp

The **ts_monthly_decomp** function transforms traditional crime data and plots the resultant components of a time series which has been decomposed into seasonal, trend and irregular components using Loess smoothing.

```
crimes <- rcrimeanalysis:::crimes
test <- ts_month_decomp(crimes, 2017)
plot(test)
```

## Built With

* [ggmap](https://github.com/dkahle/ggmap) - Integration of Google Maps API
* [igraph](https://igraph.org/r/) - Package used for plotting near repeat network series
* [prophet](https://github.com/facebook/prophet) - Forecasting algorithm for *ts* data


## Authors

* **Jamie Spaulding** - *Author, Contributor*

* **Keith Morris** - *Contributor*
