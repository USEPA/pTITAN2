test_that("Top three rows of the occurrence example are as expected",
          {
            x <- structure(list(Class = c("Ar", "Bi", "Bi"),
                                Order = c("00", "Ve", "Ve"),
                                Family = c("00", "Ca", "Sh"),
                                Genus = c("00", "01", "00"),
                                taxon = c("Ar000000", "BiVeCa01", "BiVeSh00"),
                                count = c(115L, 16L, 42L)),
                           row.names = c(NA, -3L),
                           class = c("tbl_df", "tbl", "data.frame"))

            expect_identical(occurrences(CN_06_Mall_wID[, -1], n = 6)[1:3, ], x)
          })
