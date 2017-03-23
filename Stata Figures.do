***************************************************************
*** Program Name: Stata Figures.do
***
*** Notes: This program contains information on the commands used
*** with Stata to generate figures that are compatible with StatTag
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

* Extensions

*graph export "PathToFile\FileName.pdf", as(pdf) replace
*graph export "PathToFile\FileName.eps", as(eps) replace
*graph export "PathToFile\FileName.wmf", as(wmf) replace
*graph export "PathToFile\FileName.emf", as(emf) replace
*graph export "PathToFile\FileName.png", as(png) replace
*graph export "PathToFile\FileName.tif", as(tif) replace

*EXAMPLE 3

graph box bp_diff, over(intervention) title("Change in Blood Pressure by Group")
graph export "S:/NUCATS/NUCATS_Shared/BERDShared/Analysis Manager/Software/Documentation/Script Examples/Integration Tests/StataExampleFigure.pdf", as(pdf) replace

graph box bp_diff, over(intervention) title("Change in Blood Pressure by Group")
graph export "S:/NUCATS/NUCATS_Shared/BERDShared/Analysis Manager/Software/Documentation/Script Examples/Integration Tests/StataExampleFigure.tif", as(tif) replace






