# Description:
# Author: Alice Ziegler
# Date: 2017-10-17 09:01:15

########################################################################################
###Documentation
########################################################################################
#optionale Argumente:
##r_pnts = 10, db_layers = c("kili", "kili2"), db = "http://192.168.191.183:8081", db_login = "user:password", location)
########################################################################################
########################################################################################
gap_structure <- function(dat_path, chm_path = NA, d_rst = NA, db_layers = NA, group_name = NA, db = NA,
                          db_login = NA, location = NA, gap_hght = 10, gap_sze = 9){
  library(raster)
  library(stringr)
  if (missing(chm_path)){
    if(any(is.na(c(r_pnts, db_layers, db, db_login, location)))){
      stop(paste0("One or more arguments missing for raster query (dat_path, d_rst, db_layers, db, db_login, ",
                  "group_name or location)"))
    }
    source("E:/packages_general/WoLi/raster_query.R")
    raster_query(dat_path = dat_path, d_rst = d_rst, db_layers = db_layers, group_name = group_name, db = db,
                 db_login = db_login, location = location, rst_type = c("chm"))
  }

  chm_lst <- list.files(chm_path)
  gap_frac_all <- lapply(chm_lst, function(i){
    print(i)
    chm <- raster(paste0(chm_path, i))
    values(chm)[values(chm) < gap_hght] <- NA
    values(chm)[is.finite(values(chm))] <- 0
    values(chm)[is.na(values(chm))] <- 1
    clmp <- clump(chm, directions = 8, gaps = F)
    frq<-as.data.frame(freq(clmp))
    excludeID <- frq$value[which(frq$count <= gap_sze)]
    sieve <- clmp
    sieve[clmp %in% excludeID] <- NA
    total_count <- length(sieve@data@values)
    clear_count <- sum(is.finite(sieve@data@values))
    cover_count <- sum(is.na(sieve@data@values))
    gap_frac_plt <- clear_count / total_count
    return(list(substr(i,1,4), gap_frac_plt))
  })
  gap_frac <- as.data.frame(do.call(rbind, gap_frac_all))
  colnames(gap_frac) <- c("plotID", "gap_frac")
  for (i in 1:ncol(gap_frac)) {
    gap_frac[, i] <- unlist(gap_frac[, i])
  }
  save(gap_frac, file = paste0(dat_path, "gap_structure_", str_extract(chm_path, "[0-9]+"), "m.RData"))
}


