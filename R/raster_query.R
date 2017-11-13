# Description: 
# Author: Alice Ziegler
# Date: 2017-10-17 09:01:15

########################################################################################
###Documentation
########################################################################################

########################################################################################
########################################################################################
raster_query <- function(dat_path, d_rst = 50, db_layers = c("kili", "kili2"), db = "http://192.168.191.183:8081", 
                         db_login = "user:password", group_name = "kili", rst_type = c("chm"), location){
  library(rPointDB)
  library(raster)
  remotesensing <- RemoteSensing$new(db, db_login)
  rst_all_lay <- lapply(db_layers, function(i){
    pointdb <- remotesensing$lidar(i)
    rst_lay <- lapply(location$plotID, function(j){
      poi <- remotesensing$poi(group_name = group_name, poi_name = j)
      ext <- ext <- extent_diameter(x = poi$x, y = poi$y, d = d_rst)
      for (k in rst_type){
        rst <- pointdb$query_raster(ext = ext, type = k)
        if (all(is.na(rst@data@values)) == FALSE){
          dir.create(paste0(dat_path, "raster_db_", d_rst, "m/", k, "/"), showWarnings = F, recursive = T)
          writeRaster(rst, filename = paste0(dat_path, "raster_db_", d_rst, "m/", k, "/", j, "_", i, "_", d_rst, ".tif"), format = "GTiff", 
                      overwrite = T)
        }
      }
    })
  })
}

