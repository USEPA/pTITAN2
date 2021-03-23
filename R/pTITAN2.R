#' Permutations of Treatment Lables and TITAN2 Analysis
#'
#' Permutate treatment labels for taxa and environmental gradients to generate
#' an empirical distribution of change points.
#'
#' @importFrom magrittr "%>%"
#' @importFrom magrittr "%<>%"
#' @importFrom rlang .data
#' @docType package
#' @name pTITAN2
NULL

# Define globalVariables so R CMD check doesn't freak out
utils::globalVariables(".")
utils::globalVariables("n")


