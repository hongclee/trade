log using "E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\Day1.smcl"
cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data
/*
only need the following variables
use commodity cty_code cty_subco dist_entry gen_val_yr year sic naics2 using  exp_detl_yearly_91n,clear

after agregate, imp91.dta only have total import values of each naics
*/

CHINA M cty_code 5700
CHINA T cty_code 5830
**********************************************************************************
*  Step1 1991 data
**********************************************************************************
** Export 91
** Data: exp_detl_yearly_91n.dta
** Variables
** cty_code sic naics year 
** all_val_year: total export values, 15-digit year-to-Date Total value
use exp_detl_yearly_91n.dta

* Check total exported values
sum all_val_year
disp %19.6gc r(sum)
*421,853,582,099

*https://wits.worldbank.org/CountryProfile/en/Country/USA/Year/1991/Summarytext
* shows U.S total export is: 421,555 million.
* https://www.statista.com/statistics/186577/volume-of-us-exports-of-trade-goods-to-the-world-since-1987/
* show 421.73 Billion
* Check total exported to China
sum all_val_year if cty_code == 5700
disp %19.6gc r(sum)
* 6,286,832,744

* census.gov 
* https://www.census.gov/foreign-trade/balance/c5700.html#1991
*in millions of U.S. dollars on a nominal basis, not seasonally adjusted unless otherwise specified.
** 6,278.2
keep naics all_val_year
bysort naics : egen exp91_ind = total(all_val_year)
egen tagnaics = tag(naics exp91_ind)
save exp91.dta, replace

**********************************************************************************
** import 91
* now only have imp91 naics
** Data: imp_detl_yearly_91n.dta
** Variables
** cty_code sic naics year 
** gen_val_year: total export values, 15-digit year-to-Date Total value
use imp_detl_yearly_91n.dta
* Check total imported values

sum gen_val_year
disp %19.6gc r(sum)
*488,122,838,063

* https://wits.worldbank.org/CountryProfile/en/Country/USA/Year/1991/Summarytext
* shows that:
* The U.S. total value of imports (CIF) was 508,944 million.


* Check total imported to China
sum gen_val_year if cty_code == 5700
disp %19.6gc r(sum)
*  18,975,797,651

* census.gov 
* https://www.census.gov/foreign-trade/balance/c5700.html#1991
*in millions of U.S. dollars on a nominal basis, not seasonally adjusted unless otherwise specified.
** 18,969.2 million

keep naics gen_val_yr
bysort naics  : egen imp91_ind = total(gen_val_yr)
egen tagnaics = tag(naics imp91_ind)
save imp91.dta, replace
*****************************************************************************
** Merge 1991 import + export 
**
* Merge 91imp with 91 exp_*
*
use "E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\exp91.dta"
sum exp91_ind
list exp91_ind in 1/10
use imp91
sum imp91_ind

/*
Merge imp91 with exp91
*/
use imp91
merge 1:1 naics using exp91

* Keep only mached records
drop if _merge !=3
save imp_exp91

use imp_exp91


**********************************************************************************
** Merge with NBER 1991 data to get shipment data
** Data nberces1991.dta
** Downloaded from:
** 
** variables in nber:
* naics: str6 %9s, NAICS 1997 6-digit industry
* emp: double %9.0g (total employment in 1000s)
* prode: 
*aggregate trade data98n

* Merge VShip with imp1991 + exp1991
use nberces1991
sum emp
d vship
sum vship

merge 1:1 naics using imp_exp91, gen(last)
keep if last ==3
save ship_imp_exp, replace

bysort naics : egen total_imp_val = total(gen_val_yr)
egen tagnaics = tag(naics total_imp_val)
sum *ind

use ship_imp_exp

drop ship_imp*


use us_imp_from_cn
d
sum *ind
drop *ind
save
use data98n
clear
use data98n
merge m:1 naics using ship_imp_exp91
merge m:1 naics using ship_imp_exp91, gen(lasts)
keep if lasts==3
save ok_all_trade.dta
list in 1/10
gen ip= gen_val_yr/ (vship*10^6+ imp91_ind- exp91_ind)
sum ip
sum *_ind vship
drop _merge
save, replace
est clear  // clear the est locals
estpost tabstat
est clear
estpost tabstat *ind vship ip
ssc install estout, replace
estpost tabstat *ind vship ip  c(stat) stat(mean sd min max n)
ereturn list
estpost tabstat imp91_ind exp91_ind vship ip  c(stat) stat(mean sd min max n)
sum imp91_ind exp91_ind vship ip
estpost tabstat imp91_ind exp91_ind vship ip,  c(stat) stat(mean sd min max n)
esttab, ///
 cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
  nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N")
. format ip %11.4gc
list ip in 1/10
   
   esttab using "./graphs/guide80/table1.tex", replace ////
 cells("mean(fmt(%13.4fc)) sd(fmt(%134fc)) min max count") nonumber ///
  nomtitle nonote noobs label booktabs f ///
  collabels("Mean" "SD" "Min" "Max" "N")
tab cty_code
keep if cty_code ==5700
d
save formidterm.dta
save, replace

******************************
tab year
save, replace
ls *imp*.dta
use imp_exp91
d
drop _merge
save, replace
use ship_imp_exp91
d
drop _merge last
save, replace
use data98n
list in 1/10
use ok_all_trade
list in 1/10
d
use data98n
d
bysort naics : egen total_imp_val = total(gen_val_yr)
egen tagnaics = tag(naics total_imp_val)
drop commo*
d
tab cty_code
keep if cty_code ==5700
d
drop total_imp*
drop tagna*
d
bysort naics : egen total_imp_val = total(gen_val_yr)
egen tagnaics = tag(naics total_imp_val)
tab tagnaics
list in 1/10
bysort naics(year) : replace total_imp_val = total(gen_val_yr)
drop total_imp_val
bysort year(naics) : egen total_imp_val = total(gen_val_yr)
egen tagnaics = tag(year naics total_imp_val)
drop tagnaics
egen tagnaics = tag(year naics total_imp_val)
keep if tagnaics==1
d
tab year
d
drop cty_*
d
drop dist_*
d
tag tagnaics
tab tagnaics
drop tagnaics
d
save, cleanTradeData
save cleanTradeData.dta
d
merge m:1 naics using ship_imp_exp91
keep if _merge==3
list 1/10
list in 1/10
list in 1/20, sepby(year)
sort year naics
list in 1/20, sepby(year)
drop _merge
save
save, replace
list in 1/20, sepby(year)
gen ip= gen_val_yr/ (vship*10^6+ imp91_ind- exp91_ind)
sum ip
d
do "C:\Users\hcli\AppData\Local\Temp\STD1e44_000000.tmp"
save, replace
log close


 //////

esttab, ///
 cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
  nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N")
  
  esttab using "./result/table1.tex", replace ////
 cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
  nomtitle nonote noobs label booktabs f ///
  collabels("Sum" "Mean" "SD" "Min" "Max" "N")
  
   estpost tabstat  total_imp_val imp91_ind exp91_ind vship ip,  c(stat) stat(mean sd min max n)
   
   esttab using "./result/ChinaOnly1.tex", replace ////
 cells("mean(fmt(%13.4fc)) sd(fmt(%13.4fc)) min max count") nonumber ///
  nomtitle nonote noobs label booktabs f ///
  collabels("Mean" "SD" "Min" "Max" "N")

*/

