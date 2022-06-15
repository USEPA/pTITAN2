library(pTITAN2)

# data set dimensions are as expected
stopifnot(dim(C_IC_N_06_wID)  == c(124, 2))
stopifnot(dim(C_IC_D_06_wID)  == c(251, 2))
stopifnot(dim(CD_06_Mall_wID) == c(251, 501))
stopifnot(dim(CN_06_Mall_wID) == c(124, 501))

# StationID is the first column in each dataset
stopifnot(names(C_IC_D_06_wID)[1]  == "StationID")
stopifnot(names(C_IC_N_06_wID)[1]  == "StationID")
stopifnot(names(CD_06_Mall_wID)[1] == "StationID")
stopifnot(names(CN_06_Mall_wID)[1] == "StationID")


# columns of the data sets are in the expected storage mode
stopifnot(is.character(C_IC_D_06_wID$StationID))
stopifnot(is.character(C_IC_N_06_wID$StationID))
stopifnot(is.character(CD_06_Mall_wID$StationID))
stopifnot(is.character(CN_06_Mall_wID$StationID))

stopifnot(is.numeric(C_IC_N_06_wID$ImpCover))
stopifnot(is.numeric(C_IC_D_06_wID$ImpCover))

stopifnot(all(sapply(CD_06_Mall_wID[, -1], mode) == "numeric"))
stopifnot(all(sapply(CN_06_Mall_wID[, -1], mode) == "numeric"))
