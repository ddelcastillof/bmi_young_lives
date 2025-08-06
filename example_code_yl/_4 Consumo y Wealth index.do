clear all
set mem 2000m
set more off 
set maxvar 5000

global		dir		"C:\Users\jferrer\OneDrive - Grupo de Análisis para el Desarrollo"

local 		ycr4 	"$dir\Taller NdM 2018_II\Bases\Peru\R4_YC\HH_YC"
local 		ycr3 	"$dir\Taller NdM 2018_II\Bases\Peru\R3_YC\Stata Data files"
local 		ycr2 	"$dir\Taller NdM 2018_II\Bases\Peru\R2_YC\Stata files"
local 		ycr1 	"$dir\Taller NdM 2018_II\Bases\Peru\R1_YC\Stata files"
local 		ycr3_def "$dir\Taller NdM 2018_II\Bases\Peru\Constructed Files\Supporting Data Files"

local 		results "$dir\Taller NdM 2018_II\Bases\Results"


/*

-------------------------------------------------------------------------------------------------------------------------------
                                                TALLER DE NIÑOS DEL MILENIO 
-------------------------------------------------------------------------------------------------------------------------------


Aunque ya están construidas en la base, podemos construir el consumo 
de los hogares, así como los índices de bienestar (housing
quality, access to services, consumer durables and wealth index).

  
-------------------------------------------------------------------------------------------------------------------------------
                                                BASE RONDA 3 YOUNG LIVES 
-------------------------------------------------------------------------------------------------------------------------------
*/
cd 		"`ycr3'"
use 	PE_YC_HouseholdLevel, clear

**************************************************
********* CONSTRUCCIÓN DE CONSUMO **************** 
**************************************************

*************************************************.
*I. CONSUMO DE ALIMENTOS
*************************************************.

/* En el caso de variables continuas, vamos a recodificar los valores 
-77 (No sabe), -88 (No aplica) y -99 (missing data) en valores "missings",
dado que no nos sirven al momento de calcular consumo */
desc 	fdspr301 
desc 	vlfrr301 
desc 	vlprr301 
desc 	vlowr301 
desc 	vlpyr301 
desc 	vlovr301 

foreach var in fdspr3* vlfrr3* vlprr3* vlowr3* vlpyr3* vlovr3* {
mvdecode `var', mv(-77 -88 -99)
}

/* Para verificar que no se haya escapado un valor negativo, vamos a 
describir las variables que voy a utilizar */

sum 	fdspr3* /*ok*/
sum 	vlfrr3* /*ok*/
sum 	vlprr3* /*ok*/
sum 	vlowr3* /*ok*/
sum 	vlpyr3* /*ok*/
sum 	vlovr3* /*ok*/

*Gasto monetario en alimentos.
egen 	gastom_food_r3=rowtotal(fdspr3*), mis 

*Alimentos provenientes de fuentes propias (chacra, negocio propio, parte de pago, regalos)
egen 	autoconsm_food_r3=rowtotal(vlfrr3* vlprr3* vlowr3* vlpyr3*), mis 
replace autoconsm_food_r3=0 if autoconsm_food_r3==. & gastom_food_r3!=.

* Alimentos dejados de consumir
egen 	nocons_food_r3=rowtotal(vlovr3*), mis 
replace nocons_food_r3=0 if nocons_food_r3==. & gastom_food_r3!=.

* Consumo de alimentos por mes
gen 	totg_food_r3=(gastom_food_r3+autoconsm_food_r3-nocons_food_r3)*2

* Caracterizamos las variables
sum 	gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3

/* Hacemos algunos reemplazos por valores negativos en el consumo total de alimentos (un valor negativo) */
replace totg_food_r3=175.5 if totg_food_r3==-15

sort	childid
keep	childid gastom_food_r3 autoconsm_food_r3 nocons_food_r3 totg_food_r3 

label 	var gastom_food_r3 "Food bought by household in the last 15 days, round 3"
label 	var autoconsm_food_r3 "Foods supplied from own sources and own supplies by household in the last 15 days, round 3"
label 	var nocons_food_r3 "Food left over by household in the last 15 days, round 3"
label 	var totg_food_r3 "Food consumption per month, round 3"

cd 		"`results'"
save 	pe_consumption_food_r3, replace 

*************************************************.
*II. CONSUMO EN NO-ALIMENTOS
*************************************************.

cd 		"`ycr3'"
use 	PE_YC_householdlevel, clear 

/* En el caso de variables continuas, vamos a recodificar los valores 
-77 (No sabe), -88 (No aplica) y -99 (missing data) en valores "missings",
dado que no nos sirven al momento de calcular consumo */

desc 	spndr301

recode 	spndr3* spyrr3* spyr3* (-77=.) (-88=.) (-99=.) /* Otra forma de recodificar */ 


egen 	gcloth_r3=rowtotal(spyrr301 spyrr302 spyrr32a spyrr303 spyrr304 spyrr3tl spyrr305 spyrr306 spyrr307 spyrr308), mis
replace gcloth_r3=gcloth_r3/12
sum 	gcloth_r3

egen 	geduc_r3=rowtotal(spyrr309 spyrr310 spyrr311 spyrr312 spyrr313 spyrr315 spyrr316 spyr316b), mis
replace geduc_r3=geduc_r3/12
sum 	geduc_r3

egen 	gmed_r3=rowtotal(spyrr317 spyrr318), mis
replace gmed_r3=gmed_r3/12
sum 	gmed_r3

egen 	gocio_r3=rowtotal(spyrr319), mis
replace gocio_r3=gocio_r3/12
sum 	gocio_r3

* No incluimos gasto en joyas en la categoría otros gastos
* Asimismo, no incluimos nuevas opciones, para matener comparabilidad entre rondas: SPYRR325, SPYRR326, SPYRR327, SPYRR328

egen 	gother_r3=rowtotal(spyrr320 spyrr322 spyrr323 spyrr324), mis
replace gother_r3=gother_r3/12
sum 	gother_r3

egen 	gu30d_r3=rowtotal(spndr301 spndr302 spndr303 spndr304 spndr305 spndr306 spndr325 spndr326 spndr327 spndr328 spndr329 spndr330 spndr331 spndr332 spndr333  spndr334 spndr335), mis
sum 	gu30d_r3

egen 	gu12m_r3=rowtotal(spndr314 spndr319 spndr342 spndr352 spndr362 spndr311 spndr322), mis
replace gu12m_r3=gu12m_r3/12
sum 	gu12m_r3

egen 	totg_nfood_r3=rowtotal(gcloth_r3 geduc_r3 gmed_r3 gocio_r3 gother_r3 gu30d_r3 gu12m_r3), mis
sum 	totg_nfood_r3

label 	variable gcloth_r3 "Clothes and footwear consumption per month R3"
label 	variable geduc_r3 "Education consumption per month R3"
label 	variable gmed_r3 "Doctors and medicine consumption per month R3"
label 	variable gocio_r3 "Entertainment consumption per month R3"
label 	variable gother_r3 "Other consumption per month R3"
label 	variable gu30d_r3 "Last 30 days consumption per month R3"
label 	variable gu12m_r3 "Last 12 months consumption per month R3"
label 	variable totg_nfood_r3 "Total nonfood consumption per month R3"

keep 	childid gcloth_r3-totg_nfood_r3

sort 	childid

cd 		"`results'"
save 	pe_consumption_nonfood_r3, replace

************************************************
* II. CONSUMO AGREGADO
************************************************

cd 		"`ycr3'"
use 	PE_YC_householdlevel, clear
sort 	childid
cd 		"`results'"
merge 	1:1 childid using pe_consumption_food_r3
drop	_m
merge 	1:1 childid using pe_consumption_nonfood_r3
drop 	_m 
cd 		"`ycr3_def'"
*merge 	1:1 childid using pe_deflactores
merge	1:1 childid using pe_deflator_r3yc
tab 	_m
drop 	_m

* Generamos consumo per capita real mensual, tanto alimentos como no-alimentos:

gen 	spfood_rpc=totg_food_r3/(hhsize*def_full_r3)
br 		spfood_rpc foodexp_rpc
label 	var spfood_rpc "monthly expenditure on food items per capita, in real 2006 soles"

gen 	spnonfood_rpc=totg_nfood_r3/(hhsize*def_full_r3)
br 		spnonfood_rpc nfoodexp_rpc
label 	var spnonfood_rpc "monthly expenditure on non-food items per capita, in real 2006 soles"

* Ahora sí generamos el gasto real per capita mensual

gen 	consumption_rpc=spnonfood_rpc+spfood_rpc
label 	var consumption_rpc "Total monthly expenditure per capita, in real 2006 soles"

* Describiendo la variable consumo real pc
codebook consumption_rpc
sum 	consumption_rpc, detail
local 	p95=r(p95)

/* Diferenciado consumo real pc entre zonas urbanas y rurales */
twoway (kdensity consumption_rpc if typesite=="1" & consumption_rpc<`p95') (kdensity consumption_rpc if typesite=="2" & consumption_rpc<`p95'), legend(label(1 "Urban") label(2 "Rural")) title("Consumo real pc entre zonas urbanas y rurales")

/* Diferenciado consumo real pc por género */
twoway (kdensity consumption_rpc if sex==1 & consumption_rpc<`p95') (kdensity consumption_rpc if sex==2 & consumption_rpc<`p95'), legend(label(1 "Male") label(2 "Female")) title("Consumo real pc por g�nero")



************************************************************
************************************************************
*********    WEALTH INDEX  - TERCERA RONDA    **************
************************************************************
************************************************************

*I. Generando el Housing quality index.
tab 	numrmr3, m
*1 caso de 0 cuartos, se pone missing
recode 	numrmr3 (0=.)
gen 	room_pc=numrmr3/hhsize
codebook room_pc

* Generamos un mínimo y un máximo, para generar un índice de hacinamiento
egen 	min_sca=min(room_pc)
egen 	max_sca=max(room_pc)
gen 	scaled_room=(room_pc-min_sca)/(max_sca-min_sca)
sum 	scaled_room

* 2. Material del piso

tab 	floorr3, m
tab 	floorr3, nol
gen 	floor1=(floorr3==1|floorr3==5|floorr3==6|floorr3==7|floorr3==8|floorr3==22)

*3. Material del techo.

tab		roofr3, m
tab 	roofr3, nol 
gen 	roof1=(roofr3==4|roofr3==6|roofr3==15)

*4. Material de las paredes.

tab 	wallr3, m
gen 	wall1=(wallr3==3|wallr3==25)

****Housing Quality Index.
egen 	ind_hq_r3=rowmean(scaled_room floor1 roof1 wall1)
label 	var ind_hq_r3 "Housing quality index"
br 		ind_hq_r3 hq

*II. Generando el consumer durable index

sum 	sewng7r3-flplr7r3
recode 	sewng7r3-flplr7r3 (99=.) (88=.)

gen 	radio1=radio7r3==1
gen 	tv1=tv7r3==1
gen 	fridge1=fridg7r3==1
gen 	moto1=motor7r3==1
gen 	car1=car7r3==1
gen 	plancha1=iron7r3==1
gen 	phone1=phone7r3==1
gen 	mobphone1=mbphn7r3==1
gen 	bike1=bike7r3==1
gen 	cocgas1=mitad7r3==1
gen 	licua1=blnd7r3==1
gen 	toca1=rcdp7r3==1

****Consumer durable Index.
egen 	ind_consvar_r3=rowmean(radio1 tv1 fridge1 bike1 moto1 car1 mobphone1 phone1 toca1 ///
plancha cocgas1 licua1)
label 	var ind_consvar_r3 "Consumer durable Index"

* III. Housing Services Index

* 1. Fuente de agua potable

tab 	drwtrr3, m
tab 	drwtrr3, nol
gen 	drwater1=drwtrr3==1|drwtrr3==2

*2. Acceso a electricidad

tab		elecr3, m
gen 	elec1=elecr3==1

*3. Tipo de inodoro

tab 	toiletr3, m
tab 	toiletr3, nol
gen 	toilet1=toiletr3==1| toiletr3==6
* Se incluye "pozo ciego/letrina del hogar"

*4. Tipo de combustible para cocinar

tab 	cookr3, m
tab 	cookr3, nol
gen 	cooking1=(cookr3==8|cookr3==9)

****Housing Services Index.
egen 	ind_sshouse_r3=rowmean(drwater1 elec1 toilet1 cooking1)
label 	var ind_sshouse_r3 "Access to services index"

/* Finalmente, creamos el índice de riqueza del hogar */

egen 	wealth_index_r3=rowmean(ind_hq ind_consvar ind_sshouse_r3)
label 	var wealth_index_r3 "Wealth index"
br 		wealth_index_r3 wi

/* Diferenciado consumo real pc entre zonas urbanas y rurales */
twoway (kdensity wealth_index_r3 if typesite=="1") (kdensity wealth_index_r3 if typesite=="2"), legend(label(1 "Urban") label(2 "Rural")) title("Wealth index entre zonas urbanas y rurales")

/* Diferenciado consumo real pc por género */
twoway (kdensity wealth_index_r3 if sex==1) (kdensity wealth_index_r3 if sex==2), legend(label(1 "Male") label(2 "Female")) title("Wealth index por g�nero")

/* Manteniendo variables principales */

keep 	childid hq cd sv wi totalexp_rpc
sort 	childid 

cd 		"`results'"
save 	housebase, replace

/* Borramos bases intermedias */

erase 	pe_consumption_food_r3.dta
erase 	pe_consumption_nonfood_r3.dta

