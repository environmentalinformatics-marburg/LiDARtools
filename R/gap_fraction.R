#' Calculate gap fraction from Canopy Height Models (chm)
#'
#' @description
#' Calculate gap fraction from chm Geotiffs derived in \code{\link{raster_query}}.
#'
#' @param dat_path path for the table output
#' @param chm_path path to the chm rasters created in \code{\link{raster_query}}
#' @param gap_hght threshold that defines maximum height of vegetation within a gap
#' @param gap_sze minimum number of connected pixel, that are interpreted as a gap
#'
#' @return RData file containing a data.frame called "gap_structure_<sidelength of raster>"
#'
#' @name gap_fraction
#'
#' @export gap_fraction
#'
#' @details NONE
#'
#' @references
#'
#' @seealso NONE
#'
#' @aliases gap_fraction
#'
#' @examples
#' \dontrun{
#' #Not run
#' }

########################################################################################
########################################################################################
gap_fraction <- function(dat_path, chm_path, gap_hght = 10, gap_sze = 9){
  require(raster)
  require(rgdal)
  chm_lst <- list.files(chm_path)
  gap_frac_all <- lapply(chm_lst, function(i){
    chm <- raster::raster(paste0(chm_path, i))
    raster::values(chm)[raster::values(chm) < gap_hght] <- NA
    raster::values(chm)[is.finite(raster::values(chm))] <- 0
    raster::values(chm)[is.na(raster::values(chm))] <- 1
    clmp <- raster::clump(chm, directions = 8, gaps = F)
    frq<-raster::as.data.frame(raster::freq(clmp))
    excludeID <- frq$value[which(frq$count <= gap_sze)]
    sieve <- clmp
    sieve[values(clmp) %in% excludeID] <- NA
    total_count <- length(raster::values(sieve))
    clear_count <- sum(is.finite(raster::values(sieve)))
    cover_count <- sum(is.na(raster::values(sieve)))
    gap_frac_plt <- clear_count / total_count
    return(list(substr(i,1,4), gap_frac_plt))
  })
  gap_frac <- raster::as.data.frame(do.call(rbind, gap_frac_all))
  colnames(gap_frac) <- c("plotID", "gap_frac")
  for (i in 1:ncol(gap_frac)) {
    gap_frac[, i] <- unlist(gap_frac[, i])
  }
  save(gap_frac, file = paste0(dat_path, "gap_structure.RData"))
}


