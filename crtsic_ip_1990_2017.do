

*********************************************************************************
* Merge ship1991 with import data1998_2017

*** Merge with ship_imp_exp91

cd E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\result
use agg_imp_cn1990_1997.dta , clear
append using  agg_imp_cn1998_2017
merge m:1 sic using ship_imp_exp91_sic, gen(trade_impexpship91_ind)
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
drop if year==1990
list in 1/10
*assert total_imp<. & total_imp>0
*list if !(total_imp<. & total_imp>0)


gen ip= total_imp/ (shipment*10^6+ imp91_ind- exp91_ind) if !missing(shipment*10^6+ imp91_ind- exp91_ind)

sum ip
tabstat ip, by(year) stat(mean sd min max)

*save cn_1998_2017trade_ip.dta,replace 
save cn_1998_2017trade_ip_sic.dta,replace
**

 
estpost tabstat    imp91_ind exp91_ind   ip,  c(stat) stat(mean median sd min max n)
   
esttab using "./tables/ChinaOnly1.tex", replace ////
 cells("mean(fmt(%13.4fc)) median(fmt(%13.4fc)) sd(fmt(%13.4fc)) min max count(fmt(%13.0fc))") nonumber ///
  nomtitle nonote noobs label booktabs f ///
  collabels("Mean" "Median" "SD" "Min" "Max" "N")
