***************************************************************
*** Program Name: Stata Tables.do
***
*** Notes: This program contains information on the commands used
*** with Stata to generate tables that are compatible with StatTag
***        
*** Date Created: 5 January, 2017
***************************************************************

* pull up the "bpwide" dataset that comes with Stata
sysuse bpwide

*generating additional variable,"intervention", through binomial distribution random sampling with probability of ~0.5 to be assigned to intervention group
set seed 20151103
gen intervention=rbinomial(1,0.5)
label variable intervention "1=intervention 0=control"

*generate the difference in bp
gen bp_diff=bp_after-bp_before
label variable bp_diff "Difference in BP"

*installation of estout package
ssc install estout, replace

*Variables to Store results
gen str12 rowname = ""
gen control1 = .
gen control2 = .
gen int1 = .
gen int2 = .
gen pval = .

*Lists of variables(one for categorical, one for continuous)
global catlist sex agegrp
global conlist bp_before bp_after bp_diff

*Row Counter
gen nn = _n
global rowct 1

* cycle through and fill out table 1
* note this is hard coded for intervention with 2 levels
* coded as 0 for control and 1 for intervention
foreach var of global catlist {
			
	qui tabulate `var' intervention, chi2
	replace pval = r(p) if nn == $rowct
	
	levelsof `var', local(varlevs)
	foreach lev of local varlevs {
		
		replace rowname = "`var' = `lev'" if nn == $rowct
		qui count if `var' == `lev' & intervention == 0
		replace control1 = r(N) if nn ==  $rowct
		replace control2 = r(N)/$totn if nn == $rowct
		
		qui count if `var'== `lev' & intervention == 1
		replace int1 = r(N) if nn == $rowct
		replace int2 = r(N)/$totn if nn == $rowct
		
		global rowct = $rowct + 1
	}
	}
	
foreach var of global conlist {
		replace rowname = "`var'" if nn == $rowct
		qui summarize `var' if intervention == 0
		replace control1 = r(mean) if nn == $rowct
		replace control2 = r(sd) if nn == $rowct
		
		qui summarize `var' if intervention == 1
		replace int1 = r(mean) if nn == $rowct
		replace int2 = r(sd) if nn == $rowct
		
		qui ttest `var', by(intervention)
		replace pval = r(p) if nn == $rowct
		
		global rowct = $rowct + 1
		}

mkmat control1 - pval if nn < $rowct, matrix(Table1) rownames(rowname)

*Run the regression models
regress bp_diff sex
estimates store model1

xi: regress bp_diff i.agegrp
estimates store model2

regress bp_diff intervention
estimates store model3

xi: regress bp_diff sex i.agegrp intervention
estimates store model4

estimates table model1 model2 model3 model4
matrix define A = r(coef)

estout model1 model2 model3 model4, cells("b p")
matrix define B = r(coefs)

estimates table model1 model2
matrix list r(coef)

*Simple matrix of tabulated results
tabulate sex intervention, matcell(A)
matrix list A

*using the mkmat command
mkmat control1 - pval if nn < $rowct, matrix(B) rownames(rowname)
matrix list B
