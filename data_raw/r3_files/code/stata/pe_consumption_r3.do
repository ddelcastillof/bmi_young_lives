******************** CONSUMPTION AGGREGATES PERU *******************************
* NB. BASED ON DO FILES SENT BY PERU TEAM IN DEC 2010


clear
set mem 50m
set more off

********************************************************************************

global data 	N:\Quantitative research\Data\r3\peru

use              "$data\yc\raw\pe_yc_householdlevel.dta", clear

* HOUSEHOLD SIZE

tab hhsize, m
sort childid

****** I. FOOD CONSUMPTION

recode fdspr3* vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3* vlovr3* (-77 -88 -99 -8 -888 -20=0)
recode fdspr3* vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3* vlovr3* (88=0)

* FOOD BOUGHT
egen gastom_food_r3=rsum(fdspr3*)

* FOOD FROM OWN SOURCES AND OWN SUPPLIES
egen autoconsm_food_r3=rsum(vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3*)

* FOOD LEFT OVER
egen nocons_food_r3=rsum(vlovr3*)

* FOOD CONSUMPTION PER MONTH
gen totg_food_r3=(gastom_food_r3+autoconsm_food_r3-nocons_food_r3)*2
sum gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3
sort childid
label var totg_food_r3 "Total Food Consumption per month R3"

******II. NON-FOOD CONSUMPTION

recode spndr* spyrr3* (-77=0) (-88=0) (-99=0) 
sum spndr* spyrr3*

egen gcloth_r3=rsum(spyrr301 spyrr302 spyrr32a spyrr303 spyrr304 spyrr3tl spyrr305 spyrr306 spyrr307 spyrr308)
replace gcloth_r3=gcloth_r3/12
sum gcloth_r3

egen geduc_r3=rsum(spyrr309 spyrr310 spyrr311 spyrr312 spyrr313 spyrr315 spyrr316)
replace geduc_r3=geduc_r3/12
sum geduc_r3

egen gmed_r3=rsum(spyrr317 spyrr318)
replace gmed_r3=gmed_r3/12
sum gmed_r3

egen gocio_r3=rsum(spyrr319)
replace gocio_r3=gocio_r3/12
sum gocio_r3

egen gother_r3=rsum(spyrr320 spyrr322 spyrr323 spyrr324)  
replace gother_r3=gother_r3/12
sum gother_r3 

* NB. Excluding jewelry in "other" nonfood expenditure and new options, to set a comparability between rounds.

egen gu30d_r3=rsum(spndr301 spndr302 spndr303 spndr304 spndr305 spndr306 spndr325 spndr326 spndr327 spndr328 spndr329 spndr330 spndr331 spndr332 spndr333)
sum gu30d_r3

egen gu12m_r3=rsum(spndr314 spndr319 spndr342 spndr352 spndr362 spndr311 spndr322)
replace gu12m_r3=gu12m_r3/12
sum gu12m_r3

egen totg_nfood_r3=rsum(gcloth_r3 geduc_r3 gmed_r3 gocio_r3 gother_r3 gu30d_r3 gu12m_r3)
sum totg_nfood_r3

label variable gcloth_r3   "Clothes and footwear consumption per month R3"
label variable geduc_r3    "Education consumption per month R3"
label variable gmed_r3     "Doctors and medicine consumption per month R3"
label variable gocio_r3    "Entertainment consumption per month R3"
label variable gother_r3   "Other consumption per month R3"
label variable gu30d_r3    "Last 30 days consumption per month R3"
label variable gu12m_r3         "Last 12 months consumption per month R3"
label variable totg_nfood_r3 "Total nonfood consumption per month R3"

sort childid

******* SUMMARY: CONSUMPTION AND INCOME - THIRD ROUND

sum gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3 

egen totg_r3=rsum(totg_food_r3 totg_nfood_r3)
label variable totg_r3 "Total consumption per month R3"

gen totg_pc_r3=totg_r3/hhsize
label variable totg_pc_r3 "Total per capita consumption per month R3"

sort childid
merge childid using "$data\yc\constructed\deflactores_yls_yc.dta", keep(def_full_r3)
tab _merge
drop if _merge==2
drop _merge

gen totg_real_r3=totg_r3/def_full_r3
label variable totg_real_r3 "Total real consumption per month R3"

gen totg_real_pc_r3=totg_real_r3/hhsize
label variable totg_real_pc_r3 "Total real per capita consumption per month R3"

keep  childid totg_food_r3 totg_nfood_r3 totg_r3 totg_pc_r3 totg_real_r3 totg_real_pc_r3
rename totg_food_r3 	totg_food
rename totg_nfood_r3 	totg_nfood 
rename totg_r3 		totg 
rename totg_pc_r3 	totg_pc 
rename totg_real_r3 	totg_real 
rename totg_real_pc_r3 	totg_real_pc
sort childid
save "N:\Quantitative research\Data\r3\peru\yc\constructed\consumption_3yc .dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_3yc.dta", replace


*********************************** OLDER COHORT ***************************************************

* HOUSEHOLD SIZE
use "$data\oc\raw\pe_oc_householdlevel.dta", clear
tab hhsize, m

***** I. FOOD CONSUMPTION

recode fdspr3* vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3* vlovr3* (-77 -88 -99 -8=0)
recode fdspr3* vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3* vlovr3* (88 99=0)

* FOOD BOUGHT
egen gastom_food_r3=rsum(fdspr3*)

* FOOD FROM OWN SOURCES AND OEN SUPPLIES
egen autoconsm_food_r3=rsum(vlfrr3* vlprr3* vlowr3* vlpyr3* vlb4r3*)

* FOOD LEFT OVER
egen nocons_food_r3=rsum(vlovr3*)

* FOOD CONSUMPTION PER MONTH
gen totg_food_r3=(gastom_food_r3+autoconsm_food_r3-nocons_food_r3)*2
sum gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3

sort childid
label variable gastom_food_r3 "Total food bought in 15 days R3"
label variable autoconsm_food_r3 "Total food from own sources in 15 days R3"
label variable nocons_food_r3 "Total food left over in 15 days R3"
label var totg_food_r3 "Total Food Consumption per month R3"

***** II. NON-FOOD CONSUMPTION

recode spndr* spyrr3* (-77=0) (-88=0) (-99=0) 
sum spndr* spyrr3*

egen gcloth_r3=rsum(spyrr301 spyrr302 spyrr32a spyrr303 spyrr304 spyrr3tl spyrr305 spyrr306 spyrr307 spyrr308)
replace gcloth_r3=gcloth_r3/12
sum gcloth_r3

egen geduc_r3=rsum(spyrr309 spyrr310 spyrr311 spyrr312 spyrr313 spyrr315 spyrr316)
replace geduc_r3=geduc_r3/12
sum geduc_r3

egen gmed_r3=rsum(spyrr317 spyrr318)
replace gmed_r3=gmed_r3/12
sum gmed_r3

egen gocio_r3=rsum(spyrr319)
replace gocio_r3=gocio_r3/12
sum gocio_r3

egen gother_r3=rsum(spyrr320 spyrr322 spyrr323 spyrr324)
replace gother_r3=gother_r3/12
sum gother_r3

* NB. Excluding jewelry in "other" nonfood expenditure, and new options, to set a comparability between rounds.

egen gu30d_r3=rsum(spndr301 spndr302 spndr303 spndr304 spndr305 spndr306 spndr325 spndr326 spndr327 spndr328 spndr329 spndr330 spndr331 spndr332 spndr333)
sum gu30d_r3

egen gu12m_r3=rsum(spndr314 spndr319 spndr342 spndr352 spndr362 spndr311 spndr322)
replace gu12m_r3=gu12m_r3/12
sum gu12m_r3

egen totg_nfood_r3=rsum(gcloth_r3 geduc_r3 gmed_r3 gocio_r3 gother_r3 gu30d_r3 gu12m_r3)
sum totg_nfood_r3

label variable gcloth_r3 	"Clothes and footwear consumption per month R3"
label variable geduc_r3 	"Education consumption per month R3"
label variable gmed_r3 		"Doctors and medicine consumption per month R3"
label variable gocio_r3 	"Entertainment consumption per month R3"
label variable gother_r3 	"Other consumption per month R3"
label variable gu30d_r3 	"Last 30 days consumption per month R3"
label variable gu12m_r3 	"Last 12 months consumption per month R3"
label variable totg_nfood_r3  "Total nonfood consumption per month R3"

******* SUMMARY: CONSUMPTION AND INCOME - THIRD ROUND

sum gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3 

egen totg_r3=rsum(totg_food_r3 totg_nfood_r3)
label variable totg_r3 "Total consumption per month R3"

gen totg_pc_r3=totg_r3/hhsize
label variable totg_pc_r3 "Total per capita consumption per month R3"

sort childid
merge childid using "$data\oc\constructed\deflactores_yls_oc", keep(def_full_r3)
tab _merge
drop if _merge==2
drop _merge

gen totg_real_r3=totg_r3/def_full_r3
label variable totg_real_r3 "Total real consumption per month R3"

gen totg_real_pc_r3=totg_real_r3/hhsize
label variable totg_real_pc_r3 "Total real per capita consumption per month R3"

keep  childid totg_food_r3 totg_nfood_r3 totg_r3 totg_pc_r3 totg_real_r3 totg_real_pc_r3
rename totg_food_r3 	totg_food
rename totg_nfood_r3    totg_nfood 
rename totg_r3 		totg 
rename totg_pc_r3 	totg_pc 
rename totg_real_r3 	totg_real 
rename totg_real_pc_r3  totg_real_pc

save "$data\oc\constructed\consumption_3oc.dta", replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY

keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_3oc.dta", replace


