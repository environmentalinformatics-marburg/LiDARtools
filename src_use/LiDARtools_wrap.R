# Description:
# Author: Alice Ziegler
# Date: 2018-02-26 17:46:58
# to do: dat_SR.RData befindet sich eigentlich in anderem Ordner als die ganzen LiDAR parameter.
# entweder anders programmieren, oder immer dat_SR in den entsprechenden Ordner kopieren
# traits entfernen
####missing structure query!!!!
rm(list=ls())

########################################################################################
###Presettings
########################################################################################
#Packages:
library(LiDARtools)


###before this
##00_preprocessing.R
##optional beta_div.R need to be executed

#Sources:
setwd("C:/Users/Alice/Uni/Projekte/Kili/src/")
# setwd(dirname(rstudioapi::getSourceEditorContext()[[2]]))
sub <- "nov18_test/"
inpath <- "../data/" # only original files
dat_path <- paste0("../data/", sub)
if (file.exists(dat_path)==F){
  dir.create(file.path(dat_path))
}
login_file <- paste0(inpath, ".remote_sensing_userpwd.txt") # optional file in home directory content: user:password

########################################################################################
###reading data
########################################################################################
tec_crdnt <- read.csv(paste0(inpath,"tec_crdnt.csv"), header=T, sep=",")

########################################################################################
###Settings
########################################################################################

r_pnts <- 25
d_rst <- 50
# db_layers <- c("kili", "kili2")
db_layers <- c("kili_campaign1_lidar_classified_2015", "kili_campaign2_lidar_classified_2016")
db_login <- readChar(login_file, file.info(login_file)$size) # optional read account from file
db <- "http://137.248.191.215:8081"
location <- unique(tec_crdnt[, c("plotID", "x_pnt", "y_pnt")])
rst_type <- c("chm")
group_name <- "kili_poi_plots"
gap_hght <- 10
gap_sze <- 9

########
pnts_path <- paste0("points_", r_pnts, "m.rds")
chm_path <- paste0(dat_path, "raster_db_", d_rst, "m/", rst_type[1], "/")


point_str_path <- "point_structure"
db_str_path <- "db_structure"
gap_frac_path <- "gap_structure"
dat_SR_path <- "dat_SR"
#traits_path <- "traits"
# residuals_path <- "tbl_res"
#beta_residuals_path <- "beta_residuals"
#beta_anm_plnt_path <- "beta_anm_plnt"
troph_sum_path <- "troph_sum"
# troph_sum_residuals_path <- "troph_sum_residuals"
lst_vars_path_field <- c(dat_SR_path, #residuals_path, #SR_residuals_path, #beta_anm_plnt_path, beta_residuals_path,
                         troph_sum_path) #, troph_sum_residuals_path, traits_path)
lst_vars_path_ldr <- c(db_str_path, point_str_path, gap_frac_path)
# lst_vars_path <- c(dat_SR_path, SR_residuals_path, beta_anm_plnt_path, traits_path,
#                    db_str_path, point_str_path, gap_frac_path)
########################################################################################
###Do it (Don't change anything past this point except you know what you are doing!)
########################################################################################
points_query(db_layers = db_layers,
             dat_path = dat_path,
             location = location,
             r_pnts = r_pnts,
             db = db,
             db_login = db_login)
#pnts <- readRDS(paste0(dat_path, "points_25m.rds"))
#usecase get points
point_structure(dat_path = dat_path, pnts_path = pnts_path)

#point_structure <- get(load(paste0(dat_path, "point_structure.RData")))

db_structure(dat_path = dat_path, r_pnts = r_pnts, db_layers= db_layers,
             db = db, db_login = db_login, group = "kili_poi_plots")
#db_structure <- get(load(paste0(dat_path, "db_structure.RData")))

raster_query(dat_path = dat_path, d_rst = d_rst, db_layers = db_layers, group_name = group_name, db = db,
             db_login = db_login, location = location, rst_type = rst_type)

gap_fraction(dat_path = dat_path, chm_path = chm_path, gap_hght = gap_hght, gap_sze = gap_sze)
#gap_frac <- get(load(paste0(dat_path, "gap_structure.RData")))

###
#merging
###

###merge fielddata
#lst_vars_path_field <- c(dat_SR_path, SR_residuals_path, beta_anm_plnt_path, traits_path)
field_mrg <- var_merge(dat_path = dat_path, lst_vars_path = lst_vars_path_field, descr = "field", mrg_col = "plotID")
###merge lidardata
#lst_vars_path_ldr <- c(db_str_path, point_str_path, gap_frac_path)
ldr_mrg <- var_merge(dat_path = dat_path, lst_vars_path = lst_vars_path_ldr, descr = "ldr", mrg_col = "plotUnq")
###
###merge field and ldr
lst_vars_path <- c("field_mrg", "ldr_mrg")
dat_ldr_mrg <- var_merge(dat_path = dat_path, lst_vars_path = lst_vars_path, descr = "dat_ldr", mrg_col = "plotID")
dat_ldr_mrg$plotUnq <- as.factor(dat_ldr_mrg$plotUnq)
dat_ldr_mrg <- dat_ldr_mrg[,!c(grepl("plotID\\.", colnames(dat_ldr_mrg)))]

saveRDS(dat_ldr_mrg, file = paste0(dat_path, "dat_ldr_mrg.rds"))
