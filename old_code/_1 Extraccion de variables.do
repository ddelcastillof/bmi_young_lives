clear all
global	dir		"C:\Users\Darwin\Documents\Research"
global  drive	"C:\Users\Darwin\OneDrive - Universidad Nacional Mayor de San Marcos"
global  pound   "C:\Users\Darwin\Documents\Research\Taller NdM 2018_II\Bases\Peru\Otros"

global  ycr5	"$dir\Taller NdM 2018_II\Bases\Peru\R5_YC"
global 	ycr4 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_YC"
global 	ycr3	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata files"
global 	ycr1	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"
global  ycr2	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
global 	school	"$dir\Taller NdM 2018_II\Bases\Peru\School Survey\Stata"

global 	resultados "$drive\_1. Tesis - Sobrepeso y rendimiento académico\Análisis\Resultados"

							   /// Obesidad y RA ////
							//Extracción de variables//
/*****Variables que se van a extraer: Ronda 3*****
   1. Matematica: child_q
   2. Lectura: child_q
   3. PPVT (inteligencia verbal): child_q
   4. IMC: child_q
   5. Sexo: child_q
   6. Absentismo escolar: child_q
   7. Edad en meses: household_q
   8. Actividad fisica: household_q
   9. Tipo de familia: household_q
   10. Educación papá: household_member_q
   11. Educación mamá: household_member_q
******/
///Extrayendo variables de la encuesta///

cd "$ycr3"
use PE_YC_Childlevel.dta, clear
rename  _all, lower
lookfor math
rename (math math_co rmath_co) (math_raw_r3 math_c_r3 math_rasch_r3)
lookfor read
rename (egra egra_co regra_co) (read_raw_r3 read_c_r3 read_rasch_r3)
lookfor ppvt
rename (ppvt rppvt_co) (verbaliq_raw_r3 verbaliq_rasch_r3)
lookfor bmi
rename (bmi zwfa zhfa zbfa) (bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3)
lookfor sex
rename chsex childsex
lookfor abs
rename (enrschr3 misschr3 tmabstr3) (enroll_s_r3 absent_r3 howabs_r3)
keep childid math_raw_r3 math_c_r3 math_rasch_r3 read_raw_r3 read_c_r3 read_rasch_r3 ///
verbaliq_raw_r3 verbaliq_rasch_r3 bmi_r3 zwfa_r3 zhfa_r3 zbfa_r3 childsex enroll_s_r3 absent_r3 howabs_r3
cd "$resultados"
saveold child_r3_original.dta, version(12) replace

///Extrayendo variables de la encuesta del miembro del hogar///
cd "$ycr3"
use PE_YC_HouseholdLevel.dta, clear 
rename  _all, lower
lookfor age
rename agemon agem_r3
replace agem_r3=round(agem_r3, 1) 
lookfor physacr3
rename physacr3 actfis_r3
rename clustid clustid_r3
rename typesite typesite_r3
rename region region_r3
rename wi wi_r3
rename ycslepr3 sleep_r3
**Creando variable composición de la familia**
gen famstructr3=1 if seemumr3==1 & seedadr3==1
recode famstructr3 (1=1) (.=2)
label define famstructr3 1 "Traditional family" 2 "Single-head o blended family", replace 
label val famstructr3 famstructr3 
label var famstructr3 "type of family in R3"
keep childid clustid_r3 situac_r3 mvdtypr3 typesite_r3 sleep_r3 region_r3 wi_r3 actfis_r3 agem_r3 famstructr3
cd "$resultados"
saveold ageactfis_r3.dta, version(12) replace

//Creando la variable educación de la madre//
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear
keep if relate==1 & memsex==2
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(mum_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace   
label val mum_educ par_educ
label var mum_educ "what was the highest grade that your mother completed or is currently studying?" 
rename mum_educ mum_educ_r3
keep childid mum_educ_r3
cd "$resultados"
saveold mum_educ.dta, version(12) replace

//Creando la variable educación del padre//
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear
rename _all, lower
keep if relate==1 & memsex==1
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(dad_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace
label val dad_educ par_educ
label var dad_educ "what was the highest grade that your father completed or is currently studying?" 
rename dad_educ dad_educ_r3
keep childid dad_educ_r3
cd "$resultados"
saveold dad_educ.dta, version(12) replace

//Creando las variables de otros cuidadores//
**Educación del padrastro**
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear 
rename  _all, lower
keep if relate==2 & memsex==1
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(stepdad_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace
label val stepdad_educ par_educ
label var stepdad_educ "what was the highest grade that your step-dad completed or is currently studying?" 
rename stepdad_educ stepdad_educ_r3
keep childid stepdad_educ
cd "$resultados"
saveold stepdad_educ.dta, version (12) replace

**Educación de la madrastra**
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear
rename  _all, lower
keep if relate==2 & memsex==2
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(stepmum_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace   
label val stepmum_educ par_educ
label var stepmum_educ "what was the highest grade that your step-mom completed or is currently studying?" 
rename stepmum_educ stepmum_educ_r3
keep childid stepmum_educ_r3
cd "$resultados"
saveold stepmum_educ.dta, version(12) replace

**Educación de la mama adoptiva**
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear 
rename  _all, lower
keep if relate==3 & memsex==2
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(adopmum_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace   
label val adopmum_educ par_educ
label var adopmum_educ "what was the highest grade that your step-mom completed or is currently studying?" 
rename adopmum_educ adopmum_educ_r3
keep childid adopmum_educ_r3
cd "$resultados"
saveold adopmum_educ.dta, version(12) replace

**Educación del papa adoptivo**
cd "$ycr3"
use PE_YC_HouseholdMemberLevel.dta, clear
rename  _all, lower
keep if relate==3 & memsex==1
tab	grader3
recode grader3 (1/5 17 20=1)(6=2)(7/10=3)(11=4)(13=5)(14=6)(15=7)(16=8)(18=9)(19=10) , g(adopdad_educ) 
label define par_educ 0 "none" 1 "incomplete primary education or less" 2 "complete primary education" ///
3 "incomplete secondary education" 4 "complete education" /// 
5 "incomplete technical or pedagogical institute" 6 "complete technical or pedagogical institute" ///
7 "incompete university" 8 "complete university" 9 "other" 10 "masters or doctoral at university", replace   
label val adopdad_educ par_educ
label var adopdad_educ "what was the highest grade that your adoptive dad completed or is currently studying?" 
rename adopdad_educ adopdad_educ_r3 
keep childid adopdad_educ_r3
cd "$resultados"
saveold adopdad_educ.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r3_original.dta
merge 1:1 childid using "ageactfis_r3.dta" // 109 datos no unidos por ser niños fallecidos (20), no localizados (33) o rechazaron ser evaluados (56)
drop if _merge==2
drop _merge
saveold child_r3_parcial.dta, replace //Incluye edad y actividad fisica del niño

use child_r3_parcial.dta
merge 1:m childid using "mum_educ.dta", nogen
saveold child_r3_parcial_conmamas.dta, version(12) replace
merge m:1 childid using "dad_educ.dta", nogen
saveold child_r3_parcial_conpapasymamas.dta, version(12) replace 
merge m:1 childid using "stepdad_educ.dta", nogen
saveold child_r3_parcial_constepdads.dta, version(12) replace
merge m:1 childid using "stepmum_educ.dta", nogen
saveold child_r3_parcial_constepdadsymoms.dta, version(12) replace
merge m:1 childid using "adopdad_educ.dta", nogen
saveold child_r3_parcial_conadopdads.dta, version(12) replace
merge m:1 childid using "adopmum_educ.dta", nogen //Incluye padres, padres adoptivos, padrastros
saveold child_r3_parcial_conparents.dta, version(12) replace
merge m:m childid using "famstrucr3.dta"

/*****Variables que se van a extraer: Ronda 4*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. PPVT (inteligencia verbal): child_cognitive_q
   4. IMC: child_q
   5. Sexo: child_q
   6. Absentismo escolar: child_q
   7. Edad en meses: child_q
   8. Indice de riqueza: household_q
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
rename hlimgr43 selfperception_r4
keep childid agem_r4 bmi_r4 zhfa_r4 zbfa_r4 selfperception_r4 enroll_s_r4 absent_r4 howabs_r4 sleep_r4 childsex
cd "$resultados"
saveold child_r4_original.dta, version(12) replace

//Extrayendo variables de la encuesta del hogar//
clear all
cd "$ycr4"
use PE_R4_YCHH_YoungerHousehold.dta
rename _all, lower
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
		saveold child_r4_wealth.dta, version(12) replace

//Extrayendo variables de la encuesta cognitiva//
cd "$ycr4"
use PE_R4_YCCOG_YoungerChild.dta 
rename _all, lower
**Transformando el childid**
tostring childcode, gen(childid)
	replace childid="PE0"+childid if childcode<100000
	replace childid="PE"+childid if childcode>=100000
	drop childcode
lookfor ppvt
rename (ppvt_raw ppvt_perco) (verbaliq_raw_r4 percoppvt_r4)
lookfor math
rename (maths_raw maths_perco) (math_raw_r4 percomath_r4)
lookfor lang
rename (lang_raw lang_perco) (lang_raw_r4 percolang_r4)
keep childid verbaliq_raw_r4 percoppvt_r4 math_raw_r4 percomath_r4 lang_raw_r4 percolang_r4
cd "$resultados"
saveold child_r4_cognitive.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r4_original.dta 
merge 1:1 childid using "child_r4_cognitive.dta", nogen
saveold child_r4_partial.dta, version(12) replace
merge 1:1 childid using "child_r4_wealth.dta", nogen
saveold child_r4_final.dta, version(12) replace


/*****Variables que se van a extraer: Ronda 5*****
   1. Matematica: child_cognitive_q
   2. Lectura: child_cognitive_q
   3. PPVT (inteligencia verbal): child_cognitive_q
   4. IMC: child_q
   5. Sexo: child_q
   6. Absentismo escolar: child_q
   7. Edad en meses: child_q
   8. Actividad fisica: child_q
   9. Indice de riqueza: household_q
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
lookfor phy
rename activer5 actfis_r5
rename chclstr5 clustid_r5 
rename sleepr5 sleep_r5
rename chcmstr5 typesite_r5 
keep childid clustid_r5 mvdlocr5 typesite_r5 childsex sleep_r5 enroll_s_r5 absent_r5 howabs_r5 bmi_r5 zhfa_r5 zbfa_r5 agem_r5 actfis_r5
cd "$resultados"
saveold child_r5_original.dta, version(12) replace

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
		saveold child_r5_wealth.dta, version(12) replace

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
lookfor ppvt
rename (ppvt_raw ppvt_perco) (verbaliq_raw_r5 percoppvt_r5)
lookfor math
rename (maths_raw maths_perco) (math_raw_r5 percomath_r5)
lookfor read
rename (reading_raw reading_perco) (read_raw_r5 percoread_r5)
keep childid verbaliq_raw_r5 percoppvt_r5 math_raw_r5 percomath_r5 read_raw_r5 percoread_r5
cd "$resultados"
saveold child_r5_cognitive.dta, version(12) replace

//Uniendo datos a la base maestra//
cd "$resultados"
use child_r5_original.dta 
merge 1:1 childid using "child_r5_cognitive.dta", nogen
saveold child_r5_partial.dta, version(12) replace
merge 1:1 childid using "child_r5_wealth.dta", nogen
saveold child_r5_final.dta, version(12) replace

/*****Variables que se van a extraer: Ronda 2*****
   1. IMC: child_q
******/
clear all
cd "$ycr2"
use PEChildLevel5YrOld.dta
rename _all, lower
lookfor bmi
lookfor height
lookfor weight
rename (bmi zhfa zbfa zwfl chheight) (bmi_r2 zhfa_r2 zbfa_r2 zwfl_r2 chheight_r2) 
rename clustid clustid_r2
rename typesite typesite_r2
rename region region_r2
keep childid clustid_r2 situac_r2 mvdtypr2 typesite_r2 region bmi_r2 zhfa_r2 zbfa_r2 zwfl_r2 chheight_r2
cd "$resultados"
saveold child_r2_final.dta, version(12) replace


//Union de todas las bases//
clear all
cd "$resultados"

**Ronda 2 y Ronda 3**
use child_r2_final.dta
merge 1:m childid using "child_r3_final.dta"
**109 niños que no siguieron en ronda 3**
drop if _merge!=3
drop _merge
saveold child_r23.dta, version(12) replace

**Ronda 3 y ronda 4**
merge m:1 childid using "child_r4_final.dta"
**18 duplicados en ronda 4 que no existen en ronda 3 y 59 que no siguieron en ronda 4**
drop if _merge!=3
drop _merge
saveold child_r234.dta, version(12) replace

**Ronda 4 y ronda 5**
merge m:1 childid using "child_r5_final.dta"
**60 duplicados en ronda 5 que no existen en las anteriores y 36 que no siguieron en ronda 5**
drop if _merge!=3
drop _merge
saveold child_r2345.dta, version(12) replace

**Union de factores de ponderación**
clear all
cd "$resultados"
use child_r2345.dta
cd "$pound"
merge m:1 childid using "factor_yc.dta"
drop if _merge!=3
drop _merge
cd "$resultados"
saveold childyl.dta, version(12) replace 
 
****Quedan 1825 observaciones****

/*****Variables que se van a extraer: Encuesta Escolar*****
   1. Bullying: istole sostole insulted 
				soinsult stdhitu sohit somupset fight gdfrds funtasks
				
				Total: 6 variables
******/

//Encuesta escolar//
clear all
cd "$school"
use	PE_SCH_StudentQuestionnaire.dta
rename _all, lower 
sort schlid turnoie aula pupilid
merge 1:1 schlid turnoie aula pupilid using PE_SCH_tblpupilroster.dta //29 rechazaron cuestionario del estudiante//
keep if _merge == 3
drop _merge
**Nos quedamos con los pertenecientes al estudio YL**
keep if ylchild==1
**grado del niño**
gen	grado=substr(pupilpk,7,1)
keep childid grado istole sostole insulted soinsult stdhitu sohit somupset fight gdfrds funtasks
cd "$resultados"
saveold child_sch_partial.dta, version(12) replace

**Union de datos de encuesta escolar**
cd "$resultados"
use childyl.dta
merge m:1 childid using "child_sch_partial.dta"
drop if _merge!=3
drop _merge 
saveold childyl_plussch.dta, version(12) replace

****Quedan 548 variables****
