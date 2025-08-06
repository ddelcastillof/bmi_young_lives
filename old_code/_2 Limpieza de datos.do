clear all
global	dir		"C:\Users\Darwin\Documents\Research"
global  drive	"C:\Users\Darwin\OneDrive - Universidad Nacional Mayor de San Marcos"

global 	resultados "$drive\_1. Tesis - Sobrepeso y rendimiento académico\Análisis\Resultados"


								/// Obesidad y RA ////
								//Limpieza de datos//


//Creación de variable obesidad//
cd "$resultados"
use childyl.dta

label var zbfa_r2 "BMI z-score for R2"
label var zbfa_r3 "BMI z-score for R3"
label var zbfa_r4 "BMI z-score for R4"
label var zbfa_r5 "BMI z-score for R5"

**Graficos diagnosticos**
graph hbox zbfa_r2 zbfa_r3 zbfa_r4 zbfa_r5

kdensity zbfa_r2, kernel(gaussian) normal
kdensity zbfa_r3, kernel(gaussian) normal
kdensity zbfa_r4, kernel(gaussian) normal
kdensity zbfa_r5, kernel(gaussian) normal

***Nueva variable clasificación según BMI***
///Ronda 2///
tab zbfa_r2
gen bmiclass_r2 = zbfa_r2
br if zbfa_r2==.
//24 datos perdidos//
recode bmiclass_r2 (-6/-2=-1) (-2/1 = 0) (1/2 = 1) (2/10 = 2)  
**Control de calidad**
br zbfa_r2 bmiclass_r2 if zbfa_r2==-2 
*0 datos correctos*
br zbfa_r2 bmiclass_r2 if zbfa_r2==-1
*2 datos correctos*
br zbfa_r2 bmiclass_r2 if zbfa_r2==0
*8 datos correctos*
br zbfa_r2 bmiclass_r2 if zbfa_r2==1
*10 datos correctos*
br zbfa_r2 bmiclass_r2 if zbfa_r2==2
*2 datos correctos*

///Ronda 3///
tab zbfa_r3
br if zbfa_r3==.
//4 datos no existentes//
gen bmiclass_r3 = zbfa_r3
recode bmiclass_r3 (-5/-2=-1) (-2/1 = 0) (1/2 = 1) (2/7 = 2) (.=.)
**Control de calidad**
br zbfa_r3 bmiclass_r3 if zbfa_r3==-2 
*1 datos correctos*
br zbfa_r3 bmiclass_r3 if zbfa_r3==-1
*4 datos correctos*
br zbfa_r3 bmiclass_r3 if zbfa_r3==0
*8 datos correctos*
br zbfa_r3 bmiclass_r3 if zbfa_r3==1
*7 datos correctos*
br zbfa_r3 bmiclass_r3 if zbfa_r3==2
*6 datos correctos*

///Ronda 4///
tab zbfa_r4
br if zbfa_r4==.
//17 datos no existentes//
gen bmiclass_r4=zbfa_r4
recode bmiclass_r4 (-14/-2=-1) (-2/1 = 0) (1/2 = 1) (2/7 = 2) (.=.)
**Control de calidad**
br zbfa_r4 bmiclass_r4 if zbfa_r4==-2 
*0 datos correctos*
br zbfa_r4 bmiclass_r4 if zbfa_r4==-1
*2 datos correctos*
br zbfa_r4 bmiclass_r4 if zbfa_r4==0
*7 datos correctos*
br zbfa_r4 bmiclass_r4 if zbfa_r4==1
*3 datos correctos*
br zbfa_r4 bmiclass_r4 if zbfa_r4==2
*3 datos correctos*

///Ronda 5///
tab zbfa_r5
br if zbfa_r5==.
//16 datos no existentes//
gen bmiclass_r5=zbfa_r5
recode bmiclass_r5 (-4/-2=-1) (-2/1 = 0) (1/2 = 1) (2/5 = 2) (.=.)
**Control de calidad**
br zbfa_r5 bmiclass_r5 if zbfa_r5==-2 
*0 datos correctos*
br zbfa_r5 bmiclass_r5 if zbfa_r5==-1
*4 datos correctos*
br zbfa_r5 bmiclass_r5 if zbfa_r5==0
*4 datos correctos*
br zbfa_r5 bmiclass_r5 if zbfa_r5==1
*4 datos correctos*
br zbfa_r5 bmiclass_r5 if zbfa_r5==2
*4 datos correctos*

///Etiquetas de valores para clasificación según IMC///
label define bmi_status -1 "Underweight" 0 "Normal weight" 1 "Overweight" 2 "Obesity"

label val bmiclass_r2 bmi_status
label val bmiclass_r3 bmi_status
label val bmiclass_r4 bmi_status
label val bmiclass_r5 bmi_status

label var bmiclass_r2 "BMI classification in round 2"
label var bmiclass_r3 "BMI classification in round 3"
label var bmiclass_r4 "BMI classification in round 4"
label var bmiclass_r5 "BMI classification in round 5"

//Explorando resultados//
tab bmiclass_r2, m
tab bmiclass_r3, m
tab bmiclass_r4, m
tab bmiclass_r5, m

//Manejo de datos no plausibles//
preserve
keep childid zbfa_r2 zbfa_r3 zbfa_r4 zbfa_r5
br if zbfa_r2<=-4
br if zbfa_r3<=-4
br if zbfa_r4<=-4
br if zbfa_r5<=-4
restore

**Ronda 4: valor de BMI de 0.71 con z-bfa de -13.25 no es compatible con la vida**
replace zbfa_r4=. if zbfa_r4==-13.25
replace bmi_r4=.  
replace bmiclass_r4=. 
saveold childyl.dta, version (12) replace

graph hbox zbfa_r2 zbfa_r3 zbfa_r4 zbfa_r5


