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
