global			whodata		/*write adofile directory*/

global			data		/*write data directory*/

* generating z-scores for Height-for-age
***********************************************************
*                                                         *
*          	Anthropometry for round 5, YC CHILD           *
*                                                         *
***********************************************************
***********************************************************
/* Indicate to the Stata compiler where the who2007.ado file is stored*/
adopath + "$whodata"

/* Load the data file */
use "", clear

/* generate the first three parameters reflib, datalib & datalab	*/
gen str60 	reflib	=	"$whodata"
lab var 	reflib 		"Directory of reference tables"

gen str60 	datalib	=	"$whodata\wo"
lab var 	datalib 	"Directory for datafiles"

gen str30 	datalab	=	"health_sample" 
lab var 	datalab 	"Working file"

/*	check the variable for "sex"	1 = male, 2=female */
/*	check the variable for "age"	*/
/*	define your ageunit	*/
gen 		ageunit	=	"months"
lab var 	ageunit 	"=months"

/*	check the variable for body "weight" which must be in kilograms*/
/* 	check the variable for "height" which must be in centimeters*/ 

/* 	check the variable for "oedema"*/
/* 	NOTE: if not available, please create as [gen str1 oedema="n"]*/
gen str1 	oedema	=	"n"

/*	check the variable for "sw" for the sampling weight*/
/* 	NOTE: if not available, please create as [gen sw=1]*/
gen sw=1

/* 	Fill in the macro parameters to run the command */
who2007 reflib datalib datalab /*write sex variable*/ /*write age variable*/ ageunit /*write weight variable*/ /*write height variable*/ oedema sw 

clear all
cd "$whodata\wo"
use health_sample_z, clear

gen height	=	/*write height variable*//100
gen bmi		=	/*write weight variable*//(height*height)

keep CHILDCODE CHILDID _cbmi _zwfa _zhfa _zbfa _fbfa _fhfa _fwfa bmi agemon_r5 /*write weight variable*/ /*write height variable*/
rename CHILDID childid

cd ""
saveold "", replace

cd ""
saveold "", replace
