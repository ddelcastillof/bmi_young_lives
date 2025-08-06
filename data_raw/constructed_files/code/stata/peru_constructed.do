********************************************************************************
*					PERU CONSTRUCTED PANEL DATA								   *
*					Rounds 1 to 5, OC AND YC								   *
********************************************************************************

	* Author: 		Kristine Briones
	* Date: 		15 March 2017
	* Last Update: 	19 Jan 2018
	* Last run: 	22 May 2018
	
	/* number of observations (as of 22 May 2018)

				|                    Round of survey
	Younger cohort |         1          2          3          4          5 
	---------------+-------------------------------------------------------
	  Older cohort |       714        685        678        635        608 
	Younger cohort |     2,052      1,963      1,943      1,902      1,860 
	---------------+-------------------------------------------------------
			 Total |     2,766      2,648      2,621      2,537      2,468 */	
	
/*-----------------------------------------------------------------------------*
								DATA SETS
------------------------------------------------------------------------------*/
clear
set mem 600m
set more off

global r1yc			N:\SurveyData\Peru\R1_YC\Stata files\
global r1oc			N:\SurveyData\Peru\R1_OC\Stata files\
global r2yc			N:\SurveyData\Peru\R2_YC\Stata files\
global r2oc			N:\SurveyData\Peru\R2_OC\Stata files\
global r3yc			N:\SurveyData\Peru\R3_YC\Stata data files\
global r3oc			N:\SurveyData\Peru\R3_OC\Stata files\

global r4yc1		N:\SurveyData\Peru\R4_YC\CH_YC
global r4yc2		N:\SurveyData\Peru\R4_YC\COG_YC
global r4yc3		N:\SurveyData\Peru\R4_YC\HH_YC
global r4oc1		N:\SurveyData\Peru\R4_OC\CH_OC
global r4oc2		N:\SurveyData\Peru\R4_OC\COG_OC
global r4oc3		N:\SurveyData\Peru\R4_OC\HH_OC
global r4ocsaq		N:\SurveyData\Peru\R4_OC\SAQ

global r5ochh		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_OC_HH
global r5occh		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_OC_CH
global r5occog		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_OC_COG
global r5ocsaq		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_OC_SAQ
global r5ychh		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_YC_HH
global r5ycch		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_YC_CH
global r5yccog		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_YC_COG
global r5ycsaq		R:\z_R5\Exported Data\Peru\22May2018\PeruDataset\PE_YC_SAQ

global quant		Y:\CONSTRUCTED FILES & VARIABLES
global r5calc		$quant\Calculated variables
global r5anthro		$r5calc\Anthropometrics\Peru
global r5wealth		$r5calc\CPI & Wealth\Peru
global educhist		$quant\Useful variables\Education\Education history
global r5location	$r5calc\LocationVars\Peru
global support		$quant\Panel R1 to R5\Peru\Supporting Data Files
global irt			$quant\Useful variables\Cognitive test scores\IRT
global dead			$quant\Panel R1 to R5 (in progress)\documents
global marriage		$quant\Useful variables\Marital status& Fertility\marriage cohabitation childbirth\older cohort\Data				
					
global output		$quant\Panel R1 to R5 (in progress)\Peru

/*-----------------------------------------------------------------------------*
								IDENTIFICATION
------------------------------------------------------------------------------*/

***** PANEL INFORMATION *****

	* ROUND 1
			use childid using "$r1yc/pechildlevel1yrold.dta", clear
			gen yc=1
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid)
			replace yc=0 if yc==.
			gen inr1=1
			tempfile r1
			save `r1'

	* ROUND 2
			use childid situac_r2 using "$r2yc/pechildlevel5yrold.dta", clear
			gen yc=1
			qui append using "$r2oc/pechildlevel12yrold.dta", keep(childid situac_r2)
			keep if situac_r2==1
			merge 1:1 childid using "$r2oc\PEChildQuest12YrOld.dta", keepusing(childid)
			replace yc=0 if yc==.
			gen inr2=1 if yc==1 | (yc==0 & (_merge==3 | _merge==2))
			drop _m situac_r2
			tempfile r2
			save `r2'

	* ROUND 3
			use childid using "$r3yc/PE_YC_HouseholdLevel.dta"
			merge 1:1 childid using "$r3yc\PE_YC_ChildLevel.dta", keepusing(childid)
			gen yc=1
			gen inr3=1 if (_merge==3 | _merge==2)
			drop _m
			qui append using "$r3oc/PE_OC_HouseholdLevel.dta", keep(childid)
			merge 1:1 childid using "$r3oc\PE_OC_ChildLevel.dta", keepusing(childid)
			replace yc=0 if yc==.
			replace inr3=1 if yc==0 & (_merge==3 | _merge==2)
			drop _m
			tempfile r3
			save `r3'
 
	* ROUND 4
			use CHILDCODE using "$r4yc1/PE_R4_YCCH_YoungerChild", clear
			merge 1:1 CHILDCODE using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", keepusing(CHILDCODE)
			gen yc=1
			gen inr4=1 if (_merge==3 | _merge==1)
			drop _m
			qui append using "$r4oc1/PE_R4_OCCH_OlderChild", keep(CHILDCODE)
			merge 1:1 CHILDCODE using "$r4oc3\PE_R4_OCHH_OlderHousehold.dta", keepusing(CHILDCODE)
			replace yc=0 if yc==.
			replace inr4=1 if yc==0 & (_merge==3 | _merge==1)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE _m
			tempfile r4
			save `r4'

	* ROUND 5
			use CHILDCODE using "$r5ycch/YoungerChild.dta", clear
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", keepusing(CHILDCODE)
			gen yc=1
			gen inr5=1 if (_merge==3 | _merge==1)
			drop _m
			qui append using "$r5occh/OlderChild.dta", keep(CHILDCODE)
			merge 1:1 CHILDCODE using "$r5ochh\OlderHousehold.dta", keepusing(CHILDCODE)
			replace yc=0 if yc==.
			replace inr5=1 if yc==0 & (_merge==3 | _merge==1)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE _m
			tempfile r5
			save `r5'			
	
	* MERGE
			use `r1', clear
			
			forvalues i=2/5 {
				merge 1:1 childid using `r`i'', nogen
				replace inr`i'=0 if missing(inr`i')
				}
	
			g panel12345=inr1==1 & inr2==1 & inr3==1 & inr4==1 & inr5==1			
			
	* LABELS
			label var childid		"Child ID"
			label var yc			"Younger cohort"
			label var inr1	 		"Child is present in round 1"
			label var inr2	 		"Child is present in round 2"
			label var inr3	 		"Child is present in round 3"
			label var inr4	 		"Child is present in round 4"
			label var inr5			"Child is present in round 5"
			label var panel12345 	"Child is in all rounds"

			label define yesno 0 "no" 1 "yes"
			label values inr1 inr2 inr3 inr4 inr5 panel12345 yesno
			label define yc 0 "Older cohort" 1 "Younger cohort"
			label values yc yc

			tempfile  panel
			save     `panel'

	 **** all children

			use childid using "$r1yc/pechildlevel1yrold.dta", clear
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid)
			
			forvalues i=1/5 {
				g round`i'=`i'
				}
			
			reshape long round, i(childid) j(r)
			drop r
			sort childid round 
			label var round "Survey round"
			tempfile  allchildren
			save     `allchildren'	 

			
***** HOUSEHOLD ADDRESS *****

	*ROUND 1
			use childid typesite region dint clustid placeid using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid typesite region dint clustid placeid)
			gen round=1
			tempfile   typesiter1
			save      `typesiter1'

	*ROUND 2
			use childid typesite clustid region dint placeid placenr2 peminiid2 using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid typesite clustid region dint placeid placenr2 peminiid2)
			
			destring typesite, replace
			replace placeid = placenr2 if placeid== "PE88C88"  
			replace placeid = peminiid2 if placeid== "PE99C99"  

			gen round=2
			drop placenr2 peminiid2
			tempfile   typesiter2
			save      `typesiter2'

	*ROUND 3
			use childid typesite region dint clustid placeid placenr3 peminiid3 using "$r3yc\pe_yc_householdlevel.dta", clear
			qui append using "$r3oc\pe_oc_householdlevel.dta", keep(childid typesite region dint clustid placeid placenr3 peminiid3)
			
			destring typesite, replace
			replace placeid = placenr3 if placeid== "PE88C88"  
			replace placeid = peminiid3 if placeid== "PE88C88"  

			gen round=3
			drop placenr3 peminiid3 
			tempfile   typesiter3
			save      `typesiter3'

	*ROUND 4		
			use CHILDCODE DINT using "$r4yc3\PE_R4_YCHH_YoungerHousehold", clear
			qui append using "$r4oc3\PE_R4_OCHH_OlderHousehold", keep(CHILDCODE DINT)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			g dint=date(substr(DINT,1,10), "DMY")
			format dint %td 
			tempfile dint
			save `dint'
				
			use "$r4yc3\YC_LocationVars.dta", clear
			qui append using "$r4oc3\OC_LocationVars.dta"
			rename *, lower			
			merge 1:1 childid using `dint'
						
			replace placeid = placenr if placeid== "PE88C88"  					
			replace placeid = peminiid if placeid== "PE88C88"					
			
			g round=4
			keep childid typesite region dint clustid placeid round
			tempfile  typesiter4
			save     `typesiter4'
			
	* ROUND 5																		// <---- still to add: R5 location
			* TYPESITE AND REGION
			use "$r5location\Typesite_HH_OC_21may.dta", clear
			qui append using "$r5location\Typesite_HH_YC_21may.dta", keep(CHILDCODE TYPESITE5 REGION5)
			rename TYPESITE5 typesite
			rename REGION5 region
			tempfile typesite
			save `typesite'
			
			* CLUSTID AND PLACEID
			use CHILDCODE CLUSTID5 PLACEID5 using "$r5location\CommunityID_OC_21may.dta", clear
			qui append using "$r5location\CommunityID_YC_21May.dta", keep(CHILDCODE CLUSTID5 PLACEID5)
			rename CLUSTID5 clustid 
			rename PLACEID5 placeid
			tempfile clustid
			save `clustid'
			
			* DINT
			use CHILDCODE DINT using "$r5ychh/YoungerHousehold.dta", clear
			qui append using "$r5ochh/OlderHousehold.dta", keep(CHILDCODE DINT)			
			g dint=date(substr(DINT,1,10), "DMY")
			format dint %td 
			drop DINT
			tempfile dint
			save `dint'
			
			* MERGE VARIABLES
			use `typesite', clear
			merge 1:1 CHILDCODE using `clustid', nogen
			merge 1:1 CHILDCODE using `dint', nogen
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			
			g round=5
			tempfile typesiter5
			save    `typesiter5'			
	
	* MERGE
			
			use `typesiter1', clear
			forvalues i=2/5 {
				qui append using `typesiter`i''
				}
			tempfile typesite
			save `typesite'
			
			
***** CHILD LOCATION *****

	* ROUND 1 - not asked (assumed that child is living in the household)
			use childid using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid)
			g childloc=1
			g round=1
			tempfile childlocr1
			save `childlocr1'
			
	* ROUND 2 
			use childid id livhse using "$r2yc\PESubHouseholdMember5.dta", clear
			qui append using "$r2oc\PESubHouseholdMember12.dta", keep(childid id livhse)
			keep if id==0
			rename livhse childloc
			g round=2
			keep childid childloc round
			tempfile childlocr2
			save `childlocr2'
			
	* ROUND 3		
			use childid id livhse using "$r3yc\PE_YC_HouseholdMemberLevel.dta", clear
			qui append using "$r3oc\PE_OC_HouseholdMemberLevel.dta", keep(childid id livhse)
			keep if id==0
			g childloc=livhse==1 if livhse!=.
			g round=3
			keep childid childloc round
			tempfile childlocr3
			save `childlocr3'
			
	* ROUND 4
			use CHILDCODE MEMIDR4 LIVHSER4 using "$r4yc3\PE_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 LIVHSER4)
			keep if MEMIDR4==0
			g childloc=LIVHSER4==1 if LIVHSER4!=.
			g childid="PE"+string(CHILDCODE,"%06.0f")	
			g round=4
			keep childid childloc round
			tempfile childlocr4
			save `childlocr4'
	
	* ROUND 5
			use CHILDCODE MEMIDR5 LIVHSER5 using "$r5ychh\HouseholdRosterR5.dta", clear
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 LIVHSER5)
			keep if MEMIDR5==0
			g childloc=LIVHSER5==1 if LIVHSER5!=.
			g childid="PE"+string(CHILDCODE,"%06.0f")
			g round=5
			keep childid childloc round
			tempfile childlocr5
			save `childlocr5'	
	
	* MERGE
			use `childlocr1', clear
			forvalues i=2/5 {
				qui append using `childlocr`i''
				}
			merge 1:1 childid round using `typesite', nogen
			merge m:1 childid using `panel', nogen
			merge 1:1 childid round using `allchildren', nogen
			sort childid round
			foreach v of varlist inr1 inr2 inr3 inr4 inr5 panel {
				replace `v'=1 if childid==childid[_n-1] & `v'[_n-1]==1 
				replace `v'=0 if missing(`v')
				}
			replace yc=yc[_n-1] if missing(yc) & childid==childid[_n-1]
				
	* LABELS
		
			label var childid		"Child ID"
			label var round	 		"Round of survey"
			label var clustid 		"Sentinel site ID"								
			label var placeid 		"Community ID"
			label var typesite 		"Area of residence (urban/rural)"
			label var region 		"Region of residence"
			label var dint 			"Date of interview"
			label var childloc		"Child currently lives in the household"
			
			label def typesite 1 "urban" 2 "rural"
			label val typesite typesite
			label val childloc yesno
			
			recode region (99=.)
			label define region 31 "Costa" 32 "Sierra" 33 "Selva" 88 "N/A"
			label values region region
			
			sort childid round
			order childid yc round inr* panel dint placeid clustid typesite region childloc
			tempfile  identification
			save     `identification'

/*-----------------------------------------------------------------------------*
							CHILD CHARACTERISTICS
------------------------------------------------------------------------------*/			

***** GENERAL *****			

	* SEX, ETHNICITY AND RELIGION - (taken from R1)
			use childid sex chldeth chldrel using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid sex chldeth chldrel)
			rename chldeth chethnic
			rename sex chsex
			tempfile childchar
			save    `childchar'

	* FIRST LANGUAGE (Taken from R2 - NO INFORMATION IN OTHER ROUNDS)
			use childid chlng1st using "$r2yc/pechildlevel5yrold.dta", clear
			qui append using "$r2oc/pechildlevel12yrold.dta", keep(childid chlng1st)
			rename  chlng1st chlang
			tempfile  lang
			save     `lang'
			
	* AGE (IN MONTHS) - For each round
			/*-----------------------------------------------------------------------------
			Age of child in months was estimated in the following way:
			gen agedy=dint-dob
			gen agemon=agedy/(365/12)
			Where: agedy: age in days
				   dint : Date of interview
				   Dob  : Date of birth
				   Agemon: Age in months
			It does not appear here because the date of birth is confidential information
			------------------------------------------------------------------------------*/

			* ROUND 1
			use childid agechild using "$r1yc/pechildlevel1yrold.dta", clear
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid agechild)
			gen round=1
			rename agechild agemon
			tempfile    age1
			save       `age1'	
		
			* ROUND 2
			use childid agechild using "$r2yc/pechildlevel5yrold.dta", clear
			qui append using "$r2oc/pechildlevel12yrold.dta", keep(childid agechild)
			gen round=2
			rename agechild agemon
			tempfile    age2
			save       `age2'

			* ROUND 3
			use childid agechild using "$r3yc/pe_yc_householdlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdlevel.dta", keep(childid agechild)
			gen round=3
			rename agechild agemon
			tempfile    age3
			save       `age3'

			* ROUND 4
			use CHILDCODE agemon using "$r4yc1/PE_R4_YCCH_YoungerChild.dta", clear
			qui append using "$r4oc1/PE_R4_OCCH_OlderChild.dta", keep(CHILDCODE agemon)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE			
			gen round=4
			tempfile    age4
			save       `age4'			
		
			* ROUND 5			
			use CHILDCODE agemon_r5 using "$r5anthro\anthropometry_zscores_R5_yc_21may18.dta", clear
			qui append using "$r5anthro\anthropometry_BMI_R5_oc_21may", keep(CHILDCODE agemon_r5)			
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			rename agemon_r5 agemon
			gen round=5
			tempfile    age5
			save       `age5'				
			
			* MERGE
			use `age1', clear
			forvalues i=2/5 {													
				qui append using `age`i''
				}
			rename agemon chage
			tempfile age
			save `age'

	* MERGE
			use childid round using `allchildren', clear
			merge m:1 childid using `childchar', nogen
			merge 1:1 childid round using `age', nogen
			merge m:1 childid using `lang', nogen
			order childid chsex chlang chethnic chldrel chage round

	* LABEL VARIABLES
			label var childid 	"Child ID"
			label var chsex 	"Child's sex"
			label var chlang 	"Child's first language"
			label var chethnic 	"Child's ethnic group"
			label var chldrel 	"Child's religion"
			label var chage 	"Child's age (in months)"
		
			label define ethnic 31 "White" 32 "Mestizo" 33 "Native of the Amazon" 34 "Negro" 35 "Asiatic"
			label values chethnic ethnic		
			tempfile    childgeneral
			save       `childgeneral'


***** MARRIAGE AND CHILD BIRTH *****

	* OLDER COHORT ONLY
			use "$marriage\marriage&cohab_oc_allcountries.dta", clear
			merge 1:1 childid using "$marriage\childbirth_oc_allcountries.dta", nogen
			keep if country=="Peru"
			keep childid evrmcR4 evrmcR5 age_mc evrchild age_1stbirth
			rename evrmcR4 marrcohab4 
			rename evrmcR5 marrcohab5
			rename age_mc marrcohab_age
			rename evrchild birth5
			g birth4=0 if marrcohab4!=.
			replace birth4=1 if age_1stbirth<=19
			rename age_1stbirth birth_age
			reshape long marrcohab birth, i(childid) j(round)
			lab var round ""
			lab val round .
			replace marrcohab_age=. if marrcohab==0
			replace marrcohab=1 if marrcohab_age!=.
			replace birth_age=. if birth==0
			replace birth=1 if birth_age!=.
			
			lab def yesno 0 "no" 1 "yes"
			lab val marrcohab birth yesno
			lab var marrcohab "child has ever been married or cohabited"
			lab var marrcohab_age "age of child at first marriage or cohabitation"
			lab var birth "child has a son/daughter"
			lab var birth_age "age of child when first son/daughter was born"
			tempfile marriage
			save `marriage'
			
			
***** ANTHROPOMETRIC MEASURES *****			
	/* Height, weight, underweight, wasting, stunting */			

	* ROUND 1
			use childid chheght chweght bmi-fbfa using "$r1yc\PEChildLevel1YrOld.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid chheght chweght bmi-fbfa)
			g round=1
			rename chweght chweight
			rename chheght chheight
			tempfile anthrop1
			save `anthrop1'
	
	* ROUND 2
			use childid chheight chweight bmi-fbfa zwfl fwfl using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid chheight chweight bmi-fbfa)
			g round=2
			tempfile anthrop2
			save `anthrop2'	
	
	* ROUND 3
			use childid chwghtr3 chhghtr3 using "$r3yc/pe_yc_householdlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdlevel.dta", keep(childid chwghtr3 chhghtr3)
			rename chwghtr3 chweight
			rename chhghtr3 chheight	
			tempfile height3
			save `height3'
	
			use childid bmi-fbfa using "$r3yc\pe_yc_childlevel.dta", clear
			qui append using "$r3oc\pe_oc_childlevel.dta", keep(childid bmi-fbfa)
			g round=3
			merge 1:1 childid using `height3', nogen
			tempfile anthrop3
			save `anthrop3'				
		
	* ROUND 4
			use CHILDCODE CHHGTAGR4 CHWGTAGR4 using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", clear
			merge 1:1 CHILDCODE	using "$r4yc1\PE_R4_YCCH_YoungerChild.dta", nogen keepusing(CHILDCODE bmi-fbfa)
			qui append using "$r4oc1\PE_R4_OCCH_OlderChild.dta", keep(CHILDCODE CHHGTAGR4 CHWGTAGR4 bmi-fbfa)
			rename CHWGTAGR4 chweight
			rename CHHGTAGR4 chheight
			destring chweight chheight, replace dpcomma
			recode chweight chheight (-9999=.)
			g round=4
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile anthrop4
			save `anthrop4'				

	* ROUND 5
			use CHILDCODE CHHGTAGR5 CHWGTAGR5 using "$r5ycch\YoungerChild.dta", clear
			merge 1:1 CHILDCODE	using "$r5anthro\anthropometry_zscores_R5_yc_21may18.dta", nogen 
			rename CHWGTAGR5 chweight
			rename CHHGTAGR5 chheight
			destring chweight chheight, replace dpcomma
			recode chweight chheight (-9999=.)
			rename _* *
			g round=5
			drop CHILDCODE
			tempfile anthrop5
			save `anthrop5'					

	* MERGE AND COMPUTE MEASURES
			use `anthrop1', clear
			forvalues i=2/5 {
				qui append using `anthrop`i''
				}	
			
			g underweight=1 if zwfa<-2 & zwfa!=. & fwfa!=1
			replace underweight=2 if zwfa<-3 & zwfa!=. & fwfa!=1
			replace underweight=0 if missing(underweight) & zwfa!=. & fwfa!=1
			
			g stunting=1 if zhfa<-2 & zhfa!=. & fhfa!=1
			replace stunting=2 if zhfa<-3 & zhfa!=. & fhfa!=1
			replace stunting=0 if missing(stunting) & zhfa!=. & fhfa!=1
			
			g thinness=1 if zbfa<-2 & zbfa!=. & fbfa!=1
			replace thinness=2 if zbfa<-3 & zbfa!=. & fbfa!=1
			replace thinness=0 if missing(thinness) & zbfa!=. & fbfa!=1
		
	* LABEL VARIABLES
			label var childid 		"Child ID"
			label var round			"Round of survey"
			label var chweight 		"Child's weight (kg)"
			label var chheight 		"Child's height (cm)"
			label var bmi 			"Calculated BMI=weight/squared(height)"
			label var zwfa 			"Weight-for-age z-score"
			label var zhfa 			"Height-for-age z-score"
			label var zbfa 			"BMI-for-age z-score"
			label var zwfl 			"Weight-for-length/height z-score"
			label var fhfa 			"flag=1 if (zhfa<-6 | zhfa>6)"
			label var fwfa 			"flag=1 if (zwfa<-6 | zwfa>5)"
			label var fbfa 			"flag=1 if (zbfa<-5 | zbfa>5)"
			label var fwfl 			"flag=1 if (zwfl<-5 | zwfl>5)"
			label var underweight 	"Low weight for age"
			label var stunting 		"Short height for age"
			label var thinness 		"Low BMI for age"
		
			label def underweight 0 "not underweight" 1 "moderately underweight" 2 "severely underweight"
			label val underweight underweight
			label def stunting 0 "not stunted" 1 "moderately stunted" 2 "severely stunted"
			label val stunting stunting
			label def thinness 0 "not thin" 1 "moderately thin" 2 "severely thin"
			label val thinness thinness

			drop if bmi==. & zwfa==. & zhfa==. & zbfa==. & zwfl==. & fwfa==.               // cleaning purely mv 
			sort childid round
			order childid round
			tempfile anthrop
			save `anthrop'

			
***** BIRTH AND IMMUNIZATION *****

	* ROUND 1 (YC ONLY)	
			use childid bwght bwdoc antnata numante inject docbrth-othbrth bcg measles polio using "$r1yc\pechildlevel1yrold.dta", clear
			rename inject tetanus
			replace numante=0 if antnata==2
			g withinfo=docbrth!=. & nurbrth!=. &  midbrth!=. &  relbrth!=. &  othbrth!=. 
			g delivery=(docbrth==1 | nurbrth==1 |   midbrth==1) if withinfo==1 
			g round=1
			drop docbrth nurbrth midbrth relbrth othbrth withinfo antnata
			recode bwdoc tetanus bcg measles polio (2=0)
			tempfile birth
			save `birth'
	
	* ROUND 2
			use childid bcg measles dpt opv hib using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid bcg measles dpt opv hib)
			rename opv polio
			g round=2
			tempfile vaccine
			save `vaccine'
			
	* MERGE
			use `birth', clear
			merge 1:1 childid round using `vaccine', nogen

	* LABEL VARIABLES
			lab var childid		"Child ID"
			lab var round	 	"Round of survey"	
			lab var bwght		"Child''s birth weight (grams)"
			lab var bwdoc		"Child's birth weight was from documentation"
			lab var numante		"Number of antenatal visits of mother during pregnancy with YL child"
			lab var tetanus		"Mother received at least two injections for tetanus during pregnancy with YL child"
			lab var delivery	"Mother was attended by skilled health personnel (doctor, nurse, or midwife) during delivery of YL child"
			lab var bcg			"Child have received BCG vaccination"
			lab var measles		"Child have received vaccination against measles"
			lab var polio		"Child have received vaccination against polio"
			lab var dpt			"Child have received vaccination against DPT"
			lab var hib			"Child have received vaccination against HIB"
			
			lab def yesno 0 "no" 1 "yes"
			label val bwdoc tetanus delivery bcg measles polio dpt hib yesno	
			
			order childid round bwght bwdoc numante delivery
			sort childid round
			tempfile birthvacc
			save `birthvacc'						


***** ILLNESS, INJURY, AND DISABILITY *****

	* ROUND 1
			use childid mightdie longterm using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid mightdie hpfriend hpwork hpoth) 
			recode mightdie hpfriend hpwork hpoth (2=0)
			rename mightdie chmightdie
			g chhprob=hpfriend==1 | hpwork==1 | hpoth==1
			replace chhprob=longterm if missing(chhprob)
			g round=1
			drop hpfriend hpwork hpoth longterm
			tempfile illness1
			save `illness1'
	
	* ROUND 2
			use childid mightdie longterm using "$r2yc\pechildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\pesubillnesses5.dta", nogen keepusing(childid illid)
			drop if illid>1 & illid!=.
			merge 1:m childid using "$r2yc\pesubinjuries5.dta", nogen keepusing(childid injid)
			drop if injid>1 & injid!=.
			tempfile yc2
			save `yc2'
			use childid mightdie longterm using "$r2oc\pechildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc\pesubillnesses12.dta", nogen keepusing(childid illid)
			drop if illid>1 & illid!=.
			merge 1:m childid using "$r2oc\pesubinjuries12.dta", nogen keepusing(childid injid)
			drop if injid>1 & injid!=.
			qui append using `yc2'
			g chillness=illid==1 if mightdie!=.
			g chinjury=injid==1 if mightdie!=.
			rename mightdie chmightdie
			rename longterm chhprob
			drop illid injid
			g round=2
			tempfile illness2
			save `illness2'

	* ROUND 3
			use childid tminjr3 using "$r3yc/pe_yc_householdlevel.dta", clear
			rename tminjr3 nmtminr3 
			qui append using "$r3oc/pe_oc_childlevel.dta", keep(childid nmtminr3)
			g chinjury=nmtminr3>0 if nmtminr3!=.
			drop nmtminr3 
			g round=3
			tempfile illness3
			save `illness3'
	
	* ROUND 4
			use CHILDCODE ILLNSSR4 TMINJR4 DSBWRKR4 HOWAFTR4 using "$r4yc3/PE_R4_YCHH_YoungerHousehold.dta", clear
			rename TMINJR4 NMTMINR4
			qui append using "$r4oc1/PE_R4_OCCH_OlderChild.dta", keep(CHILDCODE ILLNSSR4 NMTMINR4 LNGHL* DSBWRKR4 HOWAFTR4)
			rename ILLNSSR4 chillness			
			g chinjury=NMTMINR4>0 if NMTMINR4!=.
			rename DSBWRKR4 chdisability
			rename HOWAFTR4 chdisscale
			g round=4
			g childid="PE"+string(CHILDCODE, "%06.0f")
			keep ch* round
			tempfile illness4
			save `illness4'
			
	* ROUND 5
			use CHILDCODE ILLNSSR5 TMINJR5 LNGHLTR5 using "$r5ycch\Youngerchild.dta", clear
			rename TMINJR5 NMTMINR5
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", nogen keepusing(CHILDCODE CHDISBR5 CHAFCR5)
			rename CHDISBR5 DSBWRKR5
			rename CHAFCR5 HOWAFTR5
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE ILLNSSR5 NMTMINR5 LNGHLTR5 DSBWRKR5 HOWAFTR5)
			recode ILLNSSR5 NMTMINR5 DSBWRKR5 HOWAFTR5 LNGHLTR5 (77 79 88=.)
			rename ILLNSSR5 chillness
			rename LNGHLTR5 chhprob
			g chinjury=NMTMINR5>0 if NMTMINR5!=.
			rename DSBWRKR5 chdisability
			rename HOWAFTR5 chdisscale
			g round=5
			g childid="PE"+string(CHILDCODE, "%06.0f")
			keep ch* round
			tempfile illness5
			save `illness5'				
				
	* MERGE
			use `illness1', clear
			forvalues i=2/5 {
				qui append using `illness`i''
				}
	
	* LABEL VARIABLES
		lab var childid		"Child ID"
			lab var round	 	"Round of survey"	
			lab var chmightdie	"Child has had serious injury/illness since last round when caregiver thought child might die"
			lab var chillness	"Child has had serious illness since last round"
			lab var chinjury	"Child has had serious injury since last round"
			lab var chhprob		"Child has longterm health problem"
			lab var chdisability "Child has permanent disability"
			lab var chdisscale	"Permanent disability scale"
				
			lab def yesno 0 "no" 1 "yes"
			label val chmightdie chillness chinjury chhprob chdisability yesno			
			lab def chdisscale ///
						0 "Able to work same as others of this age" ///
						1 "Capable of most types of full-time work but some difficulty with physical work" ///
						2 "Able to work full-time but only work requiring no physical activity" ///
						3 "Can only do light work on a part-time basis" ///
						4 "Cannot work but able to care for themselves (e.g. dress themselves, etc.)" ///
						5 "Cannot work and needs help with daily activities such as dressing, washing, etc." ///
						6 "Other"
			lab val chdisscale chdisscale
						
			order childid round chmightdie chillness chinjury chhprob chdisability chdisscale
			sort childid round
			tempfile illness
			save `illness'
			
			
***** SMOKING, DRINKING, AND REPRODUCTIVE HEALTH *****

	* ROUND 3 (OLDER COHORT ONLY)
			use childid agecigr3 oftsmkr3 youalcr3 prgfrsr3-hivsexr3 whrcndr3 using "$r3oc\PE_OC_ChildLevel.dta", clear
			recode agecigr3 oftsmkr3 youalcr3 prgfrsr3-hivsexr3 whrcndr3 (77 79 88 99=.)
			recode oftsmkr3 (0=.) (1=5) (2=1) (3=2) (4=3) (5=4)
			rename oftsmkr3 chsmoke
			replace chsmoke=5 if agecigr3==4
			g chalcohol=youalcr3==1 | youalcr3==2 if youalcr3!=.
			g noresp=prgfrsr3==. & wshaftr3==. & usecndr3==. & lkshltr3==. & hivsexr3==.
			g corr1=prgfrsr3==2 if noresp==0
			g corr2=wshaftr3==2 if noresp==0
			g corr3=usecndr3==1 if noresp==0
			g corr4=lkshltr3==2 if noresp==0
			g corr5=hivsexr3==1 if noresp==0
			egen chrephealth1=rowtotal(corr1-corr5) if noresp==0
			g chrephealth2=corr3
			g chrephealth3=corr4
			rename whrcndr3 chrephealth4
			recode chrephealth4 (1 2 3=1) (4=2) (5 6 7=3) (8 9=4)
			g round=3
			keep childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			order childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			tempfile smoke3
			save `smoke3'

	* ROUND 4 (OLDER COHORT ONLY)
			use CHILDCODE AGECIGR4 OFTSMKR4 YOUALCR4 PRGFRSR4-WHRCNDR4 using "$r4ocsaq\PE_OC_SAQ_OlderChild.dta", clear
			recode YOUALCR4 OFTSMKR4 YOUALCR4 PRGFRSR4-WHRCNDR4 (77 79 88 99=.)
			g chalcohol=YOUALCR4==1 | YOUALCR4==2 if YOUALCR4!=.
			rename OFTSMKR4 chsmoke
			replace chsmoke=5 if AGECIGR4==8
			g noresp=PRGFRSR4==. & WSHAFTR4==. & USECNDR4==. & LKSHLTR4==. & HIVSEXR4==.
			g corr1=PRGFRSR4==2 if noresp==0
			g corr2=WSHAFTR4==2 if noresp==0
			g corr3=USECNDR4==1 if noresp==0
			g corr4=LKSHLTR4==2 if noresp==0
			g corr5=HIVSEXR4==1 if noresp==0
			egen chrephealth1=rowtotal(corr1-corr5) if noresp==0
			g chrephealth2=corr3
			g chrephealth3=corr4
			rename WHRCNDR4 chrephealth4
			recode chrephealth4 (1 2=1) (3=2) (4=3) (5 6=4)
			g round=4
			g childid="PE"+string(CHILDCODE, "%06.0f")	
			keep childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4 
			order childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4 
			tempfile smoke4
			save `smoke4'			
			
	* ROUND 5
			use CHILDCODE AGECIGR5 OFTSMKR5 YOUALCR5 PRGFRSR5-HIVSEXR5 WHRCNDR5 using "$r5ycsaq\YoungerChildSAQ.dta", clear
			recode AGECIGR5-WHRCNDR5 (77 78 79 88 99=.)
			rename OFTSMKR5 chsmoke
			replace chsmoke=5 if AGECIGR5==8
			g chalcohol=YOUALCR5==1 | YOUALCR5==2 if YOUALCR5!=.
			g noresp=PRGFRSR5==. & WSHAFTR5==. & USECNDR5==. & LKSHLTR5==. & HIVSEXR5==.
			g corr1=PRGFRSR5==2 if noresp==0
			g corr2=WSHAFTR5==2 if noresp==0
			g corr3=USECNDR5==1 if noresp==0
			g corr4=LKSHLTR5==2 if noresp==0
			g corr5=HIVSEXR5==1 if noresp==0
			egen chrephealth1=rowtotal(corr1-corr5) if noresp==0
			g chrephealth2=corr3
			g chrephealth3=corr4
			rename WHRCNDR5 chrephealth4
			recode chrephealth4 (1 2=1) (3=2) (4 5 6 =3) (7 8=4)
			g round=5
			g childid="PE"+string(CHILDCODE, "%06.0f")				
			keep childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			order childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			tempfile yc5
			save `yc5'	
			use CHILDCODE AGECIGR5 OFTSMKR5 YOUALCR5 WHRCNDR5 using "$r5ocsaq\OlderChildSAQ.dta", clear
			recode AGECIGR5-WHRCNDR5 (77 78 79 88 99=.)
			rename OFTSMKR5 chsmoke
			replace chsmoke=5 if AGECIGR5==8
			g chalcohol=YOUALCR5==1 | YOUALCR5==2 if YOUALCR5!=.			
			rename WHRCNDR5 chrephealth4
			recode chrephealth4 (1 2=1) (3=2) (4 5 6 =3) (7 8=4)
			g round=5
			g childid="PE"+string(CHILDCODE, "%06.0f")				
			keep childid round chsmoke chalcohol chrephealth4
			order childid round chsmoke chalcohol chrephealth4
			qui append using `yc5'
			tempfile smoke5
			save `smoke5'

	* MERGE
			use `smoke3', clear
			forvalues i=4/5 {
				qui append using `smoke`i''
				}
				
	* LABEL VARIABLES			
			lab var childid			"Child ID"
			lab var round	 		"Round of survey"	
			lab var chsmoke			"Child's frequency of smoking"
			lab var chalcohol		"Child consume alcohol everyday or at least once a week"
			lab var chrephealth1	"Child's knowledge of reproductive health"
			lab var chrephealth2	"Child knows condom can prevent disease through sex"
			lab var chrephealth3	"Child knows healthy-looking person can pass on a disease sex"
			lab var chrephealth4	"Child's source of condom"
			
			lab def chsmoke 1 "Every day" /// 
							2 "At least once a week" ///
							3 "At least once a month" ///
							4 "Hardly ever" ///
							5 "I never smoke cigarettes"
			lab	val chsmoke chsmoke
			lab def yesno 0 "no" 1 "yes"
			lab val chrephealth2 chrephealth3 chalcohol yesno
			lab def condom 	1 "Shop or street vendor" ///
							2 "Family planning services or health facility" ///
							3 "Other" ///
							4 "I do not know what a condom is/I do not know where to get a condom"
			lab val chrephealth4 condom
			
			sort childid round
			tempfile smoke
			save `smoke' 
			
			
***** SUBJECTIVE HEALTH AND WELL-BEING *****
	
		* ROUND 1
			use childid healthy using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid healthy)
			recode healthy (99=.)
			rename healthy chhrel
			g round=1
			tempfile shealth1
			save `shealth1'
			
		* ROUND 2
			use childid healthy using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\PEChildQuest12YrOld.dta", keep(childid chealthy cladder)
			replace healthy=chealthy if missing(healthy)
			drop chealthy
			rename healthy chhrel
			recode chhrel (0=.)
			g round=2
			tempfile shealth2
			save `shealth2'
		
		* ROUND 3
			use childid hlcmchr3 nmehltr3 using "$r3yc/pe_yc_householdlevel.dta", clear
			merge 1:1 childid using "$r3yc/pe_yc_childlevel.dta", nogen keepusing(childid stnprsr3)
			rename nmehltr3 yrhlthr3
			rename hlcmchr3 cmphltr3
			qui append using "$r3oc/pe_oc_childlevel.dta", keep(childid cmphltr3 yrhlthr3 stnprsr3)
			recode cmphltr3 yrhlthr3 stnprsr3 (77 79 88=.)
			rename cmphltr3 chhrel 
			recode chhrel (3=1) (4 5=2) (1 2=3)	
			rename yrhlthr3 chhealth 
			rename stnprsr3 cladder
			g round=3
			tempfile shealth3
			save `shealth3'
			
		* ROUND 4
			use CHILDCODE HLCMCHR4 NMEHLTR4 using "$r4yc3/PE_R4_YCHH_YoungerHousehold.dta", clear
			merge 1:1 CHILDCODE using "$r4yc1/PE_R4_YCCH_YoungerChild.dta", nogen keepusing(CHILDCODE STNPRSR4)
			rename HLCMCHR4 CMPHLTR4
			rename NMEHLTR4 YRHLTHR4
			qui append using "$r4oc1\PE_R4_OCCH_OlderChild.dta", keep(CHILDCODE CMPHLTR4 YRHLTHR4 STNPRSR4)
			recode YRHLTHR4 STNPRSR4 CMPHLTR4 (77 79 88=.)
			rename CMPHLTR4 chhrel
			recode chhrel (3=1) (4 5=2) (1 2=3)				
			rename YRHLTHR4 chhealth
			rename STNPRSR4 cladder
			g round=4
			g childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			tempfile shealth4
			save `shealth4'
			
		* ROUND 5
			use CHILDCODE NMEHLTR5 STNPRSR5 HLCMCHR5 using "$r5ycch/YoungerChild.dta", clear
			rename HLCMCHR5 CMPHLTR5
			rename NMEHLTR5 YRHLTHR5
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE YRHLTHR5 STNPRSR5 CMPHLTR5)
			recode YRHLTHR5 STNPRSR5 CMPHLTR5 (77 79 88=.)
			rename CMPHLTR5 chhrel
			recode chhrel (3=1) (4 5=2) (1 2=3)	
			rename YRHLTHR5 chhealth
			rename STNPRSR5 cladder
			g round=5
			g childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			tempfile shealth5
			save `shealth5'		
		
		* MERGE
			use `shealth1', clear
			forvalues i=2/5 {
				qui append using `shealth`i''
				}		
		
		* LABEL VARIABLES
			lab var childid		"Child ID"
			lab var round	 	"Round of survey"	
			lab var chhrel 		"Child's health compared to peers"
			lab var chhealth 	"Child's health in general"		
			lab var cladder 	"Child's subjective well-being (9-step ladder)"
			label define chhrel 1 "Same" 2 "Better" 3 "Worse" 
			label values chhrel chhrel			
			label define chhealth 1 "very poor" 2 "poor" 3 "average" 4 "good" 5 "very good" 
			label values chhealth chhealth

			sort childid round
			order childid round chhrel chhealth cladder
			tempfile shealth
			save `shealth' 
									

***** TIME USE *****

	* ROUND 1 (NOT COLLECTED)
	
	* ROUND 2 (NOTE: missing values for R2 mean that child is younger than 5)
			use childid id age sleep chcare hhchore npaywork paywork school study play using "$r2yc\pesubhouseholdmember5.dta", clear
			keep if id==0
			recode sleep chcare hhchore npaywork paywork school study play (77 88 99=.)
			g hsleep=sleep														// Sleeping
			g hcare=chcare 														// Caring for family members 
			g hchore=hhchore													// Domestic tasks on family farm, cattle herding, other
			g htask=npaywork													// Family business, farm (non paid)
			g hwork=paywork 													// Paid work
			g hschool=school													// At school
			g hstudy=study														// Studying			
			g hplay=play 														// Leisure
			drop id age sleep-play
			tempfile timeuse2yc
			save    `timeuse2yc'
			use childid csleep-cplay using "$r2oc\PEChildQuest12YrOld.dta", clear
			recode csleep-cplay (77 88 99=.)
			rename csleep hsleep
			rename cchcare hcare
			rename chhchore hchore
			rename cnpaywrk htask
			rename cpaywork hwork
			rename cschool hschool
			rename cstudy hstudy
			rename cplay hplay						
			qui append using `timeuse2yc'
			gen round=2
			tempfile timeuse2
			save    `timeuse2'

	* ROUND 3
			use childid id age sleepr3-playr3 using "$r3yc/pe_yc_householdmemberlevel.dta", clear
			recode *r3 (-77 77 79 88=.)			
			keep if id==0
			drop if age==.
			g hsleep=sleepr3													// Sleeping
			g hcare=chcarer3 													// Caring for family members 
			g hchore=hhchrer3													// Domestic tasks on family farm, cattle herding, other
			g htask=npywrkr3													// Family business, farm (non paid)
			g hwork=paywrkr3 													// Paid work
			g hschool=schoolr3													// At school
			g hstudy=studyr3													// Studying			
			g hplay=playr3 														// Leisure
			drop *r3 age id
			tempfile timeuse3yc
			save    `timeuse3yc'			
			use childid sleepr3-lsurer3 using "$r3oc/pe_oc_childlevel.dta", clear
			recode *r3 (-77 77 79 88=.)
			rename sleepr3 hsleep
			rename crothr3 hcare
			rename dmtskr3 hchore
			rename tsfarmr3 htask
			rename actpayr3 hwork
			rename atschr3 hschool
			rename studygr3 hstudy
			rename lsurer3 hplay			
			qui append using `timeuse3yc'
			gen round=3
			tempfile timeuse3
			save    `timeuse3'
		
	* ROUND 4
			use CHILDCODE SLEEPR4-LSURER4 TMCMWKR4 TMCMSCR4 using "$r4yc1\PE_R4_YCCH_YoungerChild.dta", clear 
			rename TMCMSCR4 COMSCHR4 			
			qui appen using "$r4oc1\PE_R4_OCCH_OlderChild.dta", keep(CHILDCODE SLEEPR4-LSURER4 TMCMWKR4 COMSCHR4)
			recode *R4 (-77 -88 -79 -99=.)
			recode SLEEPR4-LSURER4 (77 88=.)
			rename SLEEPR4 hsleep
			rename CROTHR4 hcare
			rename DMTSKR4 hchore
			rename TSFARMR4 htask
			rename ACTPAYR4 hwork
			rename ATSCHR4 hschool
			rename STUDYGR4 hstudy
			rename LSURER4 hplay
			rename TMCMWKR4 commwork
			rename COMSCHR4 commsch				
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			gen round=4
			tempfile timeuse4
			save    `timeuse4'

	* ROUND 5
			use CHILDCODE SLEEPR5-LSURER5 TMCMWKR5 TMCMSCR5 using "$r5ycch\YoungerChild.dta", clear
			rename TMCMSCR5 COMSCHR5			
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE SLEEPR5-LSURER5 TMCMWKR5 COMSCHR5)
			recode *R5 (-88 -77=.)
			recode SLEEPR5-LSURER5 (77 88=.)
			rename SLEEPR5 hsleep
			rename CROTHR5 hcare
			rename DMTSKR5 hchore
			rename TSFARMR5 htask
			rename ACTPAYR5 hwork
			rename ATSCHR5 hschool
			rename STUDYGR5 hstudy
			rename LSURER5 hplay
			rename TMCMWKR5 commwork
			rename COMSCHR5 commsch				
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			gen round=5
			tempfile timeuse5
			save    `timeuse5'

	* MERGE
			use `timeuse2', clear
			forvalues i=3/5 {
				qui append using `timeuse`i''
				}	
	
	* LABEL VARIABLES
			lab var childid		"Child ID"
			lab var round	 	"Round of survey"			
			label var hsleep    "Hours/day spent sleeping"
			label var hcare     "Hours/day spent in caring for hh members"
			label var hchore    "Hours/day spent in hh chores"
			label var htask     "Hours/day spent in domestic tasks - farming, fam business"
			label var hwork  	"Hours/day spent in paid activity"
			label var hschool   "Hours/day spent at school"
			label var hstudy    "Hours/day spent studying outside school"
			label var hplay     "Hours/day spent in leisure activities"			
			label var commwork 	"Commuting time to place of work (out and return, in minutes)"
			label var commsch 	"Commuting time to school (out and return, in minutes)"
			
			sort childid round
			order childid round 
			tempfile timeuse
			save `timeuse' 

			
***** EDUCATION VARIABLES *****			
			
		* Age start of schooling 
			use "$educhist\Older cohort\Data\educhistory_pe_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_pe_yc.dta"	
			
			recode enrolled (1=0) if grade==100
			bys childid: egen agegr1=min(age_apr) if enrolled==1 & grade==1
			keep if agegr1!=.
			keep childid agegr1
			duplicates drop
			label variable agegr1 "Child's age at start of grade 1"
			tempfile agegr1
			save `agegr1'
			
		* Pre-primary school
			use childid grade completeinfo using "$educhist\Older cohort\Data\educhistory_pe_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_pe_yc.dta", keep(childid grade completeinfo)	
			merge m:1 childid using `agegr1', nogen
			replace grade=. if grade<100
			recode grade (100=1)
			bys childid: egen preprim=max(grade)
			drop grade
			duplicates drop
			replace preprim=0 if missing(preprim) & (agegr1!=. | completeinfo==1)
			keep childid preprim
			lab var preprim "Child has attended pre-primary school"
			tempfile preprim
			save `preprim'
				
		* Enrolment per round
			use "$educhist\Older cohort\Data\educhistory_pe_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_pe_yc.dta"	
			
			recode enrolled (1=0) if grade==100	
			recode grade (100=0)
			g round=1 if year==2002
			replace round=2 if year==2006
			replace round=3 if year==2009
			replace round=4 if year==2013
			replace round=5 if year==2016
			keep childid round enrolled grade type
			rename enrolled enrol
			rename grade engrade
			rename type entype
			keep if round!=.
			order childid round
			lab var enrol "Child is currently enrolled"
			lab var engrade "Current grade enrolled in"
			lab var entype "Current type of school enrolled in"
			tempfile enrol
			save `enrol'
		
	* HIGHEST GRADE ACHIEVED AT TIME OF INTERVIEW
		* not available for Peru. Not available for round 3 and round 4. (round 4 asks highest grade achieved or current grade enrolled.)
	
		
			
	* TRAVEL TIME TO SCHOOL 
		
			* ROUND 1 (not asked)
			
			* ROUND 2 
			use childid tmschmin using "$r2oc/pechildquest12yrold.dta", clear
			qui append using "$r2yc/pechildlevel5yrold.dta", keep(childid tmschmin)
			rename tmschmin timesch
			g round=2
			tempfile time2
			save `time2'
		
			* ROUND 3
			use childid schminr3 using "$r3oc/pe_oc_childlevel.dta", clear
			qui append using "$r3yc/pe_yc_householdlevel.dta", keep(childid schminr3)
			recode schminr3 (-79=.)
			rename schminr3 timesch			
			g round=3
			tempfile time3
			save `time3'
		
			* ROUND 4
			use CHILDCODE SCHMINR4 using "$r4oc1/PE_R4_OCCH_OlderChild.dta", clear
			qui append using "$r4yc1/PE_R4_YCCH_YoungerChild.dta", keep(CHILDCODE SCHMINR4)
			rename SCHMINR4 timesch
			recode timesch (-79 -77=.)		
			g childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			g round=4
			tempfile time4
			save `time4'
				
			* ROUND 5
			use CHILDCODE SCHMINR5 using "$r5occh/OlderChild.dta", clear
			qui append using "$r5ycch/YoungerChild.dta", keep(CHILDCODE SCHMINR5)
			rename SCHMINR5 timesch
			recode timesch (-77 -88=.)		
			g childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			g round=5
			tempfile time5
			save `time5'				
		
			* merge
			use `time2', clear
			forvalues i=3/5 {
				qui append using `time`i''
				}
			lab var timesch "Travel time to school (in minutes)"
			tempfile time
			save `time'

	
		* MERGE
			use `preprim', clear
			merge 1:1 childid using `agegr1', nogen
			merge 1:m childid using `enrol', nogen
			merge 1:1 childid round using `time', nogen
			sort childid round
			tempfile education
			save `education'

			
***** READING AND WRITING *****
 
	* ROUND 1 (OC only)
		
			use childid levlread levlwrit using "$r1oc/pechildlevel8yrold.dta", clear
			recode levlread levlwrit (99=.)
			recode levlwrit (2=3) (3=2) 										// recode for consistency across rounds
			g literate=levlread==4 & levlwrit==3 if levlread!=. & levlwrit!=. 	 // Reads sentence & writes sentences w/o difficulties
			g round=1
			lab val levlread levlwrit .
			tempfile read1
			save `read1'
	
	* ROUND 2 (OC only)
		
			use childid levlread levlwrit using "$r2oc/pechildquest12yrold.dta", clear
			recode levlread levlwrit (99=.)
			g literate=levlread==4 & levlwrit==3 if levlread!=. & levlwrit!=. 	 // Reads sentence & writes sentences w/o difficulties
			g round=2
			tempfile read2
			save `read2'		
		
	* ROUND 3 (YC only)
		
			use childid vrbitm01 vrbitm02 using "$r3yc/pe_yc_childlevel.dta", clear
			rename vrbitm01 levlread
			rename vrbitm02 levlwrit
			g literate=levlread==4 & levlwrit==3 if levlread!=. & levlwrit!=. 	 // Reads sentence & writes sentences w/o difficulties
			g round=3
			tempfile read3
			save `read3'		
		
	* ROUND 4 (not asked)
		
	* ROUND 5 (not asked)
		
	* MERGE
			
			use `read1', clear
			qui append using `read2'
			qui append using `read3'
			
	* LABELS
			
			lab var levlread "Child's reading level"
			lab def levlread 1 "can't read anything" 2 "reads letters" 3 "reads word" 4 "reads sentence"
			lab val levlread levlread
			
			lab var levlwrit "Child's writing level"
			lab def levlwrit 1 "no" 2 "yes with difficulty or errors" 3 "yes without difficulty or errors"
			lab val levlwrit levlwrit
			
			lab var literate "equals 1 if child can read and write a sentence without difficulties"
			lab def yesno 0 "no" 1 "yes"
			lab val literate yesno
			
			tempfile literacy
			save `literacy'

		
***** PARENT CHARACTERISTICS (FATHER) *****

	* ROUND 1
			use childid id age sex relate yrschool using "$r1yc\pesubsec2householdroster1.dta", clear
			qui append using "$r1oc\pesubsec2householdroster8.dta", keep(childid id age sex relate yrschool)
			gen father=1 if relate==1 & sex==1
			keep if father==1                                   
			recode relate yrschool (88 99=.)
			recode yrschool (13/16=.)
			rename id dadid
			rename age dadage
			rename yrschool dadedu
			recode dadedu (35=13) (36=14) (37=15) (38=16) (31 32 33 34 88 99=.)
			keep childid dad*
			tempfile  dad1
			save     `dad1'						

			use childid daddead using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid daddead)
			rename daddead dadlive 
			recode dadlive (1=2) (2=1) (99=.)
			label drop DADDEAD
			merge 1:1 childid using `dad1', nogen
			g round=1
			tempfile dad1
			save `dad1'

	* ROUND 2
			use  childid id memsex livhse grade age relate using "$r2yc\pesubhouseholdmember5.dta", clear
			qui append using "$r2oc\pesubhouseholdmember12.dta", keep(childid id memsex age relate livhse grade)
			gen father=1 if relate==1 & memsex==1
			keep if father==1
			recode livhse (77 79 88 99=.)
			rename id dadid
			rename age dadage
			rename livhse dadlive
			rename grade dadedu
			recode dadedu (17=28) (18=30) (77 79 88 99=.)
			keep childid dad*
			tempfile  dad2
			save     `dad2'

			use childid dadlits using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid dadlits)
			merge 1:1 childid using `dad2', nogen
			g dadcantread=dadlits==3 if dadlits!=.
			replace dadcantread=0 if dadedu>11 & dadedu!=28 & dadedu!=29 & dadlits!=. // corrected literacy for those with postsecondary education.
			drop dadlits
			g round=2
			tempfile dad2
			save `dad2'

	* ROUND 3 
			use childid id memsex age relate livhse grade using "$r3yc\pe_yc_householdmemberlevel.dta", clear			
			qui append using "$r3oc\pe_oc_householdmemberlevel.dta", keep(childid id memsex age relate livhse grade)
			gen father=1 if relate==1 & memsex==1
			keep if father==1
			recode livhse (4=2) (77 79 88 99 5=.)
			recode grade (77=.)
			recode age (1=.)
			rename id dadid
			rename age dadage
			rename livhse dadlive
			rename grade dadedu	
			recode dadedu (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			keep childid dad*		
			g round=3
			tempfile  dad3
			save     `dad3'					
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4 using "$r4yc3\PE_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4)
			recode MEMAGER4 (-88 -77=.)
			gen father=1 if RELATER4==1 & MEMSEXR4==1
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep if father==1	
			recode LIVHSER4 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR4 dadid
			rename MEMAGER4 dadage
			rename LIVHSER4 dadlive
			rename GRADER4 dadedu
			recode dadedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename YRDIEDR4 dadyrdied
			recode dadyrdied (79=.)
			keep childid dad*
			g round=4
			tempfile  dad4
			save     `dad4'				

	* ROUND 5 (3 duplicates; PE021094 ID=4; PE091073 id=7; PE058015
			use CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 LIVHSER5 YRDIEDR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 LIVHSER5 YRDIEDR5)
			recode MEMAGER5 (-88 -77 1 2=.)
			gen father=1 if RELATER5==1 & MEMSEXR5==1
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep if father==1	
			recode LIVHSER5 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR5 dadid
			rename MEMAGER5 dadage
			rename LIVHSER5 dadlive
			rename GRADER5 dadedu
			recode dadedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename YRDIEDR5 dadyrdied
			drop if childid=="PE021094" & dadid==4
			drop if childid=="PE091073" & dadid==7
			drop if childid=="PE058015" & dadid==2
			keep childid dad*
			g round=5
			tempfile  dad5
			save     `dad5'					
	
	* MERGE
			use `dad1', clear
			forvalues i=2/5 {
				qui append using `dad`i''
				}					
			sort childid round
			tempfile    dad
			save       `dad'		

	* CORRECTIONS FOR FATHER EDUCATION
			
			*===================================================================*
			*	Steps in correcting education across rounds:					*
			*		1. If missing, copy succeeding nonmissing round.			*
			*		2. If still missing, copy preceeding nonmissing round.		*
			*		3. If greater than succeeding round, replace.				*
			*			Use info from succeeding round.							*
			*===================================================================*
		
			sort childid round
			keep childid dadid dadedu round
			g inround=1
			reshape wide dadedu inround, i(childid dadid) j(round)
		
			* Step 1:
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace dadedu`r'=dadedu`j' if missing(dadedu`r')
				local r=`r'-1
				}
		
			* Step 2:
			forvalues i=1/4 {
				local j=`i'+1
				replace dadedu`j'=dadedu`i' if missing(dadedu`j')
				}
				
			* Step 3:	
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace dadedu`r'=dadedu`j' if dadedu`r'>dadedu`j' 
				local r=`r'-1
				}
			reshape long
			keep if inround==1
			drop inround
			rename dadedu dadeducorr
			
			merge 1:1 childid round using `dad', nogen
			drop dadedu
			rename dadeducorr dadedu

	* CORRECTIONS FOR FATHER DEATH
			
			*===================================================================*
			*	If father has died:												*
			*		1. Information should be missing on next rounds				*
			*		2. Age should be missing (was reported in R2 and R3) 		*
			*		3. Year of death was obtained in R4, transfer year info		*
			*			on round where death was reported						*
			*===================================================================*			

			replace dadlive=3 if dadlive[_n-1]==3 & childid==childid[_n-1]
			recode dadage (*=.) if dadlive==3
			bys childid: egen diedround=min(round) if dadlive==3
			bys childid: egen yrdied=min(dadyrdied) if dadlive==3
			replace dadyrdied=yrdied
			recode dadage dadedu dadyrdied dadlive (*=.) if diedround!=round & diedround!=.
			recode dadage dadedu (*=.) if dadlive==3			
			keep childid round dad*
			
	* LABELS
			lab var childid			"Child ID"
			lab var round	 		"Round of survey"				
			label var dadage 		"Father's age"
			label var dadid  		"Father's id in roster"
			label var dadcantread 	"Father cannot read"
			label var dadedu		"Father's level of education"
			label var dadlive		"Location of YL child's father"
			label var dadyrdied		"Year when father has died"

			label define educ  0 "None" ///
							   1 "Grade 1" ///
							   2 "Grade 2" ///
							   3 "Grade 3" ///
							   4 "Grade 4" ///
							   5 "Grade 5" ///
							   6 "Grade 6" ///
							   7 "Grade 7" ///
							   8 "Grade 8" ///
							   9 "Grade 9" ///
							  10 "Grade 10" ///
							  11 "Grade 11" ///
							  13 "Technical, pedagogical, CETPRO (incomplete)" ///
							  14 "Technical, pedagogical, CETPRO (complete)" ///
							  15 "University (incomplete)" ///
							  16 "University (complete)" ///
							  28 "Adult literacy" ///
							  30 "Other"
			label values dadedu educ
			label define yesno 1 "yes" 0 "no"
			label values dadcantread yesno

			label define dadlive 1 "Lives in the household" 2 "Does not live in household" 3 "Has died" 
			label values dadlive dadlive	
			sort childid round
			tempfile    dad
			save       `dad'
						

***** PARENT CHARACTERISTICS (MOTHER) *****

	* ROUND 1
			use childid id age sex relate yrschool using "$r1yc\pesubsec2householdroster1.dta", clear
			qui append using "$r1oc\pesubsec2householdroster8.dta", keep(childid id age sex relate yrschool)
			gen mother=1 if relate==1 & sex==2
			keep if mother==1                                   
			recode relate yrschool (88 99=.)
			recode yrschool (13/16=.)
			rename id momid
			rename age momage
			rename yrschool momedu
			recode momedu (35=13) (36=14) (37=15) (38=16) (31 32 33 34 88 99=.)
			keep childid mom*
			tempfile  mom1
			save     `mom1'						

			use childid momlive using "$r1yc\pechildlevel1yrold.dta", clear
			qui append using "$r1oc\pechildlevel8yrold.dta", keep(childid momlive)
			recode momlive (1=2) (2=1) (99=.)
			label drop MOMLIVE
			merge 1:1 childid using `mom1', nogen
			g round=1
			tempfile mom1
			save `mom1'

	* ROUND 2
			use  childid id memsex livhse grade age relate using "$r2yc\pesubhouseholdmember5.dta", clear
			qui append using "$r2oc\pesubhouseholdmember12.dta", keep(childid id memsex age relate livhse grade)
			gen mother=1 if relate==1 & memsex==2
			keep if mother==1
			recode livhse (77 79 88 99=.)
			rename id momid
			rename age momage
			rename livhse momlive
			rename grade momedu
			recode momedu (17=28) (18=30) (77 79 88 99=.)
			keep childid mom*
			tempfile  mom2
			save     `mom2'

			use childid mumlits using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid mumlits)
			merge 1:1 childid using `mom2', nogen
			g momcantread=mumlits==3 if mumlits!=.
			replace momcantread=0 if momedu>11 & momedu!=28 & momedu!=29 & mumlits!=. // corrected literacy for those with postsecondary education.
			drop mumlits
			g round=2
			tempfile mom2
			save `mom2'

	* ROUND 3 (1 duplicate: PE101063 id=6)
			use childid id memsex age relate livhse grade using "$r3yc\pe_yc_householdmemberlevel.dta", clear			
			qui append using "$r3oc\pe_oc_householdmemberlevel.dta", keep(childid id memsex age relate livhse grade)
			gen mother=1 if relate==1 & memsex==2
			keep if mother==1
			recode livhse (4=2) (77 79 88 99 5=.)
			recode grade (77=.)
			recode age (1=.)
			rename id momid
			rename age momage
			rename livhse momlive
			rename grade momedu	
			recode momedu (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			drop if childid=="PE101063" & momid==6
			keep childid mom*		
			g round=3
			tempfile  mom3
			save     `mom3'					
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4 using "$r4yc3\PE_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4)
			recode MEMAGER4 (-88 -77=.)
			gen mother=1 if RELATER4==1 & MEMSEXR4==2
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep if mother==1	
			recode LIVHSER4 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR4 momid
			rename MEMAGER4 momage
			rename LIVHSER4 momlive
			rename GRADER4 momedu
			recode momedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename YRDIEDR4 momyrdied
			recode momyrdied (79=.)
			keep childid mom*
			g round=4
			tempfile  mom4
			save     `mom4'				

	* ROUND 5 (2 duplicates; PE121048 ID=4; PE128012 id=1) 
			use CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 LIVHSER5 YRDIEDR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 LIVHSER5 YRDIEDR5)
			recode MEMAGER5 (-88 -77 1 2=.)
			gen mother=1 if RELATER5==1 & MEMSEXR5==2
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep if mother==1	
			recode LIVHSER5 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR5 momid
			rename MEMAGER5 momage
			rename LIVHSER5 momlive
			rename GRADER5 momedu
			recode momedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename YRDIEDR5 momyrdied
			drop if childid=="PE121048" & momid==4
			drop if childid=="PE128012" & momid==1
			keep childid mom*
			g round=5
			tempfile  mom5
			save     `mom5'					
	
	* MERGE
			use `mom1', clear
			forvalues i=2/5 {
				qui append using `mom`i''
				}					
			sort childid round
			tempfile    mom
			save       `mom'		

	
	* CORRECTIONS FOR MOTHER EDUCATION
			
			*===================================================================*
			*	Steps in correcting education across rounds:					*
			*		1. If missing, copy succeeding nonmissing round.			*
			*		2. If still missing, copy preceeding nonmissing round.		*
			*		3. If greater than succeeding round, replace.				*
			*			Use info from succeeding round.							*
			*===================================================================*
		
			sort childid round
			keep childid momid momedu round
			g inround=1
			reshape wide momedu inround, i(childid momid) j(round)
		
			* Step 1:
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace momedu`r'=momedu`j' if missing(momedu`r')
				local r=`r'-1
				}
		
			* Step 2:
			forvalues i=1/4 {
				local j=`i'+1
				replace momedu`j'=momedu`i' if missing(momedu`j')
				}
				
			* Step 3:	
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace momedu`r'=momedu`j' if momedu`r'>momedu`j' 
				local r=`r'-1
				}
			reshape long
			keep if inround==1
			drop inround
			rename momedu momeducorr
			
			merge 1:1 childid round using `mom', nogen
			drop momedu
			rename momeducorr momedu

	* CORRECTIONS FOR MOTHER DEATH
			
			*===================================================================*
			*	If mother has died:												*
			*		1. Information should be missing on next rounds				*
			*		2. Age should be missing (was reported in R2 and R3) 		*
			*		3. Year of death was obtained in R4, transfer year info		*
			*			on round where death was reported						*
			*===================================================================*			

			replace momlive=3 if momlive[_n-1]==3 & childid==childid[_n-1]
			recode momage (*=.) if momlive==3
			bys childid: egen diedround=min(round) if momlive==3
			bys childid: egen yrdied=min(momyrdied) if momlive==3
			replace momyrdied=yrdied
			recode momage momedu momyrdied momlive (*=.) if diedround!=round & diedround!=.
			recode momage momedu (*=.) if momlive==3
			keep childid round mom*
			
	* LABELS
			lab var childid			"Child ID"
			lab var round	 		"Round of survey"				
			label var momage 		"Mother's age"
			label var momid  		"Mother's id in roster"
			label var momcantread 	"Mother cannot read"
			label var momedu		"Mother's level of education"
			label var momlive		"Location of YL child's mother"
			label var momyrdied		"Year when mother has died"

			label define educ  0 "None" ///
							   1 "Grade 1" ///
							   2 "Grade 2" ///
							   3 "Grade 3" ///
							   4 "Grade 4" ///
							   5 "Grade 5" ///
							   6 "Grade 6" ///
							   7 "Grade 7" ///
							   8 "Grade 8" ///
							   9 "Grade 9" ///
							  10 "Grade 10" ///
							  11 "Grade 11" ///
							  13 "Technical, pedagogical, CETPRO (incomplete)" ///
							  14 "Technical, pedagogical, CETPRO (complete)" ///
							  15 "University (incomplete)" ///
							  16 "University (complete)" ///
							  28 "Adult literacy" ///
							  30 "Other"
			label values momedu educ
			label define yesno 1 "yes" 0 "no"
			label values momcantread yesno

			label define momlive 1 "Lives in the household" 2 "Does not live in household" 3 "Has died" 
			label values momlive momlive	
			sort childid round
			tempfile    mom
			save       `mom'

	
***** CAREGIVER CHARACTERISTICS *****

	*==========================================================================*
	*	Note:																   *
	*		1. Caregiver literacy was collected in rounds 1 and 2 only.		   *
	*		2. No caregiver was identified for the older cohort since round 4.  *
	*		3. In identifying relationship of caregiver to child,			   *
	*			"2 = non-biological parent" includes step-parent, adoptive	   *
	*					parent, and foster parent.							   *
	*			"5 = sibling" includes step-siblings, half-siblings,		   *
	*					adoptive siblings, and foster siblings.				   *
	*==========================================================================*	

	* ROUND 1
			use childid careid literspc head using "$r1yc\pechildlevel1yrold.dta", clear
			merge 1:m childid using "$r1yc\pesubsec2householdroster1.dta", nogen keepusing(childid id age sex relate yrschool)
			tempfile careyc1
			save `careyc1'
			use childid careid literspc head using "$r1oc\pechildlevel8yrold.dta", clear
			merge 1:m childid using "$r1oc\pesubsec2householdroster8.dta", nogen keepusing(childid id age sex relate yrschool)
			qui append using `careyc1'
			keep if id==careid
			recode literspc head relate (88 99=.)
			rename age careage
			rename sex caresex
			rename head carehead
			rename yrschool caredu
			recode caredu (35=13) (36=14) (37=15) (38=16) (31 32 33 34 88 99=.)
			rename relate carerel
			recode carerel (1=1) (2=2) (3=3) (4=4) (5 10 12=5) (6 8 9 11=6) (7=7)	
			g carecantread=literspc==3 if literspc!=.
			keep childid care*
			g round=1
			tempfile care1
			save `care1'

			* Correct relationship of caregiver to child if carerel=13 using round 2 data
			use childid id relate using "$r2yc\pesubhouseholdmember5.dta", clear
			qui append using "$r2oc\pesubhouseholdmember12.dta", keep(childid id relate)
			merge m:1 childid using `care1'
			keep if careid==id | _merge==2
			replace carerel=relate if carerel==13
			keep childid round care*
			tempfile care1
			save `care1'								
			
	* ROUND 2
			use childid careid carelits headid mumid dadid ladder farlad using "$r2yc\pechildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\pesubhouseholdmember5.dta", nogen keepusing(childid id age memsex relate grade chgrade)
			tempfile careyc2
			save `careyc2'
			use childid careid carelits headid mumid dadid ladder farlad using "$r2oc\pechildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc\pesubhouseholdmember12.dta", nogen keepusing(childid id age memsex relate grade chgrade)
			qui append using `careyc2'
			keep if id==careid
			recode relate grade chgrade carelits (77 79 88 99=.)
			rename age careage
			rename memsex caresex
			g carehead=1 if headid==careid & careid !=.
			replace carehead=2 if mumid==careid & headid==dadid & careid !=.
			recode  carehead (.=3) if careid !=.	
			rename relate carerel
			recode carerel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/22=7)
			g carecantread=carelits==3 if carelits!=.	
			rename grade caredu
			replace caredu=chgrade if missing(caredu)
			recode caredu (17=28) (18=30) (77 79 88 99=.)
			rename ladder careladder
			rename farlad careldr4yrs
			keep childid care*
			drop carelits
			g round=2
			tempfile care2
			save `care2'												

	* ROUND 3 (no info on education of members aged 18 above)
			use childid pridadr3 primumr3 mumidr3 dadidr3 careidr3 headid ladderr3 farladr3 using "$r3yc/pe_yc_householdlevel.dta", clear	
			merge 1:m childid using "$r3yc/pe_yc_householdmemberlevel.dta", nogen keepusing(childid id age memsex relate grader3)
			tempfile careyc3
			save `careyc3'
			use childid pridadr3 primumr3 mumidr3 dadidr3 careidr3 headid using "$r3oc/pe_oc_householdlevel.dta", clear
			merge 1:m childid using "$r3oc/pe_oc_householdmemberlevel.dta", nogen keepusing(childid id age memsex relate grader3)
			qui append using `careyc3'
			g careid=mumidr3 if primumr3==1
			replace careid=dadidr3 if pridadr3==1 & missing(careid)
			replace careid=careidr3 if missing(careid)
			recode careid (88 90 =.)				
			keep if id==careid
			rename age careage
			rename memsex caresex
			g carehead=1 if headid==careid & careid !=.
			replace carehead=2 if mumidr3==careid & headid==dadidr3 & careid !=.
			recode  carehead (.=3) if careid !=.	 		
			rename relate carerel
			recode carerel (1=1) (2 3 4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27=6) (20/23=7) (25=8) (26=9)
			rename grader3 caredu
			recode caredu (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename ladderr3 careladder
			rename farladr3 careldr4yrs
			keep childid care*
			drop careidr3
			g round=3
			tempfile care3
			save `care3'															

	* ROUND 4 (YC ONLY)			
			use CHILDCODE MEMIDR4 RELATER4 MEMSEXR4 MEMAGER4 GRADER4 RELHHR4 CAREGVR4 using "$r4yc3\PE_R4_YCHH_HouseholdRosterR4.dta", clear
			keep if CAREGVR4==1
			duplicates drop CHILDCODE, force
			merge 1:1 CHILDCODE using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", nogen keepusing(CHILDCODE LADDERR4 FARLADR4)
			recode LADDERR4 FARLADR4 (77 79 88=.)
			g HEADIDR4=RELHHR4==1 if RELHHR4!=.
			rename MEMIDR4 careid
			rename MEMSEXR4 caresex
			rename MEMAGER4 careage
			rename GRADER4 caredu
			recode caredu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			g carehead=1 if RELHHR4==1 & careid !=.
			replace carehead=2 if RELHHR4==2 & careid !=.
			recode  carehead (.=3) if careid !=.
			rename RELATER4 carerel
			recode carerel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			rename LADDERR4 careladder
			rename FARLADR4 careldr4yrs
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep childid care*
			g round=4
			tempfile care4
			save `care4'												
									
	* ROUND 5 (YC ONLY)			
			use CHILDCODE MEMIDR5 RELATER5 MEMSEXR5 MEMAGER5 GRADER5 RELHHR5 CAREGVR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			keep if CAREGVR5==1
			duplicates drop CHILDCODE, force
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", nogen keepusing(CHILDCODE LADDERR5 FARLADR5)
			recode MEMAGER5 GRADER5 LADDERR5 FARLADR5 (-88 -77 77 79 88=.)
			g HEADIDR5=RELHHR5==1 if RELHHR5!=.
			rename MEMIDR5 careid
			rename MEMSEXR5 caresex
			rename MEMAGER5 careage
			rename GRADER5 caredu
			recode caredu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			g carehead=1 if RELHHR5==1 & careid !=.
			replace carehead=2 if RELHHR5==2 & careid !=.
			recode  carehead (.=3) if careid !=.
			rename RELATER5 carerel
			recode carerel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			rename LADDERR5 careladder
			rename FARLADR5 careldr4yrs
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			keep childid care*
			g round=5
			tempfile care5
			save `care5'					
									
	* MERGE
			use `care1', clear
			forvalues i=2/5 {
				qui append using `care`i''
				}
	
	* LABELS
			lab var childid			"Child ID"
			lab var round	 		"Round of survey"				
			label var caresex 		"Caregiver's sex"
			label var careage 		"Caregiver's age"
			label var careid  		"Caregiver's id in roster"
			label var carecantread 	"Caregiver cannot read"
			label var carerel 		"Caregiver's relationship to child"
			label var carehead 		"Caregiver's relationship to househod head"
			label var caredu		"Caregiver's level of education"
			label var careladder 	"Caregiver's Ladder - subjective well-being"			
			label var careldr4yrs  	"Caregiver's Ladder (4 years from now) - subjective well-being"
			
			label drop _all
			label define carerel 	1 "Biological parent" 2 "Non-biological parent" 3 "Grandparents" ///
									4 "Uncle/aunt" 5 "Sibling" 6 "Other-relative" 7 "Other-nonrelative" ///
									8 "Partner/spouse of YL child" 9 "Father-in-law/mother-in-law"
			label values carerel carerel

			label define carehead 1 "Caregiver is household head" 2 "Caregiver is partner of household head" 3 "Other" 
			label values carehead carehead 

			label define caresex 1 "male" 2 "female"
			label values caresex caresex
			label define yesno 1 "yes" 0 "no"
			label values carecantread yesno

			label define educ  0 "None" ///
							   1 "Grade 1" ///
							   2 "Grade 2" ///
							   3 "Grade 3" ///
							   4 "Grade 4" ///
							   5 "Grade 5" ///
							   6 "Grade 6" ///
							   7 "Grade 7" ///
							   8 "Grade 8" ///
							   9 "Grade 9" ///
							  10 "Grade 10" ///
							  11 "Grade 11" ///
							  13 "Technical, pedagogical, CETPRO (incomplete)" ///
							  14 "Technical, pedagogical, CETPRO (complete)" ///
							  15 "University (incomplete)" ///
							  16 "University (complete)" ///
							  28 "Adult literacy" ///
							  30 "Other"
			label values caredu educ

			sort childid round
			tempfile    care
			save       `care'
			
	* CORRECTIONS FOR CAREGIVER EDUCATION
			
		*===================================================================*
		*	Steps in correcting education across rounds (if same caregiver):*
		*		1. If caregiver is biological parent, copy corrected 		*
		*			grade information from previous section above.			*
		*		2. If missing, copy succeeding nonmissing round.			*
		*		3. If still missing, copy preceeding nonmissing round.		*
		*		4. If greater than succeeding round, replace.				*
		*			Use info from succeeding round.							*
		*===================================================================*
			
			* Step 1: 	
			merge 1:1 childid round using `dad', nogen
			merge 1:1 childid round using `mom', nogen
			replace caredu=dadedu if caresex==1 & carerel==1
			replace caredu=momedu if caresex==2 & carerel==1
			drop dadid-momyrdied
		
			sort childid round
			keep childid careid caredu round
			g inround=1
			reshape wide caredu inround, i(childid careid) j(round)
		
			* Step 2:
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace caredu`r'=caredu`j' if missing(caredu`r')
				local r=`r'-1
				}
		
			* Step 3:
			forvalues i=1/4 {
				local j=`i'+1
				replace caredu`j'=caredu`i' if missing(caredu`j')
				}
				
			* Step 4:	
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace caredu`r'=caredu`j' if caredu`r'>caredu`j' 
				local r=`r'-1
				}
			reshape long
			label drop I_HoueholdItems
			keep if inround==1
			drop inround
			rename caredu careducorr
			
			merge 1:1 childid round using `care', nogen
			drop caredu
			rename careducorr caredu

			tempfile    care
			save       `care'
									

/*-----------------------------------------------------------------------------*
							HOUSEHOLD CHARACTERISTICS
------------------------------------------------------------------------------*/


****************************** HOUSEHOLD WEALTH ********************************

* WEALTH INDEX AND CONSTITUENT INDICES

	* ROUND 1
		
			use childid hq-wi using "$r1yc/PEChildLevel1YrOld.dta", clear
			qui append using "$r1oc/PEChildLevel8YrOld.dta", keep(childid hq-wi)
			g round=1
			tempfile    wealth1
			save       `wealth1'
			
	* ROUND 2
	
			use childid hq-wi using "$r2yc/PEChildLevel5YrOld.dta", clear
			qui append using "$r2oc/PEChildLevel12YrOld.dta", keep(childid hq-wi)
			g round=2
			tempfile    wealth2
			save       `wealth2'			

	* ROUND 3
	
			use childid hq-wi using "$r3yc/pe_yc_householdlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdlevel.dta", keep(childid hq-wi)
			g round=3
			tempfile    wealth3
			save       `wealth3'			
	
	* ROUND 4	
		
			use CHILDCODE elecq-wi using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_OlderHousehold.dta", keep(CHILDCODE elecq-wi)
			gen childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE
			g round=4
			keep childid hq cd sv wi drwaterq toiletq cookingq elecq 
			gen round=4
			tempfile   wealth4
			save      `wealth4'
	
	* ROUND 5
			use CHILDCODE elecq_r5-wi_r5 using "$r5wealth\Wealth index YC_21may.dta", clear		
			qui append using "$r5wealth\Wealth index OC_21may.dta", keep(CHILDCODE elecq_r5-wi_r5)
			rename *_r5 *
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE
			g round=5
			tempfile wealth5
			save `wealth5'			

	* MERGE
			
			use `wealth1', clear
			forvalues i=2/5 {													
				qui append using `wealth`i''
				}	
			
	* LABELS

			label var childid	"Child ID"
			label var round	 	"Round of survey"
			label var wi 		"Wealth index"										
			label var hq 		"Housing quality index"
			label var sv 		"Access to services index"
			label var cd 		"Consumer durables index"
			label var drwaterq 	"Access to safe drinking water"
			label var toiletq  	"Access to sanitation"
			label var elecq     "Access to electricity"
			label var cookingq  "Access to adequate fuels for cooking"

			label define yesno 0 "no" 1 "yes"
			label values drwaterq toiletq elecq cookingq yesno
			
			order childid round wi hq sv cd drwaterq toiletq elecq cookingq
			tempfile   wealth
			save      `wealth'

		
***** LIVESTOCK OWNERSHIP *****

	* ROUND 1                                       
			use childid animals anyaim* aniown* using "$r1yc/pechildlevel1yrold.dta", clear     
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid animals anyaim* aniown*)

			* Four groups
			recode aniown* (.=0)
			gen aniany  =animals==1
			gen animilk =aniown2
			gen anidrau =aniown1
			gen anirumi =aniown3+aniown4
			gen anispec =aniown6
			gen round=1
			drop animals anyaim* aniown* 
			tempfile    livestock1
			save       `livestock1'

	* ROUND 2 
			use childid animals anyaim* numaim* using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid animals anyaim* numaim*)
			
			* FOUR GROUPS
			recode numaim* (. -88 -77=0)
			gen aniany  =animals==1
			gen animilk =numaim01+numaim02
			gen anidrau =numaim06+numaim09
			gen anirumi =numaim13+numaim14+numaim15+numaim16+numaim17
			gen anispec =numaim51+numaim52+numaim53+numaim54+numaim55+numaim56+numaim57+numaim58

			* EACH TYPE OF ANIMAL
			gen anicowm=numaim01
			gen anicowt=numaim02
			gen anioxen=numaim06
			gen anidonk=numaim09
			gen anishee=numaim13
			gen anigoat=numaim14
			gen anipigs=numaim15
			gen anipoul=numaim16
			gen anirabb=numaim17
			gen anillam=numaim51
			gen aniguin=numaim52
			gen anisnai=numaim53
			gen anibeeh=numaim54
			gen anifish=numaim55
			gen anishri=numaim56
			gen anifshr=numaim57
			gen aniothr=numaim58
			
			gen round=2 
			drop animals anyaim* numaim* 
			tempfile    livestock2
			save       `livestock2'

	* ROUND 3
			use childid animalr3 ayanr3* nmamr3* using "$r3yc\pe_yc_householdlevel.dta", clear
			qui append using "$r3oc\pe_oc_householdlevel.dta", keep(childid animalr3 ayanr3* nmamr3*)

			* FOUR GROUPS
			recode nmamr3* (. -99 -88 -77=0)
			gen aniany  =animalr3==1
			gen animilk =nmamr301+ nmamr302
			gen anidrau =nmamr306+ nmamr309
			gen anirumi =nmamr313+ nmamr314+ nmamr315+ nmamr316+ nmamr317
			gen anispec =nmamr351+ nmamr352 + nmamr353+ nmamr354 + nmamr355+ nmamr356 + nmamr357+ nmamr358

			* EACH TYPE OF ANIMAL
			gen anicowm=nmamr301
			gen anicowt=nmamr302
			gen anioxen=nmamr306
			gen anidonk=nmamr309
			gen anishee=nmamr313
			gen anigoat=nmamr314
			gen anipigs=nmamr315
			gen anipoul=nmamr316
			gen anirabb=nmamr317
			gen anillam=nmamr351
			gen aniguin=nmamr352
			gen anisnai=nmamr353
			gen anibeeh=nmamr354
			gen anifish=nmamr355
			gen anishri=nmamr356
			gen anifshr=nmamr357
			gen aniothr=nmamr358
			
			gen round=3 
			drop animalr3 ayanr3* nmamr3* 
			tempfile    livestock3
			save       `livestock3'

	* ROUND 4
			use AYANR4 NMAMR4 CHILDCODE LVSKIDR4 using "$r4yc3\PE_R4_YCHH_LivelihoodsLivestock.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_LivelihoodsLivestock.dta", keep(AYANR4 NMAMR4 CHILDCODE LVSKIDR4)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop  CHILDCODE
			reshape wide AYANR4  NMAMR4, i(childid) j(LVSKIDR4)
			recode AYANR4* NMAMR* (.=0)
			rename *, lower 
			order childid ayanr4* nmamr4* 
			gen aniany=ayanr41==1
			foreach var of varlist ayanr42 - ayanr458{ 
				replace aniany=1 if `var'==1
				}	
			
			* FOUR GROUPS			
			recode nmamr4* (. -99 -88 -77=0)
			gen animilk =nmamr41 	+ nmamr42 	
			gen anidrau =nmamr46 	+ nmamr49 	
			gen anirumi =nmamr413 	+ nmamr414 	+ nmamr415 	+ nmamr416 + nmamr417
			gen anispec =nmamr451 	+ nmamr452 + nmamr453 + nmamr454 + nmamr455 + nmamr456 + nmamr457 + nmamr458

			* EACH TYPE OF ANIMAL
			gen anicowm=nmamr41
			gen anicowt=nmamr42
			gen anioxen=nmamr46
			gen anidonk=nmamr49
			gen anishee=nmamr413
			gen anigoat=nmamr414
			gen anipigs=nmamr415
			gen anipoul=nmamr416
			gen anirabb=nmamr417
			gen anillam=nmamr451
			gen aniguin=nmamr452
			gen anisnai=nmamr453
			gen anibeeh=nmamr454
			gen anifish=nmamr455
			gen anishri=nmamr456
			gen anifshr=nmamr457
			gen aniothr=nmamr458
			gen round=4

			drop ayanr4* nmamr4* 
			tempfile    livestock4
			save       `livestock4' 

	* ROUND 5 (Livestock data only for YC)
			use AYANR5 NMAMR5 CHILDCODE LVSKIDR5 using "$r5ychh\LivelihoodsLivestock.dta", clear
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop  CHILDCODE
			rename *, lower 
			reshape wide ayanr5 nmamr5, i(childid) j(lvskidr5)
			recode ayanr5* nmamr5* (.=0)
			order childid ayanr5* nmamr5* 
			gen aniany=0
			foreach var of varlist ayanr52-ayanr558{ 
				replace aniany=1 if `var'==1
				}	
		
			* FOUR GROUPS	
			recode nmamr5* (. -99 -88 -77=0)
			gen animilk =nmamr51 	+ nmamr52 	
			gen anidrau =nmamr56 	+ nmamr59 	
			gen anirumi =nmamr513 	+ nmamr514 	+ nmamr515 	+ nmamr516 + nmamr517
			gen anispec =nmamr551 	+ nmamr552 + nmamr553 + nmamr554 + nmamr555 + nmamr556 + nmamr557 + nmamr558

			* EACH TYPE OF ANIMAL
			gen anicowm=nmamr51
			gen anicowt=nmamr52
			gen anioxen=nmamr56
			gen anidonk=nmamr59
			gen anishee=nmamr513
			gen anigoat=nmamr514
			gen anipigs=nmamr515
			gen anipoul=nmamr516
			gen anirabb=nmamr517
			gen anillam=nmamr551
			gen aniguin=nmamr552
			gen anisnai=nmamr553
			gen anibeeh=nmamr554
			gen anifish=nmamr555
			gen anishri=nmamr556
			gen anifshr=nmamr557
			gen aniothr=nmamr558
			gen round=5

			drop ayanr5* nmamr5* 
			tempfile    livestock5
			save       `livestock5' 
			
	* MERGE
			use `livestock1', clear
			forvalues i=2/5 {
				qui append using `livestock`i''
				}
			
	* LABELS
			label var aniany   "Household owned any livestock in the past 12 months"
			label var animilk  "Number of MILK animals in the household"
			label var anidrau  "Number of DRAUGHT animals owned by the hh"
			label var anirumi  "Number of SMALL RUMIANTS animals owned by the hh"
			label var anispec "Number of OTHER animals (specific to country)"	
			label var anicowm "Number of (modern) cows"
			label var anicowt "Number or (traditional) cows"
			label var anioxen "Number of oxen"
			label var anidonk "Number of donkeys, horses, mules"
			label var anishee "Number of sheep"
			label var anigoat "Number of goats"
			label var anipigs "Number of pigs"
			label var anipoul "Number of poultry/birds"		
			label var anirabb "Number of rabbits"
			label var anillam "Number of llamas"
			label var aniguin "Number of guinea pigs"
			label var anisnai "Number of snails"
			label var anibeeh "Number of beehives"
			label var anifish "Number of fish ponds"
			label var anishri "Number of marine shrimp tanks"
			label var anifshr "Number of fresh water shrimp tanks"
			label var aniothr "Number of other animals"
			label var childid "Child ID"
			label var round "Round of survey"
			tempfile   livestock
			save      `livestock'
	

***** LAND AND HOUSE OWNERSHIP *****

	* ROUND 1
			use childid ownhouse using "$r1yc/pechildlevel1yrold.dta", clear               
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid ownhouse)	
			g ownlandhse=ownhouse==1 if ownhouse!=.
			keep childid ownlandhse 
			g round=1
			tempfile  land1
			save     `land1'
			
	* ROUND 2
			use childid ownhouse using "$r2yc\pechildlevel5yrold.dta", clear 
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid ownhouse)
			recode ownhouse (77 79 88 99=.)
			g round=2
			tempfile  land2
			save     `land2'			
			
	* ROUND 3
			use childid ownhser3 using "$r3yc\pe_yc_householdlevel.dta", clear
			qui append using "$r3oc\pe_oc_householdlevel.dta", keep(childid ownhser3)
			recode ownhser3 (77 88 99=.)
			rename ownhser3 ownhouse
			g round=3
			tempfile land3
			save `land3'
			
	* ROUND 4
			use CHILDCODE LANDIDR4 NAMUSER4 using "$r4yc3\PE_R4_YCHH_LandType.dta", clear
			recode NAMUSER4 (77 79 88=.)
			g accomm=LANDIDR4==1 if NAMUSER4>=1 & NAMUSER4<=18
			bys CHILDCODE: egen ownlandhse=max(accomm)
			keep CHILDCODE ownlandhse 
			duplicates drop
			tempfile land4
			save `land4'
			
			use CHILDCODE OWNHSER4 using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_OlderHousehold.dta", keep(CHILDCODE OWNHSER4)
			rename OWNHSER4 ownhouse
			merge 1:1 CHILDCODE using `land4', nogen
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE
			g round=4
			tempfile land4
			save `land4'								
			
	* ROUND 5
			use CHILDCODE LANDIDR5 NAMUSER5 using "$r5ychh\LandType.dta", clear
			recode NAMUSER5 (77 79 88=.)
			g accomm=LANDIDR5==1 if NAMUSER5>=1 & NAMUSER5<=18
			bys CHILDCODE: egen ownlandhse=max(accomm)
			keep CHILDCODE ownlandhse 
			duplicates drop
			tempfile land5
			save `land5'
			
			use CHILDCODE OWNHSER5 using "$r5ychh\YoungerHousehold.dta", clear
			qui append using "$r5ochh\OlderHousehold.dta", keep(CHILDCODE OWNHSER5)
			recode OWNHSER5 (77=.)
			rename OWNHSER5 ownhouse
			merge 1:1 CHILDCODE using `land5', nogen
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE
			g round=5
			tempfile land5
			save `land5'						
			
	* MERGE
			use `land1', clear
			forvalues i=2/5 {
				qui append using `land`i''
				}	

	* LABEL
			lab var ownlandhse "Household owns land where house is on"
			lab var ownhouse "Household own the house" 
			label define yesno 1 "yes" 0 "no"
			label values ownlandhse ownhouse yesno	
			sort childid round
			order childid round
			tempfile   land
			save      `land'			

			
***** PUBLIC PROGRAMMES *****

	* ROUND 1 (NO DATA)
	
	* ROUND 2 (NO DATA)
	
	* ROUND 3
			use childid hrdjntr3 appjntr3 chvsisr3  using "$r3yc\pe_yc_householdlevel.dta", clear
			qui append using "$r3oc\pe_oc_householdlevel.dta", keep(childid hrdjntr3 appjntr3 chvsisr3)
			recode hrdjntr3 appjntr3 chvsisr3 (77 88 99=.)
			recode appjntr3 (.=0) if hrdjntr3==0
			gen juntos=appjntr3==1 if appjntr3!=.
			rename chvsisr3 sisgrat_yl
			drop appjntr3 hrdjntr3
			g round=3
			tempfile program3
			save `program3'
	
	* ROUND 4
			use CHILDCODE HRDJNTR4 APPJNTR4 HRDBONR4 AFFBONR4 using "$r4oc3\PE_R4_OCHH_OlderHousehold.dta", clear
			merge 1:1 CHILDCODE using "$r4oc1\PE_R4_OCCH_OlderChild.dta", keepusing(CHILDCODE REGSISR4 PARTSISR4 HLTHINS1R4-HLTHINSR4 JOVHRDR4 JOVAPPR4 BECA*) nogen
			recode APPJNTR4 HRDBONR4 AFFBONR4 REGSISR4 PARTSISR4 HLTHINS1R4-HLTHINSR4 JOVHRDR4 JOVAPPR4 BECA* (77 88 99=.) 
			rename REGSISR4 CHVSISR4
			rename PARTSISR4 MINSAR4
			egen healthins=rowtotal(HLTHINS1R4-HLTHINSR4) if HLTHINS1R4!=.
			g insur_yl=healthins>=1 if healthins!=.
			drop HLTHINS* healthins
			qui append using "$r4yc3\PE_R4_YCHH_YoungerHousehold.dta", keep(CHILDCODE HRDJNTR4 APPJNTR4 HRDBONR4 AFFBONR4 CHVSISR4 MINSAR4 ESSLUDR4-INSOTHR4)
			recode APPJNTR4 HRDBONR4 AFFBONR4 CHVSISR4 MINSAR4 ESSLUDR4-INSOTHR4 (77 88 99=.) 
			recode APPJNTR4 (.=0) if HRDJNTR4==0
			recode AFFBONR4 (.=0) if HRDBONR4==0
			g juntos=APPJNTR4==1 if APPJNTR4!=.
			rename AFFBONR4 bonograt
			rename CHVSISR4 sisgrat_yl
			rename MINSAR4 minsa_yl 
			egen healthins=rowtotal(ESSLUDR4-INSOTHR4) if ESSLUDR4!=.
			replace insur_yl=1 if healthins>=1 & missing(insur_yl)
			replace insur_yl=0 if missing(insur_yl) & healthins!=.
			rename BECABENR4 beca_yl
			recode beca_yl (.=0) if BECAHRDR4==0 | BECAAPPR4==0
			g projoven_yl=1 if JOVAPPR4==1 | JOVAPPR4==3
			recode projoven_yl (.=0) if JOVHRDR4==0
			replace projoven_yl=0 if missing(projoven_yl) & JOVAPPR4!=.
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE HRDJNTR4 APPJNTR4 HRDBONR4 BECAHRDR4 BECAAPPR4 JOVHRDR4 JOVAPPR4 ESSLUDR4-INSOTHR4 healthins		
			g round=4
			tempfile program4
			save `program4'
			
	* ROUND 5		
			use CHILDCODE HRDJNTR5 APPJNTR5 HRDBONR5 AFFBONR5 using "$r5ochh\OlderHousehold.dta", clear
			merge 1:1 CHILDCODE using "$r5occh\OlderChild.dta", keepusing(CHILDCODE CHVSISR5 MINSAR5 ESSLUDR5-INSOTHR5 JOVHRDR5 JOVAPPR5) nogen
			qui append using "$r5ychh\YoungerHousehold.dta", keep(CHILDCODE HRDJNTR5 APPJNTR5 HRDBONR5 AFFBONR5 CHVSISR5 MINSAR5 ESSLUDR5-INSOTHR5)
			recode APPJNTR5 HRDBONR5 AFFBONR5 CHVSISR5 MINSAR5 ESSLUDR5-INSOTHR5 JOVHRDR5 JOVAPPR5 (77 88 99=.) 
			recode APPJNTR5 (.=0) if HRDJNTR5==0
			recode AFFBONR5 (.=0) if HRDBONR5==0
			recode MINSAR5 (.=0) if CHVSISR5==1
			g juntos=APPJNTR5==1 if APPJNTR5!=.
			rename AFFBONR5 bonograt
			rename CHVSISR5 sisgrat_yl
			rename MINSAR5 minsa_yl			
			egen healthins=rowtotal(ESSLUDR5-INSOTHR5) if ESSLUDR5!=.			
			g insur_yl=healthins>=1 if healthins!=.			
			g projoven_yl=1 if JOVAPPR5==1 | JOVAPPR5==3
			recode projoven_yl (.=0) if JOVHRDR5==0
			replace projoven_yl=0 if missing(projoven_yl) & JOVAPPR5!=.
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE HRDJNTR5 APPJNTR5 HRDBONR5 ESSLUDR5-INSOTHR5 JOVHRDR5 JOVAPPR5 healthins
			g round=5
			tempfile program5
			save `program5'			
			
	* MERGE
			use `program3', clear
			forvalues i=4/5 {
				qui append using `program`i''
				}	

	* LABEL
	
			lab var juntos		"At least one member is a current beneficiary of Juntos"
			lab var bonograt	"At least one member receive transfers from Bono de Gratitud/Pension 65 programme"
			lab var sisgrat_yl	"YL child is registered in SIS gratuito" 
			lab var minsa_yl	"YL child is registered in partial SIS/ SIS independiente (MINSA)"
			lab var insur_yl	"YL child has health insurance"
			lab var beca_yl		"YL child is a beneficiary of the Beca 18 programme"
			lab var projoven_yl	"YL child has received training under the ProJoven/ Jovenes a la Obra programme"
			label define yesno 1 "yes" 0 "no"
			label values juntos bonograt sisgrat_yl minsa_yl insur_yl beca_yl projoven_yl yesno	
			sort childid round
			order childid round juntos bonograt sisgrat_yl minsa_yl insur_yl beca_yl projoven_yl
			tempfile   program
			save      `program'				
	

***** CREDIT AND FOOD SECURITY **** 			
			
	* ROUND 1 (NO DATA)
	
	* ROUND 2 
			use childid peloan pegtloan pe4c14 using "$r2yc\pechildlevel5yrold.dta", clear
			qui append using "$r2oc\pechildlevel12yrold.dta", keep(childid peloan pegtloan pe4c14)	
			recode peloan pegtloan pe4c14 (77 79 88 99=.)
			recode pegtloan (.=0) if peloan==0
			rename pe4c14 foodsec
			rename pegtloan credit
			g round=2
			drop peloan
			tempfile foodsec2
			save `foodsec2'
		
	* ROUND 3
			use childid obtnlnr3 getlnr3 fdhomer3 using "$r3yc/pe_yc_householdlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdlevel.dta", keep(childid obtnlnr3 getlnr3 fdhomer3)
			recode obtnlnr3 getlnr3 fdhomer3 (77 88 79 99=.)
			recode getlnr3 (.=0) if obtnlnr3==0
			rename fdhomer3 foodsec
			rename getlnr3 credit
			g round=3
			drop obtnlnr3
			tempfile foodsec3
			save `foodsec3'
			
	* ROUND 4 (YC ONLY)
			use CHILDCODE OBTNLNR4 GETLNR4 FDHOMER4 using "$r4yc3/PE_R4_YCHH_YoungerHousehold.dta", clear
			recode OBTNLNR4 GETLNR4 FDHOMER4(77 79 88=.)
			recode GETLNR4 (.=0) if OBTNLNR4==0
			rename FDHOMER4 foodsec
			rename GETLNR4 credit
			g round=4
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE OBTNLNR4
			tempfile foodsec4
			save `foodsec4'
			
	* ROUND 5 (YC ONLY)
			use CHILDCODE OBTNLNR5 GETLNR5 FDHOMER5 using "$r5ychh/YoungerHousehold.dta", clear
			recode OBTNLNR5 GETLNR5 FDHOMER5(77 79 88=.)
			recode GETLNR5 (.=0) if OBTNLNR5==0
			rename FDHOMER5 foodsec
			rename GETLNR5 credit
			g round=5
			g childid="PE"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE OBTNLNR5
			tempfile foodsec5
			save `foodsec5'	
	
	* MERGE
			use `foodsec2', clear
			forvalues i=3/5 {
				qui append using `foodsec`i''
				}	

	* LABEL
			lab var credit	"Household has obtained loan or credit in the last 12 months"
			lab var foodsec	"Household's food situation in the last 12 months"
			lab define yesno 1 "yes" 0 "no"
			lab values credit yesno
			lab define foodsec ///
						1 "we always eat enough of what we want" ///
						2 "we eat enough but not always what we would like" ///
						3 "we sometimes do not eat enough" ///
						4 "we frequently do not eat enough" 			
			lab values foodsec foodsec
			sort childid round
			order childid round
			tempfile   foodsec
			save      `foodsec'							


***** HOUSEHOLD HEAD CHARACTERISTICS *****

	* ROUND 1
			use childid headid using "$r1yc/pechildlevel1yrold.dta", clear
			merge 1:m childid using "$r1yc\pesubsec2householdroster1.dta", nogen keepusing(childid id age sex relate yrschool)
			keep if id==headid
			tempfile headinfo1yc
			save `headinfo1yc'
			use childid headid using "$r1oc/pechildlevel8yrold.dta", clear
			merge 1:m childid using "$r1oc\pesubsec2householdroster8.dta", nogen keepusing(childid id age sex relate yrschool)
			qui append using `headinfo1yc'
			keep if id==headid
			recode relate yrschool (88 99=.)
			rename age headage
			rename sex headsex
			rename relate headrel
			recode headrel (1=1) (2=2) (3=3) (4=4) (5 10 12=5) (6 8 9 11=6) (7=7)	
			rename yrschool headedu
			recode headedu (35=13) (36=14) (37=15) (38=16) (31 32 33 34 88 99=.) 
			keep childid head*
			g round=1
			tempfile head1
			save `head1'

			* Correct relationship of head to child if headrel=13 using round 2 data
			use childid id relate using "$r2yc\pesubhouseholdmember5.dta", clear
			qui append using "$r2oc\pesubhouseholdmember12.dta", keep(childid id relate)
			merge m:1 childid using `head1'
			keep if headid==id | _merge==2
			replace headrel=relate if headrel==13
			keep childid round head*
			tempfile head1
			save `head1'					

	* ROUND 2
			use childid headid using "$r2yc\pechildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\pesubhouseholdmember5.dta", nogen keepusing(childid id memsex grade age relate)
			tempfile headinfo2yc
			save `headinfo2yc'
			use childid headid using "$r2oc/pechildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc\pesubhouseholdmember12.dta", nogen keepusing(childid id memsex age relate grade)
			qui append using `headinfo2yc'
			keep if headid==id
			recode relate grade (77 79 88 99=.)
			rename age headage
			rename memsex headsex
			rename relate headrel
			recode headrel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/22=7)
			rename grade headedu
			recode headedu (17=28) (18=30) (77 79 88 99=.) 
			keep childid head*
			g round=2
			tempfile head2
			save `head2'			

	* ROUND 3
			use childid headid using "$r3yc\pe_yc_householdlevel.dta", clear
			merge 1:m childid using "$r3yc\pe_yc_householdmemberlevel.dta", nogen keepusing(childid id memsex age relate grade)
			tempfile headinfo3yc
			save `headinfo3yc'
			use childid headid using "$r3oc\pe_oc_householdlevel.dta", clear
			merge 1:m childid using "$r3oc\pe_oc_householdmemberlevel.dta", nogen keepusing(childid id memsex age relate grade)
			qui append using `headinfo3yc'
			keep if headid==id
			rename age headage
			rename memsex headsex
			rename relate headrel
			recode headrel (1=1) (2 3 4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27=6) (20/23=7) (25=8) (26=9)
			rename grader3 headedu
			recode headedu (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			keep childid head*
			g round=3
			tempfile head3
			save `head3'			

	* ROUND 4
			use CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 RELHHR4 using "$r4yc3\PE_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3\PE_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 RELHHR4)
			recode MEMAGER4 (-88 -77=.)
			keep if RELHHR4==1
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			rename MEMSEXR4 headsex
			rename MEMIDR4 headid
			rename MEMAGER4 headage
			rename GRADER4 headedu
			recode headedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename RELATER4 headrel
			recode headrel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			keep childid head*
			g round=4
			tempfile  head4
			save     `head4'						
	
	* ROUND 5 (9 DUPLICATES. In cases where 2 heads are identified, use ID of head in round 4)
			use CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 RELHHR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRADER5 RELHHR5)
			recode MEMAGER5 (-88 -77=.)
			keep if RELHHR5==1
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			rename MEMSEXR5 headsex
			rename MEMIDR5 headid
			rename MEMAGER5 headage
			rename GRADER5 headedu
			recode headedu (21=13) (22=14) (17=28) (19=15) (18=30) (77 79 88 99=.) (20=0)
			rename RELATER5 headrel
			recode headrel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			keep childid head*
			drop if childid=="PE071048" & headid==2
			drop if childid=="PE081057" & headid==2
			drop if childid=="PE131008" & headid==0
			drop if childid=="PE148042" & headid==0
			drop if childid=="PE161048" & headid==18
			drop if childid=="PE161092" & headid==2
			drop if childid=="PE181006" & headid==2
			drop if childid=="PE181018" & headid==2
			drop if childid=="PE191054" & headid==0
			g round=5
			tempfile  head5
			save     `head5'						
					
	* MERGE
			use `head1', clear
			forvalues i=2/5 {
				qui append using `head`i''
				}
	
	* LABELS
			lab var childid			"Child ID"
			lab var round	 		"Round of survey"				
			label var headsex 		"Household head's sex"
			label var headage 		"Household head's age"
			label var headid  		"Household head's id in roster"
			label var headrel 		"Household head's relationship to YL child"
			label var headedu		"Household head's level of education"
			
			label drop _all
			label define headrel 	1 "Biological parent" 2 "Non-biological parent" 3 "Grandparent" ///
									4 "Uncle/aunt" 5 "Sibling" 6 "Other-relative" 7 "Other-nonrelative" ///
									8 "Partner/spouse of YL child" 9 "Father-in-law/mother-in-law" ///
									0 "YL child"
			label values headrel headrel			
			
			label define headsex 1 "male" 2 "female"
			label values headsex headsex
			
			label define educ  0 "None" ///
							   1 "Grade 1" ///
							   2 "Grade 2" ///
							   3 "Grade 3" ///
							   4 "Grade 4" ///
							   5 "Grade 5" ///
							   6 "Grade 6" ///
							   7 "Grade 7" ///
							   8 "Grade 8" ///
							   9 "Grade 9" ///
							  10 "Grade 10" ///
							  11 "Grade 11" ///
							  13 "Technical, pedagogical, CETPRO (incomplete)" ///
							  14 "Technical, pedagogical, CETPRO (complete)" ///
							  15 "University (incomplete)" ///
							  16 "University (complete)" ///
							  18 "Other" ///
							  28 "Adult literacy" ///
							  30 "Other"
			label values headedu educ

			sort childid round
			tempfile    head
			save       `head'

	* CORRECTIONS FOR HEAD EDUCATION
			
		*===================================================================*
		*	Steps in correcting education across rounds (if same caregiver):*
		*		1. If head is biological parent, copy corrected 			*
		*			grade information from previous section above.			*
		*		2. If missing, copy succeeding nonmissing round.			*
		*		3. If still missing, copy preceeding nonmissing round.		*
		*		4. If greater than succeeding round, replace.				*
		*			Use info from succeeding round.							*
		*===================================================================*
			
			* Step 1: 	
			merge 1:1 childid round using `dad', nogen
			merge 1:1 childid round using `mom', nogen
			replace headedu=dadedu if headsex==1 & headrel==1
			replace headedu=momedu if headsex==2 & headedu==1
			drop dadid-momyrdied
		
			sort childid round
			keep childid headid headedu round
			g inround=1
			reshape wide headedu inround, i(childid headid) j(round)
		
			* Step 2:
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace headedu`r'=headedu`j' if missing(headedu`r')
				local r=`r'-1
				}
		
			* Step 3:
			forvalues i=1/4 {
				local j=`i'+1
				replace headedu`j'=headedu`i' if missing(headedu`j')
				}
				
			* Step 4:	
			local r=4
			forvalues i=1/4 {
				local j=`r'+1
				replace headedu`r'=headedu`j' if headedu`r'>headedu`j' 
				local r=`r'-1
				}
			reshape long
			keep if inround==1
			drop inround
			rename headedu headeducorr
			
			merge 1:1 childid round using `head', nogen
			drop headedu
			rename headeducorr headedudu

			tempfile    head
			save       `head'
									

			
*************************** HOUSEHOLD COMPOSITION ******************************

* HOUSHEOLD SIZE

	* ROUND 1
		
			use childid hhsize using "$r1yc/pechildlevel1yrold.dta", clear
			qui append using "$r1oc/pechildlevel8yrold.dta", keep(childid hhsize)
			gen round=1
			tempfile    hhsize1
			save       `hhsize1'	
		
	* ROUND 2
		
			use childid hhsize using "$r2yc/pechildlevel5yrold.dta", clear
			qui append using "$r2oc/pechildlevel12yrold.dta", keep(childid hhsize)
			gen round=2
			tempfile    hhsize2
			save       `hhsize2'

	* ROUND 3
		
			use childid hhsize using "$r3yc/pe_yc_householdlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdlevel.dta", keep(childid hhsize)
			gen round=3
			tempfile    hhsize3
			save       `hhsize3'

	* ROUND 4
			use "$r4oc3\OC_hhsize.dta", clear
			qui append using "$r4yc3/PE_R4_YCHH_YoungerHousehold.dta", keep(CHILDCODE hhsize)
			replace childid="PE"+string(CHILDCODE, "%06.0f") if missing(childid)
			drop CHILDCODE
			gen round=4
			tempfile    hhsize4
			save       `hhsize4'
			
	* ROUND 5
			use CHILDCODE hhsize using "$r5wealth\Wealth index YC_21may.dta", clear			
			qui append using "$r5wealth\Wealth index OC_21may.dta", keep(CHILDCODE hhsize)   
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			gen round=5
			tempfile    hhsize5
			save       `hhsize5'	

	* MERGE
	
			use `hhsize1', clear
			forvalues i=2/5 {
				qui append using `hhsize`i''
				}
			tempfile    hhsize
			save       `hhsize'

* SEX AND AGE COMPOSITION(without YL child)

	* ROUND 1
			use childid id age sex using "$r1yc/pesubsec2householdroster1.dta", clear
			qui append using "$r1oc/pesubsec2householdroster8.dta", keep(childid id age sex)
			tempfile    roster1
			save       `roster1'
				
	* ROUND 2
			use childid id age memsex livhse using "$r2yc/pesubhouseholdmember5.dta", clear
			qui append using "$r2oc/pesubhouseholdmember12.dta", keep(childid id age memsex livhse)
			keep if livhse==1
			drop if id==0
			rename memsex sex
			tempfile    roster2
			save       `roster2'	

	* ROUND 3
			use childid id age memsex livhse using "$r3yc/pe_yc_householdmemberlevel.dta", clear
			qui append using "$r3oc/pe_oc_householdmemberlevel.dta", keep(childid id age memsex livhse)
			keep if livhse==1			
			drop if id==0
			rename memsex sex
			tempfile    roster3
			save       `roster3'
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMAGER4 MEMSEXR4 LIVHSER4 using "$r4yc3/PE_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3/PE_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMAGER4 MEMSEXR4 LIVHSER4)
			keep if LIVHSER4==1			
			drop if MEMIDR4==0
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			rename MEMIDR4 id
			rename MEMAGER4 age
			rename MEMSEXR4 sex		
			tempfile    roster4
			save       `roster4'				
	
	* ROUND 5
			use CHILDCODE MEMIDR5 MEMAGER5 MEMSEXR5 LIVHSER5 using "$r5ychh/HouseholdRosterR5.dta", clear
			qui append using "$r5ochh/HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMAGER5 MEMSEXR5 LIVHSER5)
			keep if LIVHSER5==1				
			drop if MEMIDR5==0
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			rename MEMIDR5 id
			rename MEMAGER5 age
			rename MEMSEXR5 sex		
			tempfile    roster5
			save       `roster5'							

	* GENERATE AGE COMPOSITION PER ROUND			
	
			forvalues i=1/5 {
				* Males 0-5
				use `roster`i'', clear
				gen age05=1     if age>=0  & age<=5
				gen male05=1    if sex==1 & age05==1
				collapse (sum) male05, by(childid)
				tempfile    male051
				save       `male051'

				* Males 6-12
				use `roster`i'', clear
				gen age612=1    if age>=6  & age<=12
				gen male612=1   if sex==1  & age612==1
				collapse (sum) male612, by(childid)
				tempfile    male6121
				save       `male6121'

				* Males 13-17
				use `roster`i'', clear
				gen age1317=1    if age>=13 & age<=17
				gen male1317=1   if sex==1  & age1317==1
				collapse (sum) male1317, by(childid)
				tempfile    male13171
				save       `male13171'

				* Males 18-60
				use `roster`i'', clear
				gen age1860=1    if age>=18 & age<=60
				gen male1860=1   if sex==1  & age1860==1
				collapse (sum) male1860, by(childid)
				tempfile    male18601
				save       `male18601'

				* Males 61+
				use `roster`i'', clear
				gen age61=1     if age>=61 
				gen male61=1    if sex==1  & age61==1
				replace male61=. if age==.
				collapse (sum) male61, by(childid)
				tempfile    male611
				save       `male611'

				* Females 0-5
				use `roster`i'', clear
				gen age05=1     if age>=0 & age<=5
				gen female05=1  if sex==2 & age05==1
				collapse (sum) female05, by(childid)
				tempfile    female051
				save       `female051'

				* Females 6-12
				use `roster`i'', clear
				gen age612=1    if age>=6  & age<=12
				gen female612=1 if sex==2  & age612==1
				collapse (sum) female612, by(childid)
				tempfile    female6121
				save       `female6121'

				* Females 13-17
				use `roster`i'', clear
				gen age1317=1      if age>=13 & age<=17
				gen female1317=1   if sex==2  & age1317==1
				collapse (sum) female1317, by(childid)
				tempfile    female13171
				save       `female13171'

				* Females 18-60
				use `roster`i'', clear
				gen age1860=1    if age>=18 & age<=60
				gen female1860=1   if sex==2  & age1860==1
				collapse (sum) female1860, by(childid)
				tempfile    female18601
				save       `female18601'

				* Females 61+
				use `roster`i'', clear
				gen age61=1     if age>=61 
				gen female61=1  if sex==2  & age61==1
				replace female61=. if age==.
				collapse (sum) female61, by(childid)
				tempfile    female611
				save       `female611'

			use `male051', clear
			merge childid using `male6121' `male13171' `male18601' `male611' ///
					`female051' `female6121' `female13171' `female18601' `female611', unique 
			drop _m*
			
			gen round=`i'
			tempfile   composition`i'
			save      `composition`i''
			}

	* MERGE
			use `composition1', clear
			forvalues i=2/5 {
				qui append using `composition`i''
				}
			merge 1:1 childid round using `hhsize', nogen
			
	* LABELS
			label var male05      "Number of males aged 0-5"
			label var male612     "Number of males aged 6-12"
			label var male1317    "Number of males aged 13-17"
			label var male1860    "Number of males aged 18-60"
			label var male61      "Number of males aged 61+"
			label var female05    "Number of females aged 0-5"
			label var female612   "Number of females aged 6-12"
			label var female1317  "Number of females aged 13-17"
			label var female1860  "Number of females aged 18-60"
			label var female61    "Number of females aged 61+"
			label var hhsize	  "Household hize"
			label var childid 	  "Child ID"
			label var round		  "Round of survey"
			tempfile   hhcomposition
			save      `hhcomposition'

			
****** HOUSEHOLD SHOCKS 

		* ROUND 1

			use childid badevent phychnge hhfood hhlstck hhcrps hhlstl hhcstl hhdeath hhjob hhill hhcrime hhdiv hhbirth edu hhmove hhoth using "$r1yc\pechildlevel1yrold.dta", clear
			tempfile  shock1yc
			save     `shock1yc'
			use childid badevent phychnge hhfood hhlstck hhcrps hhlstl hhcstl hhdeath hhjob hhill hhcrime hhdiv hhbirth edu hhmove hhoth using "$r1oc\pechildlevel8yrold.dta", clear
			append using `shock1yc'

			// NOTE. missing values correspond to household that said that they didn't have 'bad events' since bioligical mother was pregnant.

			gen shcrime1=.
			gen shcrime2=.
			gen shcrime3=hhcstl==1  
			gen shcrime4=hhlstl==1   
			gen shcrime5=.
			gen shcrime6=.
			gen shcrime8=hhcrime==1  

			gen shregul1=.
			gen shregul2=.
			gen shregul4=.
			gen shregul5=.
			gen shregul6=.

			gen shecon1=.
			gen shecon2=.
			gen shecon3= hhlstck==1 
			gen shecon4=.
			gen shecon5=hhjob==1    
			gen shecon6=.
			gen shecon7=.
			gen shecon8=.
			gen shecon9=.
			gen shecon10=.
			gen shecon11=.
			gen shecon12=.
			gen shecon14=hhfood==1   

			gen shenv1=.
			gen shenv2=.
			gen shenv3=.
			gen shenv4=.
			gen shenv5=.
			gen shenv6=hhcrps==1    
			gen shenv7=.
			gen shenv8=.
			gen shenv9=phychnge==1   
			gen shenv10=.
			gen shenv11=.
			gen shenv12=.

			gen shhouse1=.
			gen shhouse2=.
			gen shhouse3=.

			gen shfam1=.
			gen shfam2=.
			gen shfam3=.
			gen shfam4=.
			gen shfam5=.
			gen shfam6=.
			gen shfam7=hhdiv==1     
			gen shfam8=hhbirth==1   
			gen shfam9=edu==1       
			gen shfam10=.
			gen shfam12=hhdeath==1   
			gen shfam13=hhill==1     
			gen shfam14=hhmove==1    
			gen shfam15=.
			gen shfam16=.
			gen shfam17=.
			gen shfam18=.

			gen shother=hhoth==1
			
			keep childid sh*
			gen round=1
			tempfile shocks1
			save    `shocks1'
			
		*ROUND 2

			use childid event* using "$r2yc\pechildlevel5yrold.dta", clear  
			tempfile shocks2yc
			save    `shocks2yc'
			use childid event* using "$r2oc\pechildlevel12yrold.dta", clear  
			qui append using `shocks2yc'

			gen shcrime1=event01==1
			gen shcrime2=event02==1
			gen shcrime3=event03==1
			gen shcrime4=event04==1
			gen shcrime5=event05==1
			gen shcrime6=event06==1
			gen shcrime8=.

			gen shregul1=event07==1
			gen shregul2=event08==1
			gen shregul4=event10==1
			gen shregul5=event11==1
			gen shregul6=.

			gen shecon1=event12==1
			gen shecon2=event13==1
			gen shecon3=event14==1
			gen shecon4=event15==1
			gen shecon5=event16==1
			gen shecon6=event17==1
			gen shecon7=event18==1
			gen shecon8=event19==1
			gen shecon9=event20==1
			gen shecon10=.
			gen shecon11=event54==1 | event55==1 
			gen shecon12=event55==1 | event56==1
			gen shecon14=.

			gen shenv1=event24==1
			gen shenv2=event25==1
			gen shenv3=event26==1
			gen shenv4=event27==1
			gen shenv5=event28==1
			gen shenv6=event29==1
			gen shenv7=event30==1
			gen shenv8=event31==1
			gen shenv9=.
			gen shenv10=event58==1
			gen shenv11=event59==1
			gen shenv12=event60==1
			
			gen shhouse1=event32==1
			gen shhouse2=event33==1
			gen shhouse3=event32==1 | event33==1

			gen shfam1=event34==1
			gen shfam2=event35==1
			gen shfam3=event36==1
			gen shfam4=event37==1
			gen shfam5=event38==1
			gen shfam6=event39==1
			gen shfam7=event40==1
			gen shfam8=event41==1
			gen shfam9=event42==1
			gen shfam10=event50==1
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam15=event51==1
			gen shfam16=event52==1
			gen shfam17=event53==1
			gen shfam18=.
 
			gen shother=event45==1 | event46==1
			
			keep childid sh*
			gen round=2
			tempfile shocks2
			save    `shocks2'

			* ROUND 3

			use childid evntr* using "$r3yc\pe_yc_householdlevel.dta", clear
			tempfile shocks3yc
			save    `shocks3yc'
			use childid evntr* using "$r3oc\pe_oc_householdlevel.dta", clear
			qui append using `shocks3yc'

			gen shcrime1=evntr301==1
			gen shcrime2=evntr302==1
			gen shcrime3=evntr303==1
			gen shcrime4=evntr304==1
			gen shcrime5=evntr305==1
			gen shcrime6=evntr306==1
			gen shcrime8=.

			gen shregul1=evntr307==1
			gen shregul2=evntr308==1
			gen shregul4=evntr310==1
			gen shregul5=.
			gen shregul6=evntr361==1

			gen shecon1=evntr312==1
			gen shecon2=evntr313==1
			gen shecon3=evntr314==1
			gen shecon4=evntr315==1
			gen shecon5=evntr362==1 | evntr363==1
			gen shecon6=evntr317==1
			gen shecon7=evntr318==1
			gen shecon8=evntr319==1
			gen shecon9=evntr320==1
			gen shecon10=evntr311==1
			gen shecon11=evntr354==1 | evntr355==1
			gen shecon12=evntr356==1 | evntr357==1
			gen shecon14=.

			gen shenv1=evntr324==1
			gen shenv2=evntr325==1
			gen shenv3=evntr326==1
			gen shenv4=evntr327==1
			gen shenv5=evntr328==1
			gen shenv6=evntr329==1
			gen shenv7=evntr330==1
			gen shenv8=evntr331==1
			gen shenv9=.
			gen shenv10=evntr358==1
			gen shenv11=evntr359==1
			gen shenv12= evntr360==1		
			
			gen shhouse1=evntr332==1
			gen shhouse2=evntr333==1
			gen shhouse3=evntr332==1 | evntr333==1

			gen shfam1=evntr334==1
			gen shfam2=evntr335==1
			gen shfam3=evntr336==1
			gen shfam4=evntr337==1
			gen shfam5=evntr338==1
			gen shfam6=evntr339==1
			gen shfam7=evntr340==1
			gen shfam8=evntr341==1
			gen shfam9=evntr342==1
			gen shfam10=evntr350==1
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam15=evntr351==1
			gen shfam16=evntr352==1
			gen shfam17=evntr353==1
			gen shfam18=.

			gen shother=evntr345==1 | evntr346==1

			keep childid sh*
			gen round=3
			tempfile shocks3
			save    `shocks3'

			*ROUND 4

			use   "$r4yc3\PE_R4_YCHH_Shocks.dta", clear
			tempfile shocks4yc
			save    `shocks4yc'
			use  "$r4oc3\PE_R4_OCHH_Shocks.dta", clear
			qui append using `shocks4yc'
			
			keep CHILDCODE EVNTR4 SHCKIDR4
			rename EVNTR4 event
			reshape wide event, i(CHILDCODE) j(SHCKIDR4)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			
			gen shcrime1=event1==1
			gen shcrime2=event2==1
			gen shcrime3=event3==1
			gen shcrime4=event4==1
			gen shcrime5=event5==1
			gen shcrime6=event6==1
			gen shcrime8=.

			gen shregul1=event7==1
			gen shregul2=event8==1
			gen shregul4=event10==1
			gen shregul5=.
			
			gen shregul6=event61==1

			gen shecon1=event12==1
			gen shecon2=event13==1
			gen shecon3=event14==1
			gen shecon4=event15==1
			gen shecon5=event62==1 | event63==1
			gen shecon6=event17==1
			gen shecon7=event18==1
			gen shecon8=event19==1
			gen shecon9=event20==1
			gen shecon10=event11==1
			gen shecon11=event54==1 | event55==1 
			gen shecon12=event56==1 | event57==1
			gen shecon14=.
			
			gen shenv1=event24==1
			gen shenv2=event25==1
			gen shenv3=event26==1
			gen shenv4=event27==1
			gen shenv5=event28==1
			gen shenv6=event29==1
			gen shenv7=event30==1
			gen shenv8=event31==1
			gen shenv9=.
			gen shenv10=event58==1
			gen shenv11=event59==1
			gen shenv12=event60==1

			gen shhouse1=event32==1
			gen shhouse2=event33==1
			gen shhouse3=event32==1 | event33==1

			gen shfam1=event34==1
			gen shfam2=event35==1
			gen shfam3=event36==1
			gen shfam4=event37==1
			gen shfam5=event38==1
			gen shfam6=event39==1
			gen shfam7=event40==1
			gen shfam8=event41==1
			gen shfam9=event42==1
			gen shfam10=event50==1
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam15=event51==1
			gen shfam16=event52==1
			gen shfam17=event53==1
			gen shfam18=event69==1

			gen shother=event45==1 | event46==1

			keep childid sh*
		 
			gen round=4
			
			tempfile shocks4
			save    `shocks4'

			
		*ROUND 5
			use CHILDCODE SHCKIDR5 EVNTR5 using "$r5ochh\Shocks.dta", clear
			qui append using "$r5ychh\Shocks.dta", keep(CHILDCODE SHCKIDR5 EVNTR5)
	
			keep CHILDCODE EVNTR5 SHCKIDR5
			rename EVNTR5 event
			reshape wide event, i(CHILDCODE) j(SHCKIDR5)
			gen childid="PE"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			
			gen shcrime1=event1==1
			gen shcrime2=event2==1
			gen shcrime3=event3==1
			gen shcrime4=event4==1
			gen shcrime5=event5==1
			gen shcrime6=event6==1
			gen shcrime8=.

			gen shregul1=.
			gen shregul2=.
			gen shregul4=event10==1
			gen shregul5=.
			gen shregul6=.

			gen shecon1=event12==1
			gen shecon2=event13==1
			gen shecon3=event14==1
			gen shecon4=.
			gen shecon5=event62==1 | event63==1
			gen shecon6=.
			gen shecon7=.
			gen shecon8=.
			gen shecon9=event20==1
			gen shecon10=.
			gen shecon11=.
			gen shecon12=.
			gen shecon14=.
			
			gen shenv1=event24==1
			gen shenv2=event25==1
			gen shenv3=event26==1
			gen shenv4=event27==1
			gen shenv5=event28==1
			gen shenv6=event29==1
			gen shenv7=event30==1
			gen shenv8=event31==1
			gen shenv9=.
			gen shenv10=event58==1
			gen shenv11=.
			gen shenv12=.

			gen shhouse1=event32==1
			gen shhouse2=event33==1
			gen shhouse3=event32==1 | event33==1

			gen shfam1=event34==1
			gen shfam2=event35==1
			gen shfam3=event36==1
			gen shfam4=event37==1
			gen shfam5=event38==1
			gen shfam6=event39==1
			gen shfam7=event40==1
			gen shfam8=event41==1
			gen shfam9=event42==1
			gen shfam10=.
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam15=.
			gen shfam16=.
			gen shfam17=.
			gen shfam18=event69==1

			gen shother=event45==1 | event46==1

			keep childid sh*
			gen round=5
			tempfile shocks5
			save    `shocks5'			
			
		* MERGE DATA SETS
			use `shocks1', clear
			forvalues i=2/5 {
				qui append using `shocks`i''
				}			
			
		* LABEL VARIABLES
			lab define  yesno 1  "Yes" 0 "No"
			lab values sh* yesno

			label var shcrime1	"shock-destruction/theft of tools for production"
			label var shcrime2 	"shock-theft of cash"
			label var shcrime3 	"shock-theft of crops"
			label var shcrime4 	"shock-theft of livestock"
			label var shcrime5 	"shock-theft/destruction of housing/consumer goods"
			label var shcrime6 	"shock-crime that resulted in death/disablement"
			label var shcrime8 	"shock-victim of crime"

			label var shregul1 	"shock-land redistribution"
			label var shregul2 	"shock-resettlement or forced migration"
			label var shregul4 	"shock-forced contributions"
			label var shregul5 	"shock-eviction"
			label var shregul6 	"shock-invasion of property"

			label var shecon1 	"shock-increase in input prices"
			label var shecon2 	"shock-decrease in output prices"
			label var shecon3 	"shock-death of livestock"
			label var shecon4 	"shock-closure place of employment"
			label var shecon5 	"loss of job/ source of income/ family enterprise"
			label var shecon6 	"shock-industrial action"
			label var shecon7 	"shock-contract disputes (purchase of inputs)"
			label var shecon8 	"shock-contract disputes (sale of output)"
			label var shecon9 	"shock-disbanding credit"
			label var shecon10 	"shock-confiscation of assets"
			label var shecon11 	"shock-disputes w family about assets"
			label var shecon12 	"shock-disputes w neighbours about assets"
			label var shecon14 	"shock-decrease in food availability"
			
			label var shenv1 	"shock-drought"
			label var shenv2 	"shock-flooding"
			label var shenv3 	"shock-erosion"
			label var shenv4 	"shock-frost"
			label var shenv5 	"shock-pests on crops"
			label var shenv6 	"shock-crop failure"
			label var shenv7 	"shock-pests on storage"
			label var shenv8 	"shock-pests on livestock"
			label var shenv9 	"shock-natural disaster"
			label var shenv10 	"shock-earthquake"
			label var shenv11 	"shock-forest fire"
			label var shenv12 	"shock-pollution caused by mining"
						
			label var shhouse1 	"shock-fire affecting house"
			label var shhouse2 	"shock-house collapse"
			label var shhouse3 	"shock-fire or collapse of builing"

			label var shfam1 	"shock-death of father"
			label var shfam2 	"shock-death of mother"
			label var shfam3 	"shock-death of other household member"
			label var shfam4 	"shock-illness of father"
			label var shfam5 	"shock-illness of mother"
			label var shfam6 	"shock-illness of other household member"
			label var shfam7 	"shock-divorce or separation"
			label var shfam8 	"shock-birth of new hh member"
			label var shfam9 	"shock-enrolment of child in school"
			label var shfam10 	"shock-imprisonment"
			label var shfam12 	"shock-death/ reduction hh members"
			label var shfam13 	"shock-severe illness or injury"
			label var shfam14 	"shock-move/ migration"
			label var shfam15 	"shock-political imprisonment"
			label var shfam16 	"shock-political discrimination"
			label var shfam17 	"shock-ethnic/social discrimination"
			label var shfam18	"shock-illness of non-household member"
			label var shother 	"shock-others"

			sort childid  round
			tempfile    hhshocks
			save       `hhshocks'

			
/*-----------------------------------------------------------------------------*
							MERGING ALL SUBFILES
------------------------------------------------------------------------------*/

**** Indicator if child has died *****			

			use "$dead\yldeathsr2-r5.dta", clear
			keep if country=="Peru"
			drop country year yc 
			reshape long dead, i(childid) j(round)
			keep if dead==1
			rename dead deceased
			lab var deceased "child has died"
			lab define yes 1 "yes"
			lab val deceased yes
			tempfile dead
			save `dead'
			
***** Identification Variables *****

			use `identification', clear			
			g inround=.
			forvalues i=1/5 {
				replace inround=inr`i' if round==`i'
				}
			drop inr1-inr5
			order childid yc round inround panel
			lab var inround "Child is present in survey round"
			lab val inround yesno
			
***** Child Variables *****
			
			merge 1:1 childid round using `dead', nogen
			merge 1:1 childid round using `childgeneral', nogen
			merge 1:1 childid round using `marriage', nogen
			merge 1:1 childid round using `anthrop', nogen
			merge 1:1 childid round using `birthvacc', nogen
			merge 1:1 childid round using `illness', nogen
			merge 1:1 childid round using `smoke', nogen
			merge 1:1 childid round using `shealth', nogen
			merge 1:1 childid round using `timeuse', nogen
			merge 1:1 childid round using `education', nogen
			merge 1:1 childid round using `literacy', nogen
			merge 1:1 childid round using `care', nogen	
			merge 1:1 childid round using `dad', nogen
			merge 1:1 childid round using `mom', nogen

***** Household Variables *****

			merge 1:1 childid round using `head', nogen
			merge 1:1 childid round using `hhsize', nogen
			merge 1:1 childid round using `hhcomposition', nogen			
			merge 1:1 childid round using `wealth', nogen
			merge 1:1 childid round using `livestock', nogen
			merge 1:1 childid round using `land', nogen
			merge 1:1 childid round using `program', nogen
			merge 1:1 childid round using `foodsec', nogen
			merge 1:1 childid round using `hhshocks', nogen

			sort childid round
			order childid yc round inround panel deceased
			drop agemon_r5
			save "$output\peru_constructed.dta", replace
			
* END OF DO FILE :) *
