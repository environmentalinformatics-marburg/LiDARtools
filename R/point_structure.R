#' Calculate structural variables from poibt table
#'
#' @description
#' Calculate structural variables from point table from \code{\link{points_query}}.
#'
#' @param dat_path path for the table output
#' @param pnts_path filename of the RData created in \code{\link{points_query}}
#'
#' @return RData file containing a data.frame called "ldr_str_pnts"
#'
#' @name point_structure
#'
#' @export point_structure
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
########################################################################################

########################################################################################
point_structure <- function(dat_path, pnts_path = NA){
  library(pls)
  load(paste0(dat_path, pnts_path))
  r_nm <- substr(pnts_path,nchar(pnts_path) - 8, nchar(pnts_path) - 7)
  str_var_plt <- lapply(unique(as.character(pnts$plotID)), function(i){
    pnts_tmp <- pnts[which(pnts$plotID == i),]
    qntl <- quantile(pnts_tmp$h_rel, probs=seq(0,1,0.25))
    qntl_0 <- qntl[[1]]
    qntl_25 <- qntl[[2]]
    qntl_50 <- qntl[[3]]
    qntl_75 <- qntl[[4]]
    qntl_100 <- qntl[[5]]
    qntl_rng <- qntl_75 - qntl_25

    ###structural measures
    #calculate maximal height
    max_hght <- max(pnts_tmp$z-pnts_tmp$h_min)
    #calculate standard deviation
    sd_hght <- sd(pnts_tmp$z)
    #calculate median of total number of returns for each coordinate
    mdn_rtrn <- median(pnts_tmp$returns)

    max_rtrn <- max(pnts_tmp$returns)
    sd_rtrn_1 <- sd(pnts_tmp$z[which(pnts_tmp$returnNumber == 1)])
    sd_nmbr_rtrn <- sd(pnts_tmp$returns)

    ###quality measures
    #calculate maximum scan angle within plot
    layer <- pnts_tmp$layer[1]
    max_angl <- max(abs(pnts_tmp$scanAngleRank))
    av_angl <- mean(abs(pnts_tmp$scanAngleRank))
    nmbr_pnts_org <- nrow(pnts_tmp)

    return(list(plotID = i, max_hght = max_hght, sd = sd_hght, mdn_rtrn = mdn_rtrn, max_rtrn = max_rtrn,
                sd_rtrn_1 = sd_rtrn_1, sd_nmbr_rtrn = sd_nmbr_rtrn, qntl_0 = qntl_0, qntl_25 = qntl_25,
                qntl_50 = qntl_50, qntl_75 = qntl_75, qntl_100 = qntl_100, qntl_rng = qntl_rng,
                #cffnt_intcpt = cffnt_intcpt, cffnt_x = cffnt_x, cffnt_x2 = cffnt_x2, cffnt_x3 = cffnt_x3,
                layer = layer, max_angl = max_angl, av_angl = av_angl, nmbr_pnts_org = nmbr_pnts_org))
  })
  point_structure <- as.data.frame(do.call(rbind, str_var_plt))
  for (i in 1:ncol(point_structure)) {
    point_structure[, i] <- unlist(point_structure[, i])
  }
  save(point_structure, file = paste0(dat_path, "point_structure.RData"))
}
