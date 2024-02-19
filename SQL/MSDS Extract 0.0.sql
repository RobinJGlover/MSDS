with cohort as (select
  bd.UniqPregID
from
  mat_pre_clear.msd401babydemographics bd
where bd.NHSNumberBaby in ()
union
select pb.UniqPregID
from mat_pre_clear.msd101pregnancybooking pb
where (pb.Person_ID_Mother = )
) select 
  distinct -- Mother Fields --------
  c.UniqPregID,
  md.NHSNumberMother,
  md.PersonBirthDateMother,
  case
    when md.EthnicCategoryMother in ('X', 'Z', '99') then null
    else md.EthnicCategoryMother
  end EthnicCategoryMother,
  md.postcode,
  -------------------------
  -- Preg Fields ----------
  pb.AntenatalAppDate,
  pb.PregFirstConDate,
  case 
    when pb.ReasonLateBooking = '01' then 'Mother unaware of pregnancy'
    when pb.ReasonLateBooking = '02' then 'Maternal choice'
    when pb.ReasonLateBooking = '03' then 'Concealed pregnancy'
    when pb.ReasonLateBooking = '04' then 'Transferred in from other maternity provider'
    when pb.ReasonLateBooking = '05' then 'Service capacity'
    when pb.ReasonLateBooking = '06' then 'Awaiting availability of interpreter'
    when pb.ReasonLateBooking = '07' then 'Did not attend one or more antenatal booking appointments'
    when pb.ReasonLateBooking = '08' then 'Recently moved to area - no previous antenatal booking appointment'
    when pb.ReasonLateBooking = '98' then 'Other (not listed)'
    else pb.ReasonLateBooking
   end as ReasonLateBooking,
  pb.OrgSiteIDBooking,
  pb.LeadAnteProvider,
  pb.OrgIDProvOrigin,
  pb.OrgIDRecv,
  pb.LastMenstrualPeriodDate,
  pb.EDDAgreed,
  case 
    when pb.EDDMethodAgreed = '01' then 'Last Menstrual Period (LMP) Date as stated by the mother'
    when pb.EDDMethodAgreed = '02' then 'Last Menstrual Period Date (LMP) confirmed by Ultrasound Scan In Pregnancy'
    when pb.EDDMethodAgreed = '03' then 'Ultrasound Scan in Pregnancy dating measurements'
    when pb.EDDMethodAgreed = '04' then 'Clinical assessment'
    else pb.EDDMethodAgreed
  end as EDDMethodAgreed,
  bd.GestationLengthBirth,
  ds.NoFetusesDatingUltrasound,
  ds.LocalFetalID,
  ds.FetalOrder,
  ds.ActivityOfferDateUltrasound,
  case
    when ds.OfferStatusDatingUltrasound = '01' then 'Offered and undecided'
    when ds.OfferStatusDatingUltrasound = '02' then 'Offered and declined'
    when ds.OfferStatusDatingUltrasound = '03' then 'Offered and accepted'
    when ds.OfferStatusDatingUltrasound = '04' then 'Not offered'
    when ds.OfferStatusDatingUltrasound = 'SP' then 'Not eligible - for stage in pregnancy'
    else ds.OfferStatusDatingUltrasound
  end as OfferStatusDatingUltrasound,
  ds.ProcedureDateDatingUltrasound,
  ds.OrgIDDatingUltrasound,
  ld.BirthsPerLabandDel,
  bd.LabourDeliveryID,
  bd.LocalFetalID,
  pb.PreviousLiveBirths,
  pb.PreviousStillbirths,
  pb.PreviousLossesLessThan24Weeks,
  case
    when pb.FolicAcidSupplement = '01' then 'Has been taking prior to becoming pregnant'
    when pb.FolicAcidSupplement = '02' then 'Started taking once pregnancy confirmed'
    when pb.FolicAcidSupplement = '03' then 'Not taking folic acid supplement'
    when pb.FolicAcidSupplement = 'ZZ' then null
    else pb.FolicAcidSupplement
  end as FolicAcidSupplement,
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
  case when bd.PersonPhenSex = 'X' then null else bd.PersonPhenSex end PersonPhenSex,
  -------------------------
  -- Outcome --------------
  case
    when bd.PregOutcome = '01' then 'Livebirth'
    when bd.PregOutcome in ('02','03','04') then 'Stillbirth'
    when bd.PregOutcome = '04' then 'Termination >= 24 weeks'
    when bd.PregOutcome = 98 then null
    else bd.PregOutcome
  end PregOutcome,
  case
    when pb.DischReason = '01' then 'Discharge following delivery'
    when pb.DischReason = '02' then 'Transfer to other Health Care Provider'
    when pb.DischReason = '03' then 'Miscarriage'
    when pb.DischReason = '04' then 'Termination of Pregnancy < 24weeks'
    when pb.DischReason = '05' then 'Termination of Pregnancy >= 24weeks'
    when pb.DischReason = '06' then 'No further contact from mother'
    when pb.DischReason = '07' then 'Maternal death'
    else pb.DischReason
  end DischReason,
  case
    when ld.DischMethCodeMothPostDelHospProvSpell in (1,2,3,4,8,9) then null
    when ld.DischMethCodeMothPostDelHospProvSpell = 5 then 'Stillbirth'
    else ld.DischMethCodeMothPostDelHospProvSpell
  end DischMethCodeMothPostDelHospProvSpell,
  bd.OrgSiteIDActualDelivery,
  case
    when bd.SettingPlaceBirth = '01' then 'NHS Obstetric unit (including theatre)'
    when bd.SettingPlaceBirth = '02' then 'NHS Alongside midwifery unit'
    when bd.SettingPlaceBirth = '03' then 'NHS Freestanding midwifery unit (FMU)'
    when bd.SettingPlaceBirth = '04' then 'Home (NHS care)'
    when bd.SettingPlaceBirth = '05' then 'Home (private care)'
    when bd.SettingPlaceBirth = '06' then 'Private hospital'
    when bd.SettingPlaceBirth = '07' then 'Maternity assessment or triage unit/ area'
    when bd.SettingPlaceBirth = '08' then 'NHS ward/health care setting without delivery facilities'
    when bd.SettingPlaceBirth = '09' then 'In transit (with NHS ambulance services)'
    when bd.SettingPlaceBirth = '10' then 'In transit (with private ambulance services)'
    when bd.SettingPlaceBirth = '11' then 'In transit (without healthcare services present)'
    when bd.SettingPlaceBirth = '12' then 'Non-domestic and non-health care setting'
    when bd.SettingPlaceBirth = '98' then 'Other (not listed)'
    when bd.SettingPlaceBirth = '99' then 'Not known (not recorded)'
    else bd.SettingPlaceBirth
   end as SettingPlaceBirth,
  case
    when bd.DeliveryMethodCode = 0 then 'Spontaneous Vertex'
    when bd.DeliveryMethodCode = 1 then 'Spontaneous Other Cephalic'
    when bd.DeliveryMethodCode = 2 then 'Low forceps, not breech'
    when bd.DeliveryMethodCode = 3 then 'Other Forceps, not breech'
    when bd.DeliveryMethodCode = 4 then 'Ventouse, Vacuum extraction'
    when bd.DeliveryMethodCode = 5 then 'Breech'
    when bd.DeliveryMethodCode = 6 then 'Breech Extraction'
    when bd.DeliveryMethodCode = 7 then 'Elective caesarean section'
    when bd.DeliveryMethodCode = 8 then 'Emergency caesarean section'
    when bd.DeliveryMethodCode = 9 then 'Other'
    else bd.DeliveryMethodCode
  end as DeliveryMethodCode,
  -------------------------
  -- Admin ----------------
  pb.RPStartDate pb_RPStartDate,
  case
    when os.ovsvischcat = 'A' then 'Standard NHS-funded PATIENT'
    when os.ovsvischcat = 'B' then 'Immigration Health Surcharge payee'
    when os.ovsvischcat = 'C' then 'Charge-exempt Overseas Visitor (European Economic Area)'
    when os.ovsvischcat = 'D' then 'Chargeable European Economic Area PATIENT'
    when os.ovsvischcat = 'E' then 'Charge-exempt Overseas Visitor (non-European Economic Area)'
    when os.ovsvischcat = 'F' then 'Chargeable non-European Economic Area PATIENT'
    when os.ovsvischcat = 'P' then 'Decision Pending'
    when os.ovsvischcat = '0' then 'Not known (not recorded)'
    else os.ovsvischcat
  end as ovsvischcat,
  -------------------------
  -- Neonatal Admission ---
  na.NeonatalTransferStartDate,
  na.NeonatalTransferStartTime,
  na.OrgSiteIDAdmittingNeonatal,
  case
    when na.NeoCritCareInd = 'Y' then 'Yes - the Neonate has been admitted to a neonatal critical care unit'
    when na.NeoCritCareInd = 'N' then 'No - the Neonate has not been admitted to a neonatal critical care unit'
    else na.NeoCritCareInd
  end NeoCritCareInd,
  -------------------------
  -- LPI ------------------
  concat(md.LPIDMother, ' - ', md.OrgIDLPID) mother_lpi_by_provider,
  concat(bd.LPIDBaby, ' - ', bd.OrgIDLocalPatientIdBaby) child_lpi_by_provider
from cohort c 
left join mat_pre_clear.msd101pregnancybooking pb on c.UniqPregID = pb.UniqPregID
left join mat_pre_clear.msd001motherdemog md on pb.RecordNumber = md.RecordNumber
left join mat_pre_clear.msd004overseasvischargcat os on md.RecordNumber = os.RecordNumber
left join mat_pre_clear.msd401babydemographics bd on c.UniqPregID = bd.UniqPregID
left join mat_pre_clear.msd103datingscan ds on c.UniqPregID = ds.UniqPregID
left join mat_pre_clear.msd301labourdelivery ld on c.UniqPregID = ld.UniqPregID
left join mat_pre_clear.msd405careactivitybaby cab on bd.Person_ID_baby = cab.Person_ID_Baby and (cab.birthweight is not null or cab.MasterSnomedCTObsTerm = 'Birth weight (observable entity)')
left join mat_pre_clear.msd402neonataladmission na on pb.UniqPregID = na.UniqPregID
