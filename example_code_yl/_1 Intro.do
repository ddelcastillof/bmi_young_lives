clear all
set mem 2000m
set more off 
set maxvar 5000

global		dir		"C:\Users\Darwin\Documents\Research"

global 		ycr4 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_YC\CH_YC"
global 		ycr3	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
global 		ycr2	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
global 		ycr1	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"

global 		results "$dir\Taller NdM 2018_II\Bases\Results"

/*
-------------------------------------------------------------------------------------------------------------------------------
                                                TALLER DE NIÑOS DEL MILENIO 
-------------------------------------------------------------------------------------------------------------------------------
*/

**Tenemos 4 rondas para cada una de las 2 cohortes (OC & YC).
**En cada ronda tenemos:
*						 una base del roster
*						 un cuestionario del hogar
*						 un cuestionario del niño, entre otros.
 
 **PRIMERO, NOS CENTRAREMOS EN LAS RONDAS 2 y 3 DE LA COHORTE MENOR DEL CUESTIONARIO DEL NIÑO
 
*1) Cuestionario del niño R2

cd		"$ycr2"
use		pechildlevel5yrold.dta, clear
	*Sexo y edad en meses de YL
	tab 	sex
	sum 	agemon
	*Rural/urbano
	tab 	typesite
	*Lengua de la madre
	tab 	mumlang
	*Lengua materna del niño
	tab 	chlng1st
	*Wealth Index (índice de riqueza)
	sum 	wi
	*Educación de la madre
	tab 	mumed
	tab 	mumed, nol
	*Noten que hay categorías que podríamos agrupar, como ningún año de educación con programas de alfabetización, etc.
	clonevar mother_edu=mumed /*  Clonevar generates newvar as an exact copy of an existing variable.*/
	replace mother_edu=0 if mumed==17 /* Reemplazando alfabetización por 0 años de educación */
	replace mother_edu=. if mumed==77 /* Missing value cuando no se sabe el año de educación de la madre */
	replace mother_edu=. if mumed==18 /* Por simplicidad, asumiremos que la categoría "otros" es missing value */ 
	*Nos quedamos con algunas variables
	keep 	childid sex agemon typesite wi mother_edu

	*Guardamos la base de datos modificada
	cd 		"$results"
	save 	"Taller_R2_child.dta", replace
 
	
**AHORA NOS CENTRAREMOS EN LAS RONDAS 1 y 2 DE LA COHORTE MENOR DE LA BASE ROSTER DEL HOGAR Y DEL CUESTIONARIO DEL NIÑO

*2)Abrimos la base roster de Ronda 2
clear all

cd		"$ycr2"
use		pesubhouseholdmember5.dta
 
	*Extraemos edad de la madre 
	tab 	relate
	keep 	if relate==1 & memsex==2
	tab		age
	hist 	age if age>0, dis /* dis: specify that the data are discrete*/
	keep	childid age
	sort	childid

	*Guardamos la base de datos modificada
	cd		"$results"
	save	mom_educ_R.dta, replace

	*Combinamos las bases creadas
	merge 	1:1 childid using "Taller_R2_child.dta"
	drop _merge

	*Renombramos la variable de rural/urbano para hacer el próximo merge.
	rename 	typesite typesite_r2

	*Guardamos la nueva base de datos modificada
	cd		"$results"
	save 	"Taller_R2_m.dta", replace


*3) Abrimos la base de niños de la Ronda 1
clear all

cd 		"$ycr1"
use 	"pechildlevel1yrold.dta"

	*Renombramos la variable de rural/urbano
	rename 	typesite typesite_r1
	keep 	childid typesite

	*Hacemos el merge con la base anterior, generada con la Ronda 2.
	cd		"$results"
	merge 	1:1 childid using "Taller_R2_m.dta", gen(_mrounds)

	*Observamos que existe migración.
	tab 	typesite*
	
	*Guardamos la nueva base de datos modificada
	cd		"$results"
	save 	"Taller_R2_m.dta", replace

	

*SUPONGAMOS AHORA QUE NOS GUSTARIA COMBINAR DATOS DE LA RONDA 1 Y 2 CON LA RONDA 4 A NIVEL DEL NIÑO

*Abrimos la base de niños de la Ronda 4
clear all

cd 		"$ycr4"
use 	"PE_R4_YCCH_YoungerChild.dta" /* existen datos tambien para el sibiling */
	
	*Edad  en meses 
	sum agemon /* En promedio, los YL tienen 12 años */
	
	*Se encuentran inscritos en la escuela (?)
	tab ENRSCHR4 /*Los missings no solo se presentan como ".", también pueden presentarse con los códigos "-77", "-88", "-99". Varían de ronda en ronda, por eso será necesario remitirse a los cuestionarios*/
	
	*Nos quedamos con algunas de las mismas variables que en el ejercicio para la ronda anterior.
	keep 	 CHILDCODE agemon ENRSCHR4 /* No en todas las rondas la variable identificadora es childid, sino una transformación equivalente */
	
	*Transformar CHILDCODE to CHILDID para realizar el merge
	tostring CHILDCODE, gen(childid)
	replace childid="PE0"+childid if CHILDCODE<100000
	replace childid="PE"+childid if CHILDCODE>=100000
	drop CHILDCODE
	
	*Combinamos las bases creadas
	cd 		"$results"
	merge 	1:1 childid using "Taller_R2_child.dta"	
	drop _merge

