********************************************************************************
*					ETHIOPIA CONSTRUCTED PANEL DATA							   *
*					Rounds 1 to 5, OC AND YC								   *
********************************************************************************

	* Author: 		Kristine Briones
	* Date: 		14 March 2017
	* Last Update: 	17 April 2018
	* Last run:		22 May 2018
	
	/* 	
	 . tab yc round if inround==1

			   Younger |
			 cohort=1; |                    Round of survey
		Older cohort=0 |         1          2          3          4          5 |     Total
		---------------+-------------------------------------------------------+----------
		  Older cohort |     1,000        979        974        908        814 |     4,675 
		Younger cohort |     1,999      1,912      1,885      1,875      1,812 |     9,483 
		---------------+-------------------------------------------------------+----------
				 Total |     2,999      2,891      2,859      2,783      2,626 |    14,158 */


/*-----------------------------------------------------------------------------*
								DATA SETS
------------------------------------------------------------------------------*/

clear all
macro drop _all
set mem 600m
set more off  

global r1yc				N:\SurveyData\Ethiopia\R1_YC\stata\
global r1oc				N:\SurveyData\Ethiopia\R1_OC\stata\
global r2yc				N:\SurveyData\Ethiopia\R2_YC\stata\
global r2oc				N:\SurveyData\Ethiopia\R2_OC\stata\
global r3yc				N:\SurveyData\Ethiopia\R3_YC\stata\
global r3oc				N:\SurveyData\Ethiopia\R3_OC\stata\

global r4yc1			N:\SurveyData\Ethiopia\R4_YC\YC_CH_ANON  
global r4yc2			N:\SurveyData\Ethiopia\R4_YC\YC_CHCOG_ANON
global r4yc3			N:\SurveyData\Ethiopia\R4_YC\YC_HH_ANON
global r4oc1			N:\SurveyData\Ethiopia\R4_OC\OC_CH_ANON
global r4oc2			N:\SurveyData\Ethiopia\R4_OC\OC_CHCOG_ANON
global r4oc3			N:\SurveyData\Ethiopia\R4_OC\OC_HH_ANON

global Minternal		N:\SurveyData\Ethiopia\DOBs
global r5ochh			R:\z_R5\Exported Data\Ethiopia\ETOC_Household
global r5occh			R:\z_R5\Exported Data\Ethiopia\ETOC_Child
global r5occog			R:\z_R5\Exported Data\Ethiopia\ETOC_CogTest
global r5ocsaq			R:\z_R5\Exported Data\Ethiopia\ETOC_SAQ
global r5ychh			R:\z_R5\Exported Data\Ethiopia\ETYC_Household
global r5ycch			R:\z_R5\Exported Data\Ethiopia\ETYC_Child
global r5yccog			R:\z_R5\Exported Data\Ethiopia\ETYC_CogTest
global r5ycsaq			R:\z_R5\Exported Data\Ethiopia\ETYC_SAQ

global quant			Y:\CONSTRUCTED FILES & VARIABLES
global r5calc			$quant\Calculated variables
global r5anthro			$r5calc\Anthropometrics\Ethiopia
global r5wealth			$r5calc\CPI & Wealth\Ethiopia
global r5location		$r5calc\LocationVars\Ethiopia
global educhist			$quant\Useful variables\Education\Education history
global wealth			$r5calc\CPI & Wealth\Ethiopia
global newwealth		$r5calc\CPI & Wealth\Ethiopia\Recalculated_R12345
global irt				$quant\Useful variables\Cognitive test scores\IRT
global dead				$quant\Panel R1 to R5 (in progress)\documents
global marriage			$quant\Useful variables\Marital status& Fertility\marriage cohabitation childbirth\older cohort\Data				

global output			$quant\Panel R1 to R5 (in progress)\Ethiopia


/*-----------------------------------------------------------------------------*
								IDENTIFICATION
------------------------------------------------------------------------------*/

***** PANEL INFORMATION *****

	* ROUND 1
			use childid using "$r1yc/etchildlevel1yrold.dta", clear
			gen yc=1
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid)		
			replace yc=0 if yc==.
			gen inr1=1
			tempfile r1
			save `r1'

	* ROUND 2
			use childid using "$r2yc/etchildlevel5yrold.dta", clear
			gen yc=1
			qui append using "$r2oc/etchildlevel12yrold.dta", keep(childid)	
			merge 1:1 childid using "$r2oc\ETChildQuest12YrOld.dta", keepusing(childid)
			replace yc=0 if yc==.
			gen inr2=1 if yc==1 | (yc==0 & (_merge==3 | _merge==2))
			drop _m
			tempfile r2
			save `r2'

	* ROUND 3
			use childid using "$r3yc/et_yc_householdlevel.dta", clear
			merge 1:1 childid using "$r3yc\ET_YC_ChildLevel.dta", keepusing(childid)
			gen yc=1
			gen inr3=1 if yc==1 & (_merge==3 | _merge==2)
			drop _m
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid)
			merge 1:1 childid using "$r3oc\ET_OC_ChildLevel.dta", keepusing(childid)
			replace yc=0 if yc==.
			replace inr3=1 if yc==0 & (_merge==3 | _merge==2)
			drop _m
			tempfile r3
			save `r3'

	* ROUND 4
			use CHILDCODE using "$r4yc1/ET_R4_YCCH_YoungerChild.dta", clear
			merge 1:1 CHILDCODE using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", keepusing(CHILDCODE)
			gen yc=1
			gen inr4=1 if yc==1 & (_merge==3 | _merge==1)
			drop _m
			qui append using "$r4oc1/ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE)
			merge 1:1 CHILDCODE using "$r4oc3\ET_R4_OCHH_OlderHousehold.dta", keepusing(CHILDCODE)
			replace yc=0 if yc==.
			replace inr4=1 if yc==0 & (_merge==3 | _merge==1)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE _m
			tempfile r4
			save `r4'
	
	* ROUND 5
			use CHILDCODE using "$r5ycch/YoungerChild.dta", clear
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", keepusing(CHILDCODE)
			gen yc=1
			gen inr5=1 if yc==1 & (_merge==3 | _merge==1)
			drop _m
			qui append using "$r5occh/OlderChild.dta", keep(CHILDCODE)
			merge 1:1 CHILDCODE using "$r5ochh\OlderHousehold.dta", keepusing(CHILDCODE)
			replace yc=0 if yc==.
			replace inr5=1 if yc==0 & (_merge==3 | _merge==1)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE _m
			tempfile r5
			save `r5'		
		
	* MERGE
			use `r1', clear
			forvalues i=2/5 {
				merge 1:1 childid using `r`i'', nogen
				replace inr`i'=0 if missing(inr`i')
				}
			g panel=inr1==1 & inr2==1 & inr3==1 & inr4==1 & inr5==1
		
	* LABELS
			label var childid		"Child ID"
			label var yc			"Younger cohort=1; Older cohort=0"
			label var inr1			"Child is present in Round 1"
			label var inr2			"Child is present in Round 2"
			label var inr3			"Child is present in Round 3"
			label var inr4			"Child is present in Round 4"
			label var inr5			"Child is present in Round 5"
			label var panel		 	"Child is present in all rounds"

			label define yesno 0 "no" 1 "yes"
			label values inr1 inr2 inr3 inr4 inr5 panel yesno
			label define yc 0 "Older cohort" 1 "Younger cohort"
			label values yc yc
			
			tempfile  panel
			save     `panel'

	 **** all children

			use childid using "$r1yc/etchildlevel1yrold.dta", clear
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid)
			
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
							
	* ROUND 1
			use childid typesite region dint clustid commid using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid typesite region dint clustid commid)
			gen round=1
			recode region (11=14) (12=3) (13=4) (14=7) (15=1) 
			tempfile   typesiter1
			save      `typesiter1'

	* ROUND 2
			use childid typesite region dint clustid commid using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid typesite region dint clustid commid)
			gen round=2
			recode region (11=14) (12=3) (13=4) (14=7) (15=1) 
			tempfile   typesiter2
			save      `typesiter2'

	* ROUND 3
			use childid typesite region dint clustid commid using "$r3yc\et_yc_householdlevel.dta", clear
			qui append using "$r3oc\et_oc_householdlevel.dta", keep(childid typesite region dint clustid commid)
			gen round=3
			recode region (11=14) (12=3) (13=4) (14=7) (15=1) 
			tempfile   typesiter3
			save      `typesiter3'
			
	* ROUND 4 
			use CHILDCODE DINT NEWCLSR4-NEWREGR4 using "$r4yc3/ET_R4_YCHH_YoungerHousehold.dta", clear

			**CLUSTER AND COMMUNITY CORRECTIONS IN ROUND 4
				replace NEWCOMR4=13 if CHILDCODE==10016
				replace NEWCOMR4=13 if CHILDCODE==10043
				replace NEWCOMR4=13 if CHILDCODE==10051
				replace NEWCOMR4=13 if CHILDCODE==10076
				replace NEWCOMR4=13 if CHILDCODE==10088
				replace NEWCOMR4=17 if CHILDCODE==30022
				replace NEWCOMR4=18 if CHILDCODE==40019
				replace NEWCLSR4=4 if CHILDCODE==40083
				replace NEWCLSR4=9 if CHILDCODE==90019
				replace NEWCLSR4=15 if CHILDCODE==150025
				replace NEWCLSR4=15 if CHILDCODE==150046
			
			/* To create typesite for the observations we assign to each of the communties the same urban/rural 
			status to communities assigned in R3 (In some cases,one community was observed as being both rural and urban. 
			The decision as to which typesite we choose here is based on the majority of responses). In the case of the YC, 
			children in communites outside YL are given code 26 (999=Non-YL Community). For these children,  NEWNONL4 tells us 
			if it is an urban or rural community*/	
			# delimit ;
			gen typesite=1 if		NEWCOMR4==13 | NEWCOMR4==19 |
									NEWCOMR4==14 | NEWCOMR4==20 |
									NEWCOMR4==16 | NEWCOMR4==21 |							  
									NEWCOMR4==15 | NEWCOMR4==22 |	
									NEWCOMR4==17 | NEWCOMR4==23 |
									NEWCOMR4==18 | NEWCOMR4==24 ;
			replace typesite=1 if   NEWCOMR4==26 & NEWNONL4==1 ;
			replace typesite=2 if 	NEWCOMR4==1 | NEWCOMR4==7  |			
									NEWCOMR4==2 | NEWCOMR4==8  |		
								                  NEWCOMR4==9  |					
									NEWCOMR4==3 | NEWCOMR4==10 |						
									NEWCOMR4==4 | NEWCOMR4==11 |		
									NEWCOMR4==5 | NEWCOMR4==12 |		
									NEWCOMR4==6 ;
			replace typesite=2 if   NEWCOMR4==26 & NEWNONL4==2 ;
			# delimit cr
			
			gen mini=regexs(0) if (regexm(NEWMCOMR4, "[0-9][0-9][0-9]"))
			replace mini="047" if NEWMCOMR4=="47"
			replace mini="082" if NEWMCOMR4=="82"
			replace mini="090" if NEWMCOMR4=="90"
			replace mini="" if NEWMCOMR4=="9420"
			replace mini="029" if NEWMCOMR4=="ETMCO29"
			replace mini="025" if NEWMCOMR4=="ETMC O25"
			
			gen minicom="ETMC"+mini if mini!=""
						 
			decode NEWCOMR4 if NEWCOMR4!=26, generate(commid) 
			decode NRUCOMMR4, generate(urbancom)
			decode NRRCOMMR4, generate(ruralcom)
			
			replace commid=urbancom if missing(commid)
			replace commid=ruralcom if missing(commid)
			replace commid=minicom if missing(commid)
			replace commid="999" if missing(commid)
			
			drop NEWCOMR4 NRUCOMMR4 NRRCOMMR4 NEWMCOMR4 urbancom ruralcom minicom mini
			
			tempfile  typesite4yc
			save     `typesite4yc'
						
			use CHILDCODE DINT NEWCLSR4-NEWREGR4 using "$r4oc3/ET_R4_OCHH_OlderHousehold.dta", clear
			merge 1:1 CHILDCODE using "$r4oc3/OC_MiniCommid_ForMerge.dta"		// location of NEWMCR4 variable
			
				**CLUSTER AND COMMUNITY CORRECTIONS IN ROUND 4
					replace NEWCLSR4=3 if CHILDCODE==31019
					replace NEWCLSR4=5 if CHILDCODE==51048
			
			/* To create typesite for the observations we assign to each of the communties the same urban/rural 
			status to communities assigned in R3 (In some cases,one community was observed as being both rural and urban. 
			The decision as to which typesite we choose here is based on the majority of responses). In the case of the OC, 
			children in communites outside YL are given code 999=Non-YL Community. For these children,  NEWSTER4 tells us 
			if it is an urban or rural community*/			
			
			# delimit ;
			gen typesite=1 if		NEWCOMR4==1011 | NEWCOMR4==1021 |
									NEWCOMR4==1022 | NEWCOMR4==1031 |
									NEWCOMR4==1032 | NEWCOMR4==2041 |							  
									NEWCOMR4==3101 | NEWCOMR4==4131 |	
									NEWCOMR4==4141 | NEWCOMR4==4143 |
									NEWCOMR4==4144 | NEWCOMR4==5191 ;
			replace typesite=1 if   NEWCOMR4==999  & NEWSTER4==1 ;
									
			replace typesite=2 if 	NEWCOMR4==2051 | NEWCOMR4==2061  |			
									NEWCOMR4==2071 | NEWCOMR4==3081  |		
									NEWCOMR4==3091 | NEWCOMR4==3111  | 
								    NEWCOMR4==4121 | NEWCOMR4==4151  |					
									NEWCOMR4==4161 | NEWCOMR4==5171  |		
									NEWCOMR4==5181 | NEWCOMR4==5201 ;
			replace typesite=2 if   NEWCOMR4==999  &  NEWSTER4==2 ;
			# delimit cr
				
			gen commid="ET"+string(NEWCOMR4, "%04.0f") if NEWCOMR4!=999
			
			decode NRCMURR4, gen(urbancom)
			decode NRCOMMR4, gen(ruralcom)
			
			replace commid=urbancom if missing(commid)
			replace commid=ruralcom if missing(commid)
			
			gen mini=regexs(0) if (regexm(NEWMCR4, "[0-9][0-9][0-9]"))
			replace mini="002" if NEWMCR4=="02"
			replace mini="091" if NEWMCR4=="91"
			replace mini="051" if NEWMCR4=="ETMC51"
			replace mini=NEWMCR4 if NEWMCR4=="9275" | NEWMCR4=="9284" | NEWMCR4=="9285" | NEWMCR4=="9286"
			gen minicomm="ETMC"+mini if mini!=""
			replace minicomm="ET"+mini if NEWMCR4=="9275" | NEWMCR4=="9284" | NEWMCR4=="9285" | NEWMCR4=="9286"
			
			replace commid=minicomm if missing(commid)
			replace commid ="999" if missing(commid)

			
			qui append using `typesite4yc'
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			
			rename NEWREGR4 region
			rename NEWCLSR4 clustid
			tab typesite
			g round=4
			g dint=date(substr(DINT,1,10), "DMY")
			format dint %td 

			keep childid round clustid commid typesite region dint
			tempfile   typesiter4
			save      `typesiter4'
			
	* ROUND 5 
			use "$r5location\et_r5_yc_hh_location.dta", clear
			qui append using "$r5location\et_r5_oc_hh_location.dta"
			recode region (15=1) (16=2) (12=3) (13=4) (17=5) (18=6) (14=7) (19=12) (20=13) (11=14) (21=15) 
			rename *_hh *
			tempfile location5
			save `location5'
			
			use CHILDCODE DINT using "$r5ychh/YoungerHousehold.dta", clear
			qui append using "$r5ochh/OlderHousehold.dta", keep(CHILDCODE DINT)
			merge 1:1 CHILDCODE using `location5', nogen
			g childid="ET"+string(CHILDCODE,"%06.0f")
			g dint=date(substr(DINT,1,10), "DMY")
			drop CHILDCODE DINT
			format dint %td 
			g round=5
			tempfile   typesiter5
			save      `typesiter5'
	
	* MERGE
			use `typesiter1', clear
			forvalues i=2/5 {
				qui append using `typesiter`i''
				}
			tempfile typesite
			save `typesite'
		
			
***** CHILD LOCATION *****

	* ROUND 1 - not asked (assumed that child is living in the household)
			use childid using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid)
			g childloc=1
			g round=1
			tempfile childlocr1
			save `childlocr1'
			
	* ROUND 2 
			use childid id livhse using "$r2yc\ETSubHouseholdMember5.dta", clear
			qui append using "$r2oc\ETSubHouseholdMember12.dta", keep(childid id livhse)
			keep if id==0
			rename livhse childloc
			g round=2
			keep childid childloc round
			tempfile childlocr2
			save `childlocr2'
			
	* ROUND 3		
			use childid id livhse using "$r3yc\ET_YC_HouseholdMemberLevel.dta", clear
			qui append using "$r3oc\ET_OC_HouseholdMemberLevel.dta", keep(childid id livhse)
			keep if id==0
			g childloc=livhse==1 if livhse!=.
			g round=3
			keep childid childloc round
			tempfile childlocr3
			save `childlocr3'
			
	* ROUND 4
			use CHILDCODE MEMIDR4 LIVHSER4 using "$r4yc3\ET_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3\ET_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 LIVHSER4)
			keep if MEMIDR4==0
			g childloc=LIVHSER4==1 if LIVHSER4!=.
			g childid="ET"+string(CHILDCODE,"%06.0f")	
			g round=4
			keep childid childloc round
			tempfile childlocr4
			save `childlocr4'
	
	* ROUND 5
			use CHILDCODE MEMIDR5 LIVHSER5 using "$r5ychh\HouseholdRosterR5.dta", clear
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 LIVHSER5)
			keep if MEMIDR5==0
			g childloc=LIVHSER5==1 if LIVHSER5!=.
			g childid="ET"+string(CHILDCODE,"%06.0f")
			g round=5
			duplicates drop
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
			
	* CORRECTING MISCODED TYPESITES
			replace typesite=1 if (clustid>=1 & clustid<=4) | clustid==10 | clustid==14 | clustid==19
			replace typesite=2 if (clustid>=5 & clustid<=9) | (clustid>=11 & clustid<=13) | (clustid>=15 & clustid<=18) | clustid==20
				
	* LABELS 
			label var childid		"Child ID"
			label var round	 		"Round of survey"
			label var clustid 		"Sentinel site ID"								
			label var commid 		"Community ID"
			label var typesite 		"Area of residence (urban/rural)"
			label var region 		"Region of residence"
			label var dint 			"Date of interview"
			label var childloc		"Child currently lives in the household"
			
			label def typesite 1 "urban" 2 "rural"
			label val typesite typesite
			label val childloc yesno
			
			label def region   1 "Tigray" ///
							   2 "Afar" ///
							   3 "Amhara" ///
							   4 "Oromiya" ///
							   5 "Somali" ///
							   6 "Benshangul Gumz" ///
							   7 "SNNP" ///
							  12 "Gambela" ///
							  13 "Harari" ///
							  14 "Addis Ababa City Administration" ///
							  15 "Dire Dawa City Administration"
			label values region region			
			
			sort childid round
			order childid yc round inr* panel dint-typesite childloc
			tempfile  identification
			save     `identification'

/*-----------------------------------------------------------------------------*
							CHILD CHARACTERISTICS
------------------------------------------------------------------------------*/			

***** GENERAL *****

	* SEX, ETHNICITY AND RELIGION - (taken from R1)
			use childid sex chldeth chldrel using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid sex chldeth chldrel)
			rename chldeth chethnic
			rename sex chsex
			tempfile childchar
			save    `childchar'

	* FIRST LANGUAGE (Taken from R2 - NO INFORMATION IN OTHER ROUNDS)
			use childid chlng1st using "$r2yc/etchildlevel5yrold.dta", clear
			qui append using "$r2oc/etchildlevel12yrold.dta", keep(childid chlng1st)
			rename  chlng1st chlang
			tempfile  lang
			save     `lang'
			
	* AGE (IN MONTHS) AT TIME OF INTERVIEW - For each round
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
			use childid agechild using "$r1yc/etchildlevel1yrold.dta", clear
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid agechild)
			gen round=1
			rename agechild agemon
			tempfile    age1
			save       `age1'	
		
			* ROUND 2
			use childid agechild using "$r2yc/etchildlevel5yrold.dta", clear
			qui append using "$r2oc/etchildlevel12yrold.dta", keep(childid agechild)
			gen round=2
			rename agechild agemon
			tempfile    age2
			save       `age2'

			* ROUND 3
			use childid agechild using "$r3yc/et_yc_householdlevel.dta", clear
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid agechild)
			gen round=3
			g agemon=round(agechild, 1.0)
			drop agechild
			tempfile    age3
			save       `age3'

			* ROUND 4
			use CHILDCODE agemon using "$r4yc1/ET_R4_YCCH_YoungerChild.dta", clear
			qui append using "$r4oc1/ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE agemon)	
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE			
			gen round=4
			tempfile    age4
			save       `age4'			
			
			* ROUND 5			
			use CHILDCODE agemons using "$r5anthro\et_r5_anthro_yc_indexch.dta", clear
			qui append using "$r5anthro\et_r5_anthro_oc_indexch.dta", keep(CHILDCODE agemons)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			rename agemons agemon
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

	* LABEL VARIABLES			label var childid	"Child ID"
			label var chsex 	"Child's sex"

			label var chlang 	"Child's first language"
			label var chethnic 	"Child's ethnic group"
			label var chldrel 	"Child's religion"
			label var chage		"Child's age (in months)"
		
			label define chethnic 10 "Other" 11 "Agew" 12 "Amhara" 13 "Gurage" ///
					14 "Hadiva" 15 "Kambata" 16 "Oromo" 17 "Sidama" 18 "Tigrian" 19 "Wolavta" 99 "NK"
			label values chethnic chethnic

			tempfile    childgeneral
			save       `childgeneral'


***** MARRIAGE AND CHILD BIRTH *****

	* OLDER COHORT ONLY
			use "$marriage\marriage&cohab_oc_allcountries.dta", clear
			merge 1:1 childid using "$marriage\childbirth_oc_allcountries.dta", nogen
			keep if country=="Ethiopia"
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
			use childid chheght chweght bmi-fbfa using "$r1yc\ETChildLevel1YrOld.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid chheght chweght bmi-fbfa)
			g round=1
			rename chweght chweight
			rename chheght chheight
			tempfile anthrop1
			save `anthrop1'
	
	* ROUND 2
			use childid chheight chweight bmi-fbfa zwfl fwfl using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid chheight chweight bmi-fbfa)
			g round=2
			tempfile anthrop2
			save `anthrop2'	
	
	* ROUND 3
			use childid chwghtr3 chhghtr3 using "$r3yc/et_yc_householdlevel.dta", clear
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid chwghtr3 chhghtr3)
			rename chwghtr3 chweight
			rename chhghtr3 chheight	
			tempfile height3
			save `height3'
	
			use childid bmi-fbfa using "$r3yc\et_yc_childlevel.dta", clear
			qui append using "$r3oc\et_oc_childlevel.dta", keep(childid bmi-fbfa)
			g round=3
			merge 1:1 childid using `height3', nogen
			tempfile anthrop3
			save `anthrop3'				
	
	* ROUND 4
			use CHILDCODE CHHGTAGR4 CHWGTAGR4 using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", clear
			merge 1:1 CHILDCODE	using "$r4yc1\ET_R4_YCCH_YoungerChild.dta", nogen keepusing(CHILDCODE bmi-fbfa)
			qui append using "$r4oc1\ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE CHHGTAGR4 CHWGTAGR4 bmi-fbfa)
			rename CHWGTAGR4 chweight
			rename CHHGTAGR4 chheight
			recode chweight chheight (-9999=.)
			g round=4
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile anthrop4
			save `anthrop4'				

	* ROUND 5
			use "$r5anthro\et_r5_anthro_yc_indexch.dta", clear
			qui append using "$r5anthro\et_r5_anthro_oc_indexch.dta"
			rename weight chweight
			rename height chheight			
			g round=5
			gen childid="ET"+string(CHILDCODE, "%06.0f")	
			drop CHILDCODE agemons
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
			label var childid		"Child ID"
			label var round	 		"Round of survey"	
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

			
***** BIRTH AND IMMUNIZATIONS *****

	* ROUND 1 (YC ONLY)	
			use childid bwght bwdoc antnata numante inject docbrth-othbrth bcg measles using "$r1yc\etchildlevel1yrold.dta", clear
			rename inject tetanus
			replace numante=0 if antnata==2
			g withinfo=docbrth!=. & nurbrth!=. &  midbrth!=. &  relbrth!=. &  othbrth!=. 
			g delivery=(docbrth==1 | nurbrth==1 |   midbrth==1) if withinfo==1 
			g round=1
			drop docbrth nurbrth midbrth relbrth othbrth withinfo antnata
			recode bwdoc tetanus bcg measles (2=0) 
			tempfile birth
			save `birth'
	
	* ROUND 2
			use childid bcg measles dpt opv hib using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid bcg measles dpt opv hib)
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
			use childid mightdie longterm using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid mightdie longterm) 
			rename mightdie chmightdie
			rename longterm chhprob
			g round=1
			recode chmightdie chhprob (2=0)
			tempfile illness1
			save `illness1'
	
	* ROUND 2
			use childid mightdie longterm using "$r2yc\etchildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\etsubillnesses5.dta", nogen keepusing(childid illid)
			drop if illid>1 & illid!=.
			merge 1:m childid using "$r2yc\etsubinjuries5.dta", nogen keepusing(childid injid)
			drop if injid>1 & injid!=.
			tempfile yc2
			save `yc2'
			use childid mightdie longterm using "$r2oc\etchildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc\etsubillnesses12.dta", nogen keepusing(childid illid)
			drop if illid>1 & illid!=.
			merge 1:m childid using "$r2oc\etsubinjuries12.dta", nogen keepusing(childid injid)
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
			use childid tminjr3 using "$r3yc/et_yc_householdlevel.dta", clear
			rename tminjr3 nmtminr3 
			qui append using "$r3oc/et_oc_childlevel.dta", keep(childid nmtminr3)
			g chinjury=nmtminr3>0 if nmtminr3!=.
			drop nmtminr3 
			g round=3
			tempfile illness3
			save `illness3'
	
	* ROUND 4
			use CHILDCODE ILLNSSR4 TMINJR4 DSBWRKR4 HOWAFTR4 using "$r4yc3/ET_R4_YCHH_YoungerHousehold.dta", clear
			rename TMINJR4 NMTMINR4
			qui append using "$r4oc1/ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE ILLNSSR4 NMTMINR4 LNGHL* DSBWRKR4 HOWAFTR4)
			rename ILLNSSR4 chillness			
			g chinjury=NMTMINR4>0 if NMTMINR4!=.
			rename DSBWRKR4 chdisability
			rename HOWAFTR4 chdisscale
			g round=4
			g childid="ET"+string(CHILDCODE, "%06.0f")
			keep ch* round
			tempfile illness4
			save `illness4'
							
	* ROUND 5
			use CHILDCODE ILLNSSR5 NMTMINR5 LNGHLTR5 using "$r5ycch\Youngerchild.dta", clear
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", nogen keepusing(CHILDCODE DSBWRKR5 HOWAFTR5)
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE ILLNSSR5 NMTMINR5 LNGHLTR5 DSBWRKR5 HOWAFTR5)
			recode ILLNSSR5 NMTMINR5 DSBWRKR5 HOWAFTR5 (77 79 88=.)
			rename ILLNSSR5 chillness
			rename LNGHLTR5 chhprob
			g chinjury=NMTMINR5>0 if NMTMINR5!=.
			rename DSBWRKR5 chdisability
			rename HOWAFTR5 chdisscale
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")
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
			use childid agecigr3 oftsmkr3 youalcr3 prgfrsr3-whrcndr3 using "$r3oc\ET_OC_ChildLevel.dta", clear
			recode agecigr3 oftsmkr3 youalcr3 prgfrsr3-whrcndr3 (77 79 88 99=.)
			rename oftsmkr3 chsmoke
			replace chsmoke=5 if agecigr3==4
			g chalcohol=youalcr3==1 | youalcr3==2 if youalcr3!=.
			g noresp=prgfrsr3==. & wshaftr3==. & usecndr3==. & lkshltr3==. & hivsexr3==.
			g corr1=prgfrsr3==0 if noresp==0
			g corr2=wshaftr3==0 if noresp==0
			g corr3=usecndr3==1 if noresp==0
			g corr4=lkshltr3==0 if noresp==0
			g corr5=hivsexr3==1 if noresp==0
			egen chrephealth1=rowtotal(corr1-corr5) if noresp==0
			g chrephealth2=corr3
			g chrephealth3=corr4
			rename whrcndr3 chrephealth4
			recode chrephealth4 (5=4)
			g round=3
			keep childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			order childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			tempfile smoke3
			save `smoke3'

	* ROUND 4 (OLDER COHORT ONLY)
			use CHILDCODE YOUALCR4 using "$r4oc1\ET_R4_OCCH_OlderChild.dta", clear
			merge 1:1 CHILDCODE using "$r4oc2\ET_R4_OCCOG_OlderChild.dta", nogen keepusing(CHILDCODE SELFR401-SELFR415)
			recode YOUALCR4 SELFR401-SELFR415 (77 79 88 99=.)
			g chalcohol=YOUALCR4==1 | YOUALCR4==2 if YOUALCR4!=.
			g noresp=SELFR401==. & SELFR402==. & SELFR403==. & SELFR404==. & SELFR405==.
			g corr1=SELFR401==2 if noresp==0
			g corr2=SELFR402==2 if noresp==0
			g corr3=SELFR403==1 if noresp==0
			g corr4=SELFR404==2 if noresp==0
			g corr5=SELFR405==1 if noresp==0
			egen chrephealth1=rowtotal(corr1-corr5) if noresp==0
			g chrephealth2=corr3
			g chrephealth3=corr4
			rename SELFR415 chrephealth4
			recode chrephealth4 (5=4)
			g round=4
			g childid="ET"+string(CHILDCODE, "%06.0f")	
			keep childid round chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			order childid round chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			tempfile smoke4
			save `smoke4'			
			
	* ROUND 5
			use CHILDCODE SMOKER5 DYSSMKR5 DYSALCR5 using "$r5ycch\YoungerChild.dta", clear
			merge 1:1 CHILDCODE using "$r5ycsaq\YoungerChildSAQ.dta", nogen keepusing(CHILDCODE WHRCNDR5-HIVSEXR5)
			recode SMOKER5 DYSSMKR5 DYSALCR5 WHRCNDR5 PRGFRSR5 WSHAFTR5 USECNDR5 LKSHLTR5 HIVSEXR5 (77 79 88 99=.)
			rename DYSSMKR5 chsmoke
			replace chsmoke=5 if SMOKER5==0
			g chalcohol=DYSALCR5==1 | DYSALCR5==2 if DYSALCR5!=.			
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
			recode chrephealth4 (1=1) (3=2) (4 5 6 =3) (8=4)
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")				
			keep childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			order childid round chsmoke chalcohol chrephealth1 chrephealth2 chrephealth3 chrephealth4
			tempfile yc5
			save `yc5'			
			use CHILDCODE EVRSMKER5 OFTSMKR5 YOUALCR5 using "$r5occh\OlderChild.dta", clear
			merge 1:1 CHILDCODE using "$r5ocsaq\OlderChildSAQ.dta", nogen keepusing(CHILDCODE WHRCNDR5)
			drop if CHILDCODE==10031
			recode EVRSMKER5 OFTSMKR5 YOUALCR5 WHRCNDR5 (77 79 88 99=.)
			rename OFTSMKR5 chsmoke
			replace chsmoke=5 if EVRSMKER5==0
			g chalcohol=YOUALCR5==1 | YOUALCR5==2 if YOUALCR5!=.				
			rename WHRCNDR5 chrephealth4
			recode chrephealth4 (1=1) (3=2) (4 5 6 =3) (8=4)			
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")				
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
			use childid healthy using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid healthy)
			recode healthy (99=.)
			rename healthy chhrel
			g round=1
			tempfile shealth1
			save `shealth1'
			
		* ROUND 2
			use childid healthy using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\ETChildQuest12YrOld.dta", keep(childid chealthy cladder)
			replace healthy=chealthy if missing(healthy)
			drop chealthy
			rename healthy chhrel
			recode chhrel (0=.)
			g round=2
			tempfile shealth2
			save `shealth2'
		
		* ROUND 3
			use childid hlcmchr3 nmehltr3 using "$r3yc/et_yc_householdlevel.dta", clear
			merge 1:1 childid using "$r3yc/et_yc_childlevel.dta", nogen keepusing(childid stnprsr3)
			rename nmehltr3 yrhlthr3
			rename hlcmchr3 cmphltr3
			qui append using "$r3oc/et_oc_childlevel.dta", keep(childid cmphltr3 yrhlthr3 stnprsr3)
			rename cmphltr3 chhrel
			recode chhrel (3=1) (4 5=2) (1 2=3)	
			rename yrhlthr3 chhealth 
			rename stnprsr3 cladder
			g round=3
			tempfile shealth3
			save `shealth3'
			
		* ROUND 4
			use CHILDCODE NMEHLTR4 using "$r4yc3/ET_R4_YCHH_YoungerHousehold.dta", clear
			merge 1:1 CHILDCODE using "$r4yc1/ET_R4_YCCH_YoungerChild.dta", nogen keepusing(CHILDCODE STNPRSR4)
			rename NMEHLTR4 YRHLTHR4
			rename STNPRSR4 LADNOWR4
			qui append using "$r4oc1\ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE YRHLTHR4 LADNOWR4)
			recode YRHLTHR4 LADNOWR4 (77 79 88=.)
			rename YRHLTHR4 chhealth
			rename LADNOWR4 cladder
			g round=4
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			tempfile shealth4
			save `shealth4'
			
		* ROUND 5
			use CHILDCODE YRHLTHR5 STNPRSR5 CMPHLTR5 using "$r5ycch/YoungerChild.dta", clear
			rename STNPRSR5 LADNOWR5
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE YRHLTHR5 LADNOWR5)
			recode YRHLTHR5 LADNOWR5 CMPHLTR5 (77 79 88=.)
			rename CMPHLTR5 chhrel
			recode chhrel (3=1) (4 5=2) (1 2=3)	
			rename YRHLTHR5 chhealth
			rename LADNOWR5 cladder
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")
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
			use childid id age sleep chcare hhchore npaywork paywork school study play using "$r2yc\etsubhouseholdmember5.dta", clear
			keep if id==0
			recode sleep chcare hhchore npaywork paywork school study play (77=.)
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
			use childid csleep-cplay using "$r2oc\ETChildQuest12YrOld.dta", clear
			recode csleep-cplay (77=.)
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
			use childid id age sleepr3-playr3 using "$r3yc/et_yc_householdmemberlevel.dta", clear
			recode *r3 (-77 77 88=.)			
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
			use childid sleepr3-lsurer3 using "$r3oc/et_oc_childlevel.dta", clear
			recode *r3 (-77 77 88=.)
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
			use CHILDCODE SLEEPR4-LSURER4 TMCMWKR4 TMCMSCR4 using "$r4yc1\ET_R4_YCCH_YoungerChild.dta", clear 
			rename TMCMWKR4 CMTACTR4
			rename TMCMSCR4 CMTSCHR4
			qui appen using "$r4oc1\ET_R4_OCCH_OlderChild.dta", keep(CHILDCODE SLEEPR4-LSURER4 CMTACTR4 CMTSCHR4)
			recode *R4 (-77 -88=.)
			rename SLEEPR4 hsleep
			rename CROTHR4 hcare
			rename DMTSKR4 hchore
			rename TSFARMR4 htask
			rename ACTPAYR4 hwork
			rename ATSCHR4 hschool
			rename STUDYGR4 hstudy
			rename LSURER4 hplay
			rename CMTACTR4 commwork
			rename CMTSCHR4 commsch			
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE	
			gen round=4
			tempfile timeuse4
			save    `timeuse4'

	* ROUND 5
			use CHILDCODE SLEEPR5-LSURER5 TMCMWKR5 TMCMSCR5 using "$r5ycch\YoungerChild.dta", clear
			rename TMCMSCR5 COMSCHR5
			qui append using "$r5occh\OlderChild.dta", keep(CHILDCODE SLEEPR5-LSURER5 TMCMWKR5 COMSCHR5)
			recode *R5 (-88 -77=.)
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
			gen childid="ET"+string(CHILDCODE, "%06.0f")
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
			use "$educhist\Older cohort\Data\educhistory_et_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_et_yc.dta"	
			
			recode enrolled (1=0) if grade==100
			bys childid: egen agegr1=min(age_sept) if enrolled==1 & grade==1
			keep if agegr1!=.
			keep childid agegr1
			duplicates drop
			label variable agegr1 "Child's age at start of grade 1"
			tempfile agegr1
			save `agegr1'
			
	* Pre-primary school
			use childid grade completeinfo using "$educhist\Older cohort\Data\educhistory_et_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_et_yc.dta", keep(childid grade completeinfo)	
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
			use "$educhist\Older cohort\Data\educhistory_et_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_et_yc.dta"	
			
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
			
	* Highest grade achieved 
		
			* ROUND 1 (OC only; source: education history)
				/* If enrolled in 2002, hghgrade=current grade minus 1. 			
					If not enrolled in 2002, check if ever enrolled in 2001 below	
					
					enrolled in 2002 - 494 obs
					not enrolled in 2002 & never enrolled before 2002 - 479 obs
					not enrolled in 2002 but enrolled before 2002 - 1 obs		<- ET121044: missing info in rounds 4 above, code hghgrade=missing
					missing info - 26										*/
		
			use "$educhist\Older cohort\Data\educhistory_et_oc.dta", clear
			replace enrolled=0 if grade==100
			replace grade=. if grade==100
			bys childid: egen below2002=max(enrolled) if year<=2001
			bys childid: egen enrolb2002=max(below2002)
			drop below2002
			g hghgrade=grade-1 if enrolled==1
			replace hghgrade=0 if hghgrade<0 | enrolb2002==0
			replace hghgrade=. if childid=="ET121044"
			keep if year==2002
			keep childid hghgrade
			g round=1
			tempfile high1
			save `high1'			
			
			* ROUND 2 (source: household)
				/* younger cohort children below age 5 at time of interview were not asked if they have completed a grade or not. 
					Use variable HASSTRT to check if child has started formal school, if answer is no, replace missing hghgrade with 0. */
			use childid id chgrade using "$r2oc\ETSubHouseholdMember12.dta", clear
			qui append using "$r2yc\ETSubHouseholdMember5.dta", keep(childid id chgrade)
			keep if id==0
			drop id
			merge 1:1 childid using "$r2yc\ETChildLevel5YrOld.dta", nogen keepusing(childid hasstrt)
			rename chgrade hghgrade
			replace hghgrade=0 if missing(hghgrade) & hasstrt==0
			drop hasstrt
			g round=2
			tempfile high2
			save `high2'
			
			* ROUND 3 (source: household)
			use childid id grader3 hsstrtr3 using "$r3oc\ET_OC_HOuseholdMemberLevel.dta", clear
			qui append using "$r3yc\ET_YC_HouseholdMemberLevel.dta", keep(childid id grader3 hsstrtr3)
			replace grader3=0 if missing(grader3) & hsstrtr3==0
			keep if id==0
			drop id hsstrtr3
			rename grader3 hghgrade
			g round=3
			tempfile high3
			save `high3'			
			
			* ROUND 4 (source: household)
			use CHILDCODE MEMIDR4 GRADER4 HSSTRTR4 using "$r4oc3\ET_R4_OCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4yc3\ET_R4_YCHH_HouseholdrosterR4.dta", keep(CHILDCODE MEMIDR4 GRADER4 HSSTRTR4)
			recode GRADER4 (18=30)
			keep if MEMIDR4==0
			drop MEMIDR4
			rename GRADER4 hghgrade
			replace hghgrade=0 if missing(hghgrade) & HSSTRTR4==0
			g round=4
			g childid="ET"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE HSSTRTR4
			tempfile high4
			save `high4'
						
			* ROUND 5 (source: educ history) 
				/* 	Highest grade completed is the grade MOST RECENTLY completed. This is done for simplification as some might move from
					secondary to vocational and vice versa (etc) and we do not know which is technically a "higher grade".  */
			use "$educhist\Older cohort\Data\educhistory_et_oc.dta", clear
			qui append using "$educhist\Younger cohort\Data\educhistory_et_yc.dta"	
			replace enrolled=0 if grade==100
			replace grade=. if grade==100
			keep if year>=2013 & year<=2016
			bys childid: egen n=count(enrolled)
			bys childid: egen hyr=max(year) if compgradeR5==1
			bys childid: egen hghyr=max(hyr)
			drop hyr
			replace hghyr=99 if missing(hghyr) & n!=0 & grade==.
			keep if year==hghyr | hghyr==99
			keep childid grade hghyr
			recode grade (13/26 31=13) (27/29 32/39=14) (40=15) (41=30)
			duplicates drop
			g round=5
			
			merge 1:1 childid using `high4', nogen keepusing(childid hghgrade)
			replace grade=hghgrade if missing(grade) & hghyr==99
			drop if missing(round)
			drop hghgrade hghyr
			rename grade hghgrade
			tempfile high5
			save `high5'
			
			* MERGE
			use `high1', clear
			forvalues i=2/5 {
				qui append using `high`i''
				}
			lab var hghgrade "Highest grade achieved at time of interview"
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
							  12 "Grade 12" ///
							  13 "Post-secondary, vocational" ///
							  14 "University" ///
							  15 "Masters, doctorate" ///
							  28 "Adult literacy" ///
							  29 "Religious education" ///
							  30 "Other" 
			label values hghgrade educ							
			tempfile highgrade
			save `highgrade'

	* TRAVEL TIME TO SCHOOL 
		
			* ROUND 1 (not asked)
			
			* ROUND 2 
			use childid tmschmin using "$r2oc/etchildquest12yrold.dta", clear
			qui append using "$r2yc/etchildlevel5yrold.dta", keep(childid tmschmin)
			rename tmschmin timesch
			g round=2
			tempfile time2
			save `time2'
		
			* ROUND 3
			use childid schminr3 using "$r3oc/et_oc_childlevel.dta", clear
			qui append using "$r3yc/et_yc_householdlevel.dta", keep(childid schminr3)
			rename schminr3 timesch			
			g round=3
			tempfile time3
			save `time3'
		
			* ROUND 4
			use CHILDCODE SCHMINR4 using "$r4oc1/ET_R4_OCCH_OlderChild.dta", clear
			qui append using "$r4yc1/ET_R4_YCCH_YoungerChild.dta", keep(CHILDCODE SCHMINR4)
			rename SCHMINR4 timesch
			recode timesch (-88 -77 1996 2001 2002=.)		
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			g round=4
			tempfile time4
			save `time4'
				
			* ROUND 5
			use CHILDCODE SCHMINR5 using "$r5occh/OlderChild.dta", clear
			qui append using "$r5ycch/YoungerChild.dta", keep(CHILDCODE SCHMINR5)
			rename SCHMINR5 timesch
			recode timesch (-77 =.)		
			g childid="ET"+string(CHILDCODE, "%06.0f")
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
			merge 1:1 childid round using `highgrade', nogen
			merge 1:1 childid round using `time', nogen
			sort childid round
			tempfile education
			save `education'
			

***** READING AND WRITING *****
 
	* ROUND 1 (OC only)
		
			use childid levlread levlwrit using "$r1oc/etchildlevel8yrold.dta", clear
			recode levlread levlwrit (99=.)
			recode levlwrit (2=3) (3=2) 										// recode for consistency across rounds
			g literate=levlread==4 & levlwrit==3 if levlread!=. & levlwrit!=. 	 // Reads sentence & writes sentences w/o difficulties
			g round=1
			lab val levlread levlwrit .
			tempfile read1
			save `read1'
		
	* ROUND 2 (OC only)
		
			use childid levlread levlwrit using "$r2oc/etchildquest12yrold.dta", clear
			recode levlread levlwrit (99=.)
			g literate=levlread==4 & levlwrit==3 if levlread!=. & levlwrit!=. 	 // Reads sentence & writes sentences w/o difficulties
			g round=2
			tempfile read2
			save `read2'		
		
	* ROUND 3 (YC only)
		
			use childid vrbitm01 vrbitm02 using "$r3yc/et_yc_childlevel.dta", clear
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
			use childid id age sex relate yrschool using "$r1yc\etsubsec2householdroster1.dta", clear
			qui append using "$r1oc\etsubsec2householdroster8.dta", keep(childid id age sex relate yrschool)
			gen father=1 if relate==1 & sex==1
			keep if father==1                                   
			recode relate yrschool (88 99=.)
			recode yrschool (13/16=.)
			rename id dadid
			rename age dadage
			rename yrschool dadedu
			keep childid dad*
			tempfile  dad1
			save     `dad1'						

			use childid daddead using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid daddead)
			rename daddead dadlive 
			recode dadlive (1=2) (2=1) (99=.)
			merge 1:1 childid using `dad1', nogen
			g round=1
			tempfile dad1
			save `dad1'
	
	* ROUND 2
			use  childid id memsex livhse grade age relate using "$r2yc\etsubhouseholdmember5.dta", clear
			qui append using "$r2oc\etsubhouseholdmember12.dta", keep(childid id memsex age relate livhse grade)
			gen father=1 if relate==1 & memsex==1
			keep if father==1
			recode livhse (77 79 88 99=.)
			rename id dadid
			rename age dadage
			rename livhse dadlive
			rename grade dadedu
			recode dadedu (77 79 88 99=.)
			keep childid dad*
			tempfile  dad2
			save     `dad2'

			use childid dadlits using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid dadlits)
			merge 1:1 childid using `dad2', nogen
			g dadcantread=dadlits==3 if dadlits!=.
			replace dadcantread=0 if dadedu>12 & dadedu!=28 & dadedu!=29 & 	dadlits!=.	// corrected literacy for those with postsecondary education.
			drop dadlits
			g round=2
			tempfile dad2
			save `dad2'

	* ROUND 3 (with duplicates: ET171038 dadid=4; ET180029 dadid=19)
			use childid id memsex age relate livhse grade using "$r3yc\et_yc_householdmemberlevel.dta", clear			
			qui append using "$r3oc\et_oc_householdmemberlevel.dta", keep(childid id memsex age relate livhse grade)
			gen father=1 if relate==1 & memsex==1
			keep if father==1
			recode livhse (4=2) (77 79 88 99 5=.)
			recode grade (77=.)
			recode age (1=.)
			rename id dadid
			rename age dadage
			rename livhse dadlive
			rename grade dadedu			
			keep childid dad*		
			drop if childid=="ET171038" & dadid==4
			drop if childid=="ET180029" & dadid==19
			g round=3
			tempfile  dad3
			save     `dad3'					
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRDE18R4 LIVHSER4 YRDIEDR4 using "$r4yc3\ET_R4_YCHH_HouseholdRosterR4.dta", clear
			recode GRDE18R4 (14=13) (15=14) (16=15) (17=30) (77 79 88 99=.) 
			qui append using "$r4oc3\ET_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4)
			recode GRADER4 (18=30) (77 79 88 99=.) 
			recode MEMAGER4 (-88 -77=.)
			replace GRDE18R4=GRADER4 if GRADER4!=.
			gen father=1 if RELATER4==1 & MEMSEXR4==1
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep if father==1	
			recode LIVHSER4 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR4 dadid
			rename MEMAGER4 dadage
			rename LIVHSER4 dadlive
			rename GRDE18R4 dadedu
			rename YRDIEDR4 dadyrdied
			keep childid dad*
			g round=4
			tempfile  dad4
			save     `dad4'				

	* ROUND 5 (2 duplicates: ET071019 dadid=17; ET160066)
			use CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRDE18R5 LIVHSER5 YRDIEDR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			rename GRDE18R5 dadedu
			recode dadedu (13/17 21/27 31=13) (42 43 30 32/39=14) (40=15) (44=30) (77 79 88 99=.) 
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRDE18R5 LIVHSER5 YRDIEDR5)
			recode GRDE18R5 (13/17 21 22 26 43 27 44 31=13) (30 32/39 42 45=14) (40=15) (41=30) (77 79 88 99=.) 
			recode MEMAGER5 (-88 -77 1 2=.)
			replace dadedu=GRDE18R5 if GRDE18R5!=.
			gen father=1 if RELATER5==1 & MEMSEXR5==1
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep if father==1	
			recode LIVHSER5 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR5 dadid
			rename MEMAGER5 dadage
			rename LIVHSER5 dadlive
			rename YRDIEDR5 dadyrdied
			keep childid dad*
			drop if childid=="ET071019" & dadid==17
			drop if childid=="ET160066" & dadid==11
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

	* CORRECTIONS FOR FATHER'S ID (Father should have the same ID across rounds, if different, use ID with most occurences)
	
			/****************************************
			childids with no modes: use most recent
			
							R1	R2	R3	R4	R5
				ET141045	-	1	-	-	6
				ET171028	1	-	18	-	-
			****************************************/	
			
			
			use childid round dadid using `dad', clear
			egen dadid2=mode(dadid), by(childid) 
			replace dadid2=6 if childid=="ET141045"
			replace dadid2=18 if childid=="ET171028"
			drop dadid
			merge 1:1 childid round using `dad', nogen
			recode dadage dadedu dadlive dadyrdied (*=.) if dadid!=dadid2
			drop dadid
			rename dadid2 dadid
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
							  12 "Grade 12" ///
							  13 "Post-secondary, vocational" ///
							  14 "University" ///
							  15 "Masters, doctorate" ///
							  28 "Adult literacy" ///
							  29 "Religious education" ///
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
			use childid id age sex relate yrschool using "$r1yc\etsubsec2householdroster1.dta", clear
			qui append using "$r1oc\etsubsec2householdroster8.dta", keep(childid id age sex relate yrschool)
			gen mother=1 if relate==1 & sex==2
			keep if mother==1                                   
			recode relate yrschool (88 99=.)
			recode yrschool (13/16=.)
			rename id momid
			rename age momage
			rename yrschool momedu
			keep childid mom*
			tempfile  mom1
			save     `mom1'						

			use childid momlive using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid momlive)
			recode momlive (1=2) (2=1) (99=.)
			merge 1:1 childid using `mom1', nogen
			g round=1
			tempfile mom1
			save `mom1'
	
	* ROUND 2
			use  childid id memsex livhse grade age relate using "$r2yc\etsubhouseholdmember5.dta", clear
			qui append using "$r2oc\etsubhouseholdmember12.dta", keep(childid id memsex age relate livhse grade)
			gen mother=1 if relate==1 & memsex==2
			keep if mother==1
			recode livhse (77 79 88 99=.)
			rename id momid
			rename age momage
			rename livhse momlive
			rename grade momedu
			recode momedu (77 79 88 99=.)
			keep childid mom*
			tempfile  mom2
			save     `mom2'

			use childid mumlits using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid mumlits)
			merge 1:1 childid using `mom2', nogen
			g momcantread=mumlits==3 if mumlits!=.
			replace momcantread=0 if momedu>12 & momedu!=28 & momedu!=29 & mumlits!=.		// corrected literacy for those with postsecondary education.
			drop mumlits
			g round=2
			tempfile mom2
			save `mom2'

	* ROUND 3 (with duplicates: ET041002 momid=3; ET161004 momid=18)
			use childid id memsex age relate livhse grade using "$r3yc\et_yc_householdmemberlevel.dta", clear			
			qui append using "$r3oc\et_oc_householdmemberlevel.dta", keep(childid id memsex age relate livhse grade)
			gen mother=1 if relate==1 & memsex==2
			keep if mother==1
			recode livhse (4=2) (77 79 88 99 5=.)
			recode grade (77=.)
			recode age (1=.)
			rename id momid
			rename age momage
			rename livhse momlive
			rename grade momedu			
			keep childid mom*		
			drop if childid=="ET041002" & momid==3
			drop if childid=="ET161004" & momid==18
			g round=3
			tempfile  mom3
			save     `mom3'					
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRDE18R4 LIVHSER4 YRDIEDR4 using "$r4yc3\ET_R4_YCHH_HouseholdRosterR4.dta", clear
			recode GRDE18R4 (14=13) (15=14) (16=15) (17=30) (77 79 88 99=.) 
			qui append using "$r4oc3\ET_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMSEXR4 MEMAGER4 RELATER4 GRADER4 LIVHSER4 YRDIEDR4)
			recode GRADER4 (18=30) (77 79 88 99=.) 
			recode MEMAGER4 (-88 -77=.)
			replace GRDE18R4=GRADER4 if GRADER4!=.
			gen mother=1 if RELATER4==1 & MEMSEXR4==2
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep if mother==1	
			recode LIVHSER4 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR4 momid
			rename MEMAGER4 momage
			rename LIVHSER4 momlive
			rename GRDE18R4 momedu
			rename YRDIEDR4 momyrdied
			keep childid mom*
			g round=4
			tempfile  mom4
			save     `mom4'				

	* ROUND 5 (1 duplicate: ET161030 momid=19)
			use CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRDE18R5 LIVHSER5 YRDIEDR5 using "$r5ychh\HouseholdRosterR5.dta", clear
			rename GRDE18R5 momedu
			recode momedu (13/17 21/27 31=13) (42 43 30 32/39=14) (40=15) (44=30) (77 79 88 99=.) 
			qui append using "$r5ochh\HouseholdRosterR5.dta", keep(CHILDCODE MEMIDR5 MEMSEXR5 MEMAGER5 RELATER5 GRDE18R5 LIVHSER5 YRDIEDR5)
			recode GRDE18R5 (13/17 21 22 26 43 27 44 31=13) (30 32/39 42 45=14) (40=15) (41=30) (77 79 88 99=.) 
			recode MEMAGER5 (-88 -77 1 2=.)
			replace momedu=GRDE18R5 if GRDE18R5!=.
			gen mother=1 if RELATER5==1 & MEMSEXR5==2
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep if mother==1	
			recode LIVHSER5 (4=2) (77 79 88 99 5=.)			
			rename MEMIDR5 momid
			rename MEMAGER5 momage
			rename LIVHSER5 momlive
			rename YRDIEDR5 momyrdied
			keep childid mom*
			drop if childid=="ET161030" & momid==19
			g round=5
			tempfile  mom5
			save     `mom5'					
	
	* MERGE
			use `mom1', clear
			forvalues i=2/5 {
				qui append using `mom`i''
				}					

			tempfile    mom
			save       `mom'		

	* CORRECTIONS FOR MOTHER'S ID (Mother should have the same ID across rounds, use ID with most occurences)
	
			/****************************************
			childid with no modes: use most recent
			
							R1	R2	R3	R4	R5
				ET080018	-	1	1	5	5
			****************************************/	
		
			use childid round momid using `mom', clear
			egen momid2=mode(momid), by(childid) 
			replace momid2=5 if childid=="ET080018"

			drop momid
			merge 1:1 childid round using `mom', nogen
			recode momage momedu momlive momyrdied (*=.) if momid!=momid2
			drop momid
			rename momid2 momid
			
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
							  12 "Grade 12" ///
							  13 "Post-secondary, vocational" ///
							  14 "University" ///
							  15 "Masters, doctorate" ///
							  28 "Adult literacy" ///
							  29 "Religious education" ///
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
	*		2. No caregiver was identified for the older cohort since round 4. *
	*		3. In identifying relationship of caregiver to child,			   *
	*			"2 = non-biological parent" includes step-parent, adoptive	   *
	*					parent, and foster parent.							   *
	*			"5 = sibling" includes step-siblings, half-siblings,		   *
	*					adoptive siblings, and foster siblings.				   *
	*==========================================================================*	

	* ROUND 1
			use childid careid literany head using "$r1yc\etchildlevel1yrold.dta", clear
			merge 1:m childid using "$r1yc\etsubsec2householdroster1.dta", nogen keepusing(childid id age sex relate yrschool)
			tempfile careyc1
			save `careyc1'
			use childid careid literany head using "$r1oc\etchildlevel8yrold.dta", clear
			merge 1:m childid using "$r1oc\etsubsec2householdroster8.dta", nogen keepusing(childid id age sex relate yrschool)
			qui append using `careyc1'
			keep if id==careid
			recode literany head relate yrschool (88 99=.)
			recode yrschool (13/16=.)
			rename age careage
			rename sex caresex
			rename head carehead
			rename relate carerel
			recode carerel (1=1) (2=2) (3=3) (4=4) (5 10 12=5) (6 8 9 11=6) (7=7)	
			g carecantread=literany==3 if literany!=.
			rename yrschool caredu
			keep childid care*
			g round=1
			tempfile care1
			save `care1'
			
			* Correct relationship of caregiver to child if carerel=13 using round 2 data
			use childid id relate using "$r2yc\etsubhouseholdmember5.dta", clear
			qui append using "$r2oc\etsubhouseholdmember12.dta", keep(childid id relate)
			recode relate (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7)
			merge m:1 childid using `care1'
			keep if careid==id | _merge==2
			replace carerel=relate if carerel==13
			keep childid round care*
			tempfile care1
			save `care1'		
		
	* ROUND 2
			use childid careid carelits headid mumid dadid ladder farlad using "$r2yc\etchildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\etsubhouseholdmember5.dta", nogen keepusing(childid id age memsex relate grade chgrade)
			tempfile careyc2
			save `careyc2'
			use childid careid carelits headid mumid dadid ladder farlad using "$r2oc\etchildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc\etsubhouseholdmember12.dta", nogen keepusing(childid id age memsex relate grade chgrade)
			qui append using `careyc2'
			keep if id==careid
			rename age careage
			rename memsex caresex
			g carehead=1 if headid==careid & careid !=.
			replace carehead=2 if mumid==careid & headid==dadid & careid !=.
			recode  carehead (.=3) if careid !=.	
			rename relate carerel
			recode carerel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7)
			rename grade caredu
			replace caredu=chgrade if missing(caredu)
			g carecantread=carelits==3 if carelits!=.	
			replace carecantread=0 if caredu>12 & caredu!=28 & caredu!=29 & carelits!=.		// corrected literacy for those with postsecondary education.
			rename ladder careladder
			rename farlad careldr4yrs
			keep childid care*
			drop carelits
			g round=2
			tempfile care2
			save `care2'			

	* ROUND 3
			use childid pridadr3 primumr3 mumidr3 dadidr3 careidr3 headid ladderr3 farladr3 using "$r3yc/et_yc_householdlevel.dta", clear	
			merge 1:m childid using "$r3yc/et_yc_householdmemberlevel.dta", nogen keepusing(childid id age memsex relate grader3 grade)
			tempfile careyc3
			save `careyc3'
			use childid pridadr3 primumr3 mumidr3 dadidr3 careidr3 headid ladderr3 farladr3 using "$r3oc/et_oc_householdlevel.dta", clear
			merge 1:m childid using "$r3oc/et_oc_householdmemberlevel.dta", nogen keepusing(childid id age memsex relate grader3 grade)
			qui append using `careyc3'
			g careid=mumidr3 if primumr3==1
			replace careid=dadidr3 if pridadr3==1 & missing(careid)
			replace careid=careidr3 if missing(careid)
			recode careid (88 90 =.)			
			replace grader3=grade if missing(grader3)		
			keep if id==careid
			rename age careage
			rename memsex caresex
			g carehead=1 if headid==careid & careid !=.
			replace carehead=2 if mumidr3==careid & headid==dadidr3 & careid !=.
			recode  carehead (.=3) if careid !=.			 
			rename relate carerel
			recode carerel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7)
			rename grader3 caredu
			recode caredu (77=.)
			rename ladderr3 careladder
			rename farladr3 careldr4yrs
			keep childid care*
			drop careidr3
			g round=3
			tempfile care3
			save `care3'			
	
	* ROUND 4 (YC ONLY)
			use CHILDCODE MEMIDR4 RELATER4 MEMSEXR4 MEMAGER4 STRT18R4 GRDE18R4 HSSTRTR4 GRADER4 RELHHR4 PRMCRER4 using "$r4yc3\ET_R4_YCHH_HouseholdRosterR4.dta", clear
			recode GRDE18R4 (14=13) (15=14) (16=15) (17=30) (77 79 88 99=.)
			recode GRADER4 (18=30)
			replace GRDE18R4=GRADER4 if missing(GRDE18R4)
			replace GRDE18R4=0 if STRT18R4==0 | HSSTRTR4==0
			keep if PRMCRER4==1
			duplicates drop CHILDCODE, force
			merge 1:1 CHILDCODE using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", nogen keepusing(CHILDCODE HEADIDR4 LADDERR4 FARLADR4)
			rename MEMIDR4 careid
			rename MEMSEXR4 caresex
			rename MEMAGER4 careage
			rename GRDE18R4 caredu
			g carehead=1 if HEADIDR4==careid & careid !=.
			replace carehead=2 if RELHHR4==0 & careid !=.
			recode  carehead (.=3) if careid !=.
			rename RELATER4 carerel
			recode carerel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			rename LADDERR4 careladder
			rename FARLADR4 careldr4yrs
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep childid care*
			g round=4
			tempfile care4
			save `care4'

	* ROUND 5 (YC ONLY)
			use CHILDCODE MEMIDR5 RELATER5 MEMSEXR5 MEMAGER5 STRT18R5 GRDE18R5 HSSTRTR5 GRADER5 RELHHR5 PRMCRER5 using "$r5ychh\HouseholdRosterR5.dta", clear
			recode GRDE18R5 (13/17 21/27 31=13) (42 43 30 32/39=14) (40=15) (44=30) (77 79 88 99=.) 
			recode GRADER5 (18=30)
			replace GRDE18R5=GRADER5 if missing(GRDE18R5)
			replace GRDE18R5=0 if STRT18R5==0 | HSSTRTR5==0
			keep if PRMCRER5==1
			duplicates drop CHILDCODE, force
			merge 1:1 CHILDCODE using "$r5ychh\YoungerHousehold.dta", nogen keepusing(CHILDCODE HEADIDR5 LADDERR5 FARLADR5)
			rename MEMIDR5 careid
			rename MEMSEXR5 caresex
			rename MEMAGER5 careage
			rename GRDE18R5 caredu
			g carehead=1 if HEADIDR5==careid & careid !=.
			replace carehead=2 if RELHHR5==0 & careid !=.
			recode  carehead (.=3) if careid !=.
			rename RELATER5 carerel
			recode carerel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27 28=6) (20/23=7) (25=8) (26=9)
			rename LADDERR5 careladder
			rename FARLADR5 careldr4yrs
			gen childid="ET"+string(CHILDCODE, "%06.0f")
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
			label var carerel 		"Caregiver's relationship to YL child"
			label var carehead 		"Caregiver's relationship to househod head"
			label var caredu		"Caregiver's level of education"
			label var careladder 	"Caregiver's Ladder - subjective well-being"			
			label var careldr4yrs  	"Caregiver's Ladder (4 years from now) - subjective well-being"
			
			label drop _all
			label define carerel 	1 "Biological parent" 2 "Non-biological parent" 3 "Grandparent" ///
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
							  12 "Grade 12" ///
							  13 "Post-secondary, vocational" ///
							  14 "University" ///
							  15 "Masters, doctorate" ///
							  28 "Adult literacy" ///
							  29 "Religious education" ///
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
			label drop I_FoodConsumption
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

***** HOUSEHOLD WEALTH INDEX AND SUBINDICES *****

			use "$newwealth/et_wi_r1.dta", clear
			forvalues i=2/5 {
				qui append using "$newwealth/et_wi_r`i'.dta"
				}	
			foreach v of varlist wi-cookingq {
				rename `v' `v'_new
				}
	* LABELS

			label var childid		"Child ID"
			label var round		 	"Round of survey"
			label var wi_new 		"Wealth index"										
			label var hq_new  		"Housing quality index"
			label var sv_new  		"Access to services index"
			label var cd_new  		"Consumer durables index"
			label var drwaterq_new  "Access to safe drinking water"
			label var toiletq_new   "Access to sanitation"
			label var elecq_new      "Access to electricity"
			label var cookingq_new   "Access to adequate fuels for cooking"

			order childid round wi hq sv cd drwaterq toiletq elecq cookingq
			tempfile   wealth
			save      `wealth'			


***** LIVESTOCK OWNERSHIP *****
			
	* ROUND 1
			use childid animals anyaim* aniown* using "$r1yc/etchildlevel1yrold.dta", clear    
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid animals anyaim* aniown*)
			recode aniown* (.=0) if animals!=.
			gen aniany  =animals==1
			gen animilk =aniown2
			gen anidrau =aniown1
			gen anirumi =aniown3+aniown4
			g round=1
			keep childid round aniany-anirumi
			tempfile    livestock1
			save       `livestock1'			
	
	* ROUND 2
			use childid animals anyaim* numaim* using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid animals anyaim* numaim*)
			
			* FOUR GROUPS
			recode numaim* (. -88 -77=0)
			gen aniany  =animals==1
			gen animilk =numaim01+numaim02+numaim03+numaim04+numaim05+numaim06
			gen anidrau =numaim07+numaim08+numaim09+numaim10+numaim11+numaim12
			gen anirumi =numaim13+numaim14+numaim15+numaim16+numaim17
			gen anispec =numaim31+numaim32

			* EACH TYPE OF ANIMAL
			gen anicowm=numaim01
			gen anicowt=numaim02
			gen anicalv=numaim03
			gen anibufm=numaim04
			gen anibuft=numaim05
			gen aniheif=numaim06
			gen anibull=numaim07
			gen anihebu=numaim08
			gen anidonk=numaim09
			gen aniybul=numaim10
			gen anioxen=numaim11
			gen anicaml=numaim12
			gen anishee=numaim13
			gen anigoat=numaim14
			gen anipigs=numaim15
			gen anipoul=numaim16
			gen anirabb=numaim17
			gen anibeeh=numaim31
			gen aniothr=numaim32												
			
			gen round=2 
			drop animals anyaim* numaim* 
			tempfile    livestock2
			save       `livestock2'			
	
	* ROUND 3
			use childid animalr3 ayanr3* nmamr3* using "$r3yc\et_yc_householdlevel.dta", clear
			qui append using "$r3oc\et_oc_householdlevel.dta", keep(childid animalr3 ayanr3* nmamr3*)
	
			* FOUR GROUPS
			recode nmamr3* (. -99 -88 -77=0)
			gen aniany  =animalr3==1
			gen animilk =nmamr301+ nmamr302+ nmamr303+ nmamr304+ nmamr305+ nmamr306
			gen anidrau =nmamr307+ nmamr308+ nmamr309+ nmamr310+ nmamr311+ nmamr312
			gen anirumi =nmamr313+ nmamr314+ nmamr315+ nmamr316+ nmamr317
			gen anispec =nmamr331+ nmamr332

			* EACH TYPE OF ANIMAL
			gen anicowm=nmamr301
			gen anicowt=nmamr302
			gen anicalv=nmamr303
			gen anibufm=nmamr304
			gen anibuft=nmamr305
			gen aniheif=nmamr306
			gen anibull=nmamr307
			gen anihebu=nmamr308
			gen anidonk=nmamr309
			gen aniybul=nmamr310
			gen anioxen=nmamr311
			gen anicaml=nmamr312
			gen anishee=nmamr313
			gen anigoat=nmamr314
			gen anipigs=nmamr315
			gen anipoul=nmamr316
			gen anirabb=nmamr317
			gen anibeeh=nmamr331
			gen aniothr=nmamr332												
			
			gen round=3 
			drop animalr3 ayanr3* nmamr3* 
			tempfile    livestock3
			save       `livestock3'
	
	* ROUND 4
			use AYANR4 NMAMR4 CHILDCODE LVSKIDR4 using "$r4yc3\ET_R4_YCHH_LivelihoodsLivestock.dta", clear
			qui append using "$r4oc3\ET_R4_OCHH_LivelihoodsLivestock.dta", keep(AYANR4 NMAMR4 CHILDCODE LVSKIDR4)
			reshape wide AYANR4 NMAMR4, i(CHILDCODE) j(LVSKIDR4)
			recode AYANR4* NMAMR* (.=0)
			rename *, lower 
			order childcode ayanr4* nmamr4* 
			gen aniany=ayanr41==1
			foreach var of varlist ayanr42-ayanr432{ 
				replace aniany=1 if `var'==1
				}
			
			* FOUR GROUPS			
			gen animilk =nmamr41 	+ nmamr42 	+ nmamr43 	+ nmamr44  + nmamr45  + nmamr46
			gen anidrau =nmamr47 	+ nmamr48 	+ nmamr49 	+ nmamr410 + nmamr411 + nmamr412
			gen anirumi =nmamr413 	+ nmamr414 	+ nmamr415 	+ nmamr416 + nmamr417
			gen anispec =nmamr431 	+ nmamr432

			* EACH TYPE OF ANIMAL			
			gen anicowm=nmamr41
			gen anicowt=nmamr42
			gen anicalv=nmamr43
			gen anibufm=nmamr44
			gen anibuft=nmamr45
			gen aniheif=nmamr46
			gen anibull=nmamr47
			gen anihebu=nmamr48
			gen anidonk=nmamr49
			gen aniybul=nmamr410
			gen anioxen=nmamr411
			gen anicaml=nmamr412
			gen anishee=nmamr413
			gen anigoat=nmamr414
			gen anipigs=nmamr415
			gen anipoul=nmamr416
			gen anirabb=nmamr417
			gen anibeeh=nmamr431
			gen aniothr=nmamr432

			gen round=4
			gen childid="ET"+string(childcode, "%06.0f")
			drop ayanr4* nmamr4* childcode
			tempfile    livestock4
			save       `livestock4'
			
	* ROUND 5
			use AYANR5 OTHLIVR5 NMAMR5 CHILDCODE LVSKIDR5 using "$r5ychh\LivelihoodsLivestock.dta", clear
			qui append using "$r5ochh\LivelihoodsLivestock.dta", keep(AYANR5 OTHLIVR5 NMAMR5 CHILDCODE LVSKIDR5)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop  CHILDCODE
			reshape wide AYANR5 OTHLIVR5 NMAMR5, i(childid) j(LVSKIDR5)
			recode AYANR5* NMAMR* (.=0)
			rename *, lower 
			order childid ayanr5* nmamr5* othlivr5*
			gen aniany=ayanr51==1
			replace ayanr53=ayanr53+ayanr533								// combine modern and traditional calves for consistency across rounds
			replace nmamr53=nmamr53+nmamr533
			foreach var of varlist ayanr52-ayanr532{ 
				replace aniany=1 if `var'==1
				}
			
			* FOUR GROUPS			
			gen animilk =nmamr51 	+ nmamr52 	+ nmamr53 	+ nmamr54  + nmamr55  + nmamr56
			gen anidrau =nmamr57 	+ nmamr58 	+ nmamr59 	+ nmamr510 + nmamr511 + nmamr512
			gen anirumi =nmamr513 	+ nmamr514 	+ nmamr515 	+ nmamr516 + nmamr517
			gen anispec =nmamr531 	+ nmamr532

			* EACH TYPE OF ANIMAL			
			gen anicowm=nmamr51
			gen anicowt=nmamr52
			gen anicalv=nmamr53
			gen anibufm=nmamr54
			gen anibuft=nmamr55
			gen aniheif=nmamr56
			gen anibull=nmamr57
			gen anihebu=nmamr58
			gen anidonk=nmamr59
			gen aniybul=nmamr510
			gen anioxen=nmamr511
			gen anicaml=nmamr512
			gen anishee=nmamr513
			gen anigoat=nmamr514
			gen anipigs=nmamr515
			gen anipoul=nmamr516
			gen anirabb=nmamr517
			gen anibeeh=nmamr531
			gen aniothr=nmamr532

			gen round=5
			drop ayanr5* nmamr5* othlivr5*
			tempfile    livestock5
			save       `livestock5'			

	* MERGE
			use `livestock1', clear
			forvalues i=2/5 {
				qui append using `livestock`i''
				}			
	
	* LABEL VARIABLES
			label var aniany  "Household owned any livestock in the past 12 months"
			label var animilk "Number of MILK animals in the household"
			label var anidrau "Number of DRAUGHT animals owned by the hh"
			label var anirumi "Number of SMALL RUMIANTS animals owned by the hh"
			label var anispec "Number of OTHER animals (specific to country)"	
			label var anicowm "Number of (modern) cows"
			label var anicowt "Number of (traditional) cows"
			label var anicalv "Number of calves (modern and traditional)"
			label var anibufm "Number of (modern) buffalos"
			label var anibuft "Number of (traditional) buffalos"
			label var aniheif "Number of heifers"
			label var anibull "Number of bullocks"
			label var anihebu "Number of he-buffalos"							
			label var anidonk "Number of donkeys, horses, mules"
			label var aniybul "Number of young bulls"
			label var anioxen "Number of oxen"
			label var anicaml "Number of camels"
			label var anishee "Number of sheep"
			label var anigoat "Number of goats"
			label var anipigs "Number of pigs"
			label var anipoul "Number of poultry/birds"							
			label var anirabb "Number of rabbits"
			label var anibeeh "Number of beehives"
			label var aniothr "Number of other livestock"
			label var childid "Child ID"
			label var round "Round of survey"
			sort childid round
			order childid round
			tempfile   livestock
			save      `livestock'
	
***** LAND AND HOUSE OWNERSHIP *****

	* ROUND 1
			use childid ownhouse using "$r1yc/etchildlevel1yrold.dta", clear               
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid ownhouse)	
			g ownlandhse=ownhouse==1 if ownhouse!=.
			keep childid ownlandhse 
			g round=1
			tempfile  land1
			save     `land1'
			
	* ROUND 2
			use childid plotid lown luse using "$r2yc\etsubplotsofland5.dta", clear            
			qui append using "$r2oc\etsubplotsofland12.dta", keep(childid plotid lown luse)
			g accomm=lown==1 if luse>=1 & luse<=4
			bys childid: egen ownlandhse=max(accomm)
			keep childid ownlandhse 
			duplicates drop
			tempfile  land2
			save     `land2'
			
			use childid ownhouse using "$r2yc\etchildlevel5yrold.dta", clear
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid ownhouse)
			recode ownhouse (77 79 88 99=.)
			merge 1:1 childid using `land2', nogen
			g round=2
			tempfile  land2
			save     `land2'			
	
	* ROUND 3
			use childid  plotid lownr3 luser3 using  "$r3yc\et_yc_stblhhsec3plots.dta", clear        
			qui append using "$r3oc\et_oc_stblhhsec3plots.dta", keep(childid  plotid lownr3 luser3)			
			g accomm=lownr3==1 if luser3>=1 & luser3<=4
			bys childid: egen ownlandhse=max(accomm)
			keep childid ownlandhse 
			duplicates drop
			tempfile  land3
			save     `land3'	
			
			use childid ownhser3 using "$r3yc\et_yc_householdlevel.dta", clear
			qui append using "$r3oc\et_oc_householdlevel.dta", keep(childid ownhser3)
			recode ownhser3 (77 88 99=.)
			rename ownhser3 ownhouse
			merge 1:1 childid using `land3', nogen
			g round=3
			tempfile land3
			save `land3'

	* ROUND 4
			use CHILDCODE PLOTIDR4 PLTUSER4 PLTDSCR4 using "$r4yc3\ET_R4_YCHH_Plots.dta", clear 
			recode PLTUSER4 PLTDSCR4 (77 99=.)
			g accomm=PLTDSCR4==1 if PLTUSER4>=1 & PLTUSER4<=4
			bys CHILDCODE: egen ownlandhse=max(accomm)
			keep CHILDCODE ownlandhse 
			duplicates drop
			tempfile  land4yc
			save     `land4yc'			
			
			use  "$r4oc3\ET_R4_OCHH_LandType.dta", clear
			g accomm=1 if LANDIDR4==1 & ANYLIVR4=="Y"
			replace accomm=0 if missing(accomm)
			bys CHILDCODE: egen ownlandhse=max(accomm)
			keep CHILDCODE ownlandhse 
			duplicates drop
			tempfile land4oc
			save `land4oc'
			qui append using `land4yc'
			tempfile land4
			save `land4'
			
			use CHILDCODE OWNHSER4 using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", clear
			qui append using "$r4oc3\ET_R4_OCHH_OlderHousehold.dta", keep(CHILDCODE OWNHSER4)
			rename OWNHSER4 ownhouse
			merge 1:1 CHILDCODE using `land4', nogen
			g childid="ET"+string(CHILDCODE,"%06.0f")
			drop CHILDCODE
			g round=4
			tempfile land4
			save `land4'			
	
	* ROUND 5
			use CHILDCODE LANDIDR5 PLTUSAR5 USEINDR5 using "$r5ychh\LandType.dta", clear
			g accomm=LANDIDR5==1 if USEINDR5>=1 & USEINDR5<=5
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
			g childid="ET"+string(CHILDCODE,"%06.0f")
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

***** COUNTRY-SPECIFIC PUBLIC PROGRAMMES *****

	* ROUND 1 (NO DATA)
	
	* ROUND 2 (NO DATA)
	
	* ROUND 3
			use childid psnprgr3 drsprgr3 ofsprgr3 using "$r3yc/et_yc_householdlevel.dta", clear
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid psnprgr3 drsprgr3 ofsprgr3)
			rename psnprgr3 psnp_pw
			rename drsprgr3 psnp_ds
			rename ofsprgr3 othprog
			g round=3
			tempfile program3
			save `program3'
		
	* ROUND 4
			use CHILDCODE RCVHEPR4 PSNPRGR4 DRSPRGR4 OFSPRGR4 RESTTLR4 using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", clear
			rename RCVHEPR4 HEXBENR4
			rename OFSPRGR4 OTHPRR4
			rename RESTTLR4 RESETR4
			qui append using "$r4oc3\ET_R4_OCHH_OlderHousehold.dta", keep(CHILDCODE HEXBENR4 PSNPRGR4 DRSPRGR4 OTHPRR4 RESETR4 EMAIDR4)
			recode HEXBENR4 PSNPRGR4 DRSPRGR4 OTHPRR4 RESETR4 EMAIDR4 (77=.)  
			rename HEXBENR4 hep
			rename PSNPRGR4 psnp_pw
			rename DRSPRGR4 psnp_ds
			rename OTHPRR4 othprog
			rename RESETR4 resettled
			rename EMAIDR4 eap
			g round=4
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile program4
			save `program4'
	
	* ROUND 5
			use CHILDCODE RCVHEPR5 PSNPRGR5 DRSPRGR5 OFSPRGR5 RESTTLR5 EMAIDR5 using "$r5ychh\YoungerHousehold.dta", clear
			qui append using "$r5ochh\OlderHousehold.dta", keep(CHILDCODE RCVHEPR5 PSNPRGR5 DRSPRGR5 OFSPRGR5 RESTTLR5 EMAIDR5)
			recode RCVHEPR5 PSNPRGR5 DRSPRGR5 OFSPRGR5 RESTTLR5 EMAIDR5 (77=.)
			rename RCVHEPR5 hep
			rename PSNPRGR5 psnp_pw
			rename DRSPRGR5 psnp_ds
			rename OFSPRGR5 othprog
			rename RESTTLR5 resettled
			rename EMAIDR5 eap
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile program5
			save `program5'			
			
	* MERGE
			use `program3', clear
			forvalues i=4/5 {
				qui append using `program`i''
				}	

	* LABEL
			lab var hep 		"At least one member is a beneficiary of the Health Extension Programme"
			lab var psnp_pw 	"At least one member is a beneficiary of the PSNP-Public Works Programme in the past 12 mos"
			lab var psnp_ds 	"At least one member is a beneficiary of the PSNP-Direct Support Programme in the past 12 mos"
			lab var eap 		"At least one member is a beneficiary of the Emergency Aid Programme since the previous round"
			lab var othprog 	"Household has received support from other security programmes in the past 12 mos"	
			lab var resettled 	"At least one member got resettled by the government since the previous round"
			label define yesno 1 "yes" 0 "no"
			label values hep psnp_pw psnp_ds eap othprog resettled yesno	
			sort childid round
			order childid round
			tempfile   program
			save      `program'						

			
***** CREDIT AND FOOD SECURITY **** 			
			
	* ROUND 1 (NO DATA)
	
	* ROUND 2 (NO DATA)
	
	* ROUND 3
			use childid fdhomer3 using "$r3yc/et_yc_householdlevel.dta", clear
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid fdhomer3)
			recode fdhomer3 (77 88 99=.)
			rename fdhomer3 foodsec
			g round=3
			tempfile foodsec3
			save `foodsec3'
			
	* ROUND 4
			use CHILDCODE FDHOMER4 CREDITR4 using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", clear
			rename CREDITR4 ETCRDTR4
			qui append using "$r4oc3\ET_R4_OCHH_OlderHousehold.dta", keep(CHILDCODE ETCRDTR4)
			recode FDHOMER4 ETCRDTR4 (77 79 88=.)
			rename FDHOMER4 foodsec
			rename ETCRDTR4 credit
			g round=4
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile foodsec4
			save `foodsec4'
	
	* ROUND 5
			use CHILDCODE FDHOMER5 CREDITR5 using "$r5ychh\YoungerHousehold.dta", clear
			qui append using "$r5ochh\OlderHousehold.dta", keep(CHILDCODE CREDITR5)
			recode FDHOMER5 CREDITR5 (77 79 88=.)
			rename FDHOMER5 foodsec
			rename CREDITR5 credit
			g round=5
			g childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			tempfile foodsec5
			save `foodsec5'
			
	* MERGE
			use `foodsec3', clear
			forvalues i=4/5 {
				qui append using `foodsec`i''
				}	

	* LABEL
			lab var credit	"Household has obtained loan or credit since the previous round"
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
			use childid headid using "$r1yc/etchildlevel1yrold.dta", clear
			merge 1:m childid using "$r1yc/etsubsec2householdroster1.dta", nogen keepusing(childid id sex age relate yrschool)
			keep if id==headid
			tempfile     headinfo1yc
			save        `headinfo1yc'		
			use childid headid using "$r1oc/etchildlevel8yrold.dta", clear
			merge 1:m childid using "$r1oc/etsubsec2householdroster8.dta", nogen keepusing(childid id sex age relate yrschool)
			keep if id==headid	
 			qui append using `headinfo1yc'          
			recode relate (88 99=.)
			rename relate headrel 
			recode headrel (1=1) (2=2) (3=3) (4=4) (5 10 12=5) (6 8 9 11=6) (7=7)
			rename age headage 
			rename sex headsex
			recode yrschool (13/16 88 99=.)
			rename yrschool headedu
			keep childid headsex headage headedu headid headrel
			gen round=1
			tempfile    head1
			save       `head1'
			
			* Correct relationship of household head to child if headrel=13 using round 2 data
			use childid id relate using "$r2yc\etsubhouseholdmember5.dta", clear
			qui append using "$r2oc\etsubhouseholdmember12.dta", keep(childid id relate)
			recode relate (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7)			
			merge m:1 childid using `head1'
			keep if headid==id | _merge==2
			replace headrel=relate if headrel==13
			keep childid round head*
			tempfile head1
			save `head1'		

			
	* ROUND 2
			use childid headid using "$r2yc\etchildlevel5yrold.dta", clear
			merge 1:m childid using "$r2yc\etsubhouseholdmember5.dta", nogen keepusing(childid id relate memsex age grade chgrade)
			keep if id==headid
			tempfile     headinfo2yc
			save        `headinfo2yc'			
			use childid headid using "$r2oc/etchildlevel12yrold.dta", clear
			merge 1:m childid using "$r2oc/etsubhouseholdmember12.dta", nogen keepusing(childid id relate memsex age grade chgrade)
			keep if id==headid			
			qui append using `headinfo2yc'			
			replace grade=chgrade if missing(grade)
			rename age headage
			rename memsex headsex
			rename grade headedu
			rename relate headrel
			recode headrel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7)
			keep childid headsex headage headedu headid headrel
			gen round=2
			tempfile    head2
			save       `head2'			
			
	* ROUND 3
			use childid headid using "$r3yc\et_yc_householdlevel.dta", clear
			merge 1:m childid using "$r3yc\et_yc_householdmemberlevel.dta", nogen keepusing(childid id relate memsex age grade grader3)
			keep if id==headid
			tempfile     headinfo3yc
			save        `headinfo3yc'
			use childid headid using "$r3oc\et_oc_householdlevel.dta", clear
			merge 1:m childid using "$r3oc\et_oc_householdmemberlevel.dta", nogen keepusing(childid id relate memsex grader3 grade age)
			keep if id==headid
			qui append using `headinfo3yc'
			replace grade=grader3 if missing(grade)
			recode grade (77=.)
			rename age headage
			rename memsex headsex
			rename grade headedu
			rename relate headrel
			recode headrel (1=1) (2 3 4=2) (5 6=3) (13=4) (7/12=5) (14/19=6) (20/23=7) (24 29=.)
			keep childid headsex headage headedu headid headrel
			gen round=3
			tempfile    head3
			save       `head3'						
			
	* ROUND 4
			use CHILDCODE HEADIDR4 using "$r4yc3\ET_R4_YCHH_YoungerHousehold.dta", clear
			merge 1:m CHILDCODE using "$r4yc3\ET_R4_YCHH_HouseholdRosterR4.dta", nogen /// 
						keepusing(CHILDCODE MEMIDR4 RELATER4 MEMSEXR4 MEMAGER4 GRDE18R4 GRADER4 RELATER4)
			recode GRDE18R4 (14=13) (15 16=14) (17=30)
			recode GRADER4 (18=30)
			replace GRDE18R4=GRADER4 if missing(GRDE18R4) 
			drop GRADER4
			keep if MEMIDR4==HEADIDR4
			tempfile     headinfo4yc
			save        `headinfo4yc'			
			use CHILDCODE RELHHR4 MEMIDR4 RELATER4 MEMSEXR4 MEMAGER4 GRADER4 RELATER4 using "$r4oc3\ET_R4_OCHH_HouseholdRosterR4.dta", clear
			recode GRADER4 (18=30)
			keep if RELHHR4==1
			rename MEMIDR4 HEADIDR4 
			duplicates drop CHILDCODE, force
			rename GRADER4 GRDE18R4			
			qui append using `headinfo4yc'
			rename MEMSEXR4 headsex
			rename MEMAGER4 headage
			rename RELATER4 headrel
			recode headrel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27/29=6) (20/23=7) (25=8) (26=9)
			rename HEADIDR4	headid
			rename GRDE18R4 headedu
			recode headedu (77 79 88 99=.)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep childid headsex headage headedu headid headrel
			gen round=4
			tempfile    head4
			save       `head4'				
			
	* ROUND 5	
			use CHILDCODE HEADIDR5 using "$r5ychh\YoungerHousehold.dta", clear
			merge 1:m CHILDCODE using "$r5ychh\HouseholdRosterR5.dta", nogen /// 
						keepusing(CHILDCODE MEMIDR5 RELATER5 MEMSEXR5 MEMAGER5 GRDE18R5 GRADER5 RELATER5)
			recode GRDE18R5 (13/27 31=13) (30 32/43=14) (44=30) (77 79 88 99=.)
			recode GRADER5 (18=30) (77 79 88 99=.)
			replace GRDE18R5=GRADER5 if missing(GRDE18R5) 
			drop GRADER5
			keep if MEMIDR5==HEADIDR5
			tempfile     headinfo5yc
			save        `headinfo5yc'			
			use CHILDCODE HEADIDR5 using "$r5ochh\OlderHousehold.dta", clear
			merge 1:m CHILDCODE using "$r5ochh\HouseholdRosterR5.dta", nogen ///
						keepusing(CHILDCODE RELHHR5 MEMIDR5 RELATER5 MEMSEXR5 MEMAGER5 GRDE18R5 GRADER5 RELATER5)
			recode GRDE18R5 GRADER5 (77 79 88 99=.) (13/17 21 22 26 43 27 44 31=13) (45 30 42 32/39=14) (40=15) (41=30)
			replace GRDE18R5=GRADER5 if missing(GRDE18R5) 
			keep if HEADIDR5==MEMIDR5
			duplicates drop CHILDCODE, force
			qui append using `headinfo5yc'
			rename MEMSEXR5 headsex
			rename MEMAGER5 headage
			rename RELATER5 headrel
			recode headrel (1=1) (2/4 24=2) (5 6=3) (13=4) (7/12=5) (14/19 27/29=6) (20/23=7) (25=8) (26=9)
			rename HEADIDR5	headid
			rename GRDE18R5 headedu
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			keep childid headsex headage headedu headid headrel
			gen round=5
			tempfile    head5
			save       `head5'				
			
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
									0 "YL Child"
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
							  12 "Grade 12" ///
							  13 "Post-secondary, vocational" ///
							  14 "University" ///
							  15 "Masters, doctorate" ///
							  28 "Adult literacy" ///
							  29 "Religious education" ///
							  30 "Other" 
			label values headedu educ

			sort childid round
			tempfile    head
			save       `head'
			
	* CORRECTIONS FOR HOUSEHOLD HEAD EDUCATION
			
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
			replace headedu=momedu if headsex==2 & headrel==1
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
			label drop I_FoodConsumption
			keep if inround==1
			drop inround
			rename headedu headeducorr
			
			merge 1:1 childid round using `head', nogen
			drop headedu
			rename headeducorr headedu

			tempfile    head
			save       `head'
			
			
*********************** HOUSEHOLD SIZE AND COMPOSITION *************************

***** HOUSEHOLD SIZE (count includes YL child) *****

	* ROUND 1
			use childid hhsize using "$r1yc/etchildlevel1yrold.dta", clear
			qui append using "$r1oc/etchildlevel8yrold.dta", keep(childid hhsize)
			gen round=1
			tempfile    hhsize1
			save       `hhsize1'	
		
	* ROUND 2
			use childid hhsize using "$r2yc/etchildlevel5yrold.dta", clear
			qui append using "$r2oc/etchildlevel12yrold.dta", keep(childid hhsize)
			gen round=2
			tempfile    hhsize2
			save       `hhsize2'

	* ROUND 3
			use childid hhsize using "$r3yc/et_yc_householdlevel.dta", clear
			qui append using "$r3oc/et_oc_householdlevel.dta", keep(childid hhsize)
			gen round=3
			tempfile    hhsize3
			save       `hhsize3'

	* ROUND 4
			use "$r4oc3/OC_hhsize.dta", clear
			qui append using "$r4yc3/ET_R4_YCHH_YoungerHousehold.dta", keep(CHILDCODE hhsize)
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			gen round=4
			tempfile    hhsize4
			save       `hhsize4'
			
	* ROUND 5
			use CHILDCODE hhsizer5 using "$r5wealth/et_r5_yc_hh_hhsize_wi.dta", clear
			qui append using "$r5wealth/et_r5_oc_hh_hhsize_wi.dta", keep(CHILDCODE hhsizer5)
			rename hhsizer5 hhsize
			gen childid="ET"+string(CHILDCODE, "%06.0f")
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

			
***** SEX AND AGE COMPOSITION OF HOUSEHOLD MEMBERS (excluding YL child) *****

	* ROUND 1
			use childid id age sex using "$r1yc/etsubsec2householdroster1.dta", clear
			qui append using "$r1oc/etsubsec2householdroster8.dta", keep(childid id age sex)
			tempfile    roster1
			save       `roster1'
				
	* ROUND 2
			use childid id age memsex livhse using "$r2yc/etsubhouseholdmember5.dta", clear
			qui append using "$r2oc/etsubhouseholdmember12.dta", keep(childid id age memsex livhse)
			keep if livhse==1
			drop if id==0
			rename memsex sex
			tempfile    roster2
			save       `roster2'	

	* ROUND 3
			use childid id age memsex livhse using "$r3yc/et_yc_householdmemberlevel.dta", clear
			qui append using "$r3oc/et_oc_householdmemberlevel.dta", keep(childid id age memsex livhse)
			keep if livhse==1			
			drop if id==0
			rename memsex sex
			tempfile    roster3
			save       `roster3'
			
	* ROUND 4
			use CHILDCODE MEMIDR4 MEMAGER4 MEMSEXR4 LIVHSER4 using "$r4yc3/ET_R4_YCHH_HouseholdRosterR4.dta", clear
			qui append using "$r4oc3/ET_R4_OCHH_HouseholdRosterR4.dta", keep(CHILDCODE MEMIDR4 MEMAGER4 MEMSEXR4 LIVHSER4)
			keep if LIVHSER4==1
			drop if MEMIDR4==0
			gen childid="ET"+string(CHILDCODE, "%06.0f")
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
			gen childid="ET"+string(CHILDCODE, "%06.0f")
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
			label var hhsize	  "Household size"
			label var childid 	  "Child ID"
			label var round		  "Round of survey"
			tempfile   hhcomposition
			save      `hhcomposition'
			
			
***** HOUSEHOLD SHOCKS *****
		
		*---------------------------------------------------------------------------------------------------* 	
		*	Shocks are events that happened that had a negative effect on households' economic situation.	*
		*	In round 1, time reference is "since biological mother was pregnant to YL child". 				*
		*	In rounds 2 to 5, time reference is "since previous round". 									*		
		*---------------------------------------------------------------------------------------------------* 	
		
		* ROUND 1
			use childid phychnge-hhoth using "$r1yc\etchildlevel1yrold.dta", clear
			qui append using "$r1oc\etchildlevel8yrold.dta", keep(childid phychnge-hhoth)

			gen shcrime1=.
			gen shcrime2=.
			gen shcrime3=hhcstl==1 
			gen shcrime4=hhlstl==1
			gen shcrime5=.
			gen shcrime6=.
			gen shcrime7=.
			gen shcrime8=hhcrime==1

			gen shregul1=.
			gen shregul2=.
			gen shregul3=.
			gen shregul4=.
			gen shregul5=.

			gen shecon1=.
			gen shecon2=.
			gen shecon3=hhlstck==1
			gen shecon4=.
			gen shecon5=hhjob==1
			gen shecon6=.
			gen shecon7=.
			gen shecon8=.
			gen shecon9=.
			gen shecon10=.
			gen shecon11=.
			gen shecon12=.
			gen shecon13=.
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
			gen shfam11=.
			gen shfam12=hhdeath==1
			gen shfam13=hhill==1
			gen shfam14=hhmove==1
			gen shfam18=.
									
			gen shother=hhoth==1

			keep childid sh*
			gen round=1
			tempfile shocks1
			save    `shocks1'

		*ROUND 2

			use childid event* using "$r2yc\etchildlevel5yrold.dta", clear  
			qui append using "$r2oc\etchildlevel12yrold.dta", keep(childid event*)

			gen shcrime1=event01==1
			gen shcrime2=event02==1
			gen shcrime3=event03==1
			gen shcrime4=event04==1
			gen shcrime5=event05==1
			gen shcrime6=event06==1
			gen shcrime7=.
			gen shcrime8=.

			gen shregul1=event07==1
			gen shregul2=event08==1
			gen shregul3=event09==1
			gen shregul4=event10==1
			gen shregul5=event11==1

			gen shecon1=event12==1
			gen shecon2=event13==1
			gen shecon3=event14==1
			gen shecon4=event15==1
			gen shecon5=event16==1
			gen shecon6=event17==1
			gen shecon7=event18==1
			gen shecon8=event19==1
			gen shecon9=event20==1
			gen shecon10=event21==1
			gen shecon11=event22==1
			gen shecon12=event23==1
			gen shecon13=.
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
			gen shfam10=event43==1
			gen shfam11=event44==1
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam18=.			

			gen shother=event45==1 | event46==1
			
			keep childid sh*
			gen round=2
			tempfile shocks2
			save    `shocks2'

		* ROUND 3

			use childid evntr* using "$r3yc\et_yc_householdlevel.dta", clear
			qui append using "$r3oc\et_oc_householdlevel.dta", keep(childid evntr*)

			gen shcrime1=.
			gen shcrime2=.
			gen shcrime3=.
			gen shcrime4=.
			gen shcrime5=.
			gen shcrime6=.
			gen shcrime7=evntr301==1 
			gen shcrime8=.

			gen shregul1=.
			gen shregul2=.
			gen shregul3=.
			gen shregul4=evntr310==1
			gen shregul5=.
			
			gen shecon1=evntr312==1
			gen shecon2=evntr313==1
			gen shecon3=evntr314==1
			gen shecon4=.
			gen shecon5=evntr316==1
			gen shecon6=.
			gen shecon7=.
			gen shecon8=.
			gen shecon9=.
			gen shecon10=.
			gen shecon11=.
			gen shecon12=evntr323==1
			gen shecon13=evntr347==1
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

			gen shhouse1=.
			gen shhouse2=.
			gen shhouse3=evntr332==1

			gen shfam1=evntr334==1
			gen shfam2=evntr335==1
			gen shfam3=evntr336==1
			gen shfam4=evntr337==1
			gen shfam5=evntr338==1
			gen shfam6=evntr339==1
			gen shfam7=evntr340==1
			gen shfam8=evntr341==1
			gen shfam9=evntr342==1
			gen shfam10=.
			gen shfam11=.
			gen shfam12=.
			gen shfam13=.
			gen shfam14=.
			gen shfam18=.
						
			gen shother=evntr345==1

			keep childid sh* 
			gen round=3
			tempfile shocks3
			save    `shocks3'
			
		
		* ROUND 4

			use   "$r4yc3\ET_R4_YCHH_Shocks.dta", clear
			qui append using "$r4oc3\ET_R4_OCHH_Shocks.dta"
			
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			recode EVNTR4 (77=.)
			keep childid SHCKIDR4 EVNTR4
			reshape wide EVNTR4, i(childid) j(SHCKIDR4)

			gen shcrime1	=.
			gen shcrime2	=.
			gen shcrime3	=. 
			gen shcrime4	=. 
			gen shcrime5 	=.
			gen shcrime6 	=. 
			gen shcrime7 	=EVNTR41==1
			gen shcrime8 	=. 

			gen shregul1 	=. 
			gen shregul2 	=. 
			gen shregul3 	=. 
			gen shregul4 	=EVNTR410==1
			gen	shregul5 	=. 

			gen	 shecon1 	=EVNTR412==1
			gen	 shecon2 	=EVNTR413==1
			gen	 shecon3 	=EVNTR414==1
			gen	 shecon4 	=. 
			gen	 shecon5 	=EVNTR416==1
			gen	 shecon6 	=. 
			gen	 shecon7 	=. 
			gen	 shecon8 	=. 
			gen	 shecon9 	=. 
			gen	 shecon10 	=. 
			gen	 shecon11 	=. 
			gen	 shecon12 	=EVNTR423==1
			gen	 shecon13 	=EVNTR447==1
			gen	 shecon14 	=. 

			gen	 shenv1 	=EVNTR424==1
			gen	 shenv2 	=EVNTR425==1
			gen	 shenv3 	=EVNTR426==1
			gen	 shenv4 	=EVNTR427==1
			gen	 shenv5 	=EVNTR428==1
			gen	 shenv6 	=EVNTR429==1
			gen	 shenv7 	=EVNTR430==1
			gen	 shenv8 	=EVNTR431==1
			gen	 shenv9 	=. 
			
			gen	 shhouse1 	=. 
			gen	 shhouse2 	=. 
			gen	 shhouse3 	=EVNTR432==1

			gen	 shfam1 	=EVNTR434==1
			gen	 shfam2 	=EVNTR435==1
			gen	 shfam3 	=EVNTR436==1
			gen	 shfam4 	=EVNTR437==1
			gen	 shfam5 	=EVNTR438==1
			gen	 shfam6 	=EVNTR439==1
			gen	 shfam7 	=EVNTR440==1
			gen	 shfam8 	=EVNTR441==1
			gen	 shfam9 	=EVNTR442==1
			gen	 shfam10 	=. 
			gen	 shfam11 	=. 
			gen	 shfam12 	=. 
			gen	 shfam13 	=. 
			gen	 shfam14 	=. 
			gen	 shfam18 	=EVNTR461==1
			 
			gen	 shother	=EVNTR445==1	
			
			keep childid sh*
			gen round=4
			
			tempfile shocks4
			save    `shocks4'

		* ROUND 5

			use   "$r5ychh\Shocks.dta", clear
			qui append using "$r5ochh\Shocks.dta"
			
			gen childid="ET"+string(CHILDCODE, "%06.0f")
			drop CHILDCODE
			recode EVNTR5 (77=.)
			keep childid SHCKIDR5 EVNTR5
			reshape wide EVNTR5, i(childid) j(SHCKIDR5)

			gen shcrime1	=.
			gen shcrime2	=.
			gen shcrime3	=. 
			gen shcrime4	=. 
			gen shcrime5 	=.
			gen shcrime6 	=. 
			gen shcrime7 	=EVNTR51==1
			gen shcrime8 	=. 

			gen shregul1 	=. 
			gen shregul2 	=. 
			gen shregul3 	=. 
			gen shregul4 	=EVNTR510==1
			gen	shregul5 	=. 

			gen	 shecon1 	=EVNTR512==1
			gen	 shecon2 	=EVNTR513==1
			gen	 shecon3 	=EVNTR514==1
			gen	 shecon4 	=. 
			gen	 shecon5 	=EVNTR516==1
			gen	 shecon6 	=. 
			gen	 shecon7 	=. 
			gen	 shecon8 	=. 
			gen	 shecon9 	=. 
			gen	 shecon10 	=. 
			gen	 shecon11 	=. 
			gen	 shecon12 	=EVNTR523==1
			gen	 shecon13 	=EVNTR547==1
			gen	 shecon14 	=. 

			gen	 shenv1 	=EVNTR524==1
			gen	 shenv2 	=EVNTR525==1
			gen	 shenv3 	=EVNTR526==1
			gen	 shenv4 	=EVNTR527==1
			gen	 shenv5 	=EVNTR528==1
			gen	 shenv6 	=EVNTR529==1
			gen	 shenv7 	=EVNTR530==1
			gen	 shenv8 	=EVNTR531==1
			gen	 shenv9 	=. 
			
			gen	 shhouse1 	=. 
			gen	 shhouse2 	=. 
			gen	 shhouse3 	=EVNTR532==1

			gen	 shfam1 	=EVNTR534==1
			gen	 shfam2 	=EVNTR535==1
			gen	 shfam3 	=EVNTR536==1
			gen	 shfam4 	=EVNTR537==1
			gen	 shfam5 	=EVNTR538==1
			gen	 shfam6 	=EVNTR539==1
			gen	 shfam7 	=EVNTR540==1
			gen	 shfam8 	=EVNTR541==1
			gen	 shfam9 	=EVNTR542==1
			gen	 shfam10 	=. 
			gen	 shfam11 	=. 
			gen	 shfam12 	=. 
			gen	 shfam13 	=. 
			gen	 shfam14 	=. 
			gen	 shfam18 	=EVNTR561==1
			 
			gen	 shother	=EVNTR545==1	
			
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
			label var shcrime7 	"shock-theft/destruction of cash, crops, livestock"
			label var shcrime8 	"shock-victim of crime"

			label var shregul1 	"shock-land redistribution"
			label var shregul2 	"shock-resettlement or forced migration"
			label var shregul3 	"shock-restrictions on migration"
			label var shregul4 	"shock-forced contributions"
			label var shregul5 	"shock-eviction"

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
			label var shecon13 	"shock-increase in food prices"
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
			label var shfam11 	"shock-conscription, abduction or draft"
			label var shfam12 	"shock-death/ reduction hh members"
			label var shfam13 	"shock-severe illness or injury"
			label var shfam14 	"shock-move/ migration"
			label var shfam18	"shock-illness of non-household member"
			
			label var shother 	"shock-others"
			
			sort childid  round
			tempfile      hhshocks
			save         `hhshocks'

			
/*-----------------------------------------------------------------------------*
							MERGING ALL SUBFILES
------------------------------------------------------------------------------*/

***** Indicator if child has died *****			

			use "$dead\yldeathsr2-r5.dta", clear
			keep if country=="Ethiopia"
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
			tempfile id
			save `id'
			
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

			order childid yc round inround panel deceased
			sort childid round
			save "$output\ethiopia_constructed.dta", replace
			
* END OF DO FILE  :) *		
