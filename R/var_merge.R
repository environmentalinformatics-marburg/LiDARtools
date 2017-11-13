# Description:
# Author: Alice Ziegler
# Date: 2017-10-12 11:55:18

########################################################################################
###Documentation
########################################################################################

var_merge <- function(dat_path, lst_vars_path){
  for (i in 1:length(lst_vars_path)){
   tmp <- get (load (paste0(dat_path,lst_vars_path[i],".RData")))
    if(i==1){
    result <- tmp
    }else{
      result <- merge(result,tmp,by.x="plotID",by.y="plotID")
    }
  }}

