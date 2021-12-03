*only need the following variables
* keep commodity cty_code cty_subco dist_entry gen_val_yr year sic naics
/*
to calculate the changes in import values  

keep 

Contains data from nberces1991.dta
  obs:           473                          
 vars:             6                          8 Nov 2021 17:29
--------------------------------------------------------------------------------------------------------
              storage   display    value
variable name   type    format     label      variable label
--------------------------------------------------------------------------------------------------------
naics           long    %12.0g                NAICS 1997 6-digit industry
year            float   %8.0g                 Year ranges from 1958 to 2018
emp             double  %9.0g                 Total employment in 1000s
prode           double  %9.0g                 Production workers in 1000s
vship           double  %10.0g                Total value of shipments in $1m
piship          float   %9.0g                 Deflator for VSHIP 1997=1.000

*/