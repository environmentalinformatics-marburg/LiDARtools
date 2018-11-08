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
#' @return rds file containing a data.frame called "gap_structure_<sidelength of raster>"
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
gap_fraction <- function(dat_path, chm_path, gap_hght, gap_sze){
  require(raster)
  require(rgdal)
  chm_lst <- list.files(chm_path)
  gap_frac_all <- lapply(chm_lst, function(i){
    chm <-raster(paste0(chm_path, i))
    values(chm)[values(chm) < gap_hght] <- NA
    values(chm)[is.finite(values(chm))] <- 0
    values(chm)[is.na(values(chm))] <- 1
    clmp <- clump(chm, directions = 8, gaps = F)
    frq<-as.data.frame(freq(clmp))
    excludeID <- frq$value[which(frq$count <= gap_sze)]
    sieve <- clmp
    #sieve[clmp %in% excludeID] <- NA
    #sieve[excludeID %in% clmp] <- NA
    sieve[values(clmp) %in% excludeID] <- NA
    total_count <- length(values(sieve))
    clear_count <- sum(is.finite(values(sieve)))
    cover_count <- sum(is.na(values(sieve)))
    gap_frac_plt <- clear_count / total_count
    plotID <- substr(i,1,4)
    plotUnq <- paste0(strsplit(i, "_")[[1]][1:6], collapse = "_")
    return(list(plotID, plotUnq, gap_frac_plt))
  })
  gap_frac <- as.data.frame(do.call(rbind, gap_frac_all))
  colnames(gap_frac) <- c("plotID", "plotUnq", "gap_frac")
  for (i in 1:ncol(gap_frac)) {
    gap_frac[, i] <- unlist(gap_frac[, i])
  }
  saveRDS(gap_frac, file = paste0(dat_path, "gap_structure.rds"))
}


