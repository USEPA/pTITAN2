# Re-import the data.
CN_06_Mall <-
  readr::read_csv(file = system.file("extdata", "CN_06_Mall_wID.csv", package = "pTITAN2"),
                  col_types = readr::cols(.default = readr::col_double()))
CD_06_Mall <-
  readr::read_csv(file = system.file("extdata", "CD_06_Mall_wID.csv", package = "pTITAN2"),
                  col_types = readr::cols(.default = readr::col_double()))

chaparral_envgrad_normal <-
  readr::read_csv(system.file("extdata", "C_IC_N_06_wID.csv", package = "pTITAN2"),
                  col_types = readr::cols(.default = readr::col_double()))
chaparral_envgrad_dry <-
  readr::read_csv(system.file("extdata", "C_IC_D_06_wID.csv", package = "pTITAN2"),
                  col_types = readr::cols(.default = readr::col_double()))


# set up the cluster (this works on Unix like systems)
library(parallel)
cl <- parallel::makeCluster(2, setup_strategy = "sequential")
clusterEvalQ(cl, {require(pTITAN2); require(TITAN2); require(dplyr) })

clusterExport(cl,
              c("CD_06_Mall", "CN_06_Mall",
                "chaparral_envgrad_dry", "chaparral_envgrad_normal"))


# generate a generic function to permute the data and run titan. This will be
# used in parallel::parLapply.  This function will return NA if an error occurs
# or the `sumz.cp` element of a titan run if the permuation and titan runs
# succeed. The number of bootstraps can be selected at 'nBoot,' which is 
# set to five for this example
foo <- function(x) {
  p <- suppressMessages(permute(taxa = list(CD_06_Mall, CN_06_Mall),
                                envs = list(chaparral_envgrad_dry, chaparral_envgrad_normal),
                                sid = StationID))
  if (is.null(p)) {
    return(NA)
  } else {
    
    Treat1_codes <- dplyr::select(p$Treatment1$taxa,
                                  occurrences(p$Treatment1$taxa, n = 6L)$taxon)
    Treat2_codes <- dplyr::select(p$Treatment2$taxa,
                                  occurrences(p$Treatment2$taxa, n = 6L)$taxon)
    out1 <- try(TITAN2::titan(env  = p$Treatment1$env,
                              txa  = Treat1_codes,
                              boot = TRUE,
                              nBoot = 5), #Change the number of bootstraps here
                silent = TRUE)
    out2 <- try(TITAN2::titan(env  = p$Treatment2$env,
                              txa  = Treat2_codes,
                              boot = TRUE,
                              nBoot = 5),
                silent = TRUE)
  }#This chunk can be altered to include more treatments, if needed
  
  if ("try-error" %in% c(class(out1), class(out2))) {
    return(NA)
  } else {
    return(dplyr::data_frame(
      "trt1cpsumz-" = out1$sumz.cp[1, 4], #decreasing taxa output
      "trt1cpsumz+" = out1$sumz.cp[2, 4], #increasing taxa output
      "trt1count" = (nrow(out1$env)), #Number of permuted sites in treatment #1 
      "trt2cpsumz-" = out2$sumz.cp[1, 4],
      "trt2cpsumz+" = out2$sumz.cp[2, 4],
      "trt2count" = (nrow(out2$env))))
  }
}


# run four permutations.
permutation_example <- parLapply(cl, 1:4, foo) #Change the number of permutations here

permutation_example <- dplyr::bind_rows(permutation_example, .id = "permutation")

stopCluster(cl)
