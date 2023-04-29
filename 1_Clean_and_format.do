*/------------------------------------------------------------*/
*/Proyect Econometrics II - Time Series */
*/------------------------------------------------------------*/
*/ Facundo Luna
*/ April 2023

*/------------------------------------------------------------*/
*/ Load data
*/------------------------------------------------------------*/

use "${dir}\Data\Data.dta", clear
tsset date

*/------------------------------------------------------------*/
*/ Label variables
label var fed "Fed Funds effective rate"
label var dt "3-month Trasury Bill"
label var gdp "Real GDP growth"
label var Inflation "Inflation"
label var M1 "M1 growth"
label var unrate "Unemp. rate"
label var date "Quartetly date"

*/------------------------------------------------------------*/
*/ Drop post pandemic years
drop if date>=yq(2020,1) | date<=yq(1990,1)

*/------------------------------------------------------------*/
*/ Split data in training and out-of-sample
gen t=_n
egen tot=max(t)
gen sample=(t<=0.8*tot)

drop t tot
save "${dir}\Data\Data_clean.dta", replace




