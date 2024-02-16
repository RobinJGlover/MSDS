remove_na_from_vector <- function(vec) {
  vec <- vec[!is.na(vec)]
}