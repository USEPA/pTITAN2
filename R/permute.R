#' Permute
#'
#' Permute treatment labels for a taxa and associated environmental gradients.
#'
#' The taxa and envs lists are expected to be of equal length and that the ith
#' element of taxa list is associated with the ith element of the envs list.
#' That is, the taxa and environmental gradient for treatment 1 are both the
#' first elements of the respective lists, the taxa and environmental gradient
#' for treatment 2 are the second elements for the respective lists, etc.
#'
#' The environmental gradient data.frames are expected to have two columns, one
#' with the station ID and one with the data defining the gradient.
#'
#' The taxa data.frames are expected to have the station ID column as well.
#' **Important** The station ID column name needs to be the same for all the
#' taxa and environmental gradient data.frames.
#'
#' @param taxa a list of \code{data.frame}s with the taxa.  See Details.
#' @param envs a list of \code{data.frame}s with the environmental gradients. See
#' Details
#' @param sid a character vector of length one with the name of the column
#' identifying the station id.
#'
#' @return
#' A list of lists of lists.  At the top level the elements are the treatment
#' groups.  There are as many elements as the length of the lists taxa and envs.
#'
#' The second level are the taxa and environmental gradient.
#'
#' @seealso \code{vignette(topic = "pTITAN2", package = "pTITAN2")}
#'
#' @examples
#'
#' example_permutation <-
#'  permute(taxa = list(CD_06_Mall_wID, CN_06_Mall_wID),
#'          envs = list(C_IC_D_06_wID, C_IC_N_06_wID),
#'          sid  = "StationID")
#' str(example_permutation, max.level = 2)
#'
#' @export
permute <- function(taxa, envs, sid) {

  stopifnot((class(taxa) == "list") & (class(envs) == "list"))
  stopifnot(all(sapply(taxa, inherits, what = "data.frame")) & all(sapply(envs, inherits, what = "data.frame")) )
  stopifnot((length(taxa) == length(envs)) & (length(taxa) > 1))

  # build a single data.frame with the station ID and treatment labels. Check
  # that the same station and treatment combinations are present in both the
  # taxa and environmental gradients.
  TAXA <- data.table::rbindlist(taxa, idcol = "..treatment..", use.names = TRUE, fill = TRUE)
  ENVG <- data.table::rbindlist(envs, idcol = "..treatment..", use.names = TRUE, fill = TRUE)

  # replace all NA values with a 0
  for(j in names(TAXA)[!(names(TAXA) %in% c("..treatment..", sid))]) {
    data.table::set(TAXA, j = j, value = data.table::nafill(TAXA[[j]], type = "const", fill = 0))
  }
  data.table::set(TAXA, j = "..rowid..", value = paste(TAXA[[sid]], TAXA[["..treatment.."]], sep = "_"))
  data.table::set(ENVG, j = "..rowid..", value = paste(ENVG[[sid]], ENVG[["..treatment.."]], sep = "_"))

  # Generate a unique identifier for each station/treatment combination.  Only
  # need to work with the TAXA data.frame for this. The ENVG was generated only
  # for the check above.  Also add a count of the number of occurrences of the
  # station id.  The final line of this code block splits the data.frame into a
  # list of data.frames where each element of the list contains a data.frame
  # with station ids which occur only once, twice, thrice, ...
  PERMS <- data.table::copy(ENVG)
  for (j in unique(PERMS[[sid]])) {
    idx <- which(PERMS[[sid]] == j)
    data.table::set(PERMS, i = idx, j = "n", value = length(idx))
  }

  # generate the permuted treatment levels.  A vector of treatment labels will be needed.
  trtlabs <- as.character(seq(1, length(taxa), by = 1))

  for (i in seq_along(trtlabs)) {
    idx <- which(PERMS$n == i)
    data.table::set(PERMS, i = idx, j = "..thistrt..", value = sample(PERMS[["..treatment.."]][idx]))
  }

  # Split by the permuted treatment labels
  PERMS <- split(PERMS[["..rowid.."]], PERMS[["..thistrt.."]])

  # generate the needed environmental gradient and tax data frames
  outE <- lapply(PERMS, function(p) { subset(ENVG, ENVG[["..rowid.."]] %in% p) })
  outE <- lapply(outE, data.table::setkeyv, cols = sid)
  outE <- lapply(outE,
                 function(x) {
                   for (j in c(sid, grep("^\\.\\.", names(x), value = TRUE))){
                     data.table::set(x, j = j, value = NULL)
                   }
                   as.data.frame(x)
                 })

  outT <- lapply(PERMS, function(p) { subset(TAXA, TAXA[["..rowid.."]] %in% p) })
  outT <- lapply(outT, data.table::setkeyv, cols = sid)
  outT <- lapply(outT,
                 function(x) {
                   for (j in c(sid, grep("^\\.\\.", names(x), value = TRUE))){
                     data.table::set(x, j = j, value = NULL)
                   }
                   as.data.frame(x)
                 })

  rtn <-
    lapply(1:length(taxa),
           function(trt) {
             list(env = outE[[trt]], taxa = outT[[trt]])
           })

  names(rtn) <- paste0("Treatment", 1:length(taxa))
  attr(rtn, "minTaxonFreq") <- as.numeric(sapply(outT, function(x) { min(colSums(data.matrix(x) > 0)) }))

  rtn
}

#'
#'
#' @param minTaxonFreq min number of occurrences for each taxon
#' @param trys maximum number of attempts to generate a meaningful permutation
#' @param ... passed to permute
#' @rdname permute
#'
#' @export
permute2 <- function(..., minTaxonFreq = 3L, trys = 100L) {
  counter <- 1L

  repeat {
    eg <- permute(...)

    if (all(attr(eg, "minTaxonFreq") > minTaxonFreq)) {
      message(sprintf("It took %d attempts to get a valid permutation.", counter))
      break
    } else {
      counter <- counter + 1L
      if (counter %% 10 == 0) {
        message(sprintf("still running, just finished attempt %d.", counter))
      }
      if (counter >= trys) {
        message(sprintf("I give up.  %d tries and still no valid permutation.", trys))
        break
      }
    }
  }

  if (counter >= trys) {
    return(invisible())
  } else {
    return(eg)
  }
}
