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
#' @name var_merge
#'
#' @export var_merge
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

# var_merge <- function(dat_path, lst_vars_path){
#   for (i in 1:length(lst_vars_path)){
#     tmp <- get(load(paste0(dat_path,lst_vars_path[i],".RData")))
#     if(i==1){
#       mrg_tbl <- tmp
#     }else{
#       mrg_tbl <- merge(mrg_tbl,tmp,by.x=c("plotID","plotUnq"),by.y=c("plotID","plotUnq"))
#     }
#   }
#   save(mrg_tbl, file = paste0(dat_path, "dat_ldr_mrg.RData"))
# }
#
var_merge <- function(dat_path, lst_vars_path, descr, mrg_col){
  for (i in 1:length(lst_vars_path)){
    tmp <- readRDS(paste0(dat_path,lst_vars_path[i],".rds"))
    if(i==1){
      res <- tmp
    }else{
      res <- merge(res,tmp,by.x=mrg_col,by.y=mrg_col)
      mrg_tbl <- res
    }
  }
  saveRDS(mrg_tbl, file = paste0(dat_path, descr, "_mrg", ".rds"))
  return(mrg_tbl)
}
