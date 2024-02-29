library(dplyr)
library(lubridate)

rm(list = ls())
cat("\014")

setwd(
  "C:/Users/rogl2/OneDrive - NHS/Dev/R/MSDS/MSDS Project/R/Preprocess Data for Loading/"
)

source("util.r")
source("rationalise_fields.R")


data <- read.csv('TESTING 20240219.csv', na = "null") %>% mutate(
  UniqPregID = paste(UniqPregID, substr(NHSNumberBaby,6,10), sep="-")
)

original_data <- data

output <- NA

unique_pregnancies <- data %>% pull(UniqPregID) %>% unique

# TODO loop by uniq preg id  + baby nhs

for (i in 1:length(unique_pregnancies)) {
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
    DischargeDateBabyHosp,
    DischargeDateMatService = dischargedatematservice,
    DeliveryMethodCode,
    PregFirstConDate,
    LeadAnteProvider,
    OrgIDProvOrigin,
    OrgIDRecv,
    LastMenstrualPeriodDate,
    ActivityOfferDateUltrasound,
    OfferStatusDatingUltrasound,
    ProcedureDateDatingUltrasound,
    OrgIDDatingUltrasound,
    BirthOrderMaternitySUS,
    PersonBirthTimeBaby,
    PersonDeathDateBaby,
    PersonDeathTimeBaby,
    OvsVisChCat=ovsvischcat,
    NeonatalTransferStartDate,
    NeonatalTransferStartTime,
    OrgSiteIDAdmittingNeonatal,
    NeoCritCareInd,
    Mother_PatientID,
    Baby_PatientID,
    PregnancyID,
    UniqPregID
  ) %>% unique


View(ordered_output)