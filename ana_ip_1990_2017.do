
*********************************************************************************
* Merge ship1991 with import data1998_2017

*** Merge with ship_imp_exp91

cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\cleandata
use agg_imp_cn1998_2017 , clear
merge m:1 naics using ship_imp_exp91, gen(trade_impexpship91_ind)
/*
 Result                           # of obs.
    -----------------------------------------
    not matched                         1,528
        from master                     1,526  (trade_impexpship91_ind==1)
        from using                          2  (trade_impexpship91_ind==2)

    matched                             6,767  (trade_impexpship91_ind==3)
*/

tab trade_impexpship91_ind

tab  year  if (trade_impexpship91_ind==3)
keep if trade_impexpship91_ind==3
drop trade_impexpship91_ind

list in 1/10
*assert total_imp<. & total_imp>0
list if !(total_imp<. & total_imp>0)


gen ip= total_imp/ (shipment*10^6+ imp91_ind- exp91_ind) if !missing(shipment*10^6+ imp91_ind- exp91_ind)

sum ip
tabstat ip, by(year) stat(mean sd min max)

 
save cn_1998_2017trade_ip.dta,replace
*********************************************************************************
use agg_imp_cn1990_1997 , clear
merge m:1 naics using ship_imp_exp91, gen(trade_impexpship91_ind)
/*
 Result                           # of obs.
    -----------------------------------------
    not matched                         1,528
        from master                     1,526  (trade_impexpship91_ind==1)
        from using                          2  (trade_impexpship91_ind==2)

    matched                             6,767  (trade_impexpship91_ind==3)
*/

tab trade_impexpship91_ind

tab  year  if (trade_impexpship91_ind==3)
keep if trade_impexpship91_ind==3
drop trade_impexpship91_ind

list in 1/10
*assert total_imp<. & total_imp>0
list if !(total_imp<. & total_imp>0)


gen ip= total_imp/ (shipment*10^6+ imp91_ind- exp91_ind) if !missing(shipment*10^6+ imp91_ind- exp91_ind)

sum ip
tabstat ip, by(year) stat(mean sd min max)

 
save cn_1990_2017trade_ip.dta,replace

******
use  cn_trade_ip.dta, clear
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

