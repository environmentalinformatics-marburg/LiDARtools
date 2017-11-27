# Description:
# Author: Alice Ziegler
# Date: 2017-10-16 16:13:38

########################################################################################
###Documentation
########################################################################################
########################################################################################
########################################################################################

rm(list=ls())

########################################################################################
###Settings
########################################################################################
library(LiDARtools)
dat_path <- "E:/Projekte/Kili/data/"
r_pnts <- 10
d_rst <- 50
db_layers <- c("kili", "kili2")
db <- "http://192.168.191.183:8081"
db_login <- "user:password"
tec_crdnt <- read.csv(paste0(dat_path,"tec_crdnt.csv"), header=T, sep=",")
location <- unique(tec_crdnt[, c("plotID", "x_pnt", "y_pnt")])
rst_type <- c("chm")
group_name <- "kili"
gap_hght <- 10
gap_sze <- 9

########
pnts_path <- paste0("points_", r_pnts, "m.RData")
chm_path <- paste0(dat_path, "raster_db_", d_rst, "m/", rst_type[1], "/")

point_str_path <- "point_structure"
gap_frac_path <- "gap_structure"
dat_SR_path <- "dat_SR"
lst_vars_path <- c(dat_SR_path, point_str_path, gap_frac_path)
########################################################################################
###Do it (Don't change anything past this point except you know what you are doing!)
########################################################################################
points_query(dat_path = dat_path, location = location)
#usecase get points
point_structure(dat_path = dat_path, pnts_path = pnts_path)

raster_query(dat_path = dat_path, d_rst = d_rst, db_layers = db_layers, group_name = group_name, db = db,
db_login = db_login, location = location, rst_type = rst_type)

gap_fraction(dat_path = dat_path, chm_path = chm_path, gap_hght = 10, gap_sze = 9)
###
#merging
###

var_merge(dat_path = dat_path, lst_vars_path = lst_vars_path)
load(paste0(dat_path, "dat_ldr_merge.RData"))
