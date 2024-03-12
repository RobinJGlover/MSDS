# MSDS

Repo to keep track of R scripts / SQL for NCARDRS MSDS Feed Project

## TODO / QUERIES
- When finding previous pregnancy counts, do we want to exclude zeroes? (currently returning earliest submitted value)
- Conflicting baby DOB rule?
- Baby DOB range rules when baby dob not available?
- Dry up distinct values into one method
- Dry up `unique %>% remove from vec %>% sort`
- Comment rules and where shared funcs list which fields are subject to it so user doesn't have to refer to `rationalise_fields::rationalise_data()`
