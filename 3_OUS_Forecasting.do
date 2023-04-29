*/ ************************************************************/
*/ Proyect Econometrics II - Time Series 
*/ ************************************************************/
*/ Facundo Luna*/ April 2023


use "${dir}\Data\Data_clean.dta", clear

*/ ************************************************************/
*/ 3- Out-of-Sample Forecasting
*/ ************************************************************/
*/ Estimate VAR(3) 
*/ ************************************************************/
 var $var if sample==1, lag(1/3)
 estimates store VAR

*/ ************************************************************/
*/ Forecasting with VAR(3) - 4 steps ahead
*/ ************************************************************/
fcast compute var_, step(4) dynamic(tq(2014q1))
fcast graph var_fedfunds var_gdp var_Inflation var_M1  , observed 
graph export "${dir}\Figures\Figure3.png", replace


*/ ************************************************************/
*/ Bayesian VAR(3)
*/ ************************************************************/
*Minnesota prior with multivariate Jeffreys prior for error covariance
bayes,  rseed(17) saving(b1.dta, replace) minnjeffprior: var $var if sample==1, lags(1/3) 
estimates store Jeffreys
bayesfcast compute jeff_, step(4) dynamic(tq(2014q1))
bayesfcast graph jeff_fedfunds jeff_gdp jeff_Inflation jeff_M1, byopts(title("Diffuse Prior")) observed
graph export "${dir}\Figures\Figure4.png", replace

*Minnesota Prior
bayes,  rseed(17) saving(b1.dta, replace) minnfixedcovprior(selftight(0.5) crosstight(0.1)) : var $var if sample==1, lags(1/3)
estimates store Minnesota
bayesfcast compute minn_, step(4) dynamic(tq(2014q1))
bayesfcast graph minn_fedfunds minn_gdp minn_Inflation minn_M1, byopts(title("Minnesota Prior")) observed
graph export "${dir}\Figures\Figure5.png", replace


*Conjugate Minnesota prior for VAR coefficients and error covariance;
bayes, rseed(17) saving(b1.dta,replace) minnconjprior(selftight(0.5) ): var $var if sample==1, lags(1/3)
estimates store Conjugate
bayesfcast  compute conj_, step(4) dynamic(tq(2014q1))
bayesfcast graph conj_fedfunds conj_gdp conj_Inflation conj_M1, byopts(title("Conjugate Prior")) observed
graph export "${dir}\Figures\Figure6.png", replace


* Minnesota prior with inverse-Wishart prior for error covariance
matrix b0=J(4,1,0.1)
matrix omega0=diag(J(4,1,1))
bayes, rseed(17)saving(b1.dta, replace)  minniwishprior(mean(b0) selftight(0.5) crosstight(0.1)): var $var if sample==1, lags(1/3)
estimates store IW
bayesfcast compute iw_, step(4) dynamic(tq(2014q1))
bayesfcast graph iw_fedfunds iw_gdp iw_Inflation iw_M1, byopts(title("Inverse Normal Wishart Prior")) observed
graph export "${dir}\Figures\Figure7.png", replace

asdoc bayestest model Jeffreys Minnesota Conjugate IW, save(Table5.doc) replace
qui bayestest model Jeffreys Minnesota Conjugate IW
mat A=r(test)

*/ Bayesian model averaging (BMA)
foreach vars in $var{
	gen bma_`vars'=A[1,3]*jeff_`vars' + A[2,3]*minn_`vars' + A[3,3]*conj_`vars' + A[4,3]*iw_`vars'
}


*/ Perform Diebold-Mariano test for dynamic forecasting
 */ ************************************************************/ 
 */ Set the Excel File to store results for DM test
*/ ************************************************************/
putexcel set "${dir}\Tables\dmariano.xlsx",  replace
putexcel A1="Variable"
putexcel A2="Fed Funds Rate"
putexcel A3="Real GDP growth"
putexcel A4="Inflation"
putexcel A5="M1 growth"
putexcel B1="VAR"
putexcel C1="Diffuse "
putexcel E1="Minnesota "
putexcel G1="Conjugate "
putexcel I1="Inverse-Wishart " 
putexcel K1="BMA " 

local i=2
foreach vars in $var  {
dmariano `vars'  var_`vars'  jeff_`vars'    , crit(MAE) kernel(bartlett)	
putexcel B`i'= `r(e1bar)'
putexcel C`i'= `r(e2bar)'
putexcel D`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var  {
dmariano `vars'  var_`vars'  minn_`vars'   , crit(MAE) kernel(bartlett)	
putexcel E`i'= `r(e2bar)'
putexcel F`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var  {
dmariano `vars'  var_`vars'  conj_`vars'  , crit(MAE) kernel(bartlett) 	
putexcel G`i'= `r(e2bar)'
putexcel H`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var  {
dmariano `vars'  var_`vars'  iw_`vars'    	, crit(MAE) kernel(bartlett)
putexcel I`i'= `r(e2bar)'
putexcel J`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var  {
dmariano `vars'  var_`vars'  bma_`vars'    	, crit(MAE) kernel(bartlett)
putexcel K`i'= `r(e2bar)'
putexcel L`i'= (`r(p)')
local i=`i'+1
}




*/ ************************************************************/
*/ Forecasting with VAR(3) - 24 steps ahead
*/ ************************************************************/
est restore VAR
fcast compute var24_, step(24) dynamic(tq(2014q1))
fcast graph var24_fedfunds var24_gdp var24_Inflation var24_M1  , observed 
graph export "${dir}\Figures\Figure3_24.png", replace


*/ ************************************************************/
*/ Forecasting with BVAR(3) - 24 steps ahead
*/ ************************************************************/
*Minnesota prior with multivariate Jeffreys prior for error covariance
est restore Jeffreys
bayesfcast compute jeff24_, step(24) dynamic(tq(2014q1))
bayesfcast graph jeff24_fedfunds jeff24_gdp jeff24_Inflation jeff24_M1, byopts(title("Diffuse Prior")) observed
graph export "${dir}\Figures\Figure4_24.png", replace


*Minnesota Prior
est restore Minnesota
bayesfcast compute minn24_, step(24) dynamic(tq(2014q1))
bayesfcast graph minn24_fedfunds minn24_gdp minn24_Inflation minn24_M1, byopts(title("Minnesota Prior")) observed
graph export "${dir}\Figures\Figure5_24.png", replace


*Conjugate Minnesota prior for VAR coefficients and error covariance;
est restore Conjugate
bayesfcast  compute conj24_, step(24) dynamic(tq(2014q1))
bayesfcast graph conj24_fedfunds conj24_gdp conj24_Inflation conj24_M1, byopts(title("Conjugate Prior")) observed
graph export "${dir}\Figures\Figure6_24.png", replace


* Minnesota prior with inverse-Wishart prior for error covariance
est restore IW
bayesfcast compute iw24_, step(24) dynamic(tq(2014q1))
bayesfcast graph iw24_fedfunds iw24_gdp iw24_Inflation iw24_M1, byopts(title("Inverse Normal Wishart Prior")) observed
graph export "${dir}\Figures\Figure7_24.png", replace

*/ Bayesian model averaging (BMA)
foreach vars in $var{
gen bma24_`vars'=A[1,3]*jeff24_`vars' + A[2,3]*minn24_`vars' + A[3,3]*conj24_`vars' + A[4,3]*iw24_`vars'
}


*/ Perform Diebold-Mariano test for dynamic forecasting
 */ ************************************************************/ 
 */ Set the Excel File to store results for DM test
*/ ************************************************************/
putexcel set "${dir}\Tables\dmariano_24.xlsx",  modify
putexcel A1="Variable"
putexcel A2="Fed Funds Rate"
putexcel A3="Real GDP growth"
putexcel A4="Inflation"
putexcel A5="M1 growth"
putexcel B1="VAR"
putexcel C1="Diffuse Prior"
putexcel E1="Minnesota Prior"
putexcel G1="Conjugate Prior"
putexcel I1="Inverse-Wishart Prior" 
putexcel K1="BMA"

local i=2
foreach vars in $var {
dmariano `vars'  var24_`vars'  jeff24_`vars'    , crit(MAE) kernel(bartlett)	
putexcel B`i'= `r(e1bar)'
putexcel C`i'= `r(e2bar)'
putexcel D`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var {
dmariano `vars'  var24_`vars'  minn24_`vars'   , crit(MAE) kernel(bartlett)	
putexcel E`i'= `r(e2bar)'
putexcel F`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var {
dmariano `vars'  var24_`vars'  conj24_`vars'  , crit(MAE) kernel(bartlett) 	
putexcel G`i'= `r(e2bar)'
putexcel H`i'= (`r(p)')
local i=`i'+1
}

*/ Diebold- Mariano test
local i=2
foreach vars in $var {
dmariano `vars'  var24_`vars'  iw24_`vars'    	, crit(MAE) kernel(bartlett)
putexcel I`i'= `r(e2bar)'
putexcel J`i'= (`r(p)')
local i=`i'+1
}

local i=2
foreach vars in $var  {
dmariano `vars'  var24_`vars'  bma24_`vars'    	, crit(MAE) kernel(bartlett)
putexcel K`i'= `r(e2bar)'
putexcel L`i'= (`r(p)')
local i=`i'+1
}

*/ Graph forecasting
gen sample_1=var_fedfunds!=.
gen sample_2=var24_M1!=.

foreach vars in $var  {
tsline `vars' var_`vars' jeff_`vars' minn_`vars' conj_`vars' iw_`vars' bma_`vars' if sample_1==1, legend(order(1 "Observed" 2 "VAR" 3 "Jeffreys" 4 "Minnesota" 5 "Conjugate" 6 "Inverse-Wishart" 7 "BMA")) saving(`vars'_4, replace)
graph export "${dir}\Figures\Figure8_`vars'.png", replace
tsline `vars' var24_`vars' jeff24_`vars' minn24_`vars' conj24_`vars' iw24_`vars' bma24_`vars' if sample_2==1, legend(order(1 "Observed" 2 "VAR" 3 "Jeffreys" 4 "Minnesota" 5 "Conjugate" 6 "Inverse-Wishart" 7 "BMA")) saving(`vars'_24, replace)
graph export "${dir}\Figures\Figure8_`vars'_24.png", replace
}
