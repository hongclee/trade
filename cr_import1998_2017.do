clear
use commodity cty_code cty_subco dist_entry gen_val_yr year sic naics using  imp_detl_yearly_98n,clear

save "./../data98n.dta"

use data98n
local peter_dta : dir . files"*.dta"
foreach file of local peter_dta {
*drop _all
   display "using file `file'"
   append  using  `file'
}


only need the following variables
 keep commodity cty_code cty_subco dist_entry gen_val_yr year sic naics2
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


* 1991
only need the following variables
use commodity cty_code cty_subco dist_entry gen_val_yr year sic naics2 using  exp_detl_yearly_91n,clear

now only have exp91 naics

bysort naics : egen exp91_ind = total(exp91)
egen tagnaics = tag(naics exp91_ind)



**import 
now only have imp91 naics

bysort naics : egen exp91_ind = total(imp91)
egen tagnaics = tag(naics imp91_ind)

*merge with NBER


*aggregate trade data98n
*aggregate trade data98n
bysort naics : egen total_imp_val = total(gen_val_yr)
egen tagnaics = tag(naics total_imp_val)
 