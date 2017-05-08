***************************************************************
*** Program Name: Values.sas
***
*** Notes: This program contains information on the commands used
*** with SAS to generate values that are compatible with StatTag
***        
*** Date Created: 5 January, 2017
***************************************************************;
OPTIONS NODATE NONUMBER;

filename Sample "%sysfunc(getoption(work))/SampleData.sas7bdat";
 
proc http method="get" 
 url="https://github.com/StatTag/IntegrationTests/raw/master/sampledata.sas7bdat" 
 out=Sample;
run;
 
filename Sample clear;
 
/* The %put command

The %put command can be used to show any string or character data stored in a 
macro variable. In brief, the %put command prints what is stored in the SAS macro 
table to the log, which is captured by StatTag and placed in the Word document. 
Additional references to relevant SAS documentation are shown below.

In order to use the %put command, data need to be stored in the macro table using 
either a %let or call symput statement. Examples of both are shown below.
*/

*EXAMPLE 1

* 1. Use the %let and %put commands to count the number of people in the dataset;
%let dsid=%sysfunc(open(SampleData));
%let num=%sysfunc(attrn(&dsid,nlobs));
%let rc=%sysfunc(close(&dsid));

%put &num;

*There are 250 observations;

* The following code shows examples of other ways in which a value can by displayed
* 2. Use the call symput statement to determine how many people are in each treatment group;
Proc Freq Data = SampleData;
	Table Drug;
	Ods Output Onewayfreqs = Summary;
Run;

Data Summary; Set Summary;
	If Drug = 0 then call symput('Placebo',trim(left(put(Frequency,8.))));
	If Drug = 1 then call symput('Treated',trim(left(put(Frequency,8.))));
Run;

%put &Placebo;
%put &Treated;
*There are 112 people in the placebo group, and 138 in the treated group;

* 3. Use the call symput statement to return a p-value from a chi-squared test;
Proc Freq Data = SampleData;
	Table Drug * Gender / chisq;
	Ods Output Chisq = Chisquaredtest;
	Ods Output CrossTabFreqs = GenderTable;
Run; 

Data Chisquaredtest; Set Chisquaredtest;
	If Statistic = "Chi-Square" then call symput('PValue',trim(left(put(Prob,PVALUE6.4))));
Run;

%put &PValue;
*The p-value is 0.8674;

/*
For additional information on any of these commands:
%let macro statement
http://support.sas.com/documentation/cdl/en/mcrolref/61885/HTML/default/viewer.htm#a000543704.htm

call symput routine
http://support.sas.com/documentation/cdl/en/mcrolref/61885/HTML/default/viewer.htm#a000210266.htm
*/

