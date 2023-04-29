*/------------------------------------------------------------*/
*/Proyect Econometrics II - Time Series */
*/------------------------------------------------------------*/
*/ Facundo Luna */ April 2023

*/ Preamble

set more off, permanently
set scheme gg_tableau

global dir = "C:\Users\rl870\Box\Proyect-Econometrics II\"
cd "$dir"

* Global of variables
global var =  "fedfunds gdp Inflation M1"

*/------------------------------------------------------------*/
*/ Run codes */

* 1-Clean and format data
do "${dir}\1_Clean_and_format.do"

* 2- Data Analysis and basic tests
do "${dir}\2_Analysis.do"

* 3-Perform Out of sample forecasting and tests
do "${dir}\3_OUS_Forecasting.do"
