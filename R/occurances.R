#' Occurrence
#'
#' Generate a taxonomic data set with codes which have at least n occurrences.
#'
#' Of the codes with at least n occurrences, the code with the most taxonomic
#' detail needs to be selected for the \code{\link[TITAN2]{titan}} run.  This
#' means if the macroinvertebrate count has at least n occurrences in a genus
#' code, the family, order, and class codes associated with these counts should
#' be removed.  Or, for another example, if there are too few counts at the
#' genus level, but at least n counts at the family level- the family code would
#' be retained and the order and class codes would be removed.
#'
#' Coding: All of the macroinvertebrates were coded so the first two letters
#' indicate the class, the second two letters indicate the order, the third two
#' letters indicate the family, and the last two numbers indicate the genus.
#' "00" indicates that there is no information at that level.  For example: A
#' code that is 'Bi000000' is the Bivalvia class, while BiVe0000 is the Bivalvia
#' class, Veneroida order. BiVeSh00 is the Bivalvia class, Veneroida order,
#' Spheriridae family. BiVeSh01 is a genus within that family.
#'
#' NOTE: The example script that inspired the development of this function
#' required the data set to have the column names in alpha order.  This function
#' relaxes that requirement by using the \code{\link[dplyr]{arrange}} call.
#'
#' @param data A \code{data.frame} wit
#' @param n the minimum number of occurrences.
#'
#' @seealso \code{vignette(topic = "pTITAN2", package = "pTITAN2")}
#'
#' @examples
#'
#' library(magrittr)
#'
#' # Read in a data set.
#'
#' CN_06_Mall <-
#'  readr::read_csv(file = system.file("extdata", "CN_06_Mall_wID.csv",
#'                                     package = "pTITAN2"),
#'                  col_types = readr::cols(.default = readr::col_double()))
#'
#' # Report the tax with at least six occurrences
#'
#' occurrences(CN_06_Mall[, -1], n = 6)
#'
#' # Compare results to the raw data were the occurrences of the
#'
#' CN_06_Mall %>%
#'   dplyr::select(-StationID) %>%
#'   tidyr::gather(key = 'taxon', value = 'count') %>%
#'   dplyr::mutate(Class = stringr::str_sub(.data$taxon, 1, 2),
#'                 Order = stringr::str_sub(.data$taxon, 3, 4),
#'                 Family = stringr::str_sub(.data$taxon, 5, 6),
#'                 Genus  = stringr::str_sub(.data$taxon, 7, 8)) %>%
#'   dplyr::group_by(.data$Class, .data$Order, .data$Family, .data$Genus) %>%
#'   dplyr::summarize(taxon = unique(.data$taxon), count = sum(.data$count > 0)) %>%
#'   dplyr::ungroup() %>%
#'   dplyr::arrange(.data$Class, .data$Order, .data$Family, .data$Genus)
#'
#'
#' @export
occurrences <-function(data, n = 6L) {
  UseMethod("occurrences")
}

#' @method occurrences data.frame
#' @export
occurrences.data.frame <- function(data, n = 6L) {

  if (any(duplicated(names(data)))) {
    stop(sprintf("All the column names in `%s` need to be unique.",
                 deparse(substitute(data))),
                 call. = FALSE)
  }

  if (!all(stringr::str_length(names(data)) == 8L)) {
    stop(sprintf("Expected all column names in `%s` to be eight characters long.  Two characters each to represent the class, order, family, and genus.",
                 deparse(substitute(data))),
                 call. = FALSE)
  }

  taxon_count <-
    data %>%
    tidyr::gather(key = "taxon", value = "count") %>%
    dplyr::mutate(Class = stringr::str_sub(.data$taxon, 1, 2),
                  Order = stringr::str_sub(.data$taxon, 3, 4),
                  Family = stringr::str_sub(.data$taxon, 5, 6),
                  Genus  = stringr::str_sub(.data$taxon, 7, 8)) %>%
    dplyr::group_by(.data$Class, .data$Order, .data$Family, .data$Genus) %>%
    dplyr::summarize(taxon = unique(.data$taxon), count = sum(.data$count > 0)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(.data$count >= n) %>%
    dplyr::arrange(.data$Class, .data$Order, .data$Family, .data$Genus)

  keep_Genus <- dplyr::filter(taxon_count, .data$Genus != "00")
  taxon_count %<>%
    dplyr::anti_join(keep_Genus, by = c("Class", "Order", "Family"))

  keep_Family <- dplyr::filter(taxon_count, .data$Family != "00")
  taxon_count %<>%
    dplyr::anti_join(keep_Genus,  by = c("Class", "Order")) %>%
    dplyr::anti_join(keep_Family, by = c("Class", "Order"))

  keep_Order <- dplyr::filter(taxon_count, .data$Order != "00")
  taxon_count %<>%
    dplyr::anti_join(keep_Genus, by = c("Class")) %>%
    dplyr::anti_join(keep_Family, by = c("Class")) %>%
    dplyr::anti_join(keep_Order, by = c("Class"))

  list(taxon_count, keep_Genus, keep_Family, keep_Order) %>%
    dplyr::bind_rows() %>%
    dplyr::arrange(.data$taxon)
}

