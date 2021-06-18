test_that("Non-unique column names result in an error",
          {
            x <- CN_06_Mall_wID[, c(1, 2, 2, 3)]
            names(x) <- c("StationID", "tax1", "tax1", "tax2")
            expect_error(occurrences(x))
          })
test_that("when !all(nchar(names(CN_06_Mall_wID))) gives error",
          {
            expect_error(occurrences(CN_06_Mall_wID))
          })
test_that("Top three rows of the occurrence example are as expected",
          {
            x <- structure(list(taxon = c("Ar000000", "BiVeCa01", "BiVeSh00"),
                                Class = c("Ar", "Bi", "Bi"),
                                Order = c("00", "Ve", "Ve"),
                                Family = c("00", "Ca", "Sh"),
                                Genus = c("00", "01", "00"),
                                count = c(115L, 16L, 42L)),
                           row.names = c(NA, -3L),
                           class = c("data.frame"))

            expect_identical(occurrences(CN_06_Mall_wID[, -1], n = 6)[1:3, ], x)
          })

