cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData

clear
use  cty_code  gen_val_yr year sic naics using imp_detl_yearly_98n,clear
keep if cty_code == 5700

save data98n, replace
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
* Merge the imported *.dta files, 1998 to 2017
* data98n is the master file, year 1998 is the first year that the cbp data uses naics code  
use E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\data98n,clear
local cn_peter_dta : dir . files"CN_*.dta"
foreach file of local cn_peter_dta {
*drop _all
   display "using file `file'"
   append  using  `file'
}
drop cty_code

gen naics5=substr(naics, 1,5)
save agg_No_imp_cn1998_2017,replace

*******************************************************
* Deflator

* need to inflat
*All import amounts are inflated to 2012 US dollars using
* the Personal Consumption Expenditure Core(PCE) deflator

use E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\Import98_2017\agg_No_imp_cn1998_2017,clear
merge m:1 year using  pce_1997as1.dta
/*
. tab _merge

                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         using only (2) |         10        0.00        0.00
            matched (3) |  5,147,074      100.00      100.00
------------------------+-----------------------------------
                  Total |  5,147,084      100.00
*/
drop _merge
* adjust with pce with 1997==1
* Deflate the total imported values
replace gen_val_yr = gen_val_yr/pce
* aggregate to naics level
*gen naics5=substr(naics, 1,5)
bysort year sic: egen  total_imp = total(gen_val_yr)
label variable total_imp "Per SIC Imported value deflator with 1997==1"
egen tagyearnaics = tag(year sic)
tab year if tagyearnaics==1
keep if tagyearnaics==1
keep year sic naics total_imp
save agg_imp_cn1998_2017, replace


*******************************************************************************************
* From 1990 to 1997, in cbp data it only has sic, so
* can merge with cbp by sic
* Therefore we will aggregage by sic here
*******************************************************************************************
 cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\imp1990_1997
 local peter_dta : dir . files"*.dta"
foreach file of local peter_dta {
*drop _all
   display "using file `file'"
   use cty_code gen_val_yr year sic naics using `file',clear
   keep if cty_code == 5700
   save CN_`file'
 *  append  using  `file'
}
* 1990 data: aCN_imp_detl_yearly_90n.dta is the master file
* Merge with data in year 1991-1997
use   aCN_imp_detl_yearly_90n.dta,clear
local cn_peter_dta : dir . files"CN_*.dta"
foreach file of local cn_peter_dta {
*drop _all
   display "using file `file'"
   append  using  `file'
}
drop cty_code
save imp_cn1990_1997,replace

/*
Merge with PCE data to deflat the imported values
master:
Using:  pce_1997as1.dta
*/

merge m:1 year using  pce_1997as1.dta
/*
  -----------------------------------------
    not matched                        54,934
        from master                    54,911  (_merge==1)
        from using                         23  (_merge==2)

    matched                           663,929  (_merge==3)
    -----------------------------------------
*/
drop _merge
* gen naics5=substr(naics, 1,5)
* Deflate the total imported values
replace gen_val_yr = gen_val_yr/pce
* bysort year naics5: egen  total_imp = total(gen_val_yr)
bysort year sic: egen  total_imp = total(gen_val_yr)
label variable total_imp "Per SIC Imported value deflator with 1997==1"
 
egen tagyear_sic = tag(year sic)
tab year if tagyear_sic==1
keep if tagyear_sic==1
 
 
keep year sic naics  total_imp
save "agg_imp_cn1990_1997.dta", replace
 
 
