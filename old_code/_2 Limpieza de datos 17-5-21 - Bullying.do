clear all
clear all
global	dir		"/Users/darwin/Documents/Research"

global 	resultados "$dir/_1. Obesidad y rendimiento académico/Análisis/Resultados"


								**** Obesidad y RA ****
								***Limpieza de datos***


//Creación de variable obesidad//
cd "$resultados"
use yl_final.dta

label var zbfa_r3 "BMI z-score for R3"
label var zbfa_r4 "BMI z-score for R4"
label var zbfa_r5 "BMI z-score for R5"

**Graficos diagnosticos**
graph hbox zbfa_r3 zbfa_r4 zbfa_r5

kdensity zbfa_r3, kernel(gaussian) normal
kdensity zbfa_r4, kernel(gaussian) normal
kdensity zbfa_r5, kernel(gaussian) normal

***Nueva variable clasificación según BMI***

///Ronda 3///
tab zbfa_r3
br if zbfa_r3==.
//4 datos no existentes//
drop if zbfa_r3==. 
drop if zbfa_r3<=-2
gen bmiclass_r3 = zbfa_r3

replace bmiclass_r3=0 if zbfa_r3>-2
replace bmiclass_r3=1 if zbfa_r3>1
replace bmiclass_r3=2 if zbfa_r3>2


///Ronda 4///
tab zbfa_r4
br if zbfa_r4==.
//17 datos no existentes//
drop if zbfa_r4==. 
drop if zbfa_r4<=-2
gen bmiclass_r4=zbfa_r4

replace bmiclass_r4=0 if zbfa_r4>-2
replace bmiclass_r4=1 if zbfa_r4>1
replace bmiclass_r4=2 if zbfa_r4>2


///Ronda 5///
tab zbfa_r5
br if zbfa_r5==.
//16 datos no existentes//
drop if zbfa_r5==. 
drop if zbfa_r5<=-2
gen bmiclass_r5=zbfa_r5

replace bmiclass_r5=0 if zbfa_r5>-2
replace bmiclass_r5=1 if zbfa_r5>1
replace bmiclass_r5=2 if zbfa_r5>2

///Etiquetas de valores para clasificación según IMC///
label define bmi_status 0 "Normal weight" 1 "Overweight" 2 "Obesity"

label val bmiclass_r3 bmi_status
label val bmiclass_r4 bmi_status
label val bmiclass_r5 bmi_status


label var bmiclass_r3 "BMI classification in round 3"
label var bmiclass_r4 "BMI classification in round 4"
label var bmiclass_r5 "BMI classification in round 5"


///Desnutricion cronica///
gen stunting_r3 = zhfa_r3
replace stunting_r3=0 if zhfa_r3>-2
replace stunting_r3=1 if zhfa_r3<=-2   

gen stunting_r4 = zhfa_r4
replace stunting_r4=0 if zhfa_r4>-2
replace stunting_r4=1 if zhfa_r4<=-2   

gen stunting_r5 = zhfa_r5
replace stunting_r5=0 if zhfa_r5>-2
replace stunting_r5=1 if zhfa_r5<=-2   

label define stunting 0 "Normal height" 1 "Stunting"

for any stunting_r3 stunting_r4 stunting_r5: label val X stunting
label var stunting_r3 "Stunting in R3"
label var stunting_r4 "Stunting in R4"
label var stunting_r5 "Stunting in R5"

//Explorando resultados//
tab bmiclass_r3, m
tab bmiclass_r4, m
tab bmiclass_r5, m
graph hbox zbfa_r3 zbfa_r4 zbfa_r5

**Convirtiendo valores de rendimiento en R3 a porcentaje**
replace math_rasch_r3 = math_rasch_r3/350*100
replace read_rasch_r3 = read_rasch_r3/350*100
for any math_rasch_r3 read_rasch_r3 percomath_r4 percolang_r4: drop if X == .

**Drop missing values**
drop if percomath_r5==.|percoread_r5==.|wi_r5==.|wi_r4==.|wi_r3==.| math_rasch_r3==.| read_rasch_r3 == . | sleep_r3 == . | sleep_r4 ==. | sleep_r5==. | absent_r3==.|absent_r4==.|absent_r5==.| percolang_r4==.| percomath_r4==.|bmiclass_r3==.| bmiclass_r4==. | bmiclass_r5==.|childsex==.|agem_r4==.|agem_r3==.|agem_r5==.

rename percolang_r4 read_rasch_r4
rename percoread_r5 read_rasch_r5
rename percomath_r4 math_rasch_r4
rename percomath_r5 math_rasch_r5
rename lang_raw_r4 read_raw_r4

destring typesite_r3, replace
label val typesite_r3 CHCMSTR5
gen age_r3 = agem_r3/12
gen age_r4 = agem_r4/12
gen age_r5 = agem_r5/12

xtile wi_tertiles_r3 = wi_r3, nq(3)
xtile wi_tertiles_r4 = wi_r4, nq(3)
xtile wi_tertiles_r5 = wi_r5, nq(3)

gen sleep_cat_r3=.
replace sleep_cat_r3=0 if sleep_r3<9
replace sleep_cat_r3=1 if sleep_r3>=9

gen sleep_cat_r4=.
replace sleep_cat_r4=0 if sleep_r4<8
replace sleep_cat_r4=1 if sleep_r4>=8

gen sleep_cat_r5=.
replace sleep_cat_r5=0 if sleep_r5<8
replace sleep_cat_r5=1 if sleep_r5>=8

label define sleep_cat 0 "Insufficient" 1 "Sufficient"
label val sleep_cat_r3 sleep_cat
label val sleep_cat_r4 sleep_cat
label val sleep_cat_r5 sleep_cat

drop mvdlocr5 enroll_s_r5 enroll_s_r3 howabs_r3 read_raw_r3 math_raw_r3 read_c_r3 math_c_r3 zwfa_r3 mvdtypr3 howabs_r5 region_r3 situac_r3 enroll_s_r4 howabs_r4 read_raw_r4 math_raw_r4 math_raw_r5 read_raw_r5 agem_r3 agem_r4 agem_r5
gen typesite_r4 = .

cd "$resultados"
saveold yl_final.dta, version (12) replace

****Quedan 1486 variables****

