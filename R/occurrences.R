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
#' @return a \code{data.frame} with six columns: \code{taxon}, \code{Class},
#' \code{Order}, \code{Family}, \code{Genus}, and \code{count}.
#'
#' @examples
#'
#' # Report the tax with minimum of five (default) occurrences.
#' occurrences(CN_06_Mall_wID[, -1])
#'
#' # Report the tax with at least six occurrences
#' occurrences(CN_06_Mall_wID[, -1], n = 6)
#'
#' @export
occurrences <-function(data, n = 5L) {
  UseMethod("occurrences")
}

#' @method occurrences data.frame
#' @export
occurrences.data.frame <- function(data, n = 5L) {

  if (any(duplicated(names(data)))) {
    stop(sprintf("All the column names in `%s` need to be unique.",
                 deparse(substitute(data))),
                 call. = FALSE)
  }

  if (!all(nchar(names(data)) == 8L)) {
    stop(sprintf("Expected all column names in `%s` to be eight characters long.  Two characters each to represent the class, order, family, and genus.",
                 deparse(substitute(data))),
                 call. = FALSE)
  }

  taxon_count <- data.table::copy(data)
  taxon_count <- data.table::setDT(taxon_count)
  for(j in as.integer(which(sapply(taxon_count, is.integer)))) {
    data.table::set(taxon_count, j = j, value = as.numeric(taxon_count[[j]]))
  }

  taxon_count <- data.table::melt(taxon_count, variable.factor = FALSE, measure.vars = names(taxon_count), variable.name = "taxon")
  taxon_count <- subset(taxon_count, taxon_count[["value"]] > 0)

  data.table::set(taxon_count, j = "Class", value = substr(taxon_count[["taxon"]], 1L, 2L))
  data.table::set(taxon_count, j = "Order", value = substr(taxon_count[["taxon"]], 3L, 4L))
  data.table::set(taxon_count, j = "Family", value = substr(taxon_count[["taxon"]], 5L, 6L))
  data.table::set(taxon_count, j = "Genus", value = substr(taxon_count[["taxon"]], 7L, 8L))
  data.table::set(taxon_count, j = "value", value = NULL)

  for (i in unique(taxon_count[["taxon"]])) {
    idx <- which(taxon_count[["taxon"]] == i)
    data.table::set(taxon_count, i = idx, j = "count", value = length(idx))
  }
  taxon_count <- unique(taxon_count)
  taxon_count <- subset(taxon_count, taxon_count[["count"]] >= n)
  data.table::setkeyv(taxon_count, c("Class", "Order", "Family", "Genus"))

  keep_Genus <- subset(taxon_count, taxon_count[["Genus"]] != "00")
  # program antijoins
  data.table::set(keep_Genus, j = "COF", value = paste(keep_Genus[["Class"]], keep_Genus[["Order"]], keep_Genus[["Family"]]))
  data.table::set(taxon_count, j = "COF", value = paste(taxon_count[["Class"]], taxon_count[["Order"]], taxon_count[["Family"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["COF"]] %in% keep_Genus[["COF"]]))

  keep_Family <- subset(taxon_count, taxon_count[["Family"]] != "00")
  data.table::set(keep_Genus,  j = "CO", value = paste(keep_Genus[["Class"]], keep_Genus[["Order"]]))
  data.table::set(keep_Family, j = "CO", value = paste(keep_Family[["Class"]], keep_Family[["Order"]]))
  data.table::set(taxon_count, j = "CO", value = paste(taxon_count[["Class"]], taxon_count[["Order"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["CO"]] %in% keep_Genus[["CO"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["CO"]] %in% keep_Family[["CO"]]))

  keep_Order <- subset(taxon_count, taxon_count[["Order"]] != "00")
  data.table::set(keep_Order,  j = "C", value = paste(keep_Order[["Class"]]))
  data.table::set(keep_Genus,  j = "C", value = paste(keep_Genus[["Class"]]))
  data.table::set(keep_Family, j = "C", value = paste(keep_Family[["Class"]]))
  data.table::set(taxon_count, j = "C", value = paste(taxon_count[["Class"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["C"]] %in% keep_Order[["C"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["C"]] %in% keep_Genus[["C"]]))
  taxon_count <- subset(taxon_count, !(taxon_count[["C"]] %in% keep_Family[["C"]]))

  rtn <- data.table::rbindlist(list(taxon_count, keep_Genus, keep_Family, keep_Order))
  data.table::set(rtn, j = "C", value = NULL)
  data.table::set(rtn, j = "CO", value = NULL)
  data.table::set(rtn, j = "COF", value = NULL)
  data.table::setkeyv(rtn, "taxon")
  as.data.frame(rtn)
}

