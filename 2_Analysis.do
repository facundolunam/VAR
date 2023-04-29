*/ ************************************************************/
*/ Proyect Econometrics II - Time Series 
*/ ************************************************************/
*/ Facundo Luna*/ April 2023


use "${dir}\Data\Data_clean.dta", clear

*/ ************************************************************/
*/ 2-Analysis
*/ ************************************************************/
*/ Summary Statistics
estpost  sum ${var}, detail
esttab using "${dir}\Tables\Table1.tex", ///
cells("count(fmt(0)) mean(fmt(1)) sd(fmt(1)) min(fmt(1)) max(fmt(1))") ///
nonumber booktabs nomtitles nonotes replace


*/ ************************************************************/
*/Graph the time series of each variable
multiline fedfunds gdp Inflation M1 date ,  xtitle("") xla(120(10)239,format("%tq_Cy")) ytitle("%") 
graph export "${dir}\Tables\Figure1.png", replace


*/ ************************************************************/
*/Lag Selection for frequentist VAR
*/ ************************************************************/
 varsoc ${var} if sample==1, lutstats
 asdoc varsoc $var if sample==1, save(Table2.doc)
*/ Optimal lag is 3 according to LR, FPE and AIC.
 

*/ ************************************************************/
*/ Estimate VAR(3) and granger causality test 
*/ ************************************************************/
 var $var if sample==1, lag(1/3)
 estimates store VAR
 
 */ Granger Causality test
asdoc vargranger, save(Table4.doc) replace
