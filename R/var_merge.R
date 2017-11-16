#' Merge tables with plotbased information
#'
#' @description
#' Merge tables with plotbased information
#'
#' @param dat_path path for the table output
#' @param lst_vars_path all file names without "ending".RData" within dat_pat that should be merged
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
#' @examples
#' \dontrun{
#' #Not run
#' }
########################################################################################
########################################################################################

var_merge <- function(dat_path, lst_vars_path){
  for (i in 1:length(lst_vars_path)){
   tmp <- get(load(paste0(dat_path,lst_vars_path[i],".RData")))
    if(i==1){
    mrg_tbl <- tmp
    }else{
      mrg_tbl <- merge(mrg_tbl,tmp,by.x="plotID",by.y="plotID")
    }
  }
  save(mrg_tbl, file = paste0(dat_path, "dat_ldr_mrg", ".RData"))
  }

