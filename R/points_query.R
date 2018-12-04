#' Query LiDAR points from database and write them into table
#' ###TEst change
#'
#' @description
#' Query LiDAR points from database and write them into table by landuse. x-, y-coordinates, intensity and height.
#'
#' @param dat_path path for the table output
#' @param r_pnts points within this radius from locations (in meter) will be taken into account (default = 10)
#' @param db_layers vector of database layer names for wich the query should be made.
#' @param db adress of the database (default = "http://192.168.191.183:8081")
#' @param db_login string of username and password for the database (default = "username:password")
#' @param location data.frame with at least 3 columns with the column names "plotID", "xpnt" and "y_pnt".
#'
#' @return  file containing a data.frame called "pnts"
#'
#' @name points_query
#'
#' @export points_query
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
#'
points_query <- function( dat_path, r_pnts,
                          db_layers = c("kili_campaign1_lidar_classified_2015",
                                        "kili_campaign2_lidar_classified_2016"),
                          group_name = "kili_poi_plots",
                          location = NA,
                          db = "http://137.248.191.215:8081",
                          db_login){
  #dat_path <- "C:/Users/Alice/Uni/Projekte/Kili/data/dez18/LiDAR/"
  #login_file <- "C:/Users/Alice/Uni/Projekte/Kili/data/.remote_sensing_userpwd.txt"
  #db_login <- readChar(login_file, file.info(login_file)$size) # optional read account from file"
  library(rPointDB)
  library(dplyr)
  remotesensing <- RemoteSensing$new(db, db_login)
  if(missing(location)){
    # get one POI group
    location <- remotesensing$poi_group(group_name=group_name)
    colnames(location) <- c("plotID", "x_pnt","y_pnt")
  }
  points_all_lay <- lapply(db_layers, function(i){
    #i <- "kili_campaign1_lidar_classified_2015"
    pointdb <- remotesensing$lidar(i)
    points_lay <- lapply(location$plotID, function(j){
      # extent <- extent_radius(x = location$x_pnt[j], y = location$y_pnt[j], r = r_pnts) ###need if location is set with coordinates
      extent <- extent_radius(x = location$x_pnt[which(location$plotID == j)], y = location$y_pnt[which(location$plotID == j)], r = r_pnts)
      points <- pointdb$query(ext = extent, normalise = "ground")
      if (nrow(points)!= 0){
        points$plotID <- j
        points$layer <- i
      }
      return(points)
    })
    points_lay_bnd <- do.call(rbind, points_lay)
  })
  points_all <- do.call(rbind, points_all_lay)
  rm(points_all_lay)

  plt_min <- setNames(aggregate(z ~ plotID, points_all, min), c("plotID", "h_min"))
  pnts <- left_join(points_all, plt_min, by = "plotID")
  rm(points_all)
  pnts$h_rel <- pnts$z-pnts$h_min
  pnts$landuse <- substr(pnts$plotID, 1, 3)
  pnts <- pnts[,c(which(colnames(pnts) == "plotID"), which(colnames(pnts) == "landuse"),
                  which(colnames(pnts) == "x") : which(colnames(pnts) == "classificationFlags"),
                  which(colnames(pnts) == "layer") : which(colnames(pnts) == "h_rel"))]

  saveRDS(pnts, file = paste0(dat_path, "points_", r_pnts, "m.rds"))
  #write(paste0("r_pnts = ", r_pnts), file = paste0(dat_path, "points_", r_pnts, "m.txt"))


}
