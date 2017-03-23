***************************************************************
*** Program Name: Stata Values.do
***
*** Notes: This program contains information on the commands used
*** with Stata to generate values that are compatible with StatTag
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

*Two ways to display n
count if bp_before != . & bp_after != .
local ntotal = r(N)
global totn = r(N)

display r(N)
display `ntotal'

count if patient != .
return list
display r(N)

count if intervention == 1
local nintervention = r(N)
local ncontrol = `ntotal' - r(N)

*Displaying values from a matrix
tabulate sex, matcell(x)
local Male = x[1,1]
local Female = x[2,1]
display `Male'
display `Female'

*Use the display command to return a p-value from a chi-squared test;
tabulate sex intervention, chi2
return list
display r(p)








