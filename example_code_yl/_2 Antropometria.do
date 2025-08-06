clear all
set mem 2000m
set more off 
set maxvar 5000

global		dir		"C:\Users\Darwin\Documents\Research"

global 		ycr3 	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
global 		ycr2 	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
global 		ycr1 	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"

global		results "$dir\Taller NdM 2018_II\Bases\Results"

/*
-------------------------------------------------------------------------------------------------------------------------------
                                                TALLER DE NIÑOS DEL MILENIO 
-------------------------------------------------------------------------------------------------------------------------------
*/

**ANTROPOMETRÍA

*****************
//	  	1	   //
*****************

*Abrimos base de R1
cd		"$ycr1"
use		"pechildlevel1yrold.dta", clear

*** Variable peso al nacer
tab		bwght, miss							 	 // Hay 270 missing values.
hist	bwght if bwght>0, xlabel (1000 (500) 5000) width(90)			 //Se repiten valores "Redondeados".
*hist bwght if bwght>0, width(80)

*** Peso fue documentado?
tab		bwdoc

*** La no documentación genera los picos?
cd		"$results"
hist	bwght if bwght>0	& bwdoc==1, xlabel (1000 (500) 5000) width(90) saving(docum, replace) title("Documentado")
hist	bwght if bwght>0	& bwdoc==2, xlabel (1000 (500) 5000) width(90) saving(nodocum, replace) title("No Documentado")
graph	combine docum.gph nodocum.gph		
tab		bwght bwdoc

	//Parece que el problema persiste, por lo que se puede usar tanto el peso documentado como el no documentado.
	
	
*****************
//	  	2	   //
*****************

*** Variable edad en meses
summ	agemon
hist	agemon
			
*** Variable talla en cms
summ	chheght
tab		chheght
tab		chheght, nol
summ	chheght if chheght>0
hist	chheght if chheght>0
			
*** Variable talla-por-edad (z-score)
sum		zhfa
hist	zhfa
kdensity zhfa

*** Outliers:
tab		fhfa
tab 	zhfa if fhfa==1

*** Talla-por-edad y edad en meses
gen		age=round(agemon)

preserve
keep	zhfa age
collapse zhfa, by(age)			//Promedio del z-score de talla para la edad por edad en meses
scatter zhfa age
restore
			
	// Una baja talla por edad (cuando está por debajo de dos desviaciones estándar respecto a la media de la WHO)
	// es consideraba como una medida de desnutrición crónica. 		

*** Desnutrición crónica

kdensity zhfa if fhfa==0, xline(-2)

gen		stunted=0
replace stunted=1 if zhfa<-2
replace stunted=. if fhfa==1
format	stunted %9.2f
tab		stunted		//28% de la muestra es desnutrida.

*** Desnutrición según urbano/rural
graph	bar stunted, over(typesite) 
tabstat stunted, by(typesite) f //Mayor desnutrición en zonas rurales.

*** Desnutrición según sexo.
tabstat stunted, by(sex) f //Mayor desnutrición en hombres que en mujeres.		
		
*** Desnutrición según lugar de nacimiento
tab		bplace
tabstat stunted if bplace!=4, by(bplace) f //Mayor desnutrición en niños nacidos en sus casas.				
		
*** Desnutrición según presencia de doctor
tab		docbrth
tabstat stunted if docbrth<=2, by(docbrth) f //Mayor desnutrición en niños nacidos sin doctor presente.				

*** Desnutrición según acceso a electricidad
tab		elec
tabstat stunted, by(elec) f //Mayor desnutrición en niños sin acceso a electricidad.				

*****************
//	  	3	   //
*****************

		// Otra medida (menos extendida) para medir problemas de nutrición es el peso por edad.
		// El peso por edad nos puede indicar si un niño está bajo en peso o no.
		
		
** Generar la variable "underweight" para niños con un peso por edad por debajo de 2 desviaciones estándar.
** Replicar hechos estilizados.

** Comparar "underweight" con "stunted". ¿Predicen lo mismo?


*****************
//	  	4	   //
*****************

cd		"$results"
save	"Taller_NDM.dta", replace
clear all

* Abrimos R2
cd		"$ycr2"
use		pechildlevel5yrold.dta
keep	childid zhfa fhfa

rename	zhfa zhfa_r2
rename	fhfa fhfa_r2

gen		stunted_r2=0
replace stunted_r2=1 if zhfa_r2<-2
replace stunted_r2=. if fhfa_r2==1
tab		stunted_r2

cd		"$results"
save	"Taller_r2.dta", replace
clear all

* Abrimos R3
cd		"$ycr3"
use		"PE_YC_ChildLevel"
keep	childid zhfa fhfa bmi zbfa fbfa

rename	zhfa zhfa_r3
rename	fhfa fhfa_r3
rename	bmi bmi_r3
rename	zbfa zbfa_r3
rename	fbfa fbfa_r3

gen		stunted_r3=0
replace stunted_r3=1 if zhfa_r3<-2
replace stunted_r3=. if fhfa_r3==1
tab		stunted_r3

cd		"$results"
save	"Taller_r3.dta", replace
clear all

* Volvemos a nuestra base inicial

use		"Taller_NDM.dta", replace

merge	1:1 childid using "Taller_r2.dta", gen(_m2)
merge	1:1 childid using "Taller_r3.dta", gen(_m3)

keep	if _m2==3 & _m3==3			// Nos quedamos con los niños que se mantienen en las diferentes rondas para mantener la muestra comparable

*****************
//	  	5	   //
*****************

rename	stunted stunted_r1

tab		stunted_r1 stunted_r2
tab		stunted_r2 stunted_r3

*Generamos medias (El porcentaje de desnutridos por ronda)
egen	stunted_m1=mean(stunted_r1)
egen	stunted_m2=mean(stunted_r2)
egen	stunted_m3=mean(stunted_r3)

sum		stunted_m*
				
graph	bar stunted_r1 stunted_r2 stunted_r3

			// Se observa que para la ronda 2, el porcentaje de stunted es mayor que en la ronda 1. 
			// Sin embargo, para la ronda 3 se lleva a cabo una recuperación considerable.

tabstat stunted_r1 stunted_r2 stunted_r3, by(typesite)
graph	hbar stunted_r1 stunted_r2 stunted_r3, over(typesite)

tabstat stunted_r1 stunted_r2 stunted_r3, by(sex)
graph	hbar stunted_r1 stunted_r2 stunted_r3, over(sex)


*****************
//	  	6	   //
*****************

* BMI (Índice de Masa corporal)
sum		bmi_r3

*BMI por edad
tab		zbfa_r3   /* bmi-for-age z-score */
tab 	fbfa_r3   /* flag = 1 if (zbfa < -5 | zbfa > 5) */

*** Generamos sobrepeso a partir de variable WFA (peso por edad)
gen		overw=0
replace overw=1 if zwfa>1 /* zwfa: weight-for-age z-score. Sobrepeso: + de 1 desviación estándar */
replace overw=. if fwfa==1 /* flag = 1 if (zwfa < -6 | zwfa >5) */ 
tab		overw
format	overw %9.2f

*** Generamos obesidad a partir de variable WFA (peso por edad)
gen		overw2=0
replace overw2=1 if zwfa>2 /* zwfa: weight-for-age z-score. Obesidad: + de 2 desviaciones estándar */
replace overw2=. if fwfa==1
tab		overw2

*** Obesidad según urbano/rural
tabstat overw, by(typesite) f // Sobrepeso principalmente en zonas urbanas.

*** Obesidad según género
tabstat overw, by(sex) f // Ligeramente mayor en mujeres.		
		
