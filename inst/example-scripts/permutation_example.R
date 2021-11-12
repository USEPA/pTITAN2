# expect to be evaluated from the package source root.
set.seed(42)
load("./data/C_IC_D_06_wID.rda")
load("./data/C_IC_N_06_wID.rda")
load("./data/CD_06_Mall_wID.rda")
load("./data/CN_06_Mall_wID.rda")
source("./R/permute.R")
source("./R/occurrences.R")

# Create an expression to replicate, that is, create several permutations.  Below
# will be an example call for serial replication and an example for parallel
# replication
expr <- expression(
                   {
  p <- permute(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
               envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
               sid = "StationID")
  trt_codes_1 <- subset(p$Treatment1$taxa, select = occurrences(p$Treatment1$taxa, n = 6L)$taxon)
  trt_codes_2 <- subset(p$Treatment2$taxa, select = occurrences(p$Treatment2$taxa, n = 6L)$taxon)

  out1 <- try(
              TITAN2::titan(env  = p[["Treatment1"]][["env"]][[1]],
                            txa  = trt_codes_1,
                            boot = TRUE,
                            nBoot = 5) #Change the number of bootstraps here
              , silent = TRUE)

  out2 <- try(
              TITAN2::titan(env  = p[["Treatment2"]][["env"]][[1]],
                            txa  = trt_codes_2,
                            boot = TRUE,
                            nBoot = 5)
              , silent = TRUE)

  if ("try-error" %in% c(class(out1), class(out2))) {
    rtn <- data.frame("trt1cpsumz-" = NA,  # decreasing taxa output
                      "trt1cpsumz+" = NA,  # increasing taxa output
                      "trt1count"   = NA,  # Number of permuted sites in treatment #1
                      "trt2cpsumz-" = NA,
                      "trt2cpsumz+" = NA,
                      "trt2count" = NA,
                      check.names = FALSE)
  } else {
    rtn <- data.frame("trt1cpsumz-" = out1$sumz.cp[1, 4],
                      "trt1cpsumz+" = out1$sumz.cp[2, 4],
                      "trt1count" = (nrow(out1$env)),
                      "trt2cpsumz-" = out2$sumz.cp[1, 4],
                      "trt2cpsumz+" = out2$sumz.cp[2, 4],
                      "trt2count" = (nrow(out2$env)),
                      check.names = FALSE)
  }
  rtn
                   }
) # end of expr definition


# Create the 10 Permutations

# Serial Computations
# permutation_example <- replicate(10, eval(expr), simplify = FALSE)

# Parallel Computations (this is for a Unix-like OS)
permutation_example <- parallel::mclapply(1:10, eval, expr = expr, mc.cores = 4L)

permutation_example <- do.call(rbind, permutation_example)
permutation_example[["permutation"]] <- seq(1, nrow(permutation_example))
permutation_example

