clear all
set more off

global		dir		"C:\Users\Darwin\Documents\Research"

local 		r1oc 	"$dir\Taller NdM 2018_II\Bases\Peru\R1_OC\Stata files"
local 		r2oc 	"$dir\Taller NdM 2018_II\Bases\Peru\R2_OC\Stata files"
local 		r3oc 	"$dir\Taller NdM 2018_II\Bases\Peru\R3_OC\Stata files"
local 		r4oc 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_OC\CH_OC"

local 		r1yc 	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"
local 		r2yc 	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
local 		r3yc 	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
local 		r4yc 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_YC\CH_YC"

local 		results "$dir\Taller NdM 2018_II\Bases\Results"

***********************************************
***		ASPIRACIONES Y BIENESTAR SUBJETIVO 	***
***********************************************

*** R2
cd 			"`r2oc'"
use 		PEChildLevel12yrOld

* hedu incluye toda educación superior.
gen 		as_hedu_r2=( gradlike==16 |  gradlike==14)
replace 	as_hedu_r2=. if  gradlike==. |  gradlike==79 |  gradlike==77
* univ incluye universidad y posgrado.
gen 		as_univ_r2=( gradlike==16)
replace 	as_univ_r2=. if  gradlike==. |  gradlike==79 |  gradlike==77
* tec incluye solo educación superior no universitaria.
gen 		as_tec_r2=gradlike==14
replace 	as_tec_r2=. if  gradlike==. |  gradlike==79 |  gradlike==77

** Bienestar subjetivo
replace 	ladder=. if ladder==77 | ladder==79
rename 		ladder ladder_r2

rename 		farlad farlad_r2

keep 		ladder* farlad* as_* childid
cd 			"`results'" 
save 		r2_hedu, replace

*** R3
cd 			"`r3oc'"
use 		PE_OC_ChildLevel

gen 		as_hedu_r3=( lvledcr3==16 |  lvledcr3==19 |  lvledcr3==14)
replace 	as_hedu_r3=. if  lvledcr3==. |  lvledcr3==79 |  lvledcr3==77
gen 		as_univ_r3=( lvledcr3==16 |  lvledcr3==19)
replace 	as_univ_r3=. if  lvledcr3==. |  lvledcr3==79 |  lvledcr3==77
gen 		as_tec_r3=lvledcr3==14
replace 	as_tec_r3=. if  lvledcr3==. |  lvledcr3==79 |  lvledcr3==77

rename 		stnprsr3 ladder_r3
replace 	ladder_r3=. if ladder_r3==77 | ladder_r3==79

keep 		ladder* as_* childid
cd 			"`results'" 
save 		r3_hedu, replace

*** R4
cd 			"`r4oc'"
use 		PE_R4_OCCH_OlderChild

gen 		as_hedu_r4=(CLDSTDR4==16 | CLDSTDR4==19 |  CLDSTDR4==14)
replace 	as_hedu_r4=. if CLDSTDR4==. | CLDSTDR4==79 | CLDSTDR4==77
gen 		as_univ_r4=(CLDSTDR4==16 | CLDSTDR4==19)
replace 	as_univ_r4=. if CLDSTDR4==. | CLDSTDR4==79 | CLDSTDR4==77
gen 		as_tec_r4=CLDSTDR4==14
replace 	as_tec_r4=. if CLDSTDR4==. | CLDSTDR4==79 | CLDSTDR4==77

rename 		STNPRSR4 ladder_r4
replace 	ladder_r4=. if ladder_r4==77 | ladder_r4==79

tostring 	CHILDCODE, gen(childid)
replace 	childid="PE0"+childid if CHILDCODE<100000
replace 	childid="PE"+childid if CHILDCODE>=100000

keep 		ladder* as_* childid
cd 			"`results'" 
save 		r4_hedu, replace

***************** ASPIRATION BAR CHART *****************

clear all
cd 			"`r1oc'"
use 		PEChildLevel8YrOld

keep 		childid

cd 			"`results'" 
merge 		1:1 childid using r4_hedu, gen(_m4)
merge 		1:1 childid using r3_hedu, gen(_m3)
merge 		1:1 childid using r2_hedu, gen(_m2)
order 		childid as_* _m*
drop 		_m*

preserve
reshape 	long as_univ_r as_hedu_r as_tec_r ladder_r, i(childid) j(round)
collapse 	(mean) as_hedu_ as_univ as_tec ladder, by(round)

graph 		bar as_hedu_r as_univ_r as_tec_r, over(round, relabel(1 "12 años" 2 "15 años" 3 "18 años")) ///
			legend(label(1 "Educación superior") label(2 "Universitaria") label(3 "No universitaria")) ///
			title("Aspiración a educación superior según tipo, por ronda")
restore

twoway 		(histogram ladder_r2, width(1) color(gs9)) ///
			(histogram ladder_r3, width(1) ///
			fcolor(none) lcolor(black)), legend(order(1 "12 años" 2 "15 años")) title("Bienestar Subjetivo") saving(r2r3, replace)

twoway 		(histogram ladder_r3, width(1) color(gs9)) ///
			(histogram ladder_r4, width(1) ///
			fcolor(none) lcolor(black)), legend(order(1 "15 años" 2 "18 años")) title("Bienestar Subjetivo")  saving(r3r4, replace)
	   
graph 		combine r2r3.gph r3r4.gph, iscale(.8)	   
graph 		export "BienestarSubj_OC.png", as(png) replace 	   
	   
	   
*******************************************
***		COMPETENCIAS PSICOSOCIALES	 	***
*******************************************

*

**********************
*** YOUNGER COHORT ***
**********************

*** R3
clear all
cd 			"`r3yc'"
use 		PE_YC_ChildLevel


* Positive statements
foreach 	x in cashshr3 cashclr3 cembbkr3 cwrunir3 cashwkr3 cftrwrr3 cbrjobr3 ctryhdr3 ccltrgr3 {
gen 		`x'_r3=1 if `x'==1
replace 	`x'_r3=2 if `x'==2
replace 	`x'_r3=3 if `x'==3
replace 	`x'_r3=4 if `x'==4
replace 	`x'_r3=5 if `x'==5
_crcslbl 	`x'_r3 `x' 
drop 		`x'
rename 		`x'_r3 `x'
}

* Negative statements
foreach 	x in  cpldecr3 cnochcr3  {
gen 		`x'_r3=1 if `x'==5
replace 	`x'_r3=2 if `x'==4
replace 	`x'_r3=3 if `x'==3
replace 	`x'_r3=4 if `x'==2
replace 	`x'_r3=5 if `x'==1
_crcslbl 	`x'_r3 `x' 
drop 		`x'
rename 		`x'_r3 `x'
}


keep 		childid cashshr3 cashclr3 cembbkr3 cwrunir3 cashwkr ctryhdr3 cpldecr3 cftrwrr3 cbrjobr3 cnochcr3 ccltrgr3
cd 			"`results'"
save 		socio_r3yc, replace

*

*** R4

clear all
cd 			"`r4yc'"
use 		PE_R4_YCCH_YoungerChild

/* 
PRIDE: CASHCLR4 CASHWKR4 CASHSHR4 CCLTRGR4 CEMBBKR4 CWRUNIR4
AGENCY: CPLDECR4 CNOCHCR4 CTRYHDR5 CFTRWRR4 CBRJOBR4           
*/

* Positive statements
foreach 	x in CTRYHDR4 CFTRWRR4 CBRJOBR4 CASHCLR4 CASHWKR4 CASHSHR4 CCLTRGR4 CEMBBKR4 CWRUNIR4  {
gen 		`x'_r3=1 if `x'==1
replace 	`x'_r3=2 if `x'==2
replace 	`x'_r3=3 if `x'==3
replace 	`x'_r3=4 if `x'==4
replace 	`x'_r3=5 if `x'==5
_crcslbl 	`x'_r3 `x' 
drop 		`x'
rename 		`x'_r3 `x'
}

* Negative statements
foreach 	x in  CPLDECR4 CNOCHCR4  {
gen 		`x'_r3=1 if `x'==5
replace 	`x'_r3=2 if `x'==4
replace 	`x'_r3=3 if `x'==3
replace 	`x'_r3=4 if `x'==2
replace 	`x'_r3=5 if `x'==1
_crcslbl 	`x'_r3 `x' 
drop 		`x'
rename 		`x'_r3 `x'
}


tostring 	CHILDCODE, gen(childid)
replace 	childid="PE0"+childid if CHILDCODE<100000
replace 	childid="PE"+childid if CHILDCODE>=100000

keep 		childid CTRYHDR4 CFTRWRR4 CBRJOBR4 CASHCLR4 CASHWKR4 CASHSHR4 CCLTRGR4 CEMBBKR4 CWRUNIR4 CPLDECR4 CNOCHCR4 FEA*

cd 			"`results'"
save 		socio_r4yc, replace

merge 		1:1 childid using socio_r3yc, gen(_m3)
drop 		_m*

rename 		_all, lower

	mvdecode ctryhdr* cpldecr*  cftrwrr* cbrjobr* cnochcr* ///
					 cashclr* cashshr* cashwkr* ccltrgr* ///
					 feay15r* feay01r* feay18r*  feay11r* feay28r*  feay32r*  feay22r* feay05r* feay08r* feay26r* ///
					 feay27r* feay33r* feay06r* feay1*r* feay17r* feay23r* feay0*r*  feay30r* ///
					 feay2*r* feay02r* feay16r* feay20r* feay3*r* feay31r* feay09r* feay12r* ///
					 feay19r* feay03r* feay07r*  feay10r*  feay13r* feay29r* ///
					 ctryhdr* cpldecr* cftrwrr* cbrjobr* cnochcr* ///
					 , mv(77 79 88 99)

	foreach v of varlist ctryhdr* cpldecr*  cftrwrr* cbrjobr* cnochcr* ///
						 cashclr* cashshr* cashwkr* ccltrgr* ///
						 feay15r* feay01r* feay18r*  feay11r* feay28r*  feay32r*  feay22r* feay05r* feay08r* feay26r* ///
						 feay27r* feay33r* feay06r* feay1*r* feay17r* feay23r* feay0*r*  feay30r* ///
						 feay2*r* feay02r* feay16r* feay20r* feay3*r* feay31r* feay09r* feay12r* ///
						 feay19r* feay03r* feay07r*  feay10r*  feay13r* feay29r* feay* ///
						 ctryhdr* cpldecr* cftrwrr* cbrjobr* cnochcr* {
				egen mean_`v' = mean(`v')
				egen sd_`v'=sd(`v')
				gen z_`v'= (`v' - mean_`v')/sd_`v'
				drop mean_`v' sd_`v' `v'
				rename z_`v' `v'
}					  


foreach 	r in 3 4 {
egen 		total_R`r'_ps=rowtotal(cashshr`r' cashclr`r' cembbkr`r' cwrunir`r' cashwkr`r' ccltrgr`r')
egen 		nonmiss_R`r'_ps=rownonmiss(cashshr`r' cashclr`r' cembbkr`r' cwrunir`r' cashwkr`r' ccltrgr`r')
gen 		pride_index_R`r'=total_R`r'_ps/nonmiss_R`r'_ps

egen 		total_R`r'_agency=rowtotal(ctryhdr`r' cpldecr`r' cftrwrr`r' cbrjobr`r' cnochcr`r')
egen 		nonmiss_R`r'_agency=rownonmiss(ctryhdr`r' cpldecr`r' cftrwrr`r' cbrjobr`r' cnochcr`r')
gen 		agency_index_R`r'=total_R`r'_agency/nonmiss_R`r'_agency

}

foreach 	var in feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4 feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4 {
replace 	`var'=. if `var'==79 | `var'==77
}

egen 		total_R4_sefficacy=rowtotal(feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4)
egen 		nonmiss_R4_sefficacy=rownonmiss(feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4)
gen 		sefficacy_index_R4=total_R4_sefficacy/nonmiss_R4_sefficacy

egen 		total_R4_sesteem=rowtotal(feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4)
egen 		nonmiss_R4_sesteem=rownonmiss(feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4)
gen 		sesteem_index_R4=total_R4_sesteem/nonmiss_R4_sesteem

					
keep 		childid agency_index_* pride_index_* sefficacy_* sesteem_*


************* GRAPHS

cd 			"`results'"

** AGENCY

twoway 		(histogram agency_index_R4, width(.2) color(gs9)) ///
			(histogram agency_index_R3, width(.2) ///
			fcolor(none) lcolor(black)), legend(order(1 "12 años" 2 "8 años")) title("Agencia (Distribución por edad)")
graph 		export "Agency_dist3_YC.png", as(png) replace


** PRIDE

twoway 		(histogram pride_index_R4, width(.2) color(gs9)) ///
			(histogram pride_index_R3, width(.2) ///
			fcolor(none) lcolor(black)), legend(order(1 "12 años" 2 "8 años")) title("Orgullo (Distribución por edad)")
graph 		export "Pride_dist3_YC.png", as(png) replace

gen 		cohort=0
cd 			"`results'"
save 		soc_yc, replace

*

********************
*** OLDER COHORT ***
********************

** R4

clear all
cd 			"`r4oc'"
use 		PE_R4_OCCH_OlderChild

tostring 	CHILDCODE, gen(childid)
replace 	childid="PE0"+childid if CHILDCODE<100000
replace 	childid="PE"+childid if CHILDCODE>=100000

keep 		childid FEA*

rename 		_all, lower

	mvdecode 		 feay15r* feay01r* feay18r*  feay11r* feay28r*  feay32r*  feay22r* feay05r* feay08r* feay26r* ///
					 feay27r* feay33r* feay06r* feay1*r* feay17r* feay23r* feay0*r*  feay30r* ///
					 feay2*r* feay02r* feay16r* feay20r* feay3*r* feay31r* feay09r* feay12r* ///
					 feay19r* feay03r* feay07r*  feay10r*  feay13r* feay29r* ///
					 , mv(77 79 88 99)

	foreach v of varlist feay15r* feay01r* feay18r*  feay11r* feay28r*  feay32r*  feay22r* feay05r* feay08r* feay26r* ///
						 feay27r* feay33r* feay06r* feay1*r* feay17r* feay23r* feay0*r*  feay30r* ///
						 feay2*r* feay02r* feay16r* feay20r* feay3*r* feay31r* feay09r* feay12r* ///
						 feay19r* feay03r* feay07r*  feay10r*  feay13r* feay29r* feay* {
				egen mean_`v' = mean(`v')
				egen sd_`v'=sd(`v')
				gen z_`v'= (`v' - mean_`v')/sd_`v'
				drop mean_`v' sd_`v' `v'
				rename z_`v' `v'
}					  

foreach 	var in feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4 feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4 {
replace 	`var'=. if `var'==79 | `var'==77
}

egen 		total_R4_sefficacy=rowtotal(feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4)
egen 		nonmiss_R4_sefficacy=rownonmiss(feay15r4 feay01r4 feay18r4 feay11r4 feay28r4 feay32r4 feay22r4 feay05r4 feay08r4 feay26r4)
gen 		sefficacy_index_R4=total_R4_sefficacy/nonmiss_R4_sefficacy

egen 		total_R4_sesteem=rowtotal(feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4)
egen 		nonmiss_R4_sesteem=rownonmiss(feay27r4 feay33r4 feay06r4 feay14r4 feay17r4 feay23r4 feay04r4 feay30r4)
gen 		sesteem_index_R4=total_R4_sesteem/nonmiss_R4_sesteem

keep 		childid sesteem_* sefficacy*
gen 		cohort=1

cd 			"`results'"
append 		using soc_yc
 

************* GRAPHS

cd 			"`results'"

** SELF-ESTEEM

twoway 		(histogram sesteem_index_R4 if cohort==0, width(.2) color(gs9)) ///
			(histogram sesteem_index_R4 if cohort==1, width(.2) ///
			fcolor(none) lcolor(black)), legend(order(1 "12 años" 2 "18 años")) title("Autoestima (Distribución por edad)")
graph 		export "SEsteem_dist_YC.png", as(png) replace


** SELF-EFFICACY

twoway 		(histogram sefficacy_index_R4 if cohort==0, width(.2) color(gs9)) ///
			(histogram sefficacy_index_R4 if cohort==1, width(.2) ///
			fcolor(none) lcolor(black)), legend(order(1 "12 años" 2 "18 años")) title("Autoeficacia (Distribución por edad)")
graph 		export "SEfficacy_dist_YC.png", as(png) replace



	   
	   
