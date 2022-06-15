library(pTITAN2)


# error is thrown when taxa or env is not a list of data.frames
test1 <- try(
             permute(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
                     envs = C_IC_D_06_wID,
                     sid  = "StationID")
             , silent = TRUE)

test2 <- try(
             permute(taxa = list(matrix(NA), CN_06_Mall_wID),
                     envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
                     sid  = "StationID")
             , silent = TRUE
            )

test3 <- try(
             permute(taxa = list(CN_06_Mall_wID),
                     envs = list(C_IC_N_06_wID),
                     sid  = "StationID")
             , silent = TRUE
            )

stopifnot(inherits(test1, "try-error"))
stopifnot(inherits(test2, "try-error"))
stopifnot(inherits(test3, "try-error"))

# permute2 failes to give a valid permutation after 100 trys
set.seed(42)
eg_permute <-
  permute2(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
          envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
          sid  = "StationID",
          minTaxonFreq = 3L,
          trys = 100L)
stopifnot(is.null(eg_permute))

# permute2 works
dry_taxa    <- subset(CD_06_Mall_wID, select = c("StationID", grep("^(Ar|BiVe)", names(CD_06_Mall_wID), value = TRUE)))
normal_taxa <- subset(CN_06_Mall_wID, select = c("StationID", grep("^(Ar|BiVe)", names(CN_06_Mall_wID), value = TRUE)))

dry_env    <- subset(C_IC_D_06_wID, subset = C_IC_D_06_wID$StationID %in% dry_taxa$StationID)
normal_env <- subset(C_IC_N_06_wID, subset = C_IC_N_06_wID$StationID %in% normal_taxa$StationID)

eg_permute <-
  permute2(taxa = list(dry_taxa, normal_taxa),
           envs = list(dry_env, normal_env),
           sid  = "StationID",
           minTaxonFreq = 3L,
           trys = 100L)

stopifnot( all(attr(eg_permute, "minTaxonFreq") >= 3L) )


