# MSDS

Repo to keep track of R scripts / SQL for NCARDRS MSDS Feed Project

## TODO / QUERIES
- Add in a unique MSDS ID column, this will be UniqPregID + digits of baby nhs or just UniqPregID when no baby nhs. Seperate by under or slash or whatever
- Clear up ethnicity if more specific available
- When finding previous pregnancy counts, do we want to exclude zeroes? (currently returning earliest submitted value)
- Conflicting baby DOB rule?
- Baby DOB range rules when baby dob not available?
- Loop over data by distinct uniq_preg_id baby_dob pairs, select these into a table and unique it then use that to partition.
- Dry up distinct values into one method
- Dry up `unique %>% remove from vec %>% sort`
- Unified outcome / termination fields from various contributing fields from MSDS whilst maintaining individual fields for MSDS? or just where boiling down the multiple fields returns multiple values do we show this in the event?
- Comment rules and where shared funcs list which fields are subject to it so user doesn't have to refer to `rationalise_fields::rationalise_data()`
- EDD method when we calculate from gestation at birth?

## Fetuses Rules (remove zeroes)
### Early
### 103DatingScan:
NoFetusesDatingUltrasound
LocalFetalID
FetalOrder

### Delivery
- birthsperdelivery derivation (redo and match)
- max distinct localfetalids in baby table or max distinct nhs numbers in baby table
