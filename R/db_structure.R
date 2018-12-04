#' Query LiDAR structure parameters from database and write them into table
#' ###Test change
#'
#' @description
#' Query LiDAR structure variables from database and write them into table by landuse.
#'
#' @param dat_path path for the table output
#' @param r_pnts points within this radius from locations (in meter) will be taken into account (default = 10)
#' @param db_layers vector of database layer names for wich the query should be made.
#' @param db adress of the database (default = "http://192.168.191.183:8081")
#' @param db_login string of username and password for the database (default = "username:password")
#' @param location data.frame with at least 3 columns with the column names "plotID", "xpnt" and "y_pnt".
#'
#' @return rds file containing a data.frame called "pnts"
#'
#' @name db_structure
#'
#' @export db_structure
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
db_structure <- function( dat_path, r_pnts,
                          db_layers = c("kili_campaign1_lidar_classified_2015", "kili_campaign2_lidar_classified_2016"),
                          group_name = "kili_poi_plots",
                             db = "http://137.248.191.215:8081", db_login, location = NA,
                             functions = NULL){
  library(rPointDB)
  remotesensing <- RemoteSensing$new(db, db_login)

  if(missing(location)){
    # get one POI group
    location <- remotesensing$poi_group(group_name=group_name)
    colnames(location) <- c("plotID", "x_pnt","y_pnt")
  }

  str_var_all_lay <- lapply(db_layers, function(i){
    pointdb <- remotesensing$pointdb(i)

  # create areas of all POIs in a POI-group with 10 meter squares
    areas <- mapply(function(name, x, y) {return(extent_diameter(x=x, y=y, d=(2*r_pnts)))}, location$plotID,
                            location$x_pnt, location$y_pnt)

  #get all lidar index processing functions
    if(is.null(functions)){
      functions_df <-  pointdb$processing_functions
      functions <- functions_df$name
    }
  df <- pointdb$process(areas=areas, functions=functions)
  df$plotUnq <- paste0(df$name, "_", i)
  return(df)
  })
  db_structure <- do.call(rbind, str_var_all_lay)
  colnames(db_structure)[1] <- "plotID"
  saveRDS(db_structure, file = paste0(dat_path, "db_structure.rds"))
  }
