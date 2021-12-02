/**************************************************************************
*
* ok_all_trade.dta 
* US import Only from China
* We use the pce-december
* pce 1991.12=68.321, 1997.M12 ==77.613 
*deflator:
 *68.321/77.613 =0.88027779
* in the original PCE index, 2012 as 100. we will not use
* this baseline, to be consistent with shipment deflator baseline 1997==1
* so the imp and exp need to multiply this value
**************************************************************************/
* E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData
*import delim E:\FinanceCourse\2021Fall\EconSeminar\project\trade_data\tradeData\PCEPILFE1990_2021.csv,clear
import delim PCEpilfe1990_2021.csv,clear
gen date2 = date(date, "YMD")
list in 1/10
format date2 %td
gen month=month(date2)
gen year=year(date2)
list in 1/20
keep if year>1990 & month ==12

gen pce=pcepilfe/77.613
list
label variable pce "pce 1997 has pce==1"
drop month
keep pce pcepilfe year
list
save pce_1997as1.dta
