clear all
global	dir		"/Users/darwin/Documents/Research"
global  pound   "/Users/darwin/Documents/Research/Taller NdM 2018_II/Bases/Peru/Otros"

global  ycr5	"$dir/Taller NdM 2018_II/Bases/Peru/R5_YC"
global 	ycr4 	"$dir/Taller NdM 2018_II/Bases/Peru/R4_YC"
global 	ycr3	"$dir/Taller NdM 2018_II/Bases/Peru/R3_YC/Stata files"
global 	ycr1	"$dir/Taller NdM 2018_II/Bases/Peru/R1_YC/Stata files"
global  ycr2	"$dir/Taller NdM 2018_II/Bases/Peru/R2_YC/Stata files"
global 	school	"$dir/Taller NdM 2018_II/Bases/Peru/School Survey/Stata"

global 	resultados "$dir/_1. Obesidad y rendimiento académico/Análisis/Resultados"

							   /// Obesidad y RA ////
							//Extracción de variables//
/*****Variables que se van a extraer: Ronda 3*****
   1. Matematica: child_q
   2. Lectura: child_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: household_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
   
******/
///Extrayendo variables de la encuesta///

cd "$ycr3"
use PE_YC_Childlevel.dta, clear
rename  _all, lower
lookfor math
rename (math math_co rmath_co) (math_raw_r3 math_c_r3 math_rasch_r3)
lookfor read
rename (egra egra_co regra_co) (read_raw_r3 read_c_r3 read_rasch_r3)
lookfor bmi
rename (bmi zwfa zhfa zbfa) (bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3)
lookfor sex
rename chsex childsex
lookfor abs
rename (enrschr3 misschr3 tmabstr3) (enroll_s_r3 absent_r3 howabs_r3)
keep childid math_raw_r3 math_c_r3 math_rasch_r3 read_raw_r3 read_c_r3 read_rasch_r3 bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3 childsex enroll_s_r3 absent_r3 howabs_r3
cd "$resultados"
saveold child_r3.dta, version(12) replace

///Extrayendo variables de la encuesta del miembro del hogar///
cd "$ycr3"
use PE_YC_HouseholdLevel.dta, clear 
rename  _all, lower
lookfor age
rename agemon agem_r3
replace agem_r3=round(agem_r3, 1) 
rename typesite typesite_r3
rename region region_r3
rename wi wi_r3
rename ycslepr3 sleep_r3
keep childid situac_r3 mvdtypr3 typesite_r3 sleep_r3 region_r3 wi_r3 agem_r3
cd "$resultados"
saveold household_r3.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r3.dta
merge 1:1 childid using "household_r3.dta" // 109 datos no unidos por ser niños fallecidos (20), no localizados (33) o rechazaron ser evaluados (56)
drop if _merge==2
drop _merge
saveold yl_r3.dta, replace //Incluye edad e indice de riqueza del niño


/*****Variables que se van a extraer: Ronda 4*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: child_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
******/

///Extrayendo variables de la primera encuesta///
clear all
cd "$ycr4"
use PE_R4_YCCH_YoungerChild.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
	
//Extrayendo variables de la encuesta principal//
lookfor sex
rename gendylr4 childsex
lookfor miss
rename (enrschr4 misschr4 tmabstr4) (enroll_s_r4 absent_r4 howabs_r4)
lookfor bmi
rename (bmi zhfa zbfa) (bmi_r4 zhfa_r4 zbfa_r4)
lookfor age
rename agemon agem_r4
lookfor sleep4
rename sleepr4 sleep_r4
keep childid agem_r4 bmi_r4 zhfa_r4 zbfa_r4 enroll_s_r4 absent_r4 howabs_r4 sleep_r4 childsex
cd "$resultados"
saveold child_r4.dta, version(12) replace

//Extrayendo variables de la encuesta del hogar//
clear all
cd "$ycr4"
use PE_R4_YCHH_YoungerHousehold.dta
rename _all, lower
lookfor site
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode

	//Indice de riqueza//
		lookfor wealth
		rename wi wi_r4
		keep childid wi_r4
		cd "$resultados"
		saveold wealth_r4.dta, version(12) replace

//Extrayendo variables de la encuesta cognitiva//
cd "$ycr4"
use PE_R4_YCCOG_YoungerChild.dta 
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
lookfor math
rename (maths_raw maths_perco) (math_raw_r4 percomath_r4)
lookfor lang
rename (lang_raw lang_perco) (lang_raw_r4 percolang_r4)
keep childid math_raw_r4 percomath_r4 lang_raw_r4 percolang_r4
cd "$resultados"
saveold cognitive_r4.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r4.dta 
merge 1:1 childid using "wealth_r4.dta", nogen
saveold child_r4_partial.dta, version(12) replace
merge 1:1 childid using "cognitive_r4.dta", nogen
saveold yl_r4.dta, version(12) replace


/*****Variables que se van a extraer: Ronda 5*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: child_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
******/

//Extrayendo variables de la encuesta del niño//
clear all
cd "$ycr5"
use pe_r5_ycch_youngerchild.dta
rename _all, lower 
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
lookfor sex
rename gendylr5 childsex
lookfor miss
rename (enrschr5 misschr5 tmabstr5) (enroll_s_r5 absent_r5 howabs_r5)
lookfor bmi
rename (bmi zhfa zbfa) (bmi_r5 zhfa_r5 zbfa_r5)
lookfor agemon
rename agemon agem_r5
rename sleepr5 sleep_r5
rename chcmstr5 typesite_r5 
keep childid mvdlocr5 typesite_r5 childsex sleep_r5 enroll_s_r5 absent_r5 howabs_r5 bmi_r5 zhfa_r5 zbfa_r5 agem_r5
cd "$resultados"
saveold child_r5.dta, version(12) replace

//Extrayendo indice de riqueza de la encuesta del hogar//
clear all
cd "$ycr5"
use pe_r5_ychh_youngerhousehold.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode

	//Indice de riqueza//
		lookfor wealth
		rename wi wi_r5
		keep childid wi_r5 
		cd "$resultados"
		saveold wealth_r5.dta, version(12) replace

//Extrayendo variables de la encuesta cognitiva//
clear all
cd "$ycr5"
use pe_r5_yccogtest_youngerchild.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
lookfor math
rename (maths_raw maths_perco) (math_raw_r5 percomath_r5)
lookfor read
rename (reading_raw reading_perco) (read_raw_r5 percoread_r5)
keep childid math_raw_r5 percomath_r5 read_raw_r5 percoread_r5
cd "$resultados"
saveold cognitive_r5.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r5.dta 
merge 1:1 childid using "cognitive_r5.dta", nogen
saveold child_r5_partial.dta, version(12) replace
merge 1:1 childid using "wealth_r5.dta", nogen
saveold yl_r5.dta, version(12) replace


****Union de todas las bases****
clear all
cd "$resultados"

**Ronda 3 y Ronda 4**
use yl_r3.dta
merge 1:1 childid using "yl_r4.dta"
**77 niños que no siguieron en ronda 4**
drop if _merge!=3
drop _merge
saveold yl_r34.dta, version(12) replace

**Ronda 4 y Ronda 5**
merge 1:1 childid using "yl_r5.dta"
**77 niños que no siguieron en ronda 5**
drop if _merge!=3
drop _merge
saveold yl_345.dta, version(12) replace


**Union de factores de ponderación**
	*Extracción de clusterid*
		clear all
		cd "$ycr1"
		use PEChildLevel1YrOld.dta
		rename _all, lower
		keep childid clustid
		cd "$resultados"
		saveold yl_clusterid.dta, version(12) replace
cd "$pound"
use factor_yc.dta
rename factor clustfactor
cd "$resultados"
saveold factor_yc.dta, version(12) replace
cd "$resultados"
use yl_345.dta
cd "$resultados"
merge 1:1 childid using "factor_yc.dta"
drop if _merge!=3
drop _merge
cd "$resultados"
merge 1:1 childid using "yl_clusterid.dta"
drop if _merge!=3
drop _merge
cd "$resultados"
saveold yl_final.dta, version(12) replace 
 
****Quedan 1824 observaciones****clear all
global	dir		"/Users/darwin/Documents/Research"
global  pound   "/Users/darwin/Documents/Research/Taller NdM 2018_II/Bases/Peru/Otros"

global  ycr5	"$dir/Taller NdM 2018_II/Bases/Peru/R5_YC"
global 	ycr4 	"$dir/Taller NdM 2018_II/Bases/Peru/R4_YC"
global 	ycr3	"$dir/Taller NdM 2018_II/Bases/Peru/R3_YC/Stata files"
global 	ycr1	"$dir/Taller NdM 2018_II/Bases/Peru/R1_YC/Stata files"
global  ycr2	"$dir/Taller NdM 2018_II/Bases/Peru/R2_YC/Stata files"
global 	school	"$dir/Taller NdM 2018_II/Bases/Peru/School Survey/Stata"

global 	resultados "$dir/_1. Obesidad y rendimiento académico/Análisis/Resultados"

							   /// Obesidad y RA ////
							//Extracción de variables//
/*****Variables que se van a extraer: Ronda 3*****
   1. Matematica: child_q
   2. Lectura: child_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: household_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
   
******/
///Extrayendo variables de la encuesta///

cd "$ycr3"
use PE_YC_Childlevel.dta, clear
rename  _all, lower
lookfor math
rename (math math_co rmath_co) (math_raw_r3 math_c_r3 math_rasch_r3)
lookfor read
rename (egra egra_co regra_co) (read_raw_r3 read_c_r3 read_rasch_r3)
lookfor bmi
rename (bmi zwfa zhfa zbfa) (bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3)
lookfor sex
rename chsex childsex
lookfor abs
rename (enrschr3 misschr3 tmabstr3) (enroll_s_r3 absent_r3 howabs_r3)
keep childid math_raw_r3 math_c_r3 math_rasch_r3 read_raw_r3 read_c_r3 read_rasch_r3 bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3 childsex enroll_s_r3 absent_r3 howabs_r3
cd "$resultados"
saveold child_r3.dta, version(12) replace

///Extrayendo variables de la encuesta del miembro del hogar///
cd "$ycr3"
use PE_YC_HouseholdLevel.dta, clear 
rename  _all, lower
lookfor age
rename agemon agem_r3
replace agem_r3=round(agem_r3, 1) 
rename typesite typesite_r3
rename region region_r3
rename wi wi_r3
rename ycslepr3 sleep_r3
keep childid situac_r3 mvdtypr3 typesite_r3 sleep_r3 region_r3 wi_r3 agem_r3
cd "$resultados"
saveold household_r3.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r3.dta
merge 1:1 childid using "household_r3.dta" // 109 datos no unidos por ser niños fallecidos (20), no localizados (33) o rechazaron ser evaluados (56)
drop if _merge==2
drop _merge
saveold yl_r3.dta, replace //Incluye edad e indice de riqueza del niño


/*****Variables que se van a extraer: Ronda 4*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: child_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
******/

///Extrayendo variables de la primera encuesta///
clear all
cd "$ycr4"
use PE_R4_YCCH_YoungerChild.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
	
//Extrayendo variables de la encuesta principal//
lookfor sex
rename gendylr4 childsex
lookfor miss
rename (enrschr4 misschr4 tmabstr4) (enroll_s_r4 absent_r4 howabs_r4)
lookfor bmi
rename (bmi zhfa zbfa) (bmi_r4 zhfa_r4 zbfa_r4)
lookfor age
rename agemon agem_r4
lookfor sleep4
rename sleepr4 sleep_r4
keep childid agem_r4 bmi_r4 zhfa_r4 zbfa_r4 enroll_s_r4 absent_r4 howabs_r4 sleep_r4 childsex
cd "$resultados"
saveold child_r4.dta, version(12) replace

//Extrayendo variables de la encuesta del hogar//
clear all
cd "$ycr4"
use PE_R4_YCHH_YoungerHousehold.dta
rename _all, lower
lookfor site
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode

	//Indice de riqueza//
		lookfor wealth
		rename wi wi_r4
		keep childid wi_r4
		cd "$resultados"
		saveold wealth_r4.dta, version(12) replace

//Extrayendo variables de la encuesta cognitiva//
cd "$ycr4"
use PE_R4_YCCOG_YoungerChild.dta 
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
lookfor math
rename (maths_raw maths_perco) (math_raw_r4 percomath_r4)
lookfor lang
rename (lang_raw lang_perco) (lang_raw_r4 percolang_r4)
keep childid math_raw_r4 percomath_r4 lang_raw_r4 percolang_r4
cd "$resultados"
saveold cognitive_r4.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r4.dta 
merge 1:1 childid using "wealth_r4.dta", nogen
saveold child_r4_partial.dta, version(12) replace
merge 1:1 childid using "cognitive_r4.dta", nogen
saveold yl_r4.dta, version(12) replace


/*****Variables que se van a extraer: Ronda 5*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. IMC: child_q
   4. Sexo: child_q
   5. Absentismo escolar: child_q
   6. Edad en meses: child_q
   7. Indice de riqueza: household_q
   8. Horas de sueño: child_q
******/

//Extrayendo variables de la encuesta del niño//
clear all
cd "$ycr5"
use pe_r5_ycch_youngerchild.dta
rename _all, lower 
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
lookfor sex
rename gendylr5 childsex
lookfor miss
rename (enrschr5 misschr5 tmabstr5) (enroll_s_r5 absent_r5 howabs_r5)
lookfor bmi
rename (bmi zhfa zbfa) (bmi_r5 zhfa_r5 zbfa_r5)
lookfor agemon
rename agemon agem_r5
rename sleepr5 sleep_r5
rename chcmstr5 typesite_r5 
keep childid mvdlocr5 typesite_r5 childsex sleep_r5 enroll_s_r5 absent_r5 howabs_r5 bmi_r5 zhfa_r5 zbfa_r5 agem_r5
cd "$resultados"
saveold child_r5.dta, version(12) replace

//Extrayendo indice de riqueza de la encuesta del hogar//
clear all
cd "$ycr5"
use pe_r5_ychh_youngerhousehold.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode

	//Indice de riqueza//
		lookfor wealth
		rename wi wi_r5
		keep childid wi_r5 
		cd "$resultados"
		saveold wealth_r5.dta, version(12) replace

//Extrayendo variables de la encuesta cognitiva//
clear all
cd "$ycr5"
use pe_r5_yccogtest_youngerchild.dta
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
lookfor math
rename (maths_raw maths_perco) (math_raw_r5 percomath_r5)
lookfor read
rename (reading_raw reading_perco) (read_raw_r5 percoread_r5)
keep childid math_raw_r5 percomath_r5 read_raw_r5 percoread_r5
cd "$resultados"
saveold cognitive_r5.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r5.dta 
merge 1:1 childid using "cognitive_r5.dta", nogen
saveold child_r5_partial.dta, version(12) replace
merge 1:1 childid using "wealth_r5.dta", nogen
saveold yl_r5.dta, version(12) replace


****Union de todas las bases****
clear all
cd "$resultados"

**Ronda 3 y Ronda 4**
use yl_r3.dta
merge 1:1 childid using "yl_r4.dta"
**77 niños que no siguieron en ronda 4**
drop if _merge!=3
drop _merge
saveold yl_r34.dta, version(12) replace

**Ronda 4 y Ronda 5**
merge 1:1 childid using "yl_r5.dta"
**77 niños que no siguieron en ronda 5**
drop if _merge!=3
drop _merge
saveold yl_345.dta, version(12) replace


**Union de factores de ponderación**
	*Extracción de clusterid*
		clear all
		cd "$ycr1"
		use PEChildLevel1YrOld.dta
		rename _all, lower
		keep childid clustid
		cd "$resultados"
		saveold yl_clusterid.dta, version(12) replace
cd "$pound"
use factor_yc.dta
rename factor clustfactor
cd "$resultados"
saveold factor_yc.dta, version(12) replace
cd "$resultados"
use yl_345.dta
cd "$resultados"
merge 1:1 childid using "factor_yc.dta"
drop if _merge!=3
drop _merge
cd "$resultados"
merge 1:1 childid using "yl_clusterid.dta"
drop if _merge!=3
drop _merge
cd "$resultados"
saveold yl_final.dta, version(12) replace 
 
****Quedan 1824 observaciones****
