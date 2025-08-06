********************************* ETHIOPIA: CONSUMPTION AGGREGATES (round 2)*****************************************
************************************** YOUNGER COHORT ***************************************************************

clear
set mem 50m
set more off


global data 	N:\Quantitative research\Data\r2\ethiopia


use              "$data\yc\constructed\cpi_r2.dta", clear
sort region month
tempfile cpi
save    `cpi'

use               "$data/yc/raw/etchildlevel5yrold.dta", clear

*recoding missing values to 0

qui recode eatv* ownv* giftv*   (.=0) (-77 -88 -99=0)
qui recode spend* spndyr* spyr* (.=0) (-77 -88 -99=0)
sum eatv* ownv* giftv*
sum spend* spndyr* spyr*


********************** FOOD EXPENDITURE ************************************************************************************ 

egen fpurchv2w=rowtotal(eatv*)   //value of food bought and consumed in the last 2 weeks 
egen fownv2w  =rowtotal(ownv*)   //value of food consumed from own harvest/stock in the last 2 weeks
egen fgiftv2w =rowtotal(giftv*)  //value of edible gifts consumed in the last 2 weeks 

********************** EDUCATION EXPENDITURE  ******************************************************************************* 

egen eduexpyr=rowtotal(spyr09-spyr16)
label var eduexpyr "Annual expenditure on education" 

gen eduexp_month=eduexpyr/12
label var eduexp_month "Monthly expenditure on education" 


********************** MEDICAL EXPENDITURE *********************************************************************************

egen medexpyr=rowtotal(spyr17-spyr18)
label var medexpyr "Annual expenditure on medical" 

gen medexp_month=medexpyr/12
label var medexp_month "Monthly expenditure on medical" 


********************** CLOTHING EXPENDITURE ********************************************************************************

egen clexpyr=rowtotal(spyr01-spyr08)	
label var clexpyr "Annual expenditure on clothing" 

gen clexp_month=clexpyr/12
label var clexp_month "Monthly expenditure on clothing" 


********************** OTHER NON-FOOD EXPENDITURE ************************************************************************** 

egen s42v30d=rowtotal(spend01-spend06)    //spending on cigs, personal care, firewood/kero/batteries etc, internet, public transport, security
gen s42expyr=s42v30d*12 			//above - per year 			
egen s43expyr=rowtotal(spndyr07-spndyr11) //spending on rent, dwelling maintenance, cleaning materials, rent (business), water, electricity, phone, vehicle maintenance, fees, paperwork, legal advice, bribes, festivals, celebrations, one-off family events */
egen othexpyr=rowtotal(spyr19-spyr23)


************************* TOTAL EXPENDITURE ********************************************************************************* 
*** YEARLY EXPENDITURE

egen nfspend30d=rowtotal(spend*)    // Non-food expenditure 1 - monthly
egen nfspndyr=rowtotal(spndyr*)     // Non-food expendidure 2
egen nfspyr=rowtotal(spyr*)         // Non-food expenditure 3

gen nfexpyr=(12*nfspend30d)+ nfspndyr + nfspyr     // Yearly expenditure in non-food items


gen fpurchvyr=fpurchv2w*26          // Yearly expenditure in food bought and consumed
gen fownvyr=fownv2w*26              // Yearly expenditure in food consumed from own harvest
gen fgiftvyr=fgiftv2w*26            // Yearly expenditure in edible gifts

gen fexpyr=fpurchvyr+fownvyr+fgiftvyr

gen texpyr=fpurchvyr+fownvyr+fgiftvyr+(12*nfspend30d)+ nfspndyr + nfspyr

label var nfexpyr "Annual non-food expenditure"
label var fexpyr "Annual food expenditure"
label var texpyr "Annual total expenditure (food+ non food)" 

*** MONTHLY EXPENDITURE

* food
gen fexp_month5=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)
label var fexp_month "Monthly expenditure in food items"

* Non-food
gen nfexp_month5=(nfspend30d)+(nfspndyr/12)+((nfspyr-spyr21)/12)
label var nfexp_month "Monthly expenditure in non-food items"

* total
gen texp_month5=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)+ (nfspend30d)+(nfspndyr/12)+((nfspyr-spyr21)/12)
label var texp_month "Total monthly expenditure"


*****************EXPENDITURE PER CAPITA AND PER ADULT (nominal values) *******************************************************

* EXPENDITURE PER CAPITA
gen texpm_pc5=texp_month5/hhsize
label var texpm_pc5   "Monthly  consumption per capita"

gen fexpm_pc5=fexp_month5/hhsize
label var fexpm_pc5   "Monthly food consumption per capita"

gen nfexpm_pc5=nfexp_month5/hhsize
label var nfexpm_pc5  "Monthly non-food consumption per capita"

* EXPENDITURE PER ADULT

sort childid
merge childid using "$data\yc\constructed\adultequiv2yc.dta", unique
tab _m
drop _m

gen texpm_pa5=texp_month5/adequiv
label var texpm_pa5   "Monthly  consumption per adult"

gen fexpm_pa5=fexp_month5/adequiv
label var fexpm_pa5   "Monthly food consumption per adult"

gen nfexpm_pa5=nfexp_month5/adequiv
label var nfexpm_pa5  "Monthly non-food consumption per adult"

******************** REAL EXPENDITURE (DEFLATING) ************************************************************************

*** GENERATE VARIABLE OF MONTH OF INTERVIEW - to deflate consumption by the cpi of that month
gen month=.
*November 2006
replace month=1 if dint>=17078 & dint<=17135
*December 2006
replace month=2 if dint>17135 & dint<=17166
*January 2007
replace month=3 if dint>17166 & dint<=17197
*February 2007
replace month=4 if dint>17197 & dint<=17225
*March 2007
replace month=5 if dint>17225 & dint<=17232
*April 2007
replace month=6 if dint>17232 & dint<=17285
*May 2007
replace month=7 if dint>17285 & dint<=17402

label var month "Month of interview"
label define month 1 "Nov06" 2 "Dec06" 3 "Jan07" 4 "Feb07" 5 "Mar07" 6 "Apr07" 7 "May07"
label values month month

**MERGING WITH CPI - monthly cpi's taken from csa-ethiopia

sort region month
merge region month using `cpi'

*** DEFLATING EXPENDITURE

* food expenditure
gen foodexp_r=fexp_month5/food_cpi 
sum foodexp_r

* non food expenditure - 30 days
gen nfoodexp_r=nfexp_month5/nfood_cpi

* total expenditure
gen totalexp_r=texp_month5/gen_cpi

sum foodexp_r nfoodexp_r totalexp_r


**** REAL CONSUMPTION PER ADULT

gen foodexp_rpa  = foodexp_r/adequiv
gen nfoodexp_rpa = nfoodexp_r/adequiv
gen totalexp_rpa = totalexp_r/adequiv

sum foodexp_rpa nfoodexp_rpa totalexp_rpa

**** renaming variables for keeping

rename foodexp_rpa   fexppa06_2yc
rename nfoodexp_rpa  nfexppa06_2yc
rename totalexp_rpa  texppa06_2yc

rename fexpm_pa5     fexppa_2yc
rename nfexpm_pa5    nfexppa_2yc
rename texpm_pa5     texppa_2yc

***************** CONSUMPTION QUINTILES AND POVERTY ***************************

*** QUINTILES

sort texppa06_2yc
xtile quintile=texppa06_2yc, nq(5)

*** POVERTY LINES 

gen     pline=415.97916 if region==11
replace pline=150.83416 if region==12
replace pline=135.42333 if region==13
replace pline=116.52166 if region==14
replace pline=154.28333 if region==15

*** ABSOLUTE POVERTY

poverty texppa06 if region==11, line(415.97916) gen(abspov_r3_11) h
poverty texppa06 if region==12, line(150.83416) gen(abspov_r3_12) h
poverty texppa06 if region==13, line(135.42333) gen(abspov_r3_13) h
poverty texppa06 if region==14, line(116.52166) gen(abspov_r3_14) h
poverty texppa06 if region==15, line(154.28333) gen(abspov_r3_15) h
egen abspov=rowtotal(abspov_r3_*)
lab var abspov "Absolute poverty"

*** RELATIVE POVERTY

poverty texppa06, line(-1) gen(relpov) h
lab var relpov "Relative poverty - 50% median"

keep childid fexppa06_2yc nfexppa06_2yc texppa06_2yc fexppa_2yc nfexppa_2yc texppa_2yc quintile abspov relpov
drop if fexppa06_2yc==.

sort childid
save "$data\yc\constructed\consumption_2yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid texppa06_2yc
rename  texppa06_2yc    tconsrpa
label var tconsrpa     "Total real consumption per adult - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\ethiopia\consumption_2yc.dta", replace


***********************************************************************************************************************
******************* OLDER COHORT = 12 YEARS OLD ***********************************************************************
***********************************************************************************************************************
clear
set mem 50m
set more off


global data 	N:\Quantitative research\Data\r2\ethiopia

use 			"$data\yc\constructed\cpi_r2.dta", clear
sort region month
tempfile cpi
save    `cpi'

use               "$data/oc/raw/etchildlevel12yrold.dta", clear



qui recode eatv* ownv* giftv* (.=0) (-77 -88 -99=0)
qui recode spend* spndyr* spyr* (.=0) (-77 -88 -99 =0)
sum eatv* ownv* giftv*
sum spend* spndyr* spyr*

********************** FOOD EXPENDITURE ******************************************************************************* 

egen fpurchv2w=rowtotal(eatv*)   //value of food bought and consumed in the last 2 weeks 
egen fownv2w  =rowtotal(ownv*)   //value of food consumed from own harvest/stock in the last 2 weeks
egen fgiftv2w =rowtotal(giftv*)  //value of edible gifts consumed in the last 2 weeks 

********************** EDUCATION EXPENDITURE ******************************************************************************* 

egen eduexpyr=rowtotal(spyr09-spyr16)
label var eduexpyr "Annual expenditure on education" 

gen eduexp_month=eduexpyr/12
label var eduexp_month "Monthly expenditure on education" 


********************** MEDICAL EXPENDITURE *********************************************************************************

egen medexpyr=rowtotal(spyr17-spyr18)
label var medexpyr "Annual expenditure on medical" 

gen medexp_month=medexpyr/12
label var medexp_month "Monthly expenditure on medical" 

********************** CLOTHING EXPENDITURE ********************************************************************************

egen clexpyr=rowtotal(spyr01-spyr08)	
label var clexpyr "Annual expenditure on clothing" 

gen clexp_month=clexpyr/12
label var clexp_month "Monthly expenditure on clothing" 


********************** OTHER NON-FOOD EXPENDITURE ************************************************************************** 

egen s42v30d=rowtotal(spend01-spend06)    //spending on cigs, personal care, firewood/kero/batteries etc, internet, public transport, security
gen s42expyr=s42v30d*12 			//above - per year 			
egen s43expyr=rowtotal(spndyr07-spndyr11) //spending on rent, dwelling maintenance, cleaning materials, rent (business), water, electricity, phone, vehicle maintenance, fees, paperwork, legal advice, bribes, festivals, celebrations, one-off family events */
egen othexpyr=rowtotal(spyr19-spyr23)


*************************TOTAL EXPENDITURE********************************************************************************* 

*** YEARLY EXPENDITURE

egen nfspend30d=rowtotal(spend*)    // Non-food expenditure 1 - monthly
egen nfspndyr=rowtotal(spndyr*)     // Non-food expendidure 2
egen nfspyr=rowtotal(spyr*)         // Non-food expenditure 3

gen nfexpyr=(12*nfspend30d)+ nfspndyr + nfspyr     // Yearly expenditure in non-food items

gen fpurchvyr=fpurchv2w*26          // Yearly expenditure in food bought and consumed
gen fownvyr=fownv2w*26              // Yearly expenditure in food consumed from own harvest
gen fgiftvyr=fgiftv2w*26            // Yearly expenditure in edible gifts

gen fexpyr=fpurchvyr+fownvyr+fgiftvyr

gen texpyr=fpurchvyr+fownvyr+fgiftvyr+(12*nfspend30d)+ nfspndyr + nfspyr

label var nfexpyr "Annual non-food expenditure"
label var fexpyr "Annual food expenditure"
label var texpyr "Annual total expenditure (food+ non food)" 

*** MONTHLY EXPENDITURE

* Food
gen fexp_month=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)
label var fexp_month "Monthly expenditure in food items"

* Non-food
gen nfexp_month=(nfspend30d)+(nfspndyr/12)+((nfspyr-spyr21)/12)
label var nfexp_month "Monthly expenditure in non-food items"

* T otal
gen texp_month=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)+ (nfspend30d)+(nfspndyr/12)+((nfspyr-spyr21)/12)
label var texp_month "Total monthly expenditure"

*****************EXPENDITURE PER CAPITA AND PER ADULT (nominal values)  **************************************************

* MONTHLY EXPENDITURE PER CAPITA

gen texpm_pc=texp_month/hhsize
label var texpm_pc   "Monthly  consumption per capita"

gen fexpm_pc=fexp_month/hhsize
label var fexpm_pc   "Monthly food consumption per capita"

gen nfexpm_pc=nfexp_month/hhsize
label var nfexpm_pc  "Monthly non-food consumption per capita"

* MONTHLY EXPENDITURE PER ADULT

sort childid
merge childid using "$data\oc\constructed\adultequiv2oc.dta", unique
tab _m
drop _m

gen texpm_pa=texp_month/adequiv
label var texpm_pa   "Monthly  consumption per adult"

gen fexpm_pa=fexp_month/adequiv
label var fexpm_pa   "Monthly food consumption per adult"

gen nfexpm_pa=nfexp_month/adequiv
label var nfexpm_pa  "Monthly non-food consumption per adult"


******************** REAL EXPENDITURE (DEFLATING) ************************************************************************

*** GENERATING VARIABLE - MONTH OF INTERVIEW - to deflate consumption by the cpi of that month

gen month=.
*November 2006
replace month=1 if dint>=17094 & dint<=17135
*December 2006
replace month=2 if dint>17135 & dint<=17166
*January 2007
replace month=3 if dint>17166 & dint<=17197
*February 2007
replace month=4 if dint>17197 & dint<=17225
*March 2007
replace month=5 if dint>17225 & dint<=17232
*April 2007
replace month=6 if dint>17232 & dint<=17286
*May 2007
replace month=7 if dint>17286 & dint<=17402

label var month "Month of interview"
label define month 1 "Nov06" 2 "Dec06" 3 "Jan07" 4 "Feb07" 5 "Mar07" 6 "Apr07" 7 "May07"
label values month month

**MERGING WITH CPI - monthly cpi's taken from csa-ethiopia

sort region month
merge region month using `cpi'

*** DEFLATING EXPENDITURE

*food expenditure
gen foodexp_06=fexp_month/food_cpi 
sum foodexp_06


*non food expenditure - 30 days
gen nfoodexp_06=nfexp_month/nfood_cpi

*total expenditure
gen totalexp_06=texp_month/gen_cpi

sum foodexp_06 nfoodexp_06 totalexp_06

**** REAL CONSUMPTION PER ADULT

gen foodexp_06pa  = foodexp_06/adequiv
gen nfoodexp_06pa = nfoodexp_06/adequiv
gen totalexp_06pa = totalexp_06/adequiv

* renaming variables for keeping

rename foodexp_06pa   fexppa06_2oc
rename nfoodexp_06pa  nfexppa06_2oc
rename totalexp_06pa  texppa06_2oc

rename fexpm_pa       fexppa_2oc
rename nfexpm_pa      nfexppa_2oc
rename texpm_pa       texppa_2oc

***************** CONSUMPTION QUINTILES AND POVERTY ***************************

*** QUINTILES

sort texppa06_2oc
xtile quintile=texppa06_2oc, nq(5)

*** POVERTY LINES 

gen     pline=415.97916 if region==11
replace pline=150.83416 if region==12
replace pline=135.42333 if region==13
replace pline=116.52166 if region==14
replace pline=154.28333 if region==15

*** ABSOLUTE POVERTY

poverty texppa06 if region==11, line(415.97916) gen(abspov_r3_11) h
poverty texppa06 if region==12, line(150.83416) gen(abspov_r3_12) h
poverty texppa06 if region==13, line(135.42333) gen(abspov_r3_13) h
poverty texppa06 if region==14, line(116.52166) gen(abspov_r3_14) h
poverty texppa06 if region==15, line(154.28333) gen(abspov_r3_15) h
egen abspov=rowtotal(abspov_r3_*)
lab var abspov "Absolute poverty"

*** RELATIVE POVERTY

poverty texppa06, line(-1) gen(relpov) h
lab var relpov "Relative poverty - 50% median"

keep childid fexppa06_2oc nfexppa06_2oc texppa06_2oc fexppa_2oc nfexppa_2oc texppa_2oc region abspov relpov quintile
drop if fexppa06_2oc==.

sort childid

save "$data\oc\constructed\consumption_2oc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid texppa06_2oc
rename  texppa06_2oc    tconsrpa
label var tconsrpa     "Total real consumption per adult - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\ethiopia\consumption_2oc.dta", replace

