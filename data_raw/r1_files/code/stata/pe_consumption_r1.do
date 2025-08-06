*********************** CONSUMPTION AGGREGATES PERU - R1 *********************

clear
set mem 600m
set more off

global data 	 N:\Quantitative research\Data\r1\peru\

use 			 "$data\yc\raw\pestblsec14Gasto.dta", clear

****************************************************
*1. FOOD CONSUMPTION.
****************************************************

*Food bought, or food from payments, or food from presents (OJO!!)
*Fiid from own sources (general).

tab comprar, m
recode comprar (9=.)

sum gastar autocons
recode gastar autocons (9999=.) (8888=.)

gen gastom_food_r1=gastar*2
gen autoconsm_food_r1=autocons*2
egen totg_food_r1=rsum(gastom_food_r1 autoconsm_food_r1)

sum gastom_food_r1-totg_food_r1

sort childid
collapse (sum) gastom_food_r1 autoconsm_food_r1 totg_food_r1, by(childid)

label var gastom_food_r1 "Food bought per month R1"
label var autoconsm_food_r1 "Food from own sources per month R1"
label var totg_food_r1 "Food consumption per month R1"

sum gastom_food_r1-totg_food_r1
sort childid

tempfile   aux_food_yc
save      `aux_food_yc'


****************************************************
*2. NON-FOOD CONSUMPTION.
****************************************************

******DEBT RELIEF.

use "$data\yc\raw\petblSec7Livelihoods.dta", clear

tab frmamnt if frmdebt!=1, m
tab semamnt if semdebt!=1, m
tab hireamnt if hiredebt!=1, m
tab infamnt if infdebt!=1, m
tab relamnt if reldebt!=1, m
tab mercamnt if mercdebt!=1, m
tab publamnt if publdebt!=1, m
tab othamnt if othdebt!=1, m

replace frmamnt=. if frmdebt!=1
replace semamnt=. if semdebt!=1
replace hireamnt=. if hiredebt!=1
replace infamnt=. if infdebt!=1
replace relamnt=. if reldebt!=1
replace mercamnt=. if mercdebt!=1
replace publamnt=. if publdebt!=1
replace othamnt=. if othdebt!=1

sum frmamnt-othamnt
recode frmamnt-othamnt (999999=.)

egen debt_r1=rsum(frmamnt-othamnt)
sum debt_r1

keep childid debt_r1
label var debt_r1 "Total Debt - R1"
sort childid

tempfile   aux_debt_yc
save      `aux_debt_yc'

********************************************************
******* SUMMARY: CONSUMPTION - FIRST ROUND
********************************************************

use childid hhsize using "$data\yc\raw\pechildlevel1yrold.dta", clear
sort childid 
merge childid using `aux_food_yc', unique
tab _merge
drop _merge
sort childid 
merge childid using `aux_debt_yc', unique
tab _merge
drop _merge

sum gastom_food_r1 autoconsm_food_r1 totg_food_r1

egen totg_r1=rsum(totg_food_r1 debt_r1)
label variable totg_r1 "Total consumption per month R1"

*round 1 specific (not comparable with other rounds)

gen totg_pc_r1=totg_r1/hhsize
label variable totg_pc_r1 "Total per capita consumption per month R1"

sort childid
merge childid using "$data\yc\constructed\deflactores_yls_yc.dta", keep(def_full_r1)
tab _merge
drop _merge

gen totg_real_r1=totg_r1/def_full_r1
label variable totg_real_r1 "Total real consumption per month R1"

gen totg_real_pc_r1=totg_real_r1/hhsize
label variable totg_real_pc_r1 "Total real per capita consumption per month R1"

sum totg_r1 totg_real_r1

keep childid  totg_food_r1 debt_r1 totg_r1 totg_pc_r1 totg_real_r1 totg_real_pc_r1
rename totg_food_r1 	totg_food
rename totg_r1 		totg
rename totg_pc_r1 	totg_pc
rename totg_real_r1 	totg_real
rename totg_real_pc_r1  totg_real_pc
sort childid
save "N:\Quantitative research\Data\r1\peru\yc\constructed\consumption_1yc.dta",replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_1yc.dta", replace

********************************* OLDER COHORT *******************************************

use "$data\oc\raw\pestblsec14Autoconsumo.dta", clear

****************************************************
*1. FOOD CONSUMPTION.
****************************************************

*OC only considers food from own sources (general).

sum autocons
recode autocons (9999=.)

gen autoconsm_food_r1=autocons*2
gen totg_food_r1=autoconsm_food_r1

sum autoconsm_food_r1 totg_food_r1
sort childid
collapse (sum) autoconsm_food_r1 totg_food_r1, by(childid)

label var autoconsm_food_r1 "Food from own sources per month R1"
label var totg_food_r1 "Food consumption per month R1"

sum autoconsm_food_r1 totg_food_r1

sort childid
tempfile   aux_food_oc
save      `aux_food_oc'

****************************************************
*2. NON-FOOD CONSUMPTION.
****************************************************

******DEBT RELIEF.

use "$data\oc\raw\petblSec7Livelihoods.dta", clear

tab frmamnt if frmdebt!=1, m
tab semamnt if semdebt!=1, m
tab hireamnt if hiredebt!=1, m
tab infamnt if infdebt!=1, m
tab relamnt if reldebt!=1, m
tab mercamnt if mercdebt!=1, m
tab publamnt if publdebt!=1, m
tab othamnt if othdebt!=1, m

replace frmamnt=. if frmdebt!=1
replace semamnt=. if semdebt!=1
replace hireamnt=. if hiredebt!=1
replace infamnt=. if infdebt!=1
replace relamnt=. if reldebt!=1
replace mercamnt=. if mercdebt!=1
replace publamnt=. if publdebt!=1
replace othamnt=. if othdebt!=1

sum frmamnt-othamnt

egen debt_r1=rsum(frmamnt-othamnt)
sum debt_r1

keep childid debt_r1

label var debt_r1 "Total Debt - R1"

sort childid

tempfile  aux_debt_oc
save     `aux_debt_oc'


****************************************************
*2. EXPENDITURE ON EDUCATION.
****************************************************

use "$data\oc\raw\pestblsec4gastoescolar_oc_r1.dta", clear
tab edtiempo, m
recode edtiempo (88=.)

sum edmonto
gen 	  totg_edu_r1=edmonto    if edtiempo==9
replace totg_edu_r1=edmonto*2  if edtiempo==8
replace totg_edu_r1=edmonto*4  if edtiempo==7
replace totg_edu_r1=edmonto*6  if edtiempo==6
replace totg_edu_r1=edmonto*12 if edtiempo==5
replace totg_edu_r1=edmonto*24 if edtiempo==4
replace totg_edu_r1=edmonto*48 if edtiempo==3
replace totg_edu_r1=edmonto*48*6 if edtiempo==2
replace totg_edu_r1=edmonto*48*6*8 if edtiempo==1

sum totg_edu_r1
collapse (sum) totg_edu_r1, by(childid)
label var totg_edu_r1 "Total expenditure on index child education"

sort childid
tempfile aux_gedu_oc
save    `aux_gedu_oc'


*******************************************************
******* SUMMARY: CONSUMPTION AND INCOME - FIRST ROUND
********************************************************

use childid hhsize using "$data\oc\raw\pechildlevel8yrold.dta", clear
sort childid
merge childid using `aux_food_oc', unique
tab _merge
drop _merge
sort childid
merge childid using `aux_gedu_oc', unique
tab _merge
drop _merge
sort childid
merge childid using `aux_debt_oc', unique
tab _merge
drop _merge

sum autoconsm_food_r1 totg_food_r1
egen totg_r1=rsum(totg_food_r1 debt_r1)
label variable totg_r1 "Total consumption per month R1"

gen totg_pc_r1=totg_r1/hhsize
label variable totg_pc_r1 "Total per capita consumption per month R1"

sort childid
merge childid using "$data\oc\constructed\deflactores_yls_oc.dta", keep(def_full_r1)
tab _merge
drop _merge

gen totg_real_r1=totg_r1/def_full_r1
label variable totg_real_r1 "Total real consumption per month R1"

gen totg_real_pc_r1=totg_real_r1/hhsize
label variable totg_real_pc_r1 "Total real per capita consumption per month R1"

keep childid  totg_food_r1 debt_r1 totg_r1 totg_pc_r1 totg_real_r1 totg_real_pc_r1
rename totg_food_r1 	totg_food
rename totg_r1 		totg
rename totg_pc_r1 	totg_pc
rename totg_real_r1 	totg_real
rename totg_real_pc_r1  totg_real_pc

sort childid
save "$data\oc\constructed\consumption_1oc.dta",replace

* REDUCED FORM FOR ARCHIVING - TOTAL REAL CONSUMPTION ONLY
keep childid totg_real_pc
rename  totg_real_pc    tconsrpa
label var tconsrpa     "Total real consumption per capita - base 2006"
sort childid
save "C:\Documents and Settings\sant2276\Desktop\consumption\peru\consumption_1oc.dta", replace
