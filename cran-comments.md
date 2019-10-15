## Test environments
* local Windows 10 install, R 3.6.1
* ubuntu 16.04 (on travis-ci), R 3.6.1

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* checking R code for possible problems ... NOTE

  kde_map: no visible binding for global variable 'providers'
  Undefined global functions or variables: providers
  
  'providers' is defined within the 'leaflet' package. The 
  example uses an ESRI basemap from the imported leaflet package.
