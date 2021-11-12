#' Example Data Sets
#'
#' Four Example data sets for use the pTITAN2 package.
#'
#' Example data sets are from publicly available macroinvertebrate survey data
#' from California.  The data sets are broken down between the environmental
#' variable, in this case percent impervious cover, and macroinvertebrate data.
#' Separate data files are provided for each 'treatment' that is explored. In
#' this case, the treatments are data from either drought (dry) or normal
#' precipitation years in the Chaparral region of California.
#'
#' \code{CN_06_Mall_wID} (Chaparral Region, Treatment = Normal) file contains
#' raw macroinvertebrate density data for 500 possible macroinvertebrate codes
#' for each taxonomic level (class, order, family, genus).
#'
#' The raw data files are provided for your use as well.  See example below for
#' accessing these files.
#'
#' @examples
#' head(C_IC_D_06_wID)  # Environemntal Gradient, Dry Treatment
#' head(C_IC_N_06_wID)  # Environemntal Gradient, Normal Treatment
#' head(CD_06_Mall_wID) # Taxonomic, Dry Treatment
#' head(CN_06_Mall_wID) # Taxonomic, Normal Treatment
#'
#' # Get the paths to the raw data files
#' list.files(system.file("extdata", package = "pTITAN2"))
#'
#' @name datasets
#'
NULL

#' @rdname datasets
"C_IC_D_06_wID"

#' @rdname datasets
"C_IC_N_06_wID"

#' @rdname datasets
"CD_06_Mall_wID"

#' @rdname datasets
"CN_06_Mall_wID"

#' Permutation Example Result
#'
#' Results for a permutation example.
#'
#' The code to generate this example permuation set can be found via
#' \code{system.file("example-scripts", "permutation_example.R", package = "pTITAN2")}
#'
#' @seealso \code{vignette("pTITIAN2")}
#'
#' @rdname permutation_example
"permutation_example"
