library(dplyr)
library(lubridate)

rm(list = ls())
cat("\014")

setwd(
  "C:/Users/rogl2/OneDrive - NHS/Dev/R/MSDS/MSDS Project/R/Preprocess Data for Loading/"
)

source("util.r")
source("rationalise_fields.R")


data <- read.csv('TESTING 20240219.csv', na = "null")

original_data <- data

output <- NA

unique_pregnancies <- data %>% pull(UniqPregID) %>% unique

# TODO loop by uniq preg id  + baby nhs

for (i in 1:length(unique_pregnancies)) {
  data_for_pt  <- data %>% filter(UniqPregID == unique_pregnancies[i])
  if (nrow(data_for_pt) == 1) {
    rationalised_row <- data_for_pt
  } else {
    rationalised_row <- rationalise_data(data_for_pt)
  }
  
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
    PreviousLossesLessThan24Weeks
  ) %>% unique

columns <- colnames(ordered_output)
qa_output <-
  data.frame(
    field_name = "UniqPregID",
    unique_values = length(unique_pregnancies),
    first_value = output$UniqPregID[1]
  )
for (i in 1:length(columns)) {
  uniq_vals = ordered_output %>% pull(any_of(columns[i])) %>% unique %>% length
  val = ordered_output %>% pull(any_of(columns[i])) %>% first
  qa_output <-
    rbind(
      qa_output,
      data.frame(
        field_name = columns[i],
        unique_values = uniq_vals,
        first_value = val
      )
    )
}

View(qa_output)

mockData = F
target_rows = 16

ETHNICITIES <-
  c('A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'R',
    'S')
FOLIC_ACID <-
  c(
    'Has been taking prior to becoming pregnant',
    'Started taking once pregnancy confirmed',
    'Not taking folic acid supplement',
    'Not Stated (Person asked but declined to provide a response)'
  )
REASON_LATE_BOOKING <- c(
  'Mother unaware of pregnancy',
  'Maternal choice',
  'Concealed pregnancy',
  'Transferred in from other maternity provider',
  'Service capacity',
  'Awaiting availability of interpreter',
  'Did not attend one or more antenatal booking appointments',
  'Recently moved to area - no previous antenatal booking appointment'
)

US_STATUS <- c (
  'Offered and undecided',
  'Offered and declined',
  'Offered and accepted',
  'Not offered',
  'Not eligible - for stage in pregnancy'
)

SETTING_PLACE_BIRTH <- c(
  'NHS Obstetric unit (including theatre)',
  'NHS Alongside midwifery unit',
  'NHS Freestanding midwifery unit (FMU)',
  'Home (NHS care)',
  'Home (private care)',
  'Private hospital',
  'Maternity assessment or triage unit/ area',
  'NHS ward/health care setting without delivery facilities',
  'In transit (with NHS ambulance services)',
  'In transit (with private ambulance services)',
  'In transit (without healthcare services present)',
  'Non-domestic and non-health care setting',
  'Other (not listed)',
  'Not known (not recorded)'
)