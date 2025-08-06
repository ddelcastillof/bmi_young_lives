********************************* ETHIOPIA: CONSUMPTION AGGREGATES **************************************************
************************************** YOUNGER COHORT ***************************************************************

clear
set mem 50m
set more off

* MERGING WITH CPI 


global data 	N:\Quantitative research\Data\r3\ethiopia

use              "$data\yc\constructed\cpi_r3.dta", clear

sort region month
tempfile cpi
save    `cpi'

use               "$data/yc/raw/et_yc_householdlevel.dta", clear


********************** FOOD EXPENDITURE ***************************************************************************** 

qui recode eatvr3* ownvr3* gftvr3* (-8888 -888 -88 -77 -99=0)
sum eatvr3* ownvr3* gftvr3*

egen fpurchv2w=rowtotal(eatvr*)   //value of food bought and consumed in the last 2 weeks 
egen fownv2w  =rowtotal(ownvr*)   //value of food consumed from own harvest/stock in the last 2 weeks
egen fgiftv2w =rowtotal(gftvr*)   //value of edible gifts consumed in the last 2 weeks 


********************** EDUCATION EXPENDITURE ************************************************************************ 

qui recode spyrr309-spyrr316 (-88 -77 -99=0)
sum spyrr309-spyrr316              // School-related expediture

egen eduexpyr=rowtotal(spyrr309-spyrr316)
label var eduexpyr "Annual expenditure on education" 

gen eduexp_month=eduexpyr/12
label var eduexp_month "Monthly expenditure on education" 


******************** MEDICAL EXPENDITURE *****************************************************************************

qui recode spyrr317 spyrr320 (-99 -88 -77=0)
sum spyrr317 spyrr320             // Medical expediture: medical consultation and other medical expenses in the last 12 months

gen medexpyr=(spyrr317+spyrr320)
label var medexpyr "Annual expenditure on medical" 

gen medexp_month=(spyrr317+spyrr320)/12
label var medexp_month "Monthly expenditure on medical"


********************** CLOTHING EXPENDITURE ***************************************************************************

qui recode spyrr301-spyrr308 (-99 -88 -77=0)
sum spyrr301-spyrr308              // Expenditure in clothing and footware in the last 12 months

egen clexpyr=rowtotal(spyrr301-spyrr308)	
label var clexpyr "Annual expenditure on clothing" 

gen clexp_month=clexpyr/12
label var clexp_month "Montly expenditure in clothing"

********************** OTHER NON-FOOD EXPENDITURE ********************************************************************** 

qui recode spndr301-spndr306 (-99 -88 -77=0)
qui recode bgyrr307-bgyrr311 (-99 -88 -77=0)
qui recode spyrr321-spyrr327 (-99 -88 -77=0)
sum spndr301-spndr306
sum bgyrr307-bgyrr311
sum spyrr321-spyrr327

egen s42v30d=rowtotal(spndr301- spndr306)    // spending on cigs, personal care, firewood/kero/batteries etc, internet, public transport, security
gen s42expyr=s42v30d*12 			   // above - per year 			

egen s43expyr=rowtotal(bgyrr307-bgyrr311)    // spending on rent, dwelling maintenance, cleaning materials, rent (business), water, electricity, phone, vehicle maintenance, fees, paperwork, legal advice, bribes, festivals, celebrations, one-off family events

egen othexpyr=rowtotal(spyrr321-spyrr327)    //spending on entertainment, and other - including presents, jewellery, other transport etc


************************* TOTAL EXPENDITURE ***************************************************************************** 

*** YEARLY EXPENDITURE

egen nfspend30d=rowtotal(spndr*)          // Non-food expenditure 1 - monthly
egen nfspndyr=rowtotal(spyrr*)            // Non-food expendidure 2
egen nfspyr=rowtotal(bgyrr*)              // Non-food expenditure 3

gen nfexpyr=(12*nfspend30d)+ nfspndyr + nfspyr     // Yearly expenditure in non-food items

gen fpurchvyr=fpurchv2w*26     	     // Yearly expenditure in food bought and consumed
gen fownvyr=fownv2w*26            	     // Yearly expenditure in food consumed from own harvest
gen fgiftvyr=fgiftv2w*26                 // Yearly expenditure in edible gifts

gen fexpyr=fpurchvyr+fownvyr+fgiftvyr

gen texpyr=fpurchvyr+fownvyr+fgiftvyr+(12*nfspend30d)+ nfspndyr + nfspyr

label var nfexpyr "Annual non-food expenditure"
label var fexpyr "Annual food expenditure"
label var texpyr "Annual total expenditure (food+ non food)" 

*** MONTHLY EXPENDITURE

*food
gen fexp_month8 =(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)
label var fexp_month8   "Monthly expenditure in food items"

*non-food
gen nfexp_month8=(nfspend30d)+ ((nfspndyr-spyrr323)/12)+ (nfspyr/12)
label var nfexp_month8  "Monthly expenditure in non-food items"

*total expenditure
gen texp_month8=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)+(nfspend30d)+ ((nfspndyr-spyrr323)/12)+ (nfspyr/12)
label var texp_month8   "Total montly expenditure"


*****************EXPENDITURE PER CAPITA AND PER ADULT (nominal values) ***************************************************

*** MONTHLY EXPENDITURE PER CAPITA

gen texpm8_pc=texp_month8/hhsize
label var texpm8_pc "Monthly consumption per capita"

gen fexpm8_pc=fexp_month8/hhsize
label var fexpm8_pc "Monthly food consumption per capita"

gen nfexpm8_pc=nfexp_month8/hhsize
label var nfexpm8_pc "Monthly non-food consumption per capita"

*** MONTHLY EXPENDITURE PER ADULT (merging with adult equivalent scales)

sort childid
merge childid using "$data\yc\constructed\adultdequiv3yc.dta", unique
tab _m
drop _m

gen texpm8_pa=texp_month8/adequiv
label var texpm8_pa "Monthly consumption per adult"

gen fexpm8_pa=fexp_month8/adequiv
label var fexpm8_pa "Monthly food consumption per adult"

gen nfexpm8_pa=nfexp_month8/adequiv
label var nfexpm8_pa "Monthly non-food consumption per adult"


******************** REAL EXPENDITURE (DEFLATING) ************************************************************************

*** GENERATING VARIABLE - MONTH OF INTERVIEW - to deflate consumption by the cpi of that month
gen month=.
*Oct 2009
replace month=1 if dint>=18183 & dint<=18201
*Nov 2009
replace month=2 if dint>18201 & dint<=18231
*Dec 2009
replace month=3 if dint>18231 & dint<=18262
*Jan 2010
replace month=4 if dint>18262 & dint<=18292
*Feb 2010
replace month=5 if dint>18292 & dint<=18320
*Mar 2010
replace month=6 if dint>18320 & dint<=18330

label var month "Month of interview"
label define month 1 "Oct09" 2 "Nov09" 3 "Dec09" 4 "Jan10" 5 "Feb10" 6 "Mar10"
label values month month


*** MERGING WITH CPI - monthly cpi's taken from csa-ethiopia

sort region month
merge region month using `cpi'

*** DEFLATING EXPENDITURE

* food expenditure
gen foodexp_06=fexp_month8/food_cpi
sum foodexp_06

* non food expenditure
gen nfoodexp_06=nfexp_month8/nfood_cpi

* total expenditure
gen totalexp_06=texp_month8/gen_cpi


sum foodexp_06 nfoodexp_06 totalexp_06

**** REAL CONSUMTION PER ADULT

gen foodexp_06pa  = foodexp_06/adequiv
gen nfoodexp_06pa = nfoodexp_06/adequiv
gen totalexp_06pa = totalexp_06/adequiv

* renaming variables for keeping

rename foodexp_06pa   fexppa06_3yc
label var fexppa06_3yc "real per adult consumption in food"

rename nfoodexp_06pa  nfexppa06_3yc
label var nfexppa06_3yc "real per adult consumption in non food"

rename totalexp_06pa  texppa06_3yc
label var texppa06_3yc "total real per adult consumption"

rename fexpm8_pa      fexppa_3yc
rename nfexpm8_pa     nfexppa_3yc
rename texpm8_pa      texppa_3yc

keep childid fexppa06_3yc nfexppa06_3yc texppa06_3yc fexppa_3yc nfexppa_3yc texppa_3yc

drop if texppa_3yc==.
sort childid

save "$data\yc\constructed\consumption_3yc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid texppa06_3yc
rename  texppa06_3yc    tconsrpa
label var tconsrpa     "Total real consumption per adult - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\ethiopia\consumption_3yc.dta", replace


********************************* ETHIOPIA: CONSUMPTION AGGREGATES **************************************************
************************************** OLDER COHORT ***************************************************************

clear
set mem 50m
set more off

global data 	N:\Quantitative research\Data\r3\ethiopia
use               "$data/oc/raw/et_oc_householdlevel.dta", clear


********************** FOOD EXPENDITURE ************************************************************************************ 

qui recode eatvr3* ownvr3* gftvr3* (-99 -88 -77=0)
sum eatvr3* ownvr3* gftvr3*

egen fpurchv2w=rowtotal(eatvr*)   //value of food bought and consumed in the last 2 weeks 
egen fownv2w  =rowtotal(ownvr*)   //value of food consumed from own harvest/stock in the last 2 weeks
egen fgiftv2w =rowtotal(gftvr*)   //value of edible gifts consumed in the last 2 weeks 

********************** EDUCATION EXPENDITURE ******************************************************************************* 

qui recode spyrr309-spyrr316 (-99 -88 -77=0)
sum spyrr309-spyrr316              // School-related expediture

egen eduexpyr=rowtotal(spyrr309-spyrr316)
label var eduexpyr "Annual expenditure on education" 

gen eduexp_month=eduexpyr/12
label var eduexp_month "Monthly expenditure on education" 


********************** MEDICAL EXPENDITURE *********************************************************************************

qui recode spyrr317 spyrr320 (-99 -88 -77=0)
sum spyrr317 spyrr320             // Medical expediture: medical consultation and other medical expenses in the last 12 months

gen medexpyr=(spyrr317+spyrr320)
label var medexpyr "Annual expenditure on medical" 

gen medexp_month=(spyrr317+spyrr320)/12
label var medexp_month "Monthly expenditure on medical"

********************** CLOTHING EXPENDITURE ********************************************************************************

qui recode spyrr301-spyrr308 (-99 -88 -77=0)
sum spyrr301-spyrr308              // Expenditure in clothing and footware in the last 12 months

egen clexpyr=rowtotal(spyrr301-spyrr308)	
label var clexpyr "Annual expenditure on clothing" 

gen clexp_month=clexpyr/12
label var clexp_month "Montly expenditure in clothing"

********************** OTHER NON-FOOD EXPENDITURE ************************************************************************** 

qui recode spndr301- spndr306 (-99 -88 -77=0)
qui recode bgyrr307-bgyrr311 (-99 -88 -77=0)
qui recode spyrr321-spyrr327 (-99 -88 -77=0)
sum spndr301- spndr306
sum bgyrr307-bgyrr311
sum spyrr321-spyrr327

egen s42v30d=rowtotal(spndr301- spndr306)    //spending on cigs, personal care, firewood/kero/batteries etc, internet, public transport, security
gen s42expyr=s42v30d*12 			   //above - per year 			

egen s43expyr=rowtotal(bgyrr307-bgyrr311)    //spending on rent, dwelling maintenance, cleaning materials, rent (business), water, electricity, phone, vehicle maintenance, fees, paperwork, legal advice, bribes, festivals, celebrations, one-off family events */

egen othexpyr=rowtotal(spyrr321-spyrr327)    // spending on entertainment, and other - including presents, jewellery, other transport etc


************************* TOTAL EXPENDITURE ********************************************************************************* 

**** YEARLY EXPENDITURE
egen nfspend30d=rowtotal(spndr*)          // Non-food expenditure 1 - monthly
egen nfspndyr=rowtotal(spyrr*)            // Non-food expendidure 2
egen nfspyr=rowtotal(bgyrr*)              // Non-food expenditure 3

gen nfexpyr=(12*nfspend30d)+ nfspndyr + nfspyr     // Yearly expenditure in non-food items

gen fpurchvyr=fpurchv2w*26     	     // Yearly expenditure in food bought and consumed
gen fownvyr=fownv2w*26            	     // Yearly expenditure in food consumed from own harvest
gen fgiftvyr=fgiftv2w*26                 // Yearly expenditure in edible gifts

gen fexpyr=fpurchvyr+fownvyr+fgiftvyr

gen texpyr=fpurchvyr+fownvyr+fgiftvyr+(12*nfspend30d)+ nfspndyr + nfspyr

label var nfexpyr "Annual non-food expenditure"
label var fexpyr "Annual food expenditure"
label var texpyr "Annual total expenditure (food+ non food)" 

*** MONTHLY EXPENDITURE
*food
gen fexp_month =(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)
label var fexp_month   "Monthly expenditure in food items"

*non-food
gen nfexp_month=(nfspend30d)+ ((nfspndyr-spyrr323)/12)+ (nfspyr/12)
label var nfexp_month  "Monthly expenditure in non-food items"

*total expenditure
gen texp_month=(fpurchv2w*2)+(fownv2w*2)+(fgiftv2w*2)+(nfspend30d)+ ((nfspndyr-spyrr323)/12)+ (nfspyr/12)
label var texp_month   "Total montly expenditure"


***************** EXPENDITURE PER CAPITA AND PER ADULT **********************************************************************

*** MONTHLY EXPENDITURE PER CAPITA

gen texpm_pc=texp_month/hhsize
label var texpm_pc "Monthly consumption per capita"

gen fexpm_pc=fexp_month/hhsize
label var fexpm_pc "Monthly food consumption per capita"

gen nfexpm_pc=nfexp_month/hhsize
label var nfexpm_pc "Monthly non-food consumption per capita"


*** MONTHLY EXPENDITURE PER ADULT

sort childid
merge childid using "$data\oc\constructed\adultequiv3oc.dta", unique
tab _m
drop _m

gen texpm_pa=texp_month/adequiv
label var texpm_pa "Monthly consumption per capita"

gen fexpm_pa=fexp_month/adequiv
label var fexpm_pa "Monthly food consumption per capita"

gen nfexpm_pa=nfexp_month/adequiv
label var nfexpm_pa "Monthly non-food consumption per capita"


******************** DEFLATING EXPENDITURE ************************************************************************************

** GENERATING VARIABLE - MONTH OF INTERVIEW
gen month=.
*Oct 2009
replace month=1 if dint>=17911 & dint<=18201
*Nov 2009
replace month=2 if dint>18201 & dint<=18231
*Dec 2009
replace month=3 if dint>18231 & dint<=18262
*Jan 2010
replace month=4 if dint>18262 & dint<=18293
*Feb 2010
replace month=5 if dint>18293 & dint<=18321
*Mar 2010
replace month=6 if dint>18321 & dint<=18330

label var month "Month of interview"
label define month 1 "Oct09" 2 "Nov09" 3 "Dec09" 4 "Jan10" 5 "Feb10" 6 "Mar10"
label values month month


**MERGING WITH CPI - monthly cpi's taken from csa-ethiopia

sort region month
merge region month using `cpi' 

*** DEFLATING EXPENDITURE

* food expenditure
gen foodexp_06=fexp_month/food_cpi

* non food expenditure 
gen nfoodexp_06=nfexp_month/nfood_cpi

* total expenditure
gen totalexp_06=texp_month/gen_cpi

sum foodexp_06 nfoodexp_06 totalexp_06

**** REAL CONSUMPTION PER CAPITA

gen foodexp_06pc  = foodexp_06/hhsize
gen nfoodexp_06pc = nfoodexp_06/hhsize
gen totalexp_06pc = totalexp_06/hhsize

sum foodexp_06pc nfoodexp_06pc totalexp_06pc

**** REAL CONSUMPTION PER ADULT

gen foodexp_06pa  = foodexp_06/adequiv
gen nfoodexp_06pa = nfoodexp_06/adequiv
gen totalexp_06pa = totalexp_06/adequiv

sum foodexp_06pa nfoodexp_06pa totalexp_06pa


**** renaming variables for keeping

rename foodexp_06pa   fexppa06_3oc
label var fexppa06_3oc "real per adult consumption in food"

rename nfoodexp_06pa  nfexppa06_3oc
label var nfexppa06_3oc "real per adult consumption in non food"

rename totalexp_06pa  texppa06_3oc
label var texppa06_3oc "total real per adult consumption"

rename fexpm_pa       fexppa_3oc
rename nfexpm_pa      nfexppa_3oc
rename texpm_pa       texppa_3oc

keep childid fexppa06_3oc nfexppa06_3oc texppa06_3oc fexppa_3oc nfexppa_3oc texppa_3oc 
drop if fexppa06_3oc==.
sort childid
save "$data\oc\constructed\consumption_3oc.dta", replace


* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid texppa06_3oc
rename  texppa06_3oc    tconsrpa
label var tconsrpa     "Total real consumption per adult - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\ethiopia\consumption_3oc.dta", replace
