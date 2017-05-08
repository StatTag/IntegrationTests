***************************************************************
*** Program Name: Figures.sas
***
*** Notes: This program contains information on the commands used
*** with SAS to generate figures that are compatible with StatTag
***        
*** Date Created: 5 January, 2017
***************************************************************;
OPTIONS NODATE NONUMBER;

* Modify the pathway as appropriate to direct to the location on your computer where
the output will be generated;
%Let Path = S:\NUCATS\NUCATS_Shared\BERDShared\Analysis Manager\Software\Documentation\Script Examples\Integration Tests;

filename Sample "%sysfunc(getoption(work))/SampleData.sas7bdat";
 
proc http method="get" 
 url="https://github.com/StatTag/IntegrationTests/raw/master/sampledata.sas7bdat" 
 out=Sample;
run;
 
filename Sample clear;

Proc Sort Data = SampleData;
	By Drug;
Run; 

*EXAMPLE 3;
ods graphics on / width=4.5in height=3.5in;
ODS PDF FILE = "&Path.\SASExampleFigure.pdf";
title1 h=12pt "Change in Blood Pressure by Treatement Group";
Proc Boxplot Data = SampleData;
	Plot BP_Difference*Drug;
Run;
ODS PDF CLOSE;

/*
For additional information on any of these commands:
ODS Statements
http://support.sas.com/documentation/cdl/en/odsug/67921/HTML/default/viewer.htm#p05xa6eans9jw2n1lsc8li0r8waw.htm
*/
