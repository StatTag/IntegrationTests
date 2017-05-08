***************************************************************
*** Program Name: Tables.sas
***
*** Notes: This program contains information on the commands used
*** with SAS to generate tables that are compatible with StatTag
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

/* The ODS CSV and ODS PDF commands

The ODS CSV and ODS PDF commands are used to print the content of a dataset, or the result of a 
procedure step to an external csv or pdf file. StatTag pulls in the destination file to the active 
word document. StatTag recognizes ODS CSV commands to create tables, and  ODS PDF commands to 
create figures. Any information in an external csv file will be pulled in as a table, and any 
information in an external pdf file will be pulled in as an un-editable figure. Examples of both 
are shown below.
*/

* 1. Using the ODS CSV command;
Proc Freq Data = SampleData;
	Table Drug * Gender / chisq;
	Ods Output Chisq = Chisquaredtest;
	Ods Output CrossTabFreqs = GenderTable;
Run; 

Data GenderTable (Keep = Drug Gender Frequency RowPercent); Set GenderTable;
	Where Drug ^= . and Gender ^= "";
Run; 

Data GenderTable; Set GenderTable;
	Length NPCT $40.;
	NPCT = trim(left(put(Frequency,8.0)))||" ("||trim(left(put(RowPercent,8.1)))||")";
Run;

Proc Transpose Data = GenderTable Out = GenderTable;
	Var NPCT;
	By Drug;
	Id Gender;
Run;

Data GenderTable (keep = Treatment Male Female); Set GenderTable;
	Length Treatment $40.;
	If Drug = 0 then Treatment = "Control";
	If Drug = 1 then Treatment = "Intervention";
Run;

ODS CSV FILE = "&Path.\SASExampleTable.csv";
Proc Print Data = GenderTable noobs; 
	Var Treatment Male Female;
Run;
ODS CSV CLOSE;

* A table has been output reflecting the contents of the dataset "Summary". This table is in the 
location specified in the &Path variable;

* This macro contains calls for generating a table 1;
Filename Table1 "&Path.\Table1.sas";
%include Table1;

%ByParametricBinary (Data=SampleData,Var=Age,By=Drug);
%ByCategories (Data=SampleData,Var=Gender,by=Drug);

%ByParametricBinary (Data=SampleData,Var=SBP_Baseline,By=Drug);
%ByParametricBinary (Data=SampleData,Var=SBP_Follow_Up,By=Drug);
%ByParametricBinary (Data=SampleData,Var=BP_Difference,By=Drug);

%ByParametricBinary (Data=SampleData,Var=Total_Cholesterol,By=Drug);
%ByCategories (Data=SampleData,Var=Current_or_Previous_Smoker,by=Drug);
%ByCategories (Data=SampleData,Var=History_of_Diabetes,by=Drug);

Data ByDescriptives; Set ByDescriptives;
	Rename _0 = Control;
	Rename _1 = Treatment;
	If Variable = "0" then Variable = "No";
	If Variable = "1" Then Variable = "Yes";
Run;

ods csv file = "&Path.\Table1Example.csv";
Proc Print Data = ByDescriptives noobs;
Var Variable Control Treatment PValue NTotal;
Run;
ods csv close;
