EDD_METHOD_PRIORITY = c(
  'Ultrasound Scan in Pregnancy dating measurements',
  'Last Menstrual Period Date (LMP) confirmed by Ultrasound Scan In Pregnancy',
  'Last Menstrual Period (LMP) Date as stated by the mother',
  'Clinical assessment'
)

FOLIC_ACID_PRIORITY = c(
  'Has been taking prior to becoming pregnant',
'Started taking once pregnancy confirmed',
'Not taking folic acid supplement',
'Not Stated (Person asked but declined to provide a response)'
)

rationalise_data <- function(data) {
  data %>% mutate(
    PersonBirthDateMother = rationalise_maternal_birth_date(data),
    EthnicCategoryMother = rationalise_ethnic_category_mother(data),
    BookingPostcode = rationalise_earliest_pregnancybooking_value(data,'postcode'),
    DeliveryPostcode = rationalise_delivery_postcode(data),
    AntenatalAppDate = rationalise_earliest_pregnancybooking_value(data,'AntenatalAppDate'),
    ReasonLateBooking = rationalise_distinct_values_for_event_only(data, 'ReasonLateBooking'),
    OrgSideIDBooking = rationalise_earliest_pregnancybooking_value(data, 'OrgSiteIDBooking'),
    EDDAgreed = rationalise_edd_by_method(data, 'EDDAgreed'),
    EDDMethodAgreed = rationalise_edd_by_method(data, 'EDDMethodAgreed'),
    NumFetusesEarly = rationalise_fetuses_early(data),
    NumFetusesDelivery = rationalise_fetuses_delivery(data),
    PreviousLiveBirths = rationalise_previous_pregnancy_counts(data, 'PreviousLiveBirths'),
    PreviousStillbirths = rationalise_previous_pregnancy_counts(data, 'PreviousStillbirths'),
    PreviousLossesLessThan24Weeks = rationalise_previous_pregnancy_counts(data, 'PreviousLossesLessThan24Weeks')
  ) %>% filter(row_number() == 1)
}

rationalise_maternal_birth_date <- function(data) {
  unique_values <- data %>% pull(PersonBirthDateMother) %>% unique
  if(length(unique_values) == 1) {
    return(unique_values[1])
  } else {
    return(max(unique_values))
  }
}

rationalise_ethnic_category_mother <- function(data) {
  unique_values <- data %>% pull(EthnicCategoryMother) %>% unique(.) %>% remove_na_from_vector(.) %>% sort()
  if(length(unique_values) <= 1) {
    return(unique_values[1])
  } else {
    # TODO remove vague ethnicities where more specific available
    return(sprintf("Conflicting values: %s", paste(unique_values,collapse=", ")))
  }
}

rationalise_delivery_postcode <- function(data) {
  # TODO make the latest md submission for pregnancy -> delivery postcode
  postcode_compare <- data %>% select(UniqPregID, pb_RPStartDate, 'postcode') %>% unique() %>% arrange(desc(pb_RPStartDate))
  return(postcode_compare$postcode[1])
}

rationalise_earliest_pregnancybooking_value <- function(data, field_name) {
  compare <- data %>% select(UniqPregID, pb_RPStartDate, all_of(field_name)) %>% unique %>% arrange(pb_RPStartDate)
  return(compare %>% pull(any_of(field_name)) %>% first)
}

rationalise_distinct_values_for_event_only <- function(data, field_name) {
  return(data %>% pull(any_of(field_name)) %>% unique %>% remove_na_from_vector %>% paste(., collapse=', ')) %>% sort
}

rationalise_edd_by_method <- function(data, field_name) {
  compare <- data %>% select(EDDAgreed, EDDMethodAgreed) %>% unique %>% arrange(match(EDDMethodAgreed, EDD_METHOD_PRIORITY))
  return(compare %>% pull(any_of(field_name)) %>% first)
}

rationalise_fetuses_early <- function(data) {
  return(1)
}

rationalise_fetuses_delivery <- function(data) {
  return(1)
}

rationalise_previous_pregnancy_counts <- function(data, field_name) {
  return(data %>% pull(all_of(field_name)) %>% unique %>% remove_na_from_vector %>% sort %>% paste(., collapse=', '))
}

rationalise_folic_acid_use <- function(data) {
  return(data %>% select(FolicAcidSupplement) %>% unique %>% remove_na_from_vector %>% arrange(match(FolicAcidSupplement, FOLIC_ACID_PRIORITY)) %>% pull(any_of(FolicAcidSupplement)) %>% first)
}

# TODO
# DRY up distinct values into one method
# Previous pregnancies info goes off earliest submission for that pregnancy as probable most accurate at booking

