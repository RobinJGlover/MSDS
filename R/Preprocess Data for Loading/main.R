library(dplyr)
library(lubridate)

rm(list = ls())
cat("\014")

# TODO
# blank where sex = 'X' (?unknown)

setwd(
  "C:/Users/rogl2/OneDrive - NHS/Dev/R/MSDS/MSDS Project/R/Preprocess Data for Loading/"
)

source("util.r")
source("rationalise_fields.R")

{
  #original_data <- read.csv('NDRSI-398 BADGER - output.csv', na = "null")
  original_data <-
    read.csv('TESTING.csv', na = "null") %>% mutate(
      preserved_pregnancy_id = UniqPregID,
      PersonBirthDateBaby = parse_date_time(PersonBirthDateBaby, c('dmy','ymd')),
      PersonBirthDateMother = parse_date_time(PersonBirthDateMother, c('dmy','ymd'))
    )
  
  data <- original_data[0, ]
  
  for (i in 1:nrow(original_data)) {
    row <- original_data[i, ]
    if (!is.na(row$NHSNumberBaby[1])) {
      row <-
        row %>% mutate(UniqPregID = paste(UniqPregID, substring(NHSNumberBaby, 6, 10), sep =
                                            "-"))
      data <- rbind(data, row)
    } else {
      unique_nhs_numbers <-
        original_data %>% filter(UniqPregID == row$UniqPregID[1] &
                                   !is.na(NHSNumberBaby)) %>% pull(NHSNumberBaby) %>% remove_na_and_nil_from_vector %>% unique
      
      if (length(unique_nhs_numbers) == 0) {
        data <- rbind(data, row)
      } else {
        for (j in 1:length(unique_nhs_numbers)) {
          new_row = row
          new_row$UniqPregID[1] = paste(row$UniqPregID[1],
                                        substring(unique_nhs_numbers[j], 6, 10),
                                        sep = "-")
          data <- rbind(data, new_row)
        }
      }
    }
  }
}

output <- NA

unique_pregnancies <- data %>% pull(UniqPregID) %>% unique

benchmark_start <- Sys.time()

for (i in 1:length(unique_pregnancies)) {
  #print(sprintf("Progress: %s / %s", i, length(unique_pregnancies)))
  data_for_pt  <- data %>% filter(UniqPregID == unique_pregnancies[i])
  rationalised_row <- rationalise_data(data_for_pt)
  
  
  if (length(output) == 1) {
    output = rationalised_row
  } else {
    output = rbind(output, rationalised_row)
  }
}

ordered_output <- output %>%
  select(
    NHSNumberMother,
    PersonBirthDateMother,
    EthnicCategoryMother,
    BookingPostcode,
    DeliveryPostcode,
    AntenatalAppDate,
    ReasonLateBooking,
    OrgSiteIDBooking,
    EDDAgreed,
    NumFetusesEarly,
    NumFetusesDelivery,
    PreviousLiveBirths,
    PreviousStillbirths,
    PreviousLossesLessThan24Weeks,
    FolicAcidSupplement,
    NHSNumberBaby,
    # BREAK
    DischargeDateBabyHosp,
    dischargedatematservice,
    DischReason,
    DischMethCodeMothPostDelHospProvSpell,
    DischargeDateMotherHosp,
    PersonPhenSex,
    PregOutcome,
    # BREAK
    EDDMethodAgreed,
    # BREAK
    Mother_PatientID,
    Baby_PatientID,
    PregnancyID,
    UniqPregID
  ) %>% unique

distinct_preg_ids_in_ordered_output <-
  ordered_output %>% pull(UniqPregID) %>% unique %>% length

time_taken <- NA

if (nrow(ordered_output) > distinct_preg_ids_in_ordered_output) {
  error("More rows than distinct pregnancy ID count")
} else if (nrow(ordered_output) == distinct_preg_ids_in_ordered_output) {
  benchmark_end <- Sys.time()
  time_taken <- benchmark_end - benchmark_start
  print(sprintf("[Success] %s unique pregnancies preprocessed in: %s seconds (%s seconds per pregnancy on average)", length(unique_pregnancies), round(time_taken, digits=1), round((time_taken)/length(unique_pregnancies), digits=2)))
  print("[Success] No QA issues identified.")
  View(ordered_output)
} else {
  error("Less rows than distinct pregnancy ID count") # Sense check - should be impossible...
}




