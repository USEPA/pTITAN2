test_that("error is thrown when taxa or env is not a list of data.frames",
          {
            expect_error(
                         permute(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
                                 envs = C_IC_D_06_wID,
                                 sid  = "StationID")
            )

            expect_error(
                         permute(taxa = list(matrix(NA), CN_06_Mall_wID),
                                 envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
                                 sid  = "StationID")
            )

            expect_error(
                         permute(taxa = list(CN_06_Mall_wID),
                                 envs = list(C_IC_N_06_wID),
                                 sid  = "StationID")
            )
          })

test_that("permute2 failes to give a valid permutation after 100 trys",
          {
            set.seed(42)
            eg_permute <-
              permute2(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
                      envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
                      sid  = "StationID",
                      minTaxonFreq = 3L,
                      trys = 100L)
            expect_null(eg_permute)
          })

test_that("permute2 works",
          {
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

            expect_true( all(attr(eg_permute, "minTaxonFreq") >= 3L) )
          })
