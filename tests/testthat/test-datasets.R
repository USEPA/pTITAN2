test_that("data set dimensions are as expected",
          {
            expect_equal(dim(C_IC_N_06_wID), c(124, 2))
            expect_equal(dim(C_IC_D_06_wID), c(251, 2))
            expect_equal(dim(CD_06_Mall_wID), c(251, 501))
            expect_equal(dim(CN_06_Mall_wID), c(124, 501))
          })

test_that("StationID is the first column in each dataset",
          {
            expect_true(names(C_IC_D_06_wID)[1] == "StationID")
            expect_true(names(C_IC_N_06_wID)[1] == "StationID")
            expect_true(names(CD_06_Mall_wID)[1] == "StationID")
            expect_true(names(CN_06_Mall_wID)[1] == "StationID")
          })

test_that("columns of the data sets are in the expected storage mode",
          {
            expect_true(is.character(C_IC_D_06_wID$StationID))
            expect_true(is.character(C_IC_N_06_wID$StationID))
            expect_true(is.character(CD_06_Mall_wID$StationID))
            expect_true(is.character(CN_06_Mall_wID$StationID))

            expect_true(is.numeric(C_IC_N_06_wID$ImpCover))
            expect_true(is.numeric(C_IC_D_06_wID$ImpCover))

            expect_true(all(sapply(CD_06_Mall_wID[, -1], mode) == "numeric"))
            expect_true(all(sapply(CN_06_Mall_wID[, -1], mode) == "numeric"))
          })
