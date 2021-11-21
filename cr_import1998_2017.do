cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData
clear
use  cty_code  gen_val_yr year sic naics using imp_detl_yearly_98n,clear
keep if cty_code == 5700
save "./../data98n.dta",replace

save data98n, replace
use E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\data98n, replace
cd ./Import98_2017
local peter_dta : dir . files"*.dta"
foreach file of local peter_dta {
*drop _all
   display "using file `file'"
   use cty_code gen_val_yr year sic naics using `file',clear
   keep if cty_code == 5700
   save CN_`file'
 *  append  using  `file'
}
use E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\data98n,clear
local cn_peter_dta : dir . files"CN_*.dta"
foreach file of local cn_peter_dta {
*drop _all
   display "using file `file'"
   append  using  `file'
}
drop cty_code
save imp_cn1998_2017,replace
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


* 1991
 
*merge with NBER


*aggregate trade data98n
*aggregate trade data98n
 