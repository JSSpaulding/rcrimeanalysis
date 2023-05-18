# rcrimeanalysis (Development Version)

* Development version has no changes from 0.4.3.

# rcrimeanalysis 0.5.0

* Removed package dependency on `rgdal` functionality. `rgdal` set to be archived Oct. 2023. `near_repeat_analysis()` and `near_repeat_eval()` were changed to depend on 'terra' for gdal integration. 

* Vignettes updated.

# rcrimeanalysis 0.4.2

* Added /vignettes with examples of package functionality.

* Added NEWS.md for entire package history.

* Added hex sticker for package.

# rcrimeanalysis 0.4.1

* Added `near_repeat_eval()` function to accompany `near_repeat_analysis()`. The function determines the ideal parameters to use for near repeat analysis given a full factorial assessment of spatio-temporal clustering in the provided dataset.

# rcrimeanalysis 0.4.0

* Update of `ts_daily_decomp()`, `ts_monthly_decomp()`, and `ts_forecast()` to remove `Prophet` dependency. These functions now utilize Seasonal Decomposition Of Time Series By Loess Smoothing functionality to decompose and forecast of the input time series

# rcrimeanalysis 0.3.1

* Example correction for `geocode_address()` with minor bug fixes.

# rcrimeanalysis 0.3.0

* `id_repeat()` function added to detect repeat crime incidents based on location. Outputs a list of repeat crimes by location.

* Change `kde_int_comp()` output from static raster to interactive leafsync widget with three maps for overall better results visualization. 

* Added the 'pts' parameter to `kde_map()` which specifies whether crime incident points are to be included in the rendered KDE crime map. Default parameter setting is `pts = TRUE`.

# rcrimeanalysis 0.2.0

* Update `geocode_address()` with API fix.

* Update README.md and overall package descriptions.

# rcrimeanalysis 0.1.0

* Initial CRAN Version. 

FUNCTIONS IN INITAL VERSION

* `geocode_address()`

* `kde_int_comp()`

* `kde_map()`

* `near_repeat_analysis()`

* `ts_daily_decomp()`

* `ts_monthly_decomp()`

* `ts_forecast()`
