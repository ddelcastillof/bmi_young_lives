*******************************
*******************************
clear
set more off

*cd "G:\Nicolás\Young Lives\Talleres\2017"
cd			"C:\Users\Darwin\Documents\Research\Taller NdM 2018_II\"

*** NdM PERU - algunos datos de ronda 2
use 		"Bases\Peru\R2_YC\Stata files\PEChildLevel5YrOld.dta", clear
tab 		mumed
tab 		mumed, nol
tab 		presch
keep 		childid mumed presch
sort 		childid
save 		"Bases\Results\edu.dta", replace

*** NdM PERU - identificador de comunidad de ronda 3 (7-8 años)
use 		"Bases\Peru\R3_YC\Stata Data files\PE_YC_HouseholdLevel.dta", clear
keep 		childid placeid ylcomm3 nrstcom3 placenr3 alrdmini3 peminiid3
sort 		childid
save 		"Bases\Results\placeid.dta", replace

*** NdM PERU - edad y sexo del niño en ronda 3 (7-8 años)
use 		"Bases\Peru\R3_YC\Stata Data files\PE_YC_HouseholdMemberLevel.dta", clear
keep 		if id==0
tab 		age
tab 		memsex
keep 		age memsex childid
sort 		childid
save 		"Bases\Results\ageR3.dta", replace

*** NdM Peru - todos los datos de ronda 1
use 		"Bases\Peru\R1_YC\Stata files\PEChildLevel1YrOld.dta", clear
keep        zhfa agechild childid clustid wi typesite
sort 		childid
save 		"Bases\Results\ronda1.dta", replace

*** Cruzando información previa con resultados del niño de ronda 3
use 		"Bases\Peru\R3_YC\Stata Data files\PE_YC_ChildLevel.dta", clear
drop 		if childid=="PE031085" & sibid==17
drop 		if childid=="PE091051" & sibid==18
drop 		if childid=="PE171035" & sibid==4

sort 		childid
merge 		childid using "Bases\Results\ronda1.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

sort 		childid
merge 		childid using "Bases\Results\ageR3.dta"
tab 		_merge
keep if 	_merge==3
drop 		_merge

sort 		childid
merge 		childid using "Bases\Results\placeid.dta"
tab 		_merge
keep if 	_merge==3
drop 		_merge

sort 		childid
merge		childid using "Bases\Results\edu.dta"
tab 		_merge
keep if 	_merge==3
drop 		_merge

*** Histograma de PPVT en ronda 3
hist 		ppvt
tab 		age, s(ppvt)

*** Estandarizacion de score en prueba PPVT por edad
egen 		std_ppvt_7=std(ppvt) if age==7
egen 		std_ppvt_8=std(ppvt) if age==8
gen 		std_ppvt=.
replace 	std_ppvt=std_ppvt_7 if age==7
replace 	std_ppvt=std_ppvt_8 if age==8

*** Variables de educación materna
drop 		if mumed==18 /*no sabemos que es*/
gen 		edu_primaria_completa=0
replace 	edu_primaria_completa=1 if mumed>=6
gen 		edu_secundaria=0
replace 	edu_secundaria=1        if mumed>6
gen 		edu_superior=0
replace 	edu_superior=1          if mumed>11
replace 	edu_primaria_completa=0 if mumed==17
replace 	edu_secundaria=0        if mumed==17 
replace 	edu_superior=0          if mumed==17

*** Outliers de haz
gen flag=0
replace flag=1 if zhfa<-5
replace flag=1 if zhfa>5

**********************************
**********************************
* ANALISIS DE REGRESION          *
**********************************
**********************************

*** Regresiones simples de asociacion entre talla-por-edad a los 6-18 meses y PPVT a los 7-8 años
reg 		std_ppvt zhfa i.memsex age                                              if flag==0, cluster(clustid)
reg 		std_ppvt zhfa i.memsex age edu_pr edu_se edu_su                         if flag==0, cluster(clustid)
reg 		std_ppvt zhfa i.memsex age edu_pr edu_se edu_su wi i.typesite           if flag==0, cluster(clustid)
reg 		std_ppvt zhfa i.memsex age edu_pr edu_se edu_su wi i.typesite i.clustid if flag==0, cluster(clustid)
reg 		std_ppvt zhfa i.memsex age edu_pr edu_se edu_su wi i.typesite i.clustid i.agechild if flag==0, cluster(clustid)

*** Regresiones simples de asociacion entre preescuela y PPVT
reg 		std_ppvt presch i.memsex age, cluster(clustid)
reg 		std_ppvt presch i.memsex age edu_pr edu_se edu_su, cluster(clustid)
reg 		std_ppvt presch i.memsex age edu_pr edu_se edu_su wi i.typesite, cluster(clustid)
reg 		std_ppvt presch i.memsex age edu_pr edu_se edu_su wi i.typesite i.clustid, cluster(clustid)

**********************************
**********************************
* FACTORES DE EXPANSION          *
**********************************
**********************************
sort 		childid
merge 		childid using "Bases\Peru\Otros\factor_yc.dta"
tab 		_merge
keep if 	_merge==3
drop 		_merge
	
tab 		typesite
tab 		typesite [weight=factor]

reg 		std_ppvt presch i.memsex age edu_pr edu_se edu_su wi typesite i.clustid, cluster(clustid)
reg 		std_ppvt presch i.memsex age edu_pr edu_se edu_su wi typesite i.clustid [weight=factor], cluster(clustid)

*******************************************************
*******************************************************
*  FUSION CON ENCUESTA DE COMUNIDAD Y DE MINICOMUNIDAD*
*******************************************************
*******************************************************

save 		"Bases\Results\archivodetrabajo.dta", replace

*** Encuestas de comunidad
use 		"Bases\Peru\Otros\pe_r3_community_comm_level_r3.dta", clear
sort 		PLACEID
save		, replace

*** Encuestas de minicomunidad
use 		"Bases\Peru\Otros\MiniPE_Comm_Level.dta", clear
rename 		*, upper
sort 		PLACEID
save		, replace

*** Fusion con comunidades
use 		"Bases\Results\archivodetrabajo.dta", clear
rename 		placeid PLACEID
sort 		PLACEID
merge 		PLACEID using "Bases\Peru\Otros\pe_r3_community_comm_level_r3.dta"
tab 		_merge
keep if     _merge==3
drop        _merge
gen         comm=.
replace     comm=1
sort        childid
save 		"Bases\Results\parte1.dta", replace

*** Fusion con minicomunidades
use 		"Bases\Results\archivodetrabajo.dta", clear
keep if     placeid=="PE88C88"
rename      placeid placeid_original
rename      peminiid3 PLACEID
sort 		PLACEID
merge 		PLACEID using "Bases\Peru\Otros\MiniPE_Comm_Level.dta"
tab 		_merge
keep if     _merge!=2
gen         comm=.
replace     comm=2 if _merge==3
replace     comm=3 if _merge==1
drop        _merge

*** Fusionando datos de comunidad y minicomunidad
sort        childid
merge       childid using "Bases\Results\parte1.dta"
tab         _merge
drop        _merge
label var    comm "Vinculado a cuestionario de comunidad o minicomunidad"
label define comm 1 "Comunidad" 2 "Minicomunidad" 3 "Ninguno" 
label values comm comm

tab         comm

*** Por ejemplo, niños que viven en localidades donde hay comisaria
tab  		PLCSTTN
