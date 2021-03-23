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
#' @param taxa a list of data.frames with the taxa.  See Details.
#' @param envs a list of data.frames with the environmental gradients. See
#' Details
#' @param sid a plan text name of the station id columns.
#' 
#' @return
#' A list of lists of lists.  At the top level the elements are the treatment
#' groups.  There are as many elements as the length of the lists taxa and envs.
#'
#' The second level are the taxa and environmental gradient.
#'
#' @examples
#' \dontrun{
#' # Read the vignette
#' vignette(topic = "pTITAN2", package = "pTITAN2")
#' }
#' 
#' @export
permute <- function(taxa, envs, sid) {

  # Testing for equal length of the tax and envs lists.
  if (length(taxa) != length(envs)) {
    stop(sprintf("taxa has length %i; evns has length %i.  Expected equal lengths.",
                 length(taxa), length(envs)), 
         call. = FALSE)
  }

  # build a single data.frame with the station ID and treatment labels. Check
  # that the same station and treatment combinations are present in both the
  # taxa and environmental gradients.
  sid_enq <- dplyr::enquo(sid)
  TAXA <-
    dplyr::bind_rows(taxa, .id = "..treatment..") %>%
    dplyr::mutate(..sid.. = !!sid_enq,
                  ..rowid.. = paste(.data$..sid.., .data$..treatment.., sep = "_")) %>%
    dplyr::mutate_at(.vars = dplyr::vars(-.data$..sid.., -.data$..rowid.., -.data$..treatment..),
                     .funs = list(~if_else(is.na(.), 0, .)))

  ENVG <-
    dplyr::bind_rows(envs, .id = "..treatment..") %>%
    dplyr::mutate(..sid.. = !!sid_enq,
                  ..rowid.. = paste(.data$..sid.., .data$..treatment.., sep = "_"))
  
  # Generate a unique identifier for each station/treatment combination.  Only
  # need to work with the TAXA data.frame for this. The ENVG was generated only
  # for the check above.  Also add a count of the number of occurrences of the
  # station id.  The final line of this code block splits the data.frame into a
  # list of data.frames where each element of the list contains a data.frame
  # with station ids which occur only once, twice, thrice, ...
  PERMS <-
    ENVG %>%
    dplyr::group_by(.data$..sid..) %>%
    dplyr::mutate(n = n()) %>%
    dplyr::ungroup() %>%
    split(x = ., f = .$n)

  # generate the permuted treatment levels.  A vector of treatment labels will be needed.
  trtlabs <- as.character(seq(1, length(taxa), by = 1))
  PERMS <-
    PERMS %>%
    lapply(.,
           function(x) {
             if (all(x$n == 1)) {# if the station id occurs only once permute the treatment labels for the data.frame
               dplyr::mutate(x, thistrt = sample(.data$..treatment..))
             } else { # station occurs more than once, sample from the possible treatment labels
               x %>%
                 dplyr::group_by(.data$..sid..) %>%
                 dplyr::mutate(thistrt = sample(trtlabs, size = unique(.data$n))) %>%
                 dplyr::ungroup()
             }
           }) %>%
    dplyr::bind_rows(.) %>%
    dplyr::arrange(.data$..rowid..) 

  # Split by the permuted treatment labels
  PERMS <- split(PERMS$..rowid.., PERMS$thistrt)

  # generate the needed environmental gradient and tax data frames
  outE <- lapply(PERMS,
                 function(xx) {
                   ENVG %>%
                     dplyr::filter(.data$..rowid.. %in% xx) %>%
                     dplyr::arrange(!!sid_enq) %>%
                     dplyr::select(-!!sid_enq, -dplyr::starts_with(".."))
                 })
  outT <- lapply(PERMS,
                 function(xx) {
                   TAXA %>%
                     dplyr::filter(.data$..rowid.. %in% xx) %>%
                     dplyr::arrange(!!sid_enq) %>%
                     dplyr::select(-!!sid_enq, -dplyr::starts_with(".."))
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
#' @param minTaxonFreq minnumber of occurrences for each taxon
#' @param trys maximum number of attempts to generate a meaningful permutation
#' @param ... passed to permute
#' @rdname permute
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
