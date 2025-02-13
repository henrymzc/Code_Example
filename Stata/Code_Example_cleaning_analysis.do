*************** Last modified: 09/02/2024*************

set scheme s1color
clear all
set more off
global filepath "~/Dropbox/Research_shared/new (with Arnaud Daniel Zhangchi)" //change file path 
cd "$filepath"
global Demo_Controls " AGE FEMALE Black Hispanic Asian Some_College College_Above PT" // Specific control variables

program replace_missing_value		
	*******************  0. Replace Missing Value ****************
	replace SF1 = . if SF1 == 9999999998
	replace SF2 = . if SF2 == 998
	replace SF3 = . if SF3 >= 77

	replace PRE_SB1 = . if PRE_SB1>=8
	replace PRE_SB2 = . if PRE_SB2==7777777777 | PRE_SB2==9999999998 | PRE_SB2==9999999999 
	replace PRE_SB3 = . if PRE_SB3==777 | PRE_SB3==998 | PRE_SB3==999 
	replace PRE_SB4 = . if PRE_SB4==7777777777 | PRE_SB4==9999999998 | PRE_SB4==9999999999 
	replace POS_SB1 = . if POS_SB1>=8
	replace POS_SB2 = . if POS_SB2==7777777777 | POS_SB2==9999999998 | POS_SB2==9999999999 
	replace POS_SB3 = . if POS_SB3==777 | POS_SB3==998 | POS_SB3==999 
	replace POS_SB4 = . if POS_SB4==7777777777 | POS_SB4==9999999998 | POS_SB4==9999999999 

	replace PRE_CB1 = . if PRE_CB1==7777777777 | PRE_CB1==9999999998 | PRE_CB1==9999999999 
	replace PRE_CB2 = . if PRE_CB2==777 | PRE_CB2==998 | PRE_CB2==999 
	replace PRE_CB3 = . if PRE_CB3>=8
	replace PRE_CB4 = . if PRE_CB4==7777777777 | PRE_CB4==9999999998 | PRE_CB4==9999999999 
	replace PRE_CB5 = . if PRE_CB5==777 | PRE_CB5==998 | PRE_CB5==999 
	replace PRE_CB6 = . if PRE_CB6==7777777777 | PRE_CB6==9999999998 | PRE_CB6==9999999999 
	replace POS_CB1 = . if POS_CB1==7777777777 | POS_CB1==9999999998 | POS_CB1==9999999999 
	replace POS_CB2 = . if POS_CB2==777 | POS_CB2==998 | POS_CB2==999 
	replace POS_CB3 = . if POS_CB3>=8
	replace POS_CB4 = . if POS_CB4==7777777777 | POS_CB4==9999999998 | POS_CB4==9999999999 
	replace POS_CB5 = . if POS_CB5==777 | POS_CB5==998 | POS_CB5==999 
	replace POS_CB6 = . if POS_CB6==7777777777 | POS_CB6==9999999998 | POS_CB6==9999999999 

	replace PRE_POP1A = . if PRE_POP1A==777 | PRE_POP1A==998 | PRE_POP1A==999 
	replace PRE_POP1B = . if PRE_POP1B==777 | PRE_POP1B==998 | PRE_POP1B==999 
	replace PRE_POP1C = . if PRE_POP1C==777 | PRE_POP1C==998 | PRE_POP1C==999
	 
	replace PRE_POP2A = . if PRE_POP2A==777 | PRE_POP2A==998 | PRE_POP2A==999 
	replace PRE_POP2B = . if PRE_POP2B==777 | PRE_POP2B==998 | PRE_POP2B==999 
	replace PRE_POP2C = . if PRE_POP2C==777 | PRE_POP2C==998 | PRE_POP2C==999 

	replace PRE_POP3A = . if PRE_POP3A==9999999998 
	replace PRE_POP3B = . if PRE_POP3B==9999999998 
	replace PRE_POP3C = . if PRE_POP3C==9999999998 

	replace PRE_POP4A = . if PRE_POP4A==777 | PRE_POP4A==998 | PRE_POP4A==999 
	replace PRE_POP4B = . if PRE_POP4B==777 | PRE_POP4B==998 | PRE_POP4B==999 
	replace PRE_POP4C = . if PRE_POP4C==777 | PRE_POP4C==998 | PRE_POP4C==999 

	sum PRE* POS* SF*,de

	replace P_PARTFULL21 =. if P_PARTFULL21 == 77 | P_PARTFULL21 == 98| P_PARTFULL21 == 99
	replace P_OCCUPY20 =. if P_OCCUPY20 == 77 | P_OCCUPY20 == 98| P_OCCUPY20 == 99
	replace P_INDUSTRY20 =. if P_INDUSTRY20 == 77 | P_INDUSTRY20 == 98| P_INDUSTRY20 == 99
	replace P_ENGLISHTALK =. if P_ENGLISHTALK == 77 | P_ENGLISHTALK == 98| P_ENGLISHTALK == 99
	replace P_ENGLISHREAD =. if P_ENGLISHREAD == 77 | P_ENGLISHREAD == 98| P_ENGLISHREAD == 99



end
				
program gen_label_variables
	*******************1. Generate New Variables (controls) ****************
	***************** Controls Label ***************
	gen SECOND_GEN = (DOV_GEN==2)
	label define Second_Gen 0 "First Gen" 1 "Second Gen"
	label values SECOND_GEN Second_Gen

	gen FEMALE = (GENDER==2)

	label define Treatment 0 "Control" 1 "Treatment"
	label values P_EXP Treatment
	label var P_EXP "Treat"

	label define edu 1 "Less than HS" ///
					 2 "HS graduate or equivalent" ///
					 3 "Some college/ associates degree" ///
					 4 "Bachelor's degree" ///
					 5 "Post grad study/professional degree"
	label values EDUC5 edu

	gen HS_less = (EDUC5==1) | (EDUC5==2)
	gen Some_College = (EDUC5==3)
	gen College_Above = (EDUC5==4) | (EDUC5==5)

	gen Black = (RACETHNICITY == 2)
	gen Hispanic = (RACETHNICITY == 4)
	gen Asian = (RACETHNICITY == 6)
	
	gen PT = (P_PARTFULL21==2)
	bysort P_OCCUPY20: gen count_occupation = _N
	bysort P_EXP SECOND_GEN: gen count = _N


	label define occupation 1 "Arts, Design, Entertainment, Sports, and Media Occupations" ///
							2 "Community and Social Service Occupations" ///
							3 "Healthcare Support Occupations" ///
							4 "Installation, Maintenance, and Repair Occupations" ///
							5 "Architecture and Engineering Occupations" ///
							6 "Construction and Extraction Occupations" ///
							7 "Production Occupations" ///
							8 "Building and Grounds Cleaning and Maintenance Occupations" ///
							9 "Healthcare Practitioners and Technical Occupations" ///
							10 "Life, Physical, and Social Science Occupations" ///
							11 "Protective Service Occupations" ///
							12 "Personal Care and Service Occupations" ///
							13 "Computer and Mathematical Occupations" ///
							14 "Sales and Related Occupations" ///
							15 "Education, Training, and Library Occupations" ///
							16 "Office and Administrative Support Occupations" ///
							17 "Food Preparation and Serving Related Occupations" ///
							18 "Legal Occupations" ///
							19 "Farming, Fishing, and Forestry Occupations" ///
							20 "Business and Financial Operations Occupations" ///
							21 "Management Occupations" ///
							22 "Transportation and Materials Moving Occupations" ///
							23 "Military Specific Occupations" ///
							24 "Other" ///
							25 "Have never worked" 
	label values P_OCCUPY20 occupation

	label define industry 	1 "Agriculture, Forestry, Fishing and Hunting" ///
							2 "Mining, Quarrying, and Oil and Gas Extraction" ///
							3 "Utilities" ///
							4 "Construction" ///
							5 "Manufacturing" ///
							6 "Wholesale Trade" ///
							7 "Retail Trade" ///
							8 "Transportation and Warehousing" ///
							9 "Information" ///
							10 "Finance and Insurance" ///
							11 "Real Estate and Rental and Leasing" ///
							12 "Professional, Scientific, and Technical Services" ///
							13 "Management of Companies and Enterprises" ///
							14 "Administrative and Support and Waste Management and Remediation Services" ///
							15 "Educational Services" ///
							16 "Health Care and Social Assistance" ///
							17 "Arts, Entertainment, and Recreation" ///
							18 "Accommodation and Food Services" ///
							19 "Other Services (except Public Administration)" ///
							20 "Public Administration" ///
							21 "Have never worked" 
	label values P_INDUSTRY20 industry
	
	*******************2. Generate New Variables (OUTCOMES) ****************
	** Median of Categorical Variable
	foreach var in PRE_SB1 ///
				   PRE_CB3 ///
				   POS_SB1 ///
				   POS_CB3 {
		gen `var'_med =  .
		replace `var'_med = 97.5 if `var'==1
		replace `var'_med = 90 if `var'==2
		replace `var'_med = 75 if `var'==3
		replace `var'_med = 50 if `var'==4
		replace `var'_med = 25 if `var'==5
		replace `var'_med = 10 if `var'==6
		replace `var'_med = 2.5 if `var'==7
	}

	label var SF1 "Current Wage"
	label var PRE_CB1 "Native Wage"
	label var PRE_SB2 "Future Wage"
	label var PRE_CB4 "Native Future Wage"
	label var PRE_SB4 "Job Search Wage"
	label var PRE_CB6 "Native Job Search Wage"

	label var PRE_SB1_med "Promotion Prob."
	label var PRE_CB3_med "Native Promotion Prob."

	label var PRE_SB3 "Job Search CV Sent"
	label var PRE_CB5 "Native CV Sent"

	label var SF2 "Current Hours"
	label var PRE_CB2 "Native Current Hours"

	gen log_wage = log(SF1)
	label var log_wage "Log(Wage)"
	
	
	********* 3. POPULATION BELIEF Difference*******************
	local POP_NB_EMP = 81.2
	local POP_IMMI_EMP = 79.1
	local POP_SECOND_EMP = 81.8
	local POP_EMP_NB_IMMI_GAP_TRUE = (`POP_NB_EMP'-`POP_IMMI_EMP')/`POP_IMMI_EMP'
	local POP_EMP_NB_SECOND_GAP_TRUE = (`POP_NB_EMP'-`POP_SECOND_EMP')/`POP_SECOND_EMP'

	local POP_NB_FT = 88.0
	local POP_IMMI_FT = 88.1
	local POP_SECOND_FT = 87.6
	local POP_FT_NB_IMMI_GAP_TRUE = (`POP_NB_FT'-`POP_IMMI_FT')/`POP_IMMI_FT'
	local POP_FT_NB_SECOND_GAP_TRUE = (`POP_NB_FT'-`POP_SECOND_FT')/`POP_SECOND_FT'

	local POP_NB_WAGE = 68855.4
	local POP_IMMI_WAGE = 63418.8
	local POP_SECOND_WAGE = 68538.9
	local POP_WAGE_NB_IMMI_GAP_TRUE = (`POP_NB_WAGE'-`POP_IMMI_WAGE')/`POP_IMMI_WAGE'
	local POP_WAGE_NB_SECOND_GAP_TRUE = (`POP_NB_WAGE'-`POP_SECOND_WAGE')/`POP_SECOND_WAGE'

	local POP_NB_HOUR = 40.67
	local POP_IMMI_HOUR = 39.98
	local POP_SECOND_HOUR = 40.01
	local POP_HOUR_NB_IMMI_GAP_TRUE = (`POP_NB_HOUR'-`POP_IMMI_HOUR')/`POP_IMMI_HOUR'
	local POP_HOUR_NB_SECOND_GAP_TRUE = (`POP_NB_HOUR'-`POP_SECOND_HOUR')/`POP_SECOND_HOUR'

	// a. SHIFT OF BELIEF ON EMPLOTMENT RATE
	gen POP_NB_EMP_DIFF = PRE_POP1A - `POP_NB_EMP'   
	gen POP_IMMI_EMP_DIFF = PRE_POP1B - `POP_IMMI_EMP' 
	gen POP_SECOND_EMP_DIFF = PRE_POP1C - `POP_SECOND_EMP' 
	label var POP_NB_EMP_DIFF "Native-Born Emp. Rate (Belief-True)"
	label var POP_IMMI_EMP_DIFF "First-Gen Emp. Rate (Belief-True)"
	label var POP_SECOND_EMP_DIFF "Second-Gen Emp. Rate (Belief-True)"

	// b. SHIFT OF BELIEF ON FULL TIME RATE
	gen POP_NB_FT_DIFF = PRE_POP2A - `POP_NB_FT'   
	gen POP_IMMI_FT_DIFF = PRE_POP2B - `POP_IMMI_FT'  
	gen POP_SECOND_FT_DIFF = PRE_POP2C - `POP_SECOND_FT'   
	label var POP_NB_FT_DIFF "Native-Born FT Rate (Belief-True)"
	label var POP_IMMI_FT_DIFF "First-Gen FT Rate (Belief-True)"
	label var POP_SECOND_FT_DIFF "Second-Gen FT Rate (Belief-True)"
	
	// c. SHIFT OF BELIEF ON ANNUAL SALARY
	gen POP_NB_WAGE_DIFF = PRE_POP3A - `POP_NB_WAGE'   
	gen POP_IMMI_WAGE_DIFF = PRE_POP3B - `POP_IMMI_WAGE'   
	gen POP_SECOND_WAGE_DIFF = PRE_POP3C - `POP_SECOND_WAGE'  
	label var POP_NB_WAGE_DIFF "Native-Born Salary (Belief-True)"
	label var POP_IMMI_WAGE_DIFF "First-Gen Salary (Belief-True)"
	label var POP_SECOND_WAGE_DIFF "Second-Gen Salary (Belief-True)"
	
	// d. SHIFT OF BELIEF ON WORKING HOURS
	gen POP_NB_HOUR_DIFF = PRE_POP4A - `POP_NB_HOUR'
	gen POP_IMMI_HOUR_DIFF = PRE_POP4B - `POP_IMMI_HOUR' 
	gen POP_SECOND_HOUR_DIFF = PRE_POP4C - `POP_SECOND_HOUR' 
	label var POP_NB_HOUR_DIFF "Native-Born Hour (Belief-True)"
	label var POP_IMMI_HOUR_DIFF "First-Gen Hour (Belief-True)"
	label var POP_SECOND_HOUR_DIFF "Second-Gen Hour (Belief-True)"
	
end

program winsor_raw_data
	syntax [if] [, only_pop(integer 0)]
	
	if `only_pop' == 1{
		winsor2 PRE_POP1A PRE_POP2A PRE_POP3A PRE_POP4A /// Belief on Native Born
				PRE_POP1B PRE_POP2B PRE_POP3B PRE_POP4B /// Belief on First-Gen
				PRE_POP1C PRE_POP2C PRE_POP3C PRE_POP4C ///	Belief on Second-Gen
			, replace  cuts(5 95) 			
	}
	else{
		
		****** METHOD : Winsorize Orignial Data ******
	winsor2 SF1 PRE_SB2 PRE_SB4 POS_SB2 POS_SB4 /// Self-Belief Wage
			PRE_CB1 PRE_CB4 PRE_CB6 /// Prior Counterfactual Wage
			POS_CB1 POS_CB4 POS_CB6 /// Posterior Counterfactual Wage
			PRE_SB3 POS_SB3 PRE_CB5 POS_CB5 /// CV Sent
			SF2 PRE_CB2 POS_CB2 /// Hours
			PRE_POP1A PRE_POP2A PRE_POP3A PRE_POP4A /// Belief on Native Born
			PRE_POP1B PRE_POP2B PRE_POP3B PRE_POP4B /// Belief on First-Gen
			PRE_POP1C PRE_POP2C PRE_POP3C PRE_POP4C ///	Belief on Second-Gen
			, replace  cuts(5 95) 	
	}
			
end 

program gen_gap
	*********** Generate Perceived Gap *******************
	* Prior
	gen PRE_GAP1 = (PRE_CB1 - SF1)/SF1             //WAGE
	gen PRE_GAP2 = PRE_CB2 - SF2             //HOUR
	gen PRE_GAP3 = PRE_CB3_med - PRE_SB1_med
	gen PRE_GAP4 = (PRE_CB4 - PRE_SB2)/PRE_SB2
	gen PRE_GAP5 = PRE_CB5 - PRE_SB3
	gen PRE_GAP6 = (PRE_CB6 - PRE_SB4)/PRE_SB4

	label var PRE_GAP1 "Current Wage Gap (Prior)"
	label var PRE_GAP2 "Current Hour Gap (Prior)"
	label var PRE_GAP3 "Promote Prob Gap (Prior)"
	label var PRE_GAP4 "Future Wage Gap (Prior)"
	label var PRE_GAP5 "Job Arrival Gap (Prior)"
	label var PRE_GAP6 "Job Search Wage Gap (Prior)"

	* Posterior
	gen POS_GAP1 = (POS_CB1 - SF1)/SF1             //WAGE
	gen POS_GAP2 = POS_CB2 - SF2             //HOUR
	gen POS_GAP3 = POS_CB3_med - POS_SB1_med
	gen POS_GAP4 = (POS_CB4 - POS_SB2)/POS_SB2
	gen POS_GAP5 = POS_CB5 - POS_SB3
	gen POS_GAP6 = (POS_CB6 - POS_SB4)/POS_SB4

	label var POS_GAP1 "Current Wage Gap (Post)"
	label var POS_GAP2 "Current Hour Gap (Post)"
	label var POS_GAP3 "Promote Prob Gap (Post)"
	label var POS_GAP4 "Future Wage Gap (Post)"
	label var POS_GAP5 "Job Arrival Gap (Post)"
	label var POS_GAP6 "Job Search Wage Gap (Post)"

	* Difference between prior and postrior perceived gap
	forvalues i = 1/6{
		gen DIFF_GAP`i' = POS_GAP`i' - PRE_GAP`i'
	}
	label var DIFF_GAP1 "Current Wage Gap (Post-Prior)"
	label var DIFF_GAP2 "Current Hour Gap (Post-Prior)"
	label var DIFF_GAP3 "Promote Prob Gap (Post-Prior)"
	label var DIFF_GAP4 "Future Wage Gap (Post-Prior)"
	label var DIFF_GAP5 "Job Arrival Gap (Post-Prior)"
	label var DIFF_GAP6 "Job Search Wage Gap (Post-Prior)"
	
	* Difference between prior and postrior perceived gap
	forvalues i = 1/6{
		gen ABS_DIFF_GAP`i' = abs(POS_GAP`i' - PRE_GAP`i')
	}
	label var ABS_DIFF_GAP1 "Abs(Current Wage Gap) ($|Post-Prior|$)"
	label var ABS_DIFF_GAP2 "Abs(Current Hour Gap) ($|Post-Prior|$)"
	label var ABS_DIFF_GAP3 "Abs(Promote Prob Gap) ($|Post-Prior|$)"
	label var ABS_DIFF_GAP4 "Abs(Future Wage Gap) ($|Post-Prior|$)"
	label var ABS_DIFF_GAP5 "Abs(Job Arrival Gap) ($|Post-Prior|$)"
	label var ABS_DIFF_GAP6 "Abs(Job Search Wage Gap) ($|Post-Prior|$)"

	
	*********** Population belief gap ************
	//e. SHIFT OF BELIEF ON NATIVE-BORN / IMMI GAP
	// NOTE: GREATER THAN 0 MEANS OVER ESTIMATING THE GAP
	local POP_NB_EMP = 81.2
	local POP_IMMI_EMP = 79.1
	local POP_SECOND_EMP = 81.8
	local POP_EMP_NB_IMMI_GAP_TRUE = (`POP_NB_EMP'-`POP_IMMI_EMP')
	local POP_EMP_NB_SECOND_GAP_TRUE = (`POP_NB_EMP'-`POP_SECOND_EMP')

	local POP_NB_FT = 88.0
	local POP_IMMI_FT = 88.1
	local POP_SECOND_FT = 87.6
	local POP_FT_NB_IMMI_GAP_TRUE = (`POP_NB_FT'-`POP_IMMI_FT')
	local POP_FT_NB_SECOND_GAP_TRUE = (`POP_NB_FT'-`POP_SECOND_FT')

	local POP_NB_WAGE = 68855.4
	local POP_IMMI_WAGE = 63418.8
	local POP_SECOND_WAGE = 68538.9
	local POP_WAGE_NB_IMMI_GAP_TRUE = (`POP_NB_WAGE'-`POP_IMMI_WAGE')/`POP_IMMI_WAGE'
	local POP_WAGE_NB_SECOND_GAP_TRUE = (`POP_NB_WAGE'-`POP_SECOND_WAGE')/`POP_SECOND_WAGE'

	local POP_NB_HOUR = 40.67
	local POP_IMMI_HOUR = 39.98
	local POP_SECOND_HOUR = 40.01
	local POP_HOUR_NB_IMMI_GAP_TRUE = (`POP_NB_HOUR'-`POP_IMMI_HOUR')
	local POP_HOUR_NB_SECOND_GAP_TRUE = (`POP_NB_HOUR'-`POP_SECOND_HOUR')
	
* Employment rate
	gen POP_EMP_NB_IMMI_GAP = (PRE_POP1A - PRE_POP1B)
	gen POP_EMP_NB_IMMI_GAP_DIFF = POP_EMP_NB_IMMI_GAP - `POP_EMP_NB_IMMI_GAP_TRUE'
	label var POP_EMP_NB_IMMI_GAP_DIFF "Native-FirstGen Emp. Rate Gap(Belief-True)"
	gen ABS_POP_EMP_NB_IMMI_GAP_DIFF = abs(POP_EMP_NB_IMMI_GAP_DIFF)
	label var ABS_POP_EMP_NB_IMMI_GAP_DIFF "abs(Native-FirstGen Emp. Rate Gap) ($|Belief-True|$)"
	
	gen POP_EMP_NB_SECOND_GAP = (PRE_POP1A - PRE_POP1C)
	gen POP_EMP_NB_SECOND_GAP_DIFF = POP_EMP_NB_SECOND_GAP - `POP_EMP_NB_SECOND_GAP_TRUE'
	label var POP_EMP_NB_SECOND_GAP_DIFF "Native-SecondGen Emp. Rate Gap(Belief-True)"
	gen ABS_POP_EMP_NB_SECOND_GAP_DIFF = abs(POP_EMP_NB_SECOND_GAP_DIFF)
	label var ABS_POP_EMP_NB_SECOND_GAP_DIFF "abs(Native-SecondGen Emp. Rate Gap) ($|Belief-True|$)"

	gen POP_EMP_GAP_DIFF = POP_EMP_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace POP_EMP_GAP_DIFF = POP_EMP_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var POP_EMP_GAP_DIFF "Emp. Rate Gap Bias(Belief-True)"
	gen ABS_POP_EMP_GAP_DIFF = ABS_POP_EMP_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace ABS_POP_EMP_GAP_DIFF = ABS_POP_EMP_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var ABS_POP_EMP_GAP_DIFF "abs(Emp. Rate Gap)($|Belief-True|$)"
		
* FT rate
	gen POP_FT_NB_IMMI_GAP = (PRE_POP2A - PRE_POP2B)
	gen POP_FT_NB_IMMI_GAP_DIFF = POP_FT_NB_IMMI_GAP -  `POP_FT_NB_IMMI_GAP_TRUE'
	label var POP_FT_NB_IMMI_GAP_DIFF "Native-FirstGen FT. Rate Gap(Belief-True)"
	gen ABS_POP_FT_NB_IMMI_GAP_DIFF = abs(POP_FT_NB_IMMI_GAP_DIFF)
	label var ABS_POP_FT_NB_IMMI_GAP_DIFF "abs(Native-FirstGen FT. Rate Gap) ($|Belief-True|$)"
	
	gen POP_FT_NB_SECOND_GAP = (PRE_POP2A - PRE_POP2C)
	gen POP_FT_NB_SECOND_GAP_DIFF = POP_FT_NB_SECOND_GAP - `POP_FT_NB_SECOND_GAP_TRUE'
	label var POP_FT_NB_SECOND_GAP_DIFF "Native-SecondGen FT. Rate Gap(Belief-True)"
	gen ABS_POP_FT_NB_SECOND_GAP_DIFF = abs(POP_FT_NB_SECOND_GAP_DIFF)
	label var ABS_POP_FT_NB_SECOND_GAP_DIFF "abs(Native-SecondGen FT. Rate Gap) ($|Belief-True|$)"

	gen POP_FT_GAP_DIFF = POP_FT_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace POP_FT_GAP_DIFF = POP_FT_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var POP_FT_GAP_DIFF "FT. Rate Gap Bias(Belief-True)"
	gen ABS_POP_FT_GAP_DIFF = ABS_POP_FT_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace ABS_POP_FT_GAP_DIFF = ABS_POP_FT_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var ABS_POP_FT_GAP_DIFF "abs(FT. Rate Gap Bias)($|Belief-True|$)"
	
* Annual Salray
	gen POP_WAGE_NB_IMMI_GAP = (PRE_POP3A - PRE_POP3B)/PRE_POP3B
	gen POP_WAGE_NB_IMMI_GAP_DIFF = POP_WAGE_NB_IMMI_GAP - `POP_WAGE_NB_IMMI_GAP_TRUE'
	label var POP_WAGE_NB_IMMI_GAP_DIFF "Native-FirstGen Wage Gap(Belief-True)"
	gen ABS_POP_WAGE_NB_IMMI_GAP_DIFF = abs(POP_WAGE_NB_IMMI_GAP_DIFF)
	label var ABS_POP_WAGE_NB_IMMI_GAP_DIFF "abs(Native-FirstGen Wage Gap) ($|Belief-True|$)"
	
	gen POP_WAGE_NB_SECOND_GAP = (PRE_POP3A - PRE_POP3C)/PRE_POP3C
	gen POP_WAGE_NB_SECOND_GAP_DIFF = POP_WAGE_NB_SECOND_GAP - `POP_WAGE_NB_SECOND_GAP_TRUE'
	label var POP_WAGE_NB_SECOND_GAP_DIFF "Native-SecondGen Wage Gap(Belief-True)"
	gen ABS_POP_WAGE_NB_SECOND_GAP_DIFF = abs(POP_WAGE_NB_SECOND_GAP_DIFF)
	label var ABS_POP_WAGE_NB_SECOND_GAP_DIFF "abs(Native-SecondGen Wage Gap) ($|Belief-True|$)"

	gen POP_WAGE_GAP_DIFF = POP_WAGE_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace POP_WAGE_GAP_DIFF = POP_WAGE_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var POP_WAGE_GAP_DIFF "Wage Gap Bias(Belief-True)"
	gen ABS_POP_WAGE_GAP_DIFF = ABS_POP_WAGE_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace ABS_POP_WAGE_GAP_DIFF = ABS_POP_WAGE_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var ABS_POP_WAGE_GAP_DIFF "abs(Wage Gap Bias)($|Belief-True|$)"
	
* Hour
	gen POP_HOUR_NB_IMMI_GAP = (PRE_POP4A - PRE_POP4B)
	gen POP_HOUR_NB_IMMI_GAP_DIFF = POP_HOUR_NB_IMMI_GAP - `POP_HOUR_NB_IMMI_GAP_TRUE'
	label var POP_HOUR_NB_IMMI_GAP_DIFF "Native-FirstGen Hour Gap(Belief-True)"
	gen ABS_POP_HOUR_NB_IMMI_GAP_DIFF = abs(POP_HOUR_NB_IMMI_GAP_DIFF)
	label var ABS_POP_HOUR_NB_IMMI_GAP_DIFF "abs(Native-FirstGen Hour Gap) ($|Belief-True|$)"
	
	gen POP_HOUR_NB_SECOND_GAP = (PRE_POP4A - PRE_POP4C)
	gen POP_HOUR_NB_SECOND_GAP_DIFF = POP_HOUR_NB_SECOND_GAP - `POP_HOUR_NB_SECOND_GAP_TRUE'
	label var POP_HOUR_NB_SECOND_GAP_DIFF "Native-SecondGen Hour Gap(Belief-True)"
	gen ABS_POP_HOUR_NB_SECOND_GAP_DIFF = abs(POP_HOUR_NB_SECOND_GAP_DIFF)
	label var ABS_POP_HOUR_NB_SECOND_GAP_DIFF "abs(Native-SecondGen Hour Gap) ($|Belief-True|$)"
	
	gen POP_HOUR_GAP_DIFF = POP_HOUR_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace POP_HOUR_GAP_DIFF = POP_HOUR_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var POP_HOUR_GAP_DIFF "Hour Gap Bias(Belief-True)"
	gen ABS_POP_HOUR_GAP_DIFF = ABS_POP_HOUR_NB_IMMI_GAP_DIFF if SECOND_GEN ==0
	replace ABS_POP_HOUR_GAP_DIFF = ABS_POP_HOUR_NB_SECOND_GAP_DIFF if SECOND_GEN == 1
	label var ABS_POP_HOUR_GAP_DIFF "abs(Hour Gap Bias)($|Belief-True|$)"

* Dummy 
	gen POP_EMP_GAP_DIFF_D = (POP_EMP_GAP_DIFF>0) 
	gen POP_FT_GAP_DIFF_D = (POP_FT_GAP_DIFF>0) 
	gen POP_HOUR_GAP_DIFF_D = (POP_HOUR_GAP_DIFF>0)
	gen POP_WAGE_GAP_DIFF_D = (POP_WAGE_GAP_DIFF>0) 
	label var POP_EMP_GAP_DIFF_D "Emp. Rate Gap Bias>0"
	label var POP_FT_GAP_DIFF_D "FT. Rate Gap Bias>0"
	label var POP_HOUR_GAP_DIFF_D "Hour Gap Bias>0"
	label var POP_WAGE_GAP_DIFF_D "Wage Gap Bias>0"	
end

program count_figure
	*********************      Figure: Sample Size    *******************
	graph bar (count) CaseId, over( P_EXP) over(SECOND_GEN) ytitle("Count")  blabel(bar, size(medium) lwidth(2))
	graph export "result/figures/Observation.png", as(png)    replace

end

program balance_table
	*********************   Table Sumamry Stats.   *******************
		eststo clear
		estpost sum $Demo_Controls SF1 SF2 if P_EXP ==0 & SECOND_GEN == 0 
		estimates store first_control
		
		estpost sum $Demo_Controls SF1 SF2 if P_EXP ==1 & SECOND_GEN == 0 
		estimates store first_treat
		
		estpost sum $Demo_Controls SF1 SF2 if P_EXP ==0 & SECOND_GEN == 1 
		estimates store second_control
		
		estpost sum $Demo_Controls SF1 SF2 if P_EXP ==1 & SECOND_GEN == 1 
		estimates store second_treat	
		
		esttab  first_control first_treat second_control second_treat using "result/tables/balance_table.tex" , label compress ///
			   mtitles("First Gen Control " ///
					   "First Gen Treat" ///
					   "Second Gen Control " ///
					   "Second Gen Treat") ///	
				cell((mean(fmt(%9.2f %9.2f %9.2f %9.2f) label("\textcolor{white}{Mean}")))) aux(sd) replace 
		
end 

program prior_regression
	syntax [if] [, truncy(integer 0) output(integer 0) file_suf(string)]

	*********** 4.1. Prior Perceived Gap******************
	****** COMPARISON FIRST GEN V.S. SECOND GEN*****
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0{
			quietly sum PRE_GAP`i' ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
			
			eststo: quietly reg PRE_GAP`i' SECOND_GEN if PRE_GAP`i'>p_low & PRE_GAP`i'<p_high , robust
		}
		else{
			eststo: quietly reg PRE_GAP`i' SECOND_GEN , robust
		}
		}

		esttab ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) se(%9.2f) ///
				nonotes  replace 
	
		if `output'>0{
			if `truncy'>0{
			esttab using "result/tables/truncate/Prior_Gap_By_Gen_truncate_`file_suf'.tex"  ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) se(%9.2f) ///
				nonotes  replace 				
			}
			else{
			esttab using "result/tables/Prior_Gap_By_Gen.tex"  ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) se(%9.2f) ///
				nonotes  replace 						
			}
		}
	

	****** 4.2 COMPARISON DEMOGRAPHICS*****
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0{
			quietly sum PRE_GAP`i' ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
			
			eststo: quietly reg PRE_GAP`i'  SECOND_GEN $Demo_Controls log_wage SF2 if PRE_GAP`i'>p_low & PRE_GAP`i'<p_high , robust
		}
		else{
			eststo: reg PRE_GAP`i'  SECOND_GEN $Demo_Controls log_wage SF2 , robust
			}
		}
		esttab  ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
				
		if `output'>0{
			if `truncy'>0{				
			esttab using "result/tables/truncate/Prior_Gap_By_Demo_truncate_`file_suf'.tex"  ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
			}
			else{	
			esttab using "result/tables/Prior_Gap_By_Demo.tex"  ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
			}
		}

	/*
	****** COMPARISON OCCUPATION*****
	eststo clear
	eststo X :  estpost tabstat PRE_GAP* , by(P_OCCUPY20) stats(mean) 
	esttab X , cells("PRE_GAP1 PRE_GAP2 PRE_GAP3 PRE_GAP4 PRE_GAP5 PRE_GAP6")  nomtitle nonumber noobs
		x
	****** COMPARISON INDUSTRY*****
	eststo clear
	forvalues i = 1/6{
		eststo: reg PRE_GAP`i'  i.P_INDUSTRY20
	}

		esttab   ,label se  ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) se(%9.2f) ///
				nonotes  replace 
	x
	*/
end

program population_regression
	syntax [if] [, truncy(integer 0) output(integer 0) file_suf(string)]

	eststo clear
	forvalues i = 1/6{
		if `truncy'>0 & `i'!=3{
			quietly sum PRE_GAP`i'   ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
		
			eststo:  quietly reg PRE_GAP`i' POP_EMP_GAP_DIFF ///
											POP_FT_GAP_DIFF ///
											POP_HOUR_GAP_DIFF ///
											POP_WAGE_GAP_DIFF ///
											$Demo_Controls ///
											log_wage ///
											SF2 ///
											if  PRE_GAP`i'<p_high & PRE_GAP`i'>p_low  ,robust
			}
		else{
			eststo: quietly reg PRE_GAP`i' POP_EMP_GAP_DIFF ///
											POP_FT_GAP_DIFF ///
											POP_HOUR_GAP_DIFF ///
											POP_WAGE_GAP_DIFF ///
											$Demo_Controls ///
											log_wage ///
											SF2 ///
											,robust
			}
		}
	
			esttab   ,label se ///
								 keep(POP_EMP_GAP_DIFF ///
									  POP_FT_GAP_DIFF ///
									  POP_HOUR_GAP_DIFF ///
									  POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 		

			
end

program winsor_gap_data
	****** METHOD 1 : DROP OBSERVATION ******
	/*
	sum POP_EMP_GAP_DIFF,de
		scalar POP_EMP_GAP_DIFF_p5 = r(p5)
		scalar POP_EMP_GAP_DIFF_p95 = r(p95)
		
	sum POP_FT_GAP_DIFF,de
		scalar POP_FT_GAP_DIFF_p5 = r(p5)
		scalar POP_FT_GAP_DIFF_p95 = r(p95)
		
	sum POP_HOUR_GAP_DIFF,de
		scalar POP_HOUR_GAP_DIFF_p5 = r(p5)
		scalar POP_HOUR_GAP_DIFF_p95 = r(p95)
		
	sum POP_WAGE_GAP_DIFF,de
		scalar POP_WAGE_GAP_DIFF_p5 = r(p5)
		scalar POP_WAGE_GAP_DIFF_p95 = r(p95)
	*/


	
	****** METHOD 3 : Winsorize Final Analysis Data ******
	winsor2 DIFF_GAP1 DIFF_GAP2 DIFF_GAP3 DIFF_GAP4 DIFF_GAP5 DIFF_GAP6 /// DV
			POP_EMP_GAP_DIFF POP_FT_GAP_DIFF POP_HOUR_GAP_DIFF	POP_WAGE_GAP_DIFF /// IDV
			log_wage /// Controls
			, replace  cuts(5 95) 
	
end

program main_treat_regression
	syntax [if] [, truncy(integer 0) output(integer 0) trunc_time(integer 0) file_suf(string)]
	
	preserve
	if `trunc_time'>0{
	quietly sum INT_FIG3_TIMER_TOTALTIME ,de 
			scalar t_low = r(p`truncy')
			drop if INT_FIG3_TIMER_TOTALTIME < t_low & P_EXP == 1
	}
	
			*************  TABLE 1: Treatment Effect TBD: Analysis result depend onf extreme value...******************
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0 & `i'!=3 {
			quietly sum DIFF_GAP`i' ,de 
				scalar p_low = r(p`truncy')
				local high = 100 - `truncy'
				scalar p_high = r(p`high')

				eststo: quietly reg DIFF_GAP`i' P_EXP SECOND_GEN c.P_EXP#c.SECOND_GEN $Demo_Controls log_wage SF2 ///
					if DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low ,robust							
				
			}
		else{
					eststo: quietly reg DIFF_GAP`i' P_EXP SECOND_GEN c.P_EXP#c.SECOND_GEN $Demo_Controls log_wage SF2 ///
					 , robust
				}
		}
		
		
			esttab ,label se keep(P_EXP SECOND_GEN c.P_EXP#c.SECOND_GEN _cons) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 


		if `output'>0{
			if `truncy'>0{
				esttab using "result/tables/truncate/Treatment_Effect_Overall_truncate_`file_suf'.tex",label se keep(P_EXP SECOND_GEN c.P_EXP#c.SECOND_GEN _cons) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
			}
			else{
				esttab using "result/tables/Treatment_Effect_Overall.tex",label se keep(P_EXP SECOND_GEN c.P_EXP#c.SECOND_GEN _cons ) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 	
			}
		}
	
	
	***************Table 2 : Treatment_Effect_Control (Placebo)******************************************
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0 & `i'!=3 {
			quietly sum DIFF_GAP`i' if P_EXP==0  ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
			
			eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
									POP_FT_GAP_DIFF ///
									POP_HOUR_GAP_DIFF ///
									POP_WAGE_GAP_DIFF ///
									$Demo_Controls ///
									log_wage ///
									SF2 ///
									if P_EXP==0 & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low  , robust
			}
		else{
			eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
								POP_FT_GAP_DIFF ///
								POP_HOUR_GAP_DIFF ///
								POP_WAGE_GAP_DIFF ///
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==0 , robust		
			}					
		}	
		
		esttab  ,label se ///
				 keep(POP_EMP_GAP_DIFF ///
				 POP_FT_GAP_DIFF ///
				 POP_HOUR_GAP_DIFF ///
				 POP_WAGE_GAP_DIFF) ///
			     star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				 nonotes  replace 
			
		if `output'>0{
			if `truncy'>0{
				esttab using "result/tables/truncate/Treatment_Effect_Control_truncate_`file_suf'.tex" ,label se ///
				 keep(POP_EMP_GAP_DIFF ///
				 POP_FT_GAP_DIFF ///
				 POP_HOUR_GAP_DIFF ///
				 POP_WAGE_GAP_DIFF) ///
			     star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				 nonotes  replace 
			}
			else{	
				esttab using "result/tables/Treatment_Effect_Control.tex" ,label se ///
				 keep(POP_EMP_GAP_DIFF ///
				 POP_FT_GAP_DIFF ///
				 POP_HOUR_GAP_DIFF ///
				 POP_WAGE_GAP_DIFF) ///
			     star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				 nonotes  replace 
			}
		}


	***************Table 3: Treatment_Effect_Control (Dummy) ******************************************
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0 & `i'!=3{
			quietly sum DIFF_GAP`i' if P_EXP==1  ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
			
				eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF_D ///
											POP_FT_GAP_DIFF_D ///
											POP_HOUR_GAP_DIFF_D ///
											POP_WAGE_GAP_DIFF_D ///
											$Demo_Controls ///
											log_wage ///
											SF2 ///
											if P_EXP==1  & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low ,robust						
				}
		else{
			eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF_D ///
											POP_FT_GAP_DIFF_D ///
											POP_HOUR_GAP_DIFF_D ///
											POP_WAGE_GAP_DIFF_D ///
											$Demo_Controls ///
											log_wage ///
											SF2 ///
											if P_EXP==1 & INT_FIG3_TIMER_TOTALTIME>=7  ,robust
			}
		}
	
			esttab   ,label se ///
								 keep(POP_EMP_GAP_DIFF_D ///
									  POP_FT_GAP_DIFF_D ///
									  POP_HOUR_GAP_DIFF_D ///
									  POP_WAGE_GAP_DIFF_D) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 		
		
		if `output'>0{	
			if `truncy'>0{
			esttab using "result/tables/truncate/Treatment_Effect_Combine_Dummy_truncate_`file_suf'.tex"	  ,label se ///
								 keep(POP_EMP_GAP_DIFF_D ///
									  POP_FT_GAP_DIFF_D ///
									  POP_HOUR_GAP_DIFF_D ///
									  POP_WAGE_GAP_DIFF_D) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 		
			}
			else{			
				esttab using "result/tables/Treatment_Effect_Combine_Dummy.tex"	  ,label se ///
								 keep(POP_EMP_GAP_DIFF_D ///
									  POP_FT_GAP_DIFF_D ///
									  POP_HOUR_GAP_DIFF_D ///
									  POP_WAGE_GAP_DIFF_D) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 	
				}
			}
		


*******************Table 4: Treatment_Effect_Combine****************************************		
	eststo clear
	forvalues i = 1/6{

		if `truncy'>0 & `i'!=3 {
			quietly sum DIFF_GAP`i' if P_EXP==1  ,de 
			scalar p_low = r(p`truncy')
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
			eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
								POP_FT_GAP_DIFF ///
								POP_HOUR_GAP_DIFF ///
								POP_WAGE_GAP_DIFF ///
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1  & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low  & INT_FIG3_TIMER_TOTALTIME>=7, robust
			}
		else{
			eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
								POP_FT_GAP_DIFF ///
								POP_HOUR_GAP_DIFF ///
								POP_WAGE_GAP_DIFF ///
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1   & INT_FIG3_TIMER_TOTALTIME>=7 ,robust
			}
		}
			esttab ,label se ///
								 keep(POP_EMP_GAP_DIFF ///
									  POP_FT_GAP_DIFF ///
									  POP_HOUR_GAP_DIFF ///
									  POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 					
				
			if `output'>0{
				if `truncy'>0{
				
				esttab using "result/tables/truncate/Treatment_Effect_Combine_truncate_`file_suf'.tex",label se ///
								 keep(POP_EMP_GAP_DIFF ///
									  POP_FT_GAP_DIFF ///
									  POP_HOUR_GAP_DIFF ///
									  POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 		
				}
			else{
				esttab using "result/tables/Treatment_Effect_Combine.tex",label se ///
								 keep(POP_EMP_GAP_DIFF ///
									  POP_FT_GAP_DIFF ///
									  POP_HOUR_GAP_DIFF ///
									  POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 						
				
			}
			}
	
		*scatter DIFF_GAP1 POP_WAGE_GAP_DIFF if  P_EXP==1
				
******************Table 5 :Treatment_Effect_Combine (absolute)****************************************		
	eststo clear
	forvalues i = 1/6{
		if `truncy'>0 & `i'!=3{
			quietly sum ABS_DIFF_GAP`i' if P_EXP==1 ,de 
			local high = 100 - `truncy'
			scalar p_high = r(p`high')
		
			eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_GAP_DIFF ///
												ABS_POP_FT_GAP_DIFF ///
												ABS_POP_HOUR_GAP_DIFF ///
												ABS_POP_WAGE_GAP_DIFF ///
												$Demo_Controls ///
												log_wage ///
												SF2 ///
												if P_EXP==1 &  ABS_DIFF_GAP`i'< p_high, robust
		}
		else{
			eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_GAP_DIFF ///
												ABS_POP_FT_GAP_DIFF ///
												ABS_POP_HOUR_GAP_DIFF ///
												ABS_POP_WAGE_GAP_DIFF ///
												$Demo_Controls ///
												log_wage ///
												SF2 ///
												if P_EXP==1 , robust
			}
		}
			esttab ,label se ///
								 keep(ABS_POP_EMP_GAP_DIFF ///
									  ABS_POP_FT_GAP_DIFF ///
									  ABS_POP_HOUR_GAP_DIFF ///
									  ABS_POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
				
		if `output'>0{		
			if `truncy'>0{
				esttab using "result/tables/truncate/Treatment_Effect_Combine_ABS_truncate_`file_suf'.tex" ,label se ///
								 keep(ABS_POP_EMP_GAP_DIFF ///
									  ABS_POP_FT_GAP_DIFF ///
									  ABS_POP_HOUR_GAP_DIFF ///
									  ABS_POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 
			}
			else{
				esttab using "result/tables/Treatment_Effect_Combine_ABS.tex" ,label se ///
								 keep(ABS_POP_EMP_GAP_DIFF ///
									  ABS_POP_FT_GAP_DIFF ///
									  ABS_POP_HOUR_GAP_DIFF ///
									  ABS_POP_WAGE_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 			
				
				}
		}
	restore
end

program subsample_treat_regression
	syntax [if] [, truncy(integer 0) trunc_time(integer 0)]

	preserve
	if `trunc_time'>0{
	quietly sum INT_FIG3_TIMER_TOTALTIME ,de 
			scalar t_low = r(p`truncy')
			drop if INT_FIG3_TIMER_TOTALTIME < t_low & P_EXP == 1
	}
******************************Treatment_Effect_Combine_Asymetric****************************************		
	eststo clear
	gen POP_EMP_GAP_DIFF_P = (POP_EMP_GAP_DIFF>0) * POP_EMP_GAP_DIFF
	gen POP_FT_GAP_DIFF_P = (POP_FT_GAP_DIFF>0) * POP_FT_GAP_DIFF
	gen POP_HOUR_GAP_DIFF_P = (POP_HOUR_GAP_DIFF>0) * POP_HOUR_GAP_DIFF
	gen POP_WAGE_GAP_DIFF_P = (POP_WAGE_GAP_DIFF>0) * POP_WAGE_GAP_DIFF
	label var POP_EMP_GAP_DIFF_P "Emp. Rate Gap Bias * (Bias>0)"
	label var POP_FT_GAP_DIFF_P "FT. Rate Gap Bias * (Bias>0)"
	label var POP_HOUR_GAP_DIFF_P "Hour Gap Bias * (Bias>0)"
	label var POP_WAGE_GAP_DIFF_P "Wage Gap Bias * (Bias>0)"
	
	forvalues i = 1/6{
		if `truncy' >0{
			
			quietly sum DIFF_GAP`i',de 
			scalar p_low = r(p`truncy')
			local high = 100-`truncy'
			scalar p_high = r(p`high')
			
		eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
								POP_FT_GAP_DIFF ///
								POP_HOUR_GAP_DIFF ///
								POP_WAGE_GAP_DIFF ///
								POP_EMP_GAP_DIFF_P ///
								POP_FT_GAP_DIFF_P ///
								POP_HOUR_GAP_DIFF_P ///
								POP_WAGE_GAP_DIFF_P ///
								$Demo_Controls ///
								log_wage ///
								SF2 if P_EXP==1 & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low , robust 
			}
		else{
		eststo: quietly reg DIFF_GAP`i' POP_EMP_GAP_DIFF ///
								POP_FT_GAP_DIFF ///
								POP_HOUR_GAP_DIFF ///
								POP_WAGE_GAP_DIFF ///
								POP_EMP_GAP_DIFF_P ///
								POP_FT_GAP_DIFF_P ///
								POP_HOUR_GAP_DIFF_P ///
								POP_WAGE_GAP_DIFF_P ///
								$Demo_Controls ///
								log_wage ///
								SF2 if P_EXP==1 , robust 
		}
		}
		esttab ,label se ///
								 keep(POP_EMP_GAP_DIFF ///
									  POP_FT_GAP_DIFF ///
									  POP_HOUR_GAP_DIFF ///
									  POP_WAGE_GAP_DIFF ///
									  POP_EMP_GAP_DIFF_P ///
									  POP_FT_GAP_DIFF_P ///
									  POP_HOUR_GAP_DIFF_P ///
									  POP_WAGE_GAP_DIFF_P ///											  
									  ) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 			
				
	*using "result/tables/Treatment_Effect_Combine_Asy.tex"  
				
	****************************Treatment_Effect_First_Gen******************************************
	eststo clear
	forvalues i = 1/6{
		if `truncy' >0{
			
			quietly sum DIFF_GAP`i' if P_EXP==1 & SECOND_GEN == 0 ,de 
			scalar p_low = r(p`truncy')
			local high = 100-`truncy'
			scalar p_high = r(p`high')
		
		eststo: quietly reg DIFF_GAP`i' POP_EMP_NB_IMMI_GAP_DIFF ///
								POP_FT_NB_IMMI_GAP_DIFF ///
								POP_HOUR_NB_IMMI_GAP_DIFF ///
								POP_WAGE_NB_IMMI_GAP_DIFF ///
								POP_EMP_NB_SECOND_GAP_DIFF ///
								POP_FT_NB_SECOND_GAP_DIFF ///
								POP_HOUR_NB_SECOND_GAP_DIFF ///
								POP_WAGE_NB_SECOND_GAP_DIFF ///			
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1 & SECOND_GEN == 0 & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low , robust
								
			}
		else{
		eststo: quietly reg DIFF_GAP`i' POP_EMP_NB_IMMI_GAP_DIFF ///
								POP_FT_NB_IMMI_GAP_DIFF ///
								POP_HOUR_NB_IMMI_GAP_DIFF ///
								POP_WAGE_NB_IMMI_GAP_DIFF ///
								POP_EMP_NB_SECOND_GAP_DIFF ///
								POP_FT_NB_SECOND_GAP_DIFF ///
								POP_HOUR_NB_SECOND_GAP_DIFF ///
								POP_WAGE_NB_SECOND_GAP_DIFF ///			
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1 & SECOND_GEN == 0 & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low , robust
		}
	}

		esttab   ,label se ///
								 keep(POP_EMP_NB_IMMI_GAP_DIFF ///
									  POP_FT_NB_IMMI_GAP_DIFF ///
								      POP_HOUR_NB_IMMI_GAP_DIFF ///
									  POP_WAGE_NB_IMMI_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 		
				
			* using "result/tables/Treatment_Effect_First_Gen.tex"
			
	*Absolute Value
	eststo clear
	forvalues i = 1/6{
		if `truncy' >0{
			quietly sum ABS_DIFF_GAP`i' if P_EXP==1 & SECOND_GEN == 0 , de 
			local high = 100-`truncy'
			scalar p_high = r(p`high')
		
		eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_NB_IMMI_GAP_DIFF ///
									ABS_POP_FT_NB_IMMI_GAP_DIFF ///
									ABS_POP_HOUR_NB_IMMI_GAP_DIFF ///
									ABS_POP_WAGE_NB_IMMI_GAP_DIFF ///
									ABS_POP_EMP_NB_SECOND_GAP_DIFF ///
									ABS_POP_FT_NB_SECOND_GAP_DIFF ///
									ABS_POP_HOUR_NB_SECOND_GAP_DIFF ///
									ABS_POP_WAGE_NB_SECOND_GAP_DIFF ///			
									$Demo_Controls ///
									log_wage ///
									SF2 ///
									if P_EXP==1 & SECOND_GEN == 0 & ABS_DIFF_GAP`i'<p_high, robust
								
		}
		else{
		eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_NB_IMMI_GAP_DIFF ///
									ABS_POP_FT_NB_IMMI_GAP_DIFF ///
									ABS_POP_HOUR_NB_IMMI_GAP_DIFF ///
									ABS_POP_WAGE_NB_IMMI_GAP_DIFF ///
									ABS_POP_EMP_NB_SECOND_GAP_DIFF ///
									ABS_POP_FT_NB_SECOND_GAP_DIFF ///
									ABS_POP_HOUR_NB_SECOND_GAP_DIFF ///
									ABS_POP_WAGE_NB_SECOND_GAP_DIFF ///			
									$Demo_Controls ///
									log_wage ///
									SF2 ///
									if P_EXP==1 & SECOND_GEN == 0 & ABS_DIFF_GAP`i'<p_high, robust			
			
		}
		}

		esttab    ,label se ///
								 keep(ABS_POP_EMP_NB_IMMI_GAP_DIFF ///
									  ABS_POP_FT_NB_IMMI_GAP_DIFF ///
								      ABS_POP_HOUR_NB_IMMI_GAP_DIFF ///
									  ABS_POP_WAGE_NB_IMMI_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 				
				*using "result/tables/Treatment_Effect_First_Gen_ABS.tex"
				
				
******************************Treatment_Effect_Second_Gen****************************************				
	eststo clear
	forvalues i = 1/6{
	if `truncy' >0{
			
			quietly sum DIFF_GAP`i' if P_EXP==1 & SECOND_GEN == 1 ,de 
			scalar p_low = r(p`truncy')
			local high = 100-`truncy'
			scalar p_high = r(p`high')
		
			eststo: quietly reg DIFF_GAP`i' POP_EMP_NB_IMMI_GAP_DIFF ///
								POP_FT_NB_IMMI_GAP_DIFF ///
								POP_HOUR_NB_IMMI_GAP_DIFF ///
								POP_WAGE_NB_IMMI_GAP_DIFF ///
								POP_EMP_NB_SECOND_GAP_DIFF ///
								POP_FT_NB_SECOND_GAP_DIFF ///
								POP_HOUR_NB_SECOND_GAP_DIFF ///
								POP_WAGE_NB_SECOND_GAP_DIFF ///			
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1 & SECOND_GEN == 1 & DIFF_GAP`i'<p_high & DIFF_GAP`i'>p_low  , robust
								
		}
		else{
			eststo: quietly reg DIFF_GAP`i' POP_EMP_NB_IMMI_GAP_DIFF ///
								POP_FT_NB_IMMI_GAP_DIFF ///
								POP_HOUR_NB_IMMI_GAP_DIFF ///
								POP_WAGE_NB_IMMI_GAP_DIFF ///
								POP_EMP_NB_SECOND_GAP_DIFF ///
								POP_FT_NB_SECOND_GAP_DIFF ///
								POP_HOUR_NB_SECOND_GAP_DIFF ///
								POP_WAGE_NB_SECOND_GAP_DIFF ///			
								$Demo_Controls ///
								log_wage ///
								SF2 ///
								if P_EXP==1 & SECOND_GEN == 1, robust			
			
		}
		}

		esttab   ,label se ///
								 keep(POP_EMP_NB_SECOND_GAP_DIFF ///
									  POP_FT_NB_SECOND_GAP_DIFF ///
									  POP_HOUR_NB_SECOND_GAP_DIFF ///
									  POP_WAGE_NB_SECOND_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 				
		* using "result/tables/Treatment_Effect_Second_Gen.tex"
		
	* Absolute change	
	eststo clear
	forvalues i = 1/6{
	if `truncy' >0{
			quietly sum ABS_DIFF_GAP`i' if P_EXP==1 & SECOND_GEN == 1 ,de 
			local high = 100-`truncy'
			scalar p_high = r(p`high')
		
			eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_NB_IMMI_GAP_DIFF ///
									ABS_POP_FT_NB_IMMI_GAP_DIFF ///
									ABS_POP_HOUR_NB_IMMI_GAP_DIFF ///
									ABS_POP_WAGE_NB_IMMI_GAP_DIFF ///
									ABS_POP_EMP_NB_SECOND_GAP_DIFF ///
									ABS_POP_FT_NB_SECOND_GAP_DIFF ///
									ABS_POP_HOUR_NB_SECOND_GAP_DIFF ///
									ABS_POP_WAGE_NB_SECOND_GAP_DIFF ///			
									$Demo_Controls ///
									log_wage ///
									SF2 ///
									if P_EXP==1 & SECOND_GEN == 1 & ABS_DIFF_GAP`i'<p_high , robust							
		}
		else{
		
			eststo: quietly reg ABS_DIFF_GAP`i' ABS_POP_EMP_NB_IMMI_GAP_DIFF ///
									ABS_POP_FT_NB_IMMI_GAP_DIFF ///
									ABS_POP_HOUR_NB_IMMI_GAP_DIFF ///
									ABS_POP_WAGE_NB_IMMI_GAP_DIFF ///
									ABS_POP_EMP_NB_SECOND_GAP_DIFF ///
									ABS_POP_FT_NB_SECOND_GAP_DIFF ///
									ABS_POP_HOUR_NB_SECOND_GAP_DIFF ///
									ABS_POP_WAGE_NB_SECOND_GAP_DIFF ///			
									$Demo_Controls ///
									log_wage ///
									SF2 ///
									if P_EXP==1 & SECOND_GEN == 1  , robust					
			
			
		}
	}

		esttab   ,label se ///
								 keep(ABS_POP_EMP_NB_SECOND_GAP_DIFF ///
									  ABS_POP_FT_NB_SECOND_GAP_DIFF ///
									  ABS_POP_HOUR_NB_SECOND_GAP_DIFF ///
									  ABS_POP_WAGE_NB_SECOND_GAP_DIFF) ///
				 star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ///
				nonotes  replace 			
				
			*using "result/tables/Treatment_Effect_Second_Gen_ABS.tex" 		
	restore
end

program summary_tb
	syntax [if], vlist(str) filename(str)
	est clear 
	estpost tabstat `vlist' `if', stat(count min p1 p5 p25 p50 p75 p95 p99 max) c(s)
	esttab using "`filename'.tex", replace ///
				cells("count(fmt(%12.0fc)) Min(fmt(%12.0fc)) p1(fmt(%12.0fc)) p5(fmt(%12.0fc)) p25(fmt(%12.0fc)) p50(fmt(%12.0fc)) p75(fmt(%12.0fc)) p95(fmt(%12.0fc)) p99(fmt(%12.0fc)) Max(fmt(%12.0fc))") ///
				 nomtitle nonote noobs nonumber label alignment(rrrrrrrrrrrr)
end 


*******************************************************************************
*************************** MAIN Code is here *********************************
*******************************************************************************

import sas using "data/wave1/9781_SpelmanCollege_ForeignRemittance24_W1_FinalWeightedData.sas7bdat",clear
keep if  QUAL == 1 // 1,168 COMPLETES

	replace_missing_value
	
	gen_label_variables

	summary_tb if SECOND_GEN == 0, vlist("SF1 PRE_CB1 PRE_SB2 PRE_CB4 PRE_SB4 PRE_CB6 PRE_SB1_med PRE_CB3_med PRE_SB3 PRE_CB5 SF2 PRE_CB2") ///
								   filename("result/tables/prior_qtle_first")
	summary_tb if SECOND_GEN == 1, vlist("SF1 PRE_CB1 PRE_SB2 PRE_CB4 PRE_SB4 PRE_CB6 PRE_SB1_med PRE_CB3_med PRE_SB3 PRE_CB5 SF2 PRE_CB2") ///
								   filename("result/tables/prior_qtle_second")

	summary_tb if SECOND_GEN == 0, vlist("POP_NB_EMP_DIFF POP_IMMI_EMP_DIFF POP_SECOND_EMP_DIFF POP_NB_FT_DIFF POP_IMMI_FT_DIFF POP_SECOND_FT_DIFF POP_NB_WAGE_DIFF POP_IMMI_WAGE_DIFF POP_SECOND_WAGE_DIFF POP_NB_HOUR_DIFF POP_IMMI_HOUR_DIFF POP_SECOND_HOUR_DIFF") ///
								   filename("result/tables/pop_qtle_first")
	summary_tb if SECOND_GEN == 1, vlist("POP_NB_EMP_DIFF POP_IMMI_EMP_DIFF POP_SECOND_EMP_DIFF POP_NB_FT_DIFF POP_IMMI_FT_DIFF POP_SECOND_FT_DIFF POP_NB_WAGE_DIFF POP_IMMI_WAGE_DIFF POP_SECOND_WAGE_DIFF POP_NB_HOUR_DIFF POP_IMMI_HOUR_DIFF POP_SECOND_HOUR_DIFF") ///
								   filename("result/tables/pop_qtle_second")
		
		
	winsor_raw_data	, only_pop(1)
		
*	winsor_raw_data	

	gen_gap
	
	*count_figure
	
	balance_table 
	
	prior_regression, truncy(5) 
	
	population_regression, truncy(5)
	
	*winsor_gap_data
		
	main_treat_regression, truncy(5) trunc_time(5)
	
	subsample_treat_regression, truncy(5)
	
	

	

			
