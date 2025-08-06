clear all
set mem 2000m
set more off 
set maxvar 5000

global		dir		"C:\Users\jferrer\OneDrive - Grupo de Análisis para el Desarrollo"

local 		ycr4 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_YC\HH_YC"
local 		ycr3 	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
local 		ycr2 	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
local 		ycr1 	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"

local 		results "$dir\Taller NdM 2018_II\Bases\Results"

/*
-------------------------------------------------------------------------------------------------------------------------------
                                                TALLER DE NIÑOS DEL MILENIO 
-------------------------------------------------------------------------------------------------------------------------------
*/

*** Ahora vamos a intentar observar cambios en el bienestar de los hogares.
**En las siguientes líneas haremos esto para la cohorte menor.

*Abrimos la ronda 4
cd		"`ycr4'"
use		"PE_R4_YCHH_YoungerHousehold", clear
rename 	_all, lower

tostring childcode, gen(childid)
replace childid="PE0"+childid if childcode<100000
replace childid="PE"+childid if childcode>=100000

rename	* *_r4
rename	childid_r4 childid

*Abrimos la ronda 3

cd		"`ycr3'"
merge	1:1 childid using "PE_YC_HouseholdLevel"

drop	_m
rename	* *_r3
rename	*_r4_r3 *_r4
rename	childid_r3 childid

*Hacemos el merge con la ronda 2
cd		"`ycr2'"
merge	1:1 childid using "pechildlevel5yrold"

drop	_m
rename	* *_r2
rename	*_r3_r2 *_r3
rename 	*_r4_r2 *_r4
rename	childid_r2 childid

*Hacemos el merge con la ronda 1
cd		"`ycr1'"
merge	1:1 childid using "pechildlevel1yrold"

********************************
***Cambios en el Wealth Index***
********************************

gen		difwi=wi_r4-wi
tabstat wi wi_r2 wi_r3 wi_r4 difwi

*Urbano/Rural según ronda 1
tabstat wi wi_r2 wi_r3 wi_r4 difwi, by(typesite)

*Según quintiles de gasto real per cápita de los hogares en ronda 2
desc	totalexp_pc_r2
sum		totalexp_pc_r2
xtile	qgasto = totalexp_pc_r2, nq(5)
tabstat wi wi_r2 wi_r3 wi_r4 difwi, by(qgasto)

*Según lengua materna de la madre
tab		mothidio
gen		spanish=mothidio==1
replace spanish=. if mothidio==88
tabstat wi wi_r2 wi_r3 wi_r4 difwi, by(spanish)

*Nivel educativo de la madre
tab		mumed
gen		m_educ=0
replace m_educ=1 if mumed>=6 & mumed<=11
replace m_educ=2 if mumed>11
replace m_educ=0 if mumed==17
replace m_educ=. if mumed==18 | mumed==77
tabstat wi wi_r2 wi_r3 wi_r4 difwi, by(m_educ)

************************
***Acceso a servicios***
************************

**Agua entubada
tab		drwater_r2
gen		entubada_r2=drwater_r2==1
tab		drwtrr3_r3
gen		entubada_r3=drwtrr3_r3==1
tab		drwtrr4_r4
gen		entubada_r4=drwtrr4_r4==1

graph	hbar entubada_r2 entubada_r3 entubada_r4, title(Agua Entubada) yvaroptions(relabel(1 "Ronda 2 (2006)" 2 "Ronda 3 (2009)" 3 "Ronda 4 (2013)"))

*Saneamiento (Inodoro o letrina)
gen		saneamiento_r1=(toilet==1 | toilet==5)
gen		saneamiento_r2=(toilet_r2==1 | toilet_r2==5 | toilet_r2==6)
gen		saneamiento_r3=(toiletr3_r3==1 | toiletr3_r3==5 | toiletr3_r3==6)
gen		saneamiento_r4=(toiletr4_r4==1 | toiletr4_r4==5 | toiletr4_r4==6)
graph	hbar saneamiento_r1 saneamiento_r2 saneamiento_r3 saneamiento_r4, title(Saneamiento) yvaroptions(relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)"  4 "Ronda 4 (2013)"))

*Servicios Higiénicos (Inodoro)
gen		sshh_r1=toilet==1
gen		sshh_r2=toilet_r2==1
gen 	sshh_r3=toiletr3_r3==1
gen 	sshh_r4=toiletr4_r4==1
graph 	hbar sshh_r1 sshh_r2 sshh_r3 sshh_r4, title(Servicios Higiénicos) yvaroptions(relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))

*Electricidad
rename 	elecq elecq_r1
graph 	hbar elecq_r1 elecq_r2 elecq_r3 elecq_r4, title(Electricidad) yvaroptions(relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)"  4 "Ronda 4 (2013)"))

*Internet
replace intrntr3_r3=. if intrntr3_r3==79
rename 	intrntr3_r3 internet_r3
rename 	intrntr4_r4 internet_r4
graph 	hbar internet_r2 internet_r3 internet_r4, title(Internet) yvaroptions(relabel(1 "Ronda 2 (2006)" 2 "Ronda 3 (2009)" 3 "Ronda 4 (2013)"))

*Computer
replace computer=0 if computer==2
replace computer=. if computer==99
rename 	computer computer_r1
rename 	cmpt7r3_r3 computer_r3
graph 	hbar computer_r1 computer_r2 computer_r3, title(Computadora en Casa) yvaroptions(relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2013)"))

******************************************
***CAMBIOS HETEROGÉNEOS EN EL BIENESTAR***
****************************************** 
 
****Cabmios según lengua materna (Español vs Indígena)
*preserve

keep 	entubada* saneamiento* sshh* elecq* internet* childid spanish
reshape long entubada_r saneamiento_r sshh_r elecq_r internet_r, i(childid) j(ronda)
 
graph	bar entubada, nofill title(Agua Entubada) asy over(spanish, relabel(1 "Indígena" 2 "Español")) over(ronda, relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))
graph	bar saneamiento, nofill title(Saneamiento) asy over(spanish, relabel(1 "Indígena" 2 "Español")) over(ronda, relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))
graph	bar sshh, nofill title(Servicios Higiécos) asy over(spanish, relabel(1 "Indígena" 2 "Español")) over(ronda, relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))
graph	bar elecq, nofill title(Electricidad) asy over(spanish, relabel(1 "Indígena" 2 "Español")) over(ronda, relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))
graph	bar internet, nofill title(Internet) asy over(spanish, relabel(1 "Indígena" 2 "Español")) over(ronda, relabel(1 "Ronda 1 (2002)" 2 "Ronda 2 (2006)" 3 "Ronda 3 (2009)" 4 "Ronda 4 (2013)"))

*restore
