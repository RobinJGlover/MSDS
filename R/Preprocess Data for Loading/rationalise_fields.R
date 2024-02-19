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
    OrgSiteIDBooking = rationalise_earliest_pregnancybooking_value(data, 'OrgSiteIDBooking'),
    EDDAgreed = rationalise_edd_by_method(data, 'EDDAgreed'),
    EDDMethodAgreed = rationalise_edd_by_method(data, 'EDDMethodAgreed'),
    NumFetusesEarly = rationalise_fetuses_early(data),
    NumFetusesDelivery = rationalise_fetuses_delivery(data),
    PreviousLiveBirths = rationalise_previous_pregnancy_counts(data, 'PreviousLiveBirths'),
    PreviousStillbirths = rationalise_previous_pregnancy_counts(data, 'PreviousStillbirths'),
    PreviousLossesLessThan24Weeks = rationalise_previous_pregnancy_counts(data, 'PreviousLossesLessThan24Weeks'),
    FolicAcidSupplement = rationalise_folic_acid_use(data),
    PersonBirthDateBaby1 = rationalise_baby_dob_lower_bound(data),
    PersonBirthDateBaby2 = rationalise_baby_dob_upper_bound(data),
    DischargeDateBabyHosp = rationalise_distinct_values_for_event_only(data, 'DischargeDateBabyHosp'),
    dischargedatematservice = rationalise_distinct_values_for_event_only(data, "dischargedatematservice"),
    DischReason = rationalise_distinct_values_for_event_only(data, "DischReason"),
    DischMethCodeMothPostDelHospProvSpell = rationalise_distinct_values_for_event_only(data, "DischMethCodeMothPostDelHospProvSpell"),
    DischargeDateMotherHosp = rationalise_distinct_values_for_event_only(data, "dischargedatemotherhosp"),
    PersonPhenSex = rationalise_distinct_values_for_event_only(data,"PersonPhenSex"),
    PregOutcome = rationalise_distinct_values_for_event_only(data, "PregOutcome"),
    OrgSiteIDActualDelivery = rationalise_distinct_values_for_event_only(data, "OrgSiteIDActualDelivery"),
    birthweight = rationalise_birth_weight(data),
    PregFirstConDate = rationalise_distinct_values_for_event_only(data, "PregFirstConDate"),
    ovsvischcat = rationalise_distinct_values_for_event_only(data, "ovsvischcat")
  ) %>% unique
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
  return(data %>% pull(any_of(field_name)) %>% unique %>% remove_na_and_nil_from_vector %>% sort %>% paste(., collapse=', '))
}

rationalise_edd_by_method <- function(data, field_name) {
  compare <- data %>% select(EDDAgreed, EDDMethodAgreed) %>% unique %>% arrange(match(EDDMethodAgreed, EDD_METHOD_PRIORITY))
  return(compare %>% pull(any_of(field_name)) %>% first)
}

rationalise_fetuses_early <- function(data) {
  max_by_NoFetuses = data %>% pull(NoFetusesDatingUltrasound) %>% max
  max_by_LocalFetalID = data %>% pull(LocalFetalID) %>% remove_na_and_nil_from_vector %>% unique %>% length
  max_by_FetalOrder = data %>% pull(FetalOrder) %>% remove_na_and_nil_from_vector %>% unique %>% length
  
  return(max(max_by_NoFetuses, max_by_LocalFetalID, max_by_FetalOrder, na.rm=T))
}

rationalise_fetuses_delivery <- function(data) {
  max_by_NoDeliveries = data %>% pull(BirthsPerLabandDel) %>% max
  max_by_LabourDeliveryID = data %>% pull(LabourDeliveryID) %>% remove_na_and_nil_from_vector %>% unique %>% length
  max_by_LocalFetalID = data %>% pull(LocalFetalID_delivery) %>% remove_na_and_nil_from_vector %>% unique %>% length
  max_by_BNHSNos = original_data %>% filter(UniqPregID == data$UniqPregID[1]) %>% pull(NHSNumberBaby) %>% remove_na_and_nil_from_vector %>% unique %>% length
  return(max(max_by_NoDeliveries, max_by_LabourDeliveryID, max_by_LocalFetalID, max_by_BNHSNos,na.rm=T))
}

rationalise_previous_pregnancy_counts <- function(data, field_name) {
  return(data %>% pull(all_of(field_name)) %>% unique %>% remove_na_from_vector %>% sort %>% paste(., collapse=', '))
}

rationalise_folic_acid_use <- function(data) {
  return(data %>% pull(FolicAcidSupplement) %>% unique %>% remove_na_from_vector %>% paste(., collapse=", "))
}

rationalise_baby_dob_lower_bound <- function(data) {
  uniq_dobs <- data %>% pull(PersonBirthDateBaby) %>% unique %>% remove_na_from_vector %>% sort
  if(length(uniq_dobs) == 1) {
    return(uniq_dobs %>% first)
  } else {
    # TODO figure out what we do if we have conflicting DOBs - latest row in baby table for this preg?
    
    # PLACEHOLDER
    return(uniq_dobs %>% first)
  }
}

rationalise_baby_dob_upper_bound <- function(data) {
  uniq_dobs <- data %>% pull(PersonBirthDateBaby) %>% unique %>% remove_na_from_vector %>% sort
  if(length(uniq_dobs) == 1) {
    return(uniq_dobs %>% first)
  } else {
    # TODO figure out what we do if we have conflicting DOBs - latest row in baby table for this preg?
    
    # PLACEHOLDER
    return(uniq_dobs %>% first)
  }
}

rationalise_birth_weight <- function(data) {
  # get unique dobs from first rate column
  uniq_wts <- data %>% pull(birthweight) %>% unique %>% remove_na_from_vector
  if(length(uniq_wts) == 1) {
    return(uniq_wts[1])
  } else if(length(uniq_wts) > 1) {
    return (paste(uniq_wts, collapse=", "))
  } else {
    # If no weights in first rate column, get from observations entries
    uniq_wts_obs <- data %>% select(MasterSnomedCTObsTerm, obsvalue, ucumunit) %>% filter(!is.na(obsvalue))
    if(nrow(uniq_wts_obs) == 0) return (NA)
    error("Handle observation value weights in g + kg & multiples")
  }
}
