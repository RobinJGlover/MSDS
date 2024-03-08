EDD_METHOD_PRIORITY = c(
  '03', # Ultrasound Scan in Pregnancy dating measurements
  '02', # Last Menstrual Period Date (LMP) confirmed by Ultrasound Scan In Pregnancy
  '01', # Last Menstrual Period (LMP) Date as stated by the mother
  '04'  # Clinical assessment
)

FOLIC_ACID_PRIORITY = c(
  '01', # Has been taking prior to becoming pregnant
  '02', # Started taking once pregnancy confirmed'
  '03', # Not taking folic acid supplement
  '04'  # Not Stated (Person asked but declined to provide a response)
)

rationalise_data <- function(data) {
  data %>% mutate(
    NHSNumberMother = rationalise_distinct_values(data, "NHSNumberMother"),
    NHSNumberBaby = rationalise_distinct_values(data,'NHSNumberBaby'),
    PersonBirthDateMother = rationalise_maternal_birth_date(data),
    EthnicCategoryMother = rationalise_ethnic_category_mother(data),
    BookingPostcode = rationalise_earliest_pregnancybooking_value(data,'postcode'),
    DeliveryPostcode = rationalise_delivery_postcode(data),
    AntenatalAppDate = rationalise_earliest_pregnancybooking_value(data,'AntenatalAppDate'),
    ReasonLateBooking = rationalise_distinct_values(data, 'ReasonLateBooking'),
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
    DischargeDateBabyHosp = rationalise_earliest_pregnancybooking_value(data, 'DischargeDateBabyHosp'),
    dischargedatematservice = rationalise_distinct_values(data, "dischargedatematservice"),
    DischReason = rationalise_distinct_values(data, "DischReason"),
    DischMethCodeMothPostDelHospProvSpell = rationalise_distinct_values(data, "DischMethCodeMothPostDelHospProvSpell"),
    DischargeDateMotherHosp = rationalise_distinct_values(data, "dischargedatemotherhosp"),
    PersonPhenSex = rationalise_distinct_values(data,"PersonPhenSex"),
    PregOutcome = rationalise_distinct_values(data, "PregOutcome"),
    OrgSiteIDActualDelivery = rationalise_earliest_pregnancybooking_value(data, "OrgSiteIDActualDelivery"),
    DeliveryMethodCode = rationalise_distinct_values(data, 'DeliveryMethodCode'),
    birthweight = rationalise_birth_weight(data),
    PregFirstConDate = rationalise_earliest_pregnancybooking_value(data, "PregFirstConDate"),
    LeadAnteProvider = rationalise_distinct_values(data, 'LeadAnteProvider'),
    OrgIDProvOrigin = rationalise_distinct_values(data, 'OrgIDProvOrigin'),
    OrgIDRecv = rationalise_distinct_values(data, 'OrgIDRecv'),
    LastMenstrualPeriodDate = rationalise_earliest_pregnancybooking_value(data, 'LastMenstrualPeriodDate'),
    ActivityOfferDateUltrasound = rationalise_distinct_values(data,"ActivityOfferDateUltrasound"),
    OfferStatusDatingUltrasound = rationalise_distinct_values(data, "OfferStatusDatingUltrasound"),
    ProcedureDateDatingUltrasound = rationalise_distinct_values(data, "ProcedureDateDatingUltrasound"),
    OrgIDDatingUltrasound = rationalise_distinct_values_preserving_blanks(data, 'OrgIDDatingUltrasound'),
    BirthOrderMaternitySUS = rationalise_blank_if_conflicting(data, 'BirthOrderMaternitySUS'),
    PersonBirthTimeBaby = rationalise_blank_if_conflicting(data, 'PersonBirthTimeBaby'),
    PersonDeathDateBaby = rationalise_blank_if_conflicting(data, 'PersonDeathDateBaby'),
    PersonDeathTimeBaby = rationalise_blank_if_conflicting(data, 'PersonDeathTimeBaby'),
    ovsvischcat = rationalise_distinct_values(data, "OvsVisChCat"),
    NeonatalTransferStartDate = rationalise_distinct_values_preserving_blanks(data, 'NeonatalTransferStartDate'),
    NeonatalTransferStartTime = rationalise_distinct_values_preserving_blanks(data, 'NeonatalTransferStartTime'),
    OrgSiteIDAdmittingNeonatal = rationalise_distinct_values_preserving_blanks(data, 'OrgSiteIDAdmittingNeonatal'),
    NeoCritCareInd = rationalise_distinct_values_preserving_blanks(data, 'NeoCritCareInd'),
    Mother_PatientID = 'placeholder',
    Baby_PatientID = 'placeholder',
    PregnancyID = 'placeholder'
  ) %>% unique
}

rationalise_maternal_birth_date <- function(data) {
  unique_values <- data %>% pull(PersonBirthDateMother) %>% unique
  return(max(unique_values))
}

rationalise_ethnic_category_mother <- function(data) {
  unique_values <- data %>% pull(EthnicCategoryMother) %>% unique(.) %>% remove_na_from_vector(.) %>% sort()
  
  unique_values <- unique_values[!unique_values %in% c('X', 'Z', '99')]
  
  if('0' %in% unique_values || 'G' %in% unique_values || 'L' %in% unique_values || 'P' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('S')]
  }
  
  if('A' %in% unique_values || 'B' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('0','C','S')]
  }
  
  if('C' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('0','S')]
  }
  
  if('D' %in% unique_values || 'E' %in% unique_values || 'F' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('G','S')]
  }
  
  if('H' %in% unique_values || 'J' %in% unique_values || 'K' %in% unique_values || 'R' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('L','S')]
  }
  
  if('M' %in% unique_values || 'N' %in% unique_values) {
    unique_values <- unique_values[!unique_values %in% c('P','S')]
  }
  
  if(length(unique_values) <= 1) {
    return(unique_values[1])
  } else {
    return(sprintf("Conflicting values: %s", paste(unique_values,collapse=", ")))
  }
}

rationalise_delivery_postcode <- function(data) {
  postcode_compare <- data %>% select(UniqPregID, pb_RPStartDate, 'postcode') %>% unique() %>% arrange(desc(pb_RPStartDate))
  return(postcode_compare$postcode[1])
}

rationalise_earliest_pregnancybooking_value <- function(data, field_name) {
  compare <- data %>% select(UniqPregID, pb_RPStartDate, all_of(field_name)) %>% unique %>% arrange(pb_RPStartDate)
  return(compare %>% pull(any_of(field_name)) %>% first)
}

rationalise_distinct_values <- function(data, field_name) {
  return(data %>% pull(any_of(field_name)) %>% unique %>% remove_na_and_nil_from_vector %>% sort %>% paste(., collapse=', '))
}

rationalise_distinct_values_preserving_blanks <- function(data, field_name) {
  return(data %>% pull(any_of(field_name)) %>% paste(., collapse=', ') %>% gsub('NA', '', ., fixed=T))
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
  max_by_LocalFetalID = data %>% pull(LocalFetalID_baby) %>% remove_na_and_nil_from_vector %>% unique %>% length
  max_by_BNHSNos = original_data %>% filter(UniqPregID == data$UniqPregID[1]) %>% pull(NHSNumberBaby) %>% remove_na_and_nil_from_vector %>% unique %>% length
  return(max(max_by_NoDeliveries, max_by_LabourDeliveryID, max_by_LocalFetalID, max_by_BNHSNos,na.rm=T))
}

rationalise_previous_pregnancy_counts <- function(data, field_name) {
  return(data %>% pull(all_of(field_name)) %>% unique %>% remove_na_from_vector %>% sort %>% paste(., collapse=', '))
}

rationalise_folic_acid_use <- function(data) {
  return(data %>% select(FolicAcidSupplement) %>% unique %>% arrange(match(FolicAcidSupplement, FOLIC_ACID_PRIORITY)) %>% pull(FolicAcidSupplement) %>% first)
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
    return (paste(unique(uniq_wts_obs$obsvalue), collapse=', '))
  }
}

rationalise_blank_if_conflicting <- function(data, field_name) {
  unique_values <- data %>% pull(any_of(field_name)) %>% remove_na_and_nil_from_vector %>% unique
  if(length(unique_values)>1) {
    return(NA)
  }
  return(unique_values[1])
}
