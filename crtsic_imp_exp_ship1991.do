log using "E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\Day1.smcl"
cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData
/*
only need the following variables
use commodity cty_code cty_subco dist_entry gen_val_yr year sic naics2 using  exp_detl_yearly_91n,clear
Input:
use imp_detl_yearly_91n.dta
use exp_detl_yearly_91n.dta

Output:
total import in each naics: imp91_ind imp91.dta
total export in each naics: exp91_ind in exp91.dta
imp91_exp91_merged.dta : merge imp91 and exp91 

*
use imp_detl_yearly_91n.dta
after agregate, imp91.dta only have total U.S. import values of each naics
save imp91.dta,
*
use exp_detl_yearly_91n.dta
after agregate, emp91.dta only have total U.S. export values of each naics
save exp91.dta
Merge with NBER-1991 Vshipment
 ship_imp_exp91.dta
*/
// 5700 5,147,074 14.61 
// 5800 1,061,423     3.01
// 5830 |  1,642,443      4.66     
// 5880 |  2,102,058   5.97

*CHINA M cty_code 5700
*CHINA T cty_code 5830
**********************************************************************************
* Employment data: CBP-Current Business Pattern
* CES-Current Employment Servey
*https://www.census.gov/programs-surveys/cbp.html
*  Step1 1991 data
**********************************************************************************
** Export 91
** Data: exp_detl_yearly_91n.dta
** Variables
** cty_code sic naics year 
** all_val_year: total export values, 15-digit year-to-Date Total value
use exp_detl_yearly_91n.dta

* Check total exported values
sum all_val_yr
disp %19.6gc r(sum)
*421,853,582,099

*https://wits.worldbank.org/CountryProfile/en/Country/USA/Year/1991/Summarytext
* shows U.S total export is: 421,555 million.
* https://www.statista.com/statistics/186577/volume-of-us-exports-of-trade-goods-to-the-world-since-1987/
* show 421.73 Billion
* nber shows 400,842,402,497
* Check total exported to China
sum all_val_yr if cty_code == 5700
disp %19.6gc r(sum)
* 6,286,832,744

* census.gov 
* https://www.census.gov/foreign-trade/balance/c5700.html#1991
*in millions of U.S. dollars on a nominal basis, not seasonally adjusted unless otherwise specified.
** 6,278.2
**  0.8802778 is the 1991 pce adjust ment with 1997 pce index==1

keep sic naics all_val_yr

replace all_val_yr = all_val_yr/0.8802778
save exp91.dta, replace
use exp91, clear
/* Note:
If merge by naics first, there are 458 unique Naics code, 
* among which 358 sic codes are unique 
First merge by Sic then merge by naics, ***we can get more unique  SIC code
*/
* bysort naics : egen exp91_ind = total(all_val_yr)
bysort sic : egen exp91_ind = total(all_val_yr)
label variable exp91_ind "Per SIC total export in 1991"
*Aggregagte all export 
* egen tagnaics = tag(naics exp91_ind)
 
egen tagnaics = tag(sic exp91_ind)
keep if (tagnaics==1)
keep sic naics exp91_ind
 
save exp91_sic.dta, replace
* Contains data from exp91.dta
*  obs:           454  

**********************************************************************************
** import 91
* now only have imp91 naics
** Data: imp_detl_yearly_91n.dta
** Variables
** cty_code sic naics year 
** gen_val_year: total export values, 15-digit year-to-Date Total value
cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\Import1990_1997
use imp_detl_yearly_91n.dta
* Check total imported values

sum gen_val_yr
disp %19.6gc r(sum)
*488,122,838,063

* https://wits.worldbank.org/CountryProfile/en/Country/USA/Year/1991/Summarytext
* shows that:
* The U.S. total value of imports (CIF) was 508,944 million.


* Check total imported to China
sum gen_val_yr if cty_code == 5700
disp %19.6gc r(sum)
*  18,975,797,651

* census.gov 
* https://www.census.gov/foreign-trade/balance/c5700.html#1991
*in millions of U.S. dollars on a nominal basis, not seasonally adjusted unless otherwise specified.
** 18,969.2 million
** scalar pce adjust with 1997 ==1
** 1991 has adj value = .8802778
* scalar pce1991=  .8802778
keep sic naics gen_val_yr
replace gen_val_yr = gen_val_yr/0.8802778
bysort naics  : egen imp91_ind = total(gen_val_yr)
label variable imp91_ind "Per naics total import in 1991"
*bysort sic : egen imp91_ind = total(gen_val_yr)
* label variable imp91_ind "Per SIC total import in 1991"
*put the following adjust at the end of the merged file
* replace imp91_ind= imp91_ind/ 0.8802778
* Aggregate all import by naicscode
egen tagnaics = tag(naics  imp91_ind)
*egen tagnaics = tag(sic imp91_ind)
keep if tagnaics==1
keep sic naics imp91_ind
save imp91_sic.dta, replace
* observations: 458  
*****************************************************************************
** Merge 1991 import + export 
**
* Merge 91imp with 91 exp_*
*
* Memory Data---imp91.dta
sum imp91_ind

/*
Merge imp91 with exp91.dta
*/
* merge 1:1 naics using exp91, gen(imp_exp_indicator)
merge 1:1 sic using exp91_sic, gen(imp_exp_indicator)
tab imp_exp_indicator
/*
      imp_exp_indicator |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |          3        0.67        0.67
         using only (2) |          3        0.67        1.34
            matched (3) |        443       98.66      100.00
------------------------+-----------------------------------
                  Total |        449      100.00
*/
* Keep only mached records
* assert(imp_exp_indicator==3)
drop if imp_exp_indicator != 3
drop imp_exp_indicator

* Need to aggregate in Naics level inorder to merge with NBER data,
* which only has NAICS code
* imp91_ind
* bysort naics  : egen imp91_ind = total(gen_val_yr)
*gen naics5=substr(naics, 1,5)
save imp91_exp91_sic_merged, replace
* use imp91_exp91_merged// merged by naics2
 
/*
 Total 443 unique SIC codes, and 367 unique NAICS among theml
          1 |        367       82.84      100.00
------------+-----------------------------------
      Total |        443      100.00
*/
 
 

**********************************************************************************
** Merge with NBER 1991 data to get shipment data
** Data nberces1991.dta
** Downloaded from:
** 
** variables in nber:
* naics: str6 %9s, NAICS 1997 6-digit industry
* emp: double %9.0g (total employment in 1000s)
* prode: 
* aggregate trade data98n

* Merge shipment (=VShip/piship) with imp1991 + exp1991
use imp91_exp91_sic_merged, clear
rename imp91_ind imp91_ind_sic
rename exp91_ind exp91_ind_sic
bysort naics: egen imp91_ind = total(imp91_ind_sic)
bysort naics: egen exp91_ind = total(exp91_ind_sic)
save imp91_exp91_1stsic_2ndnaics_merged, replace
egen tabnaics=tag(naics)
/*
. tab tabnaics

 tag(naics) |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         76       17.16       17.16
          1 |        367       82.84      100.00
------------+-----------------------------------
      Total |        443      100.00
*/
keep if tabnaics==1
drop *_sic tabnaics 
save, replace



use nberces5818v1_n1997.dta,clear
keep if year==1991

* vship/piship: need to appy the deflator by 1997==1
gen shipment = vship/piship
keep naics shipment emp
tostring naics, replace
*gen naics5=substr(naics, 1,5)
*label variable naics5 "The first 5 digits of naics"
label variable shipment "Deflator Adjusted shipment values" 
* 473 records left

describe shipment
summarize shipment
/*
   Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    shipment |        469    6266.449    10998.93   143.1125   149579.7
*/

save nberces_clean_1991, replace
use nberces_clean_1991,clear

tostring naics,replace
* merge 1:1 naics using imp91_exp91_merged, gen(imp_exp91_nberces91)
* merge 1:1 naics using imp91_exp91_sic_merged, gen(imp_exp91_nberces91)
merge 1:1 naics using imp91_exp91_1stsic_2ndnaics_merged, gen(imp_exp91_nberces91)

tab imp_exp91_nberces91
/*
   imp_exp91_nberces91 |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        161       30.49       30.49
         using only (2) |         55       10.42       40.91
            matched (3) |        312       59.09      100.00
------------------------+-----------------------------------
                  Total |        528      100.00
*/
				  
keep if imp_exp91_nberces91 == 3
drop imp_exp91_nberces91
 

save ship_imp_exp91_sic, replace

* Finish 1991 merge now.
