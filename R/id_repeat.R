## id_repeat
## Jamie Spaulding

#' Identify Repeat Crime Incidents
#' @description This function identifies crime incidents which occur at the same
#'     location and returns a list of such incidents where each data frame in
#'     the list contains the RMS data for the repeat crime incidents. The data
#'     is based on the Chicago Police Department RMS structure.
#' @param data Data frame of crime or RMS data. See provided Chicago Data Portal
#'     example for reference
#' @return A list where each data frame contains repeat crime incidents for a
#'     given location.
#' @author Jamie Spaulding, Keith Morris
#' @keywords spatial
#' @examples
#' #Using provided dataset from Chicago Data Portal:
#' data(crimes)
#' crimes <- head(crimes, n = 1000)
#' out <- id_repeat(crimes)
#' @export
id_repeat <- function(data){
  n_occur <- data.frame(table(data$block))
  out <- n_occur[n_occur$Freq > 1,]
  r_list <- NULL
  jj <- 1
  for(i in out[,1]){
    r_list[[jj]] <- subset(data, data$block==i)
    jj <- jj+1
  }
  return(r_list)
}
