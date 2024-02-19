remove_na_from_vector <- function(vec) {
  vec <- vec[!is.na(vec)]
}

remove_nil_from_vector <- function(vec) {
  vec <- vec[!vec==""]
}

remove_na_and_nil_from_vector <- function(vec) {
  vec %>% remove_na_from_vector %>% remove_nil_from_vector
}