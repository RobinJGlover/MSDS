library(dplyr)
library(lubridate)

setwd("C:/Users/rogl2/OneDrive - NHS/Dev/R/MSDS/MSDS Project/R/Create Query from Tracing List")


{
list <- read.csv(file.choose()) 
colnames(list) <- tolower(colnames(list))
list <- list %>% mutate(
  mother_query_portion = case_when(
    !is.na(mother_nhsnumber) & !is.na(expecteddeliverydate) ~ sprintf("(pb.Person_ID_Mother = %s and abs(datediff(pb.EDDAgreed,'%s'::date)) < 30)", mother_nhsnumber, format(dmy(expecteddeliverydate), '%Y-%m-%d'))
  )#,
  #mother_query_portion_2 = case_when(
  #  !is.na(Mother.NHS) & !is.na(Antenatal.Date) ~ sprintf("(pb.Person_ID_Mother = %s and '%s'::date between pb.AntenatalAppDate and pb.EDDAgreed)", mother_nhsnumber, format(dmy(Antenatal.Date), '%Y-%m-%d'))
  #),
  #mother_query_portion = case_when(
  #  !is.na(mother_query_portion) ~ mother_query_portion,
  #  T ~ mother_query_portion_2
  #)
)

query <- sprintf(
  "with cohort as (select
  bd.RecordNumber, bd.UniqPregID
from
  mat_pre_clear.msd401babydemographics bd
where bd.NHSNumberBaby in (%s)
union
select
  pb.RecordNumber, bd.UniqPregID
from
  mat_pre_clear.msd401babydemographics bd
left join mat_pre_clear.msd101pregnancybooking pb on bd.UniqPregID = pb.UniqPregID
where bd.NHSNumberBaby in (%s)
union
select pb.RecordNumber, pb.UniqPregID
from mat_pre_clear.msd101pregnancybooking pb
where %s", list %>% filter(!is.na(child_nhsnumber)) %>% pull(child_nhsnumber) %>% paste(.,collapse=','), list %>% filter(!is.na(child_nhsnumber)) %>% pull(child_nhsnumber) %>% paste(.,collapse=','),
  list %>% filter(!is.na(mother_query_portion)) %>% pull(mother_query_portion) %>% paste(.,collapse=' OR ')) %>%
  paste0(., ") select 
  distinct -- Mother Fields --------
  c.UniqPregID,
  md.NHSNumberMother,
  md.PersonBirthDateMother,
  md.EthnicCategoryMother,
  md.postcode,
  -------------------------
  -- Preg Fields ----------
  pb.AntenatalAppDate,
  pb.PregFirstConDate,
  pb.ReasonLateBooking,
  pb.OrgSiteIDBooking,
  pb.LeadAnteProvider,
  pb.OrgIDProvOrigin,
  pb.OrgIDRecv,
  pb.LastMenstrualPeriodDate,
  pb.EDDAgreed,
  pb.EDDMethodAgreed,
  bd.GestationLengthBirth,
  ds.NoFetusesDatingUltrasound,
  ds.LocalFetalID,
  ds.FetalOrder,
  ds.ActivityOfferDateUltrasound,
  ds.OfferStatusDatingUltrasound,
  ds.ProcedureDateDatingUltrasound,
  ds.OrgIDDatingUltrasound,
  ld.BirthsPerLabandDel,
  bd.LabourDeliveryID,
  bd.LocalFetalID LocalFetalID_baby,
  pb.PreviousLiveBirths,
  pb.PreviousStillbirths,
  pb.PreviousLossesLessThan24Weeks,
  pb.FolicAcidSupplement,
  -------------------------
  -- Baby Fields ----------
  bd.NHSNumberBaby,
  bd.PersonBirthDateBaby,
  bd.PersonBirthTimeBaby,
  bd.PersonDeathDateBaby,
  bd.PersonDeathTimeBaby,
  bd.DischargeDateBabyHosp,
  pb.dischargedatematservice,
  ld.dischargedatemotherhosp,
  bd.BirthOrderMaternitySUS,
  cab.birthweight,
  cab.MasterSnomedCTObsTerm,
  cab.obsvalue,
  cab.ucumunit,
  bd.PersonPhenSex,
  -------------------------
  -- Outcome --------------
  bd.PregOutcome,
  pb.DischReason,
  ld.DischMethCodeMothPostDelHospProvSpell,
  bd.OrgSiteIDActualDelivery,
  bd.SettingPlaceBirth,
  bd.DeliveryMethodCode,
  -------------------------
  -- Admin ----------------
  pb.RPStartDate pb_RPStartDate,
  os.OvsVisChCat,
  -------------------------
  -- Neonatal Admission ---
  na.NeonatalTransferStartDate,
  na.NeonatalTransferStartTime,
  na.OrgSiteIDAdmittingNeonatal,
  na.NeoCritCareInd,
  -------------------------
  -- LPI ------------------
  concat(md.LPIDMother, ' - ', md.OrgIDLPID) mother_lpi_by_provider,
  concat(bd.LPIDBaby, ' - ', bd.OrgIDLocalPatientIdBaby) child_lpi_by_provider
from cohort c 
left join mat_pre_clear.msd101pregnancybooking pb on c.RecordNumber = pb.RecordNumber
left join mat_pre_clear.msd001motherdemog md on pb.RecordNumber = md.RecordNumber
left join mat_pre_clear.msd004overseasvischargcat os on md.RecordNumber = os.RecordNumber
left join mat_pre_clear.msd401babydemographics bd on c.RecordNumber = bd.RecordNumber
left join mat_pre_clear.msd103datingscan ds on c.RecordNumber = ds.RecordNumber
left join mat_pre_clear.msd301labourdelivery ld on c.RecordNumber = ld.RecordNumber
left join mat_pre_clear.msd405careactivitybaby cab on bd.RecordNumber = cab.RecordNumber and (cab.birthweight is not null or cab.MasterSnomedCTObsTerm = 'Birth weight (observable entity)')
left join mat_pre_clear.msd402neonataladmission na on pb.RecordNumber = na.RecordNumber")
writeClipboard(query)
}