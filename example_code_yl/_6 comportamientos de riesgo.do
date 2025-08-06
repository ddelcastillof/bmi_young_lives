clear all
set more off

global		dir		"C:\Users\Darwin\Documents\Research"

local		saqocr4	"$dir\Taller NdM 2018_II\Bases\Peru\R4_OC\SAQ"
local		r4oc	"$dir\Taller NdM 2018_II\Bases\Peru\R4_OC\HH_OC"
local		results	"$dir\Taller NdM 2018_II\Bases\Results"

***************************************
***		COMPORTAMIENTOS DE RIESGO 	***
***************************************

* BASADO EN:
* Fávara M. & A. Sánchez (2017), "Psychosocial competencies and risky behaviours in Peru", IZA Journal of Labor & Development (2017) 6:3 DOI 10.1186/s40175-016-0069-3


*** SAQ R4
cd			"`saqocr4'"
use			PE_OC_SAQ_OlderChild

rename		*, lower
gen 		childid="PE"+string(childcode, "%06.0f")

tab			wntansr4, m
tab			wntansr4, m nolabel

/*0 = No --> El resto de preguntas tiene asignado el c󤩧o 79. (23 obs.)
  79= NqC --> Τem (1 obs.)
  88= NA  --> El resto de preguntas tiene asignado el c󤩧o 88 (9 obs.)*/

*Selección muestra relevante:
drop		if wntansr4==0 | wntansr4==79 | wntansr4==88 // 602 obs.


	
*-----------------------
* FUMAR
*-----------------------
	

foreach 	var of varlist smkprnr4 smksibr4 smkboyr4 smkfrnr4 oftsmkr4 numcigr4 frnsmkr4 agecigr4{
tab 		`var'
recode 		`var' (77 99=.) 
}
	
*Fumar (creando dummy)	
gen			smoke_now=1 if oftsmkr4!=5 &  oftsmkr4!=4 
replace		smoke_now=0 if smoke_now==. & (oftsmkr4==5 |  oftsmkr4==4)
replace		smoke_now=. if oftsmkr4==.
	
label var	smoke_now "Fuma al menos una vez al mes"

*-----------------------
* BEBER 
*-----------------------	
foreach		var of varlist youalcr4 mchalcr4 drkalcr4 drksexr4 {
tab			`var'
recode		`var' (77=.) (99=.)
}
	
* Bebe (dummy)
gen			drinking=1 if youalcr4>=1 &youalcr4<=4
replace		drinking=0 if youalcr4==5|youalcr4==6
	
gen			everdrunk=1 if drkalcr4==1
replace		everdrunk=0 if drkalcr4==0 | drkalcr4==2 // si nunca se embriaga
	
replace		everdrunk=. if youalcr4==.
replace		everdrunk=0 if youalcr4==6 //

* Comportamientos riesgosos habiendo bebido
gen 		rbdrinking=1 if drksexr4==1 | drksexr4==2 	/* Alguna vez haber tenido sexo estando ebrio*/
replace 	rbdrinking=1 if alcfghr4==1 				/* Haber entrado en una pelea estando ebrio*/
replace 	rbdrinking=1 if alcsckr4==1 				/* Se sintió enfermo o se cayó */
replace 	rbdrinking=1 if drkalcr4==1 				/*: estado ebrio (everdrunk)*/
replace 	rbdrinking=0 if rbdrinking!=1	/* Incluyendo a aquellos que beben pero nunca han incurrido en comportamientos de riesgo y quienes nunca beben.*/

* Resolviendo inconsistencia
*Re codificamos drinking si reporta haber incurrido en conductas de riesgo. 
recode		drinking (0=1) if rbdrinking==1
	
*Definicion 1: drink alcohol + been drunk
gen			drinking1=1 if (drinking==1 & everdrunk==1) 
replace		drinking1=0 if drinking==0 | (drinking==1 & everdrunk==0)
label var	drinking1 "Ha estado ebrio(a) al menos una vez en su vida"
tab			drinking1, m

*Definicion 2: drink alcohol + risky behavior
gen			drinking2=1 if (drinking==1 & rbdrinking==1) 
replace		drinking2=0 if drinking==0 | (drinking==1 & rbdrinking==0)
label var	drinking2 "Se comportó de forma arriesgada mientras estaba ebrio"
tab			drinking2, m

*-----------------------
* USO DE DROGAS
*-----------------------
/*YL child: try drugs
  trdmarr4        byte    %17.0g     L_TriedDrugs Have you ever tried any of the following drugs? Marijuana
  trdinhr4        byte    %17.0g     L_TriedDrugs  Inhalantes (terokal, etc)
  trdpbcr4        byte    %17.0g     L_TriedDrugs  Coca paste -PBC
  trdcocr4        byte    %17.0g     L_TriedDrugs  Coca
  trdextr4        byte    %17.0g     L_TriedDrugs  Extasis
  trdmthr4        byte    %17.0g     L_TriedDrugs  Methamphetamines   
  trdhalr4        byte    %17.0g     L_TriedDrugs  Hallucinogens (san pedro, ayahua
  trdothr4        byte    %17.0g     L_TriedDrugs  Other drugs (crack, heroin, opiu
*/                                         
	
foreach 	var of varlist trdmarr4 trdinhr4 trdpbcr4 trdcocr4 trdextr4 trdmthr4 trdhalr4 trdothr4 {
tab			`var'
recode		`var' (77 99=.)
gen			c`var' =1 if `var'>=1 &`var'<=3
replace		c`var'=0 if `var'==4
}
		
egen		drugs_numb=rowtotal(ctrdmarr4 ctrdinhr4 ctrdpbcr4 ctrdcocr4 ctrdextr4 ctrdmthr4 ctrdhalr4 ctrdothr4), missing
	
rename		ctrdmarr4 marijuana
	
*Definicion 1: any drugs.
gen			drugs_any=1 if drugs_numb!=0 &drugs_numb!=.
replace		drugs_any=0 if drugs_numb==0
label var	drinking2 "Alguna vez consumió drogas ilegales."
tab			drugs_any, m 


*-----------------------
*SEXO SIN PROTECCIÓN
*-----------------------
	
foreach		var of varlist agesexr4 nownsxr4 drksexr4 notuser4 {
tab			`var'
recode		`var' (77 99=.)
}
	
*Tuvo sexo

gen			eversex=1 if agesexr4>=1 & agesexr4<=7
replace		eversex=0 if  agesexr4==8 & nvrsexr4==1
replace		eversex=1 if condomr4==1| drkinfr4==1| mrnaftr4==1| useinjr4==1| othmtdr4==1  /* Consideramos a los que reportan nunca haber tenido sexo como si lo hubiesen tenido si dicen haber usado preservativos alguna vez*/

*Sexo sin protección
foreach		var of varlist condomr4 drkinfr4 mrnaftr4 useinjr4 othmtdr4{
tab			`var'
recode		`var' (79 99=.)
}
	
egen		methods=rowtotal (condomr4 mrnaftr4 useinjr4 othmtdr4), missing
recode		methods (2=1) /*15 observation used 2 methods (after morning pill and other methods)*/
replace		methods=. if eversex==0| eversex==.
replace		methods=0 if notuser4==1 & eversex==1
	
*Definicion 1: Tuvo sexo sin condón
*gen			risky_sex=1 if nownsxr4==1 /*no methods used*/
gen			risky_sex=. 
replace		risky_sex=1 if (mrnaftr4==1 | useinjr4==1| drkinfr4==1) /*morning pill, injection, drink mate*/
replace		risky_sex=0 if condomr4==1 /*|othmtdr4==1*/
replace		risky_sex=0 if eversex==0

label var	risky_sex "No utilizó condón en su última relación sexual."
	
tab			risky_sex eversex, miss	

*-----------------------------
* COMPORTAMIENTOS DELICTIVOS
*-----------------------------

/*YL child: delinquent behaviors
crywpnr4        byte    %14.0g     During the last 30 days, on how many days did you carry a weapon such as a knife
memgngr4        byte    %14.0g     Have you ever been member of a gang? (Choose only one option)
arrstdr4        byte    %14.0g     L_YesNo    Have you been arrested by the police or taken into custody for an illegal or del
crcinsr4        byte    %14.0g     L_YesNo    Have you ever been sentenced to spend time in a corrections institution, like a*/

/*Friends:delinquent behaviors
frngngr4        byte    %27.0g     How many of your best friends have been / are members of a gang?*/
	
	
foreach 	var of varlist crywpnr4 memgngr4 frngngr4 crcinsr4 arrstdr4{
tab			`var'
recode		`var' (77 99=.)
}
** Portar un arma
gen			weapon=1 if crywpnr4==1|crywpnr4==2|crywpnr4==3
replace		weapon=0 if crywpnr4==4
label var	weapon "Llevó un arma en los últimos 30 días."
	
**Ser parte de una pandilla
rename		memgngr4 gang 
	
** Amigos son parte de una pandilla
gen			gang_friend=1 if frngngr4==1|frngngr4==2|frngngr4==3
replace		gang_friend=0 if frngngr4==4
	
** Arrestado o preso
gen			arrested=1 if arrstdr4==1|crcinsr4==1
replace		arrested=0 if arrstdr4==0&crcinsr4==0

*Definicion 1:  arma o arrestado o encarcelado o pandillaje
gen			criminal1=(arrested==1|weapon==1|gang==1)
replace		criminal1=. if (arrested==.|weapon==.|gang==.)
		
*Definicion 2: arma + arrestado + encarcelado + pandillaje
egen		criminal2= rowtotal(weapon arrstdr4 crcinsr4 gang)
replace		criminal2=. if (arrested==.|weapon==.|gang==.)
label var	criminal2 "Criminal behavior - intensity"
	
*** NOS QUEDAMOS CON LAS VARIABLES QUE NOS INTERESAN
rename		childcode CHILDCODE	
keep		CHILDCODE smoke_now drinking1 drinking2 drugs_any risky_sex weapon criminal1 criminal2
		
sort		CHILDCODE
cd			"`results'"
save		risky_r4, replace
	
	
***********************************************
**** Correlaciones con Índice de Bienestar ****
***********************************************

cd			"`r4oc'"
merge		1:1 CHILDCODE using PE_R4_OCHH_OlderHousehold

rename		_all, lower

foreach		var in smoke_now drinking1 drinking2 drugs_any risky_sex weapon criminal1 criminal2 {
corr		`var' wi
}

xtile		wi_terc=wi, n(3)
tab			wi_terc, gen(wi_)

foreach		var in smoke_now drinking1 drinking2 drugs_any risky_sex weapon criminal1 criminal2 {
reg			`var' wi_2 wi_3
}
**Corresgir por clusterificación en los análisis realizados en NdM. Los cluster son identificados por clustid variable***
