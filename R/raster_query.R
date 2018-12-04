#' Query Raster from database and write them into file
#'
#' @description
#' Query Raster from database and write them into GTiff file
#'
#' @param dat_path path for the table output
#' @param d_rst diameter (=sidelength) for raster query in m
#' @param db_layers vector of database layer names for wich the query should be made.
#' @param db adress of the database (default = "http://192.168.191.183:8081")
#' @param db_login string of username and password for the database (default = "username:password")
#' @param group_name name of the group in the database
#' @param rst_type vector of the raster layers that should be derived from database ()
#' @param location data.frame with at least 3 columns with the column names "plotID", "xpnt" and "y_pnt".
#' @param pnts_path filename of the rds created in \code{\link{points_query}}
#'
#' @return One Geotiff per location
#'
#' @name raster_query
#'
#' @export raster_query
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
raster_query <- function(dat_path, d_rst = 50,
                         db_layers = c("kili_campaign1_lidar_classified_2015", "kili_campaign2_lidar_classified_2016"),
                         db = "http://137.248.191.215:8081",
                         db_login,
                         group_name = "kili_poi_plots",
                         rst_type = c("chm"), location = NA){
  library(rPointDB)
  library(raster)
  remotesensing <- RemoteSensing$new(db, db_login)
  if(missing(location)){
    # get one POI group
    location <- remotesensing$poi_group(group_name=group_name)
    colnames(location) <- c("plotID", "x_pnt","y_pnt")
  }
  rst_all_lay <- lapply(db_layers, function(i){
    pointdb <- remotesensing$lidar(i)
    rst_lay <- lapply(location$plotID, function(j){
      poi <- remotesensing$poi(group_name = group_name, poi_name = j)
      ext <- ext <- extent_diameter(x = poi$x, y = poi$y, d = d_rst)
      for (k in rst_type){
        rst <- pointdb$query_raster(ext = ext, type = k)
        if (all(is.na(rst@data@values)) == FALSE){
          dir.create(paste0(dat_path, "raster_db_", d_rst, "m/", k, "/"), showWarnings = F, recursive = T)
          writeRaster(rst, filename = paste0(dat_path, "raster_db_", d_rst, "m/", k, "/", j, "_", i, "_",
                                             d_rst, ".tif"), format = "GTiff",
                      overwrite = T)
        }
      }
    })
  })
}

