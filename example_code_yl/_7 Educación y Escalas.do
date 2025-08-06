**************************************

* Taller de uso de base de datos NdM *

**************************************

clear	all
set more off

global		dir		"C:\Users\cfelipe\Dropbox"

global 		r3yc	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
global 		r3oc	"$dir\Taller NdM 2018_II\Bases\Peru\R3_OC\Stata files"
global 		results "$dir\Taller NdM 2018_II\Bases\Results"
global 		school	"$dir\Taller NdM 2018_II\Bases\Peru\School Survey\Stata"

* Calcular educación de la madre 

cd			"$r3yc"
use			pe_yc_householdmemberlevel.dta 
rename  	_all, lower

tab relate
tab memsex

keep		if relate==1 & memsex==2  //Padre o Madre biológico y sexo mujer
tab			grader3
recode		grader3 (1/10 17 20=0) (11/19=1) , g(mum_educ) // 0= secundaria incompleta o menos 1=secundaria completa o más
keep		childid mum_educ

sort		childid
cd 			"$results"
save		mom_educ.dta, replace

* Historial educativo 
cd			"$r3oc"
use			pe_oc_householdlevel.dta, clear
rename 		_all, lower

rename 		grder399 GRADE1999
rename 		grder300 GRADE2000
rename 		grder301 GRADE2001
rename 		grder302 GRADE2002
rename 		grder303 GRADE2003
rename 		grder304 GRADE2004
rename 		grder305 GRADE2005
rename 		grder306 GRADE2006
rename 		grder307 GRADE2007
rename 		grder308 GRADE2008
rename 		grder309 GRADE2009

rename  	atscr399 atscr1999
rename  	atscr300 atscr2000
rename  	atscr301 atscr2001
rename  	atscr302 atscr2002
rename  	atscr303 atscr2003
rename  	atscr304 atscr2004
rename  	atscr305 atscr2005
rename  	atscr306 atscr2006
rename  	atscr307 atscr2007
rename  	atscr308 atscr2008
rename  	atscr309 atscr2009

keep 		GRADE* atscr* childid
drop		atscr398 atscr397 atscr396 atscr395 atscr394
reshape 	long GRADE atscr, i(childid) j(año)

* Año en que empezaron la escuela
bys 		childid: egen	emp_escuela=min(año) if GRADE==1 

* Año en el que terminaron primaria 
bys 		childid: egen	termi_pri=max(año) if GRADE==6 

collapse	(mean) emp_escuela termi_pri, by(childid)
 
* Expectativas de los padres
cd 			"$r3yc"
use 		pe_yc_householdlevel.dta, clear 
rename 		_all, lower

sort  		childid 
merge 		1:1	childid using pe_yc_childlevel.dta

tab 		grdlker3
tab 		expgrdr3

bys			typesite: tab grdlker3

tab 		cambtnr3
bys			typesite: tab cambtnr3 

* Encuesta Escolar de NdM
******************************

cd 			"$school"
use			PE_SCH_tblSocioDemographic.dta, clear
rename		_all, lower 

* Información solo para los pares: repitencia del niño y educación de la madre
* Crear el código pupilpk
egen		pupilpk=concat(schlid turnoie aula pupilid)
order		pupilpk
sort		pupilpk

merge 		1:1	pupilpk using PE_SCH_StudentQuestionnaire.dta 
tab 		mateduc
tab			repgrade
tab			_merge	// 570 son NdM. 5 son missing.
drop		_merge 

* Para el niño del milenio (se debe extraer data de rondas): repitencia del niño y educación de la madre

sort		schlid turnoie aula pupilid
merge 		1:1	schlid turnoie aula pupilid using PE_SCH_tblpupilroster.dta
tab			_merge
drop		_merge

sort		childid
cd 			"$results"
merge		childid using mom_educ.dta
tab 		_merge
drop		if _merge == 2
drop		_merge

tab 		mum_educ 
tab			repgrade

* ¿Cómo hacemos para juntarlos con docentes?

sort		schlid turnoie aula 
cd 			"$school"
merge 		m:1	schlid turnoie aula using PE_SCH_mathsteacher.dta
tab			_merge
* También se podría hacer con la base del profesor de Comprensión Lectora.

des 		mtgest01 mtgest02 mtgest03 mtgest04 mtgest05 mtgest06 mtgest07 mtgest08 mtgest09 mtgest10 mtgest11


*******************************************************************************************************************************


* Queremos trabajar con niños de 4to grado y que sean parte del estudio NdM
cd 			"$school"
use 		PE_SCH_StudentQuestionnaire.dta, clear 
rename		_all, lower

sort		schlid turnoie aula pupilid
merge 		1:1	schlid turnoie aula pupilid using PE_SCH_tblpupilroster.dta

keep		if _merge == 3
drop		_merge
* Nos quedamos con los NdM
keep		if ylchild == 1
* Que sean de 4to grado
gen			grado=substr(pupilpk,7,1)
keep		if grado=="4"



*****************
* CONFIABILIDAD *
*****************

* Es importante analizar las características psicométricas (confiabilidad y validez) de las escalas.
** Por ejemplo, para las pruebas de rendimiento existe un documento (disponible en la web, Cueto y León 2009) sobre características psicométricas del PPVT, Mate y Comprensión Lectora.
** No existe para las escalas socioemocionales y otras: es necesario hacer el análisis psicométrico.

* Veremos Confiabilidad.

/* Ejemplo 1: Se tiene una escala que mide seguridad escolar con 6 items y dos alternativas de respuesta 
	si/no , es confiable y valida la escala? */

for 	 	any istole sostole insulted soinsult stdhitu sohit: recode X (77 79 99 = .)
summ	 	istole sostole insulted soinsult stdhitu sohit

* Consistencia Interna.

/* Kuder Richarson */ 
* Solo funciona cuando los items son dicotomicos
ssc install kr20
kr20  	 	istole sostole insulted soinsult stdhitu sohit
* Item difficulty: Media (El nombre viene de analisis de pruebas: 1 correcto, 0 incorrecto)
* Item variance: Varianza del item.
* Item-rest: Correlación del item con el puntaje (la suma) del resto.
* KR20 es el coeficiente de confiabilidad. (min .6, a nivel grupal. 0.8 individual)

/* Alpha de Cronbach */
 
alpha	 	istole sostole insulted soinsult stdhitu sohit  //	0.63	
alpha	 	istole sostole insulted soinsult stdhitu sohit , item	
* Fórmula es muy parecidas a KR20.		
* Item-test es como Item-rest, pero incluye al mismo item. El item-rest es más riguroso.
* OJO: No existe una confiabilidad por item. El alpha que vemos no es el alfa de cada item, sino cuanto valdría
* el alfa de la escala si eliminamos ese item.

/* Ejemplo 2: Se tiene una escala que intenta medir sentido de pertenencia en la escuela con 3 alternativas
   de respuesta */

for 	 	any stranger easyfrds feelhome awkward clsslike alone faltar bored: recode X (77 79 99 = .)
  		
alpha 	 	stranger easyfrds feelhome awkward clsslike alone faltar bored 
alpha 	 	stranger easyfrds feelhome awkward clsslike alone faltar bored, item /* 0.59 */
* Para clsslike solo 325 contestaron. Queremos trabajar solo con esos: cas.

alpha 	 	stranger easyfrds feelhome awkward clsslike alone faltar bored, item cas
* Es muy bajo.

/*	
	Alternativas: 
		1) Eliminar items con correlaciones negativas
		2) Eliminar items con correlaciones menores a 0.1 
*/
* Stata voltea el signo de los items. Veamos la verdadera correlación:
alpha 		stranger easyfrds feelhome awkward clsslike alone faltar bored, item asis   // alpha: 0.38. Sacamos Item 3 y 5 
alpha 		stranger easyfrds awkward alone faltar bored, item asis				 // alpha: 0.54. Sacamos Item 2 
alpha 		stranger awkward alone faltar bored, item asis				 	 	 // alpha: 0.64.

* alpha = 0.64
* PERO:
* Antes de realizar el análisis de confiabilidad, se debe revisar la dirección de los items
for 		any	stranger awkward alone faltar bored: recode X (1=3) (3=1)
alpha 		stranger easyfrds feelhome awkward clsslike alone faltar bored, item asis 
*Ya no hay correlación negativa, pero el alpha es bajo: No es confiable.
