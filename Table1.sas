*********************************************************************
* This macro contains 5 macro definitions, all taking 3 arguments:  *
*  ByCategories(Data=,Var=,by=);									*
*  ByParametricBinary(Data=,Var=,By=);								*
*  ByParametricBinary(Data=,Var=,By=);								*
*  NonParametric(Data=,Var=,By=);									*
*  NonParametricBinary(Data=,Var=,By=);								*
*																	*
* Data: identifies the dataset on which to run the code				*
* Var: indicates the variable used for descriptive statistics		*
* By: indicates the group variable by which to stratify             *
*																	*
* This macro returns a dataset "ByDescriptives".					*
* Categorical data is presented as N(%) with a chi-squared p-value. *
* Continuous data is presented as either mean(SD) or median(IQR).   *
* ANOVA, t-test and Kruskal-Wallis are returned as appropriate. 	*										*
*																	*
* These macros can be called by inserting the following statements  *
* to your program:													*
*  Filename Table1 "&Path.\Table1.sas";								*
*  %include Table1;													*
*********************************************************************

*Create Macros For Table1;
%Macro ByCategories(Data=,Var=,by=);

Proc Freq Data = &Data;
	Table &by*&Var / chisq;
	Ods Output CrossTabFreqs = Cat;
	ods output chisq = chisqtest;
RUN;

Data Cat; Set Cat;
	If _TYPE_ = "00" then Call Symput ("NTot", put(Frequency,BEST12.));
	Type = vtype(&By);
Run;

Data Cat (Keep = &by Descriptive Variable);
	Set Cat;
	If ColPercent = . then Delete;
	If (Type="N" and &by = .) then Delete;
	Else If (Type="C" and &by = "") then Delete;
    length Descriptive Variable $40.;
	Variable = trim(left(put(&Var,15.)));
	Descriptive = trim(left(put(Frequency,8.0)))||" ("||trim(left(put(RowPercent,8.0)))||")";
Run;

Proc Sort Data = Cat; By Variable; Run; 

Proc Transpose Data = Cat Out = Cat;
	Var Descriptive;
	By Variable;
	Id &by;
Run;

Data ChisqTest; Set ChisqTest;
	Where Statistic = "Chi-Square";
	Call Symput ("PVal", put(Prob,PVALUE6.4));
Run;

Proc sql;                                                                                    
  insert into Cat                                                                                
  set Variable="%upcase(&Var)";                                               
quit; 

Proc Sort Data = Cat; By _NAME_; Run;

Data Cat (Drop =_NAME_); Set Cat;     
	Length NTotal $12.;
	If Variable = "%upcase(&Var)" then do;
		Pvalue = "&Pval";
		NTotal = "&NTot";
	End;
Run;

Proc Append Base = ByDescriptives Data = Cat Force; Run;
%Mend ByCategories;

%Macro ByParametricBinary(Data=,Var=,By=);
proc ttest data = &Data;
	class &By;
	Var &Var;
	ods output statistics = continuous;
	ods output Ttests = ttest;
Run;

Proc Means Data = &Data; 
	Var &Var;
	Ods output summary = ContinuousTotal;
Run; 

data continuous (keep= Variable Class descriptive);
  set continuous;
  length descriptive $40.;
  if index(Class, "Diff") > 0 then delete;
  descriptive=trim(left(put(Mean,8.2)))||" "||byte(177)||" "||trim(left(put(StdDev,8.2)));
run;

Proc Transpose Data = continuous Out = continuous;
	Var Descriptive;
	Id Class;
Run;
	
Data TTest; Set TTest;
	If Method = "Pooled" then Call Symput ("PVal", put(Probt,PVALUE6.4));
Run;

Data ContinuousTotal; Set ContinuousTotal;
	Call Symput ("NTot", put(&Var._N,BEST5.));
Run;

Data continuous (Drop =_NAME_); Set continuous;     
	length variable $40. NTotal $12.;
	variable = "%upcase(&Var)";
	Pvalue = "&Pval";
	NTotal = "&NTot";
Run;

Proc Append Base = ByDescriptives Data = continuous Force; Run;
%Mend ByParametricBinary;

%Macro ByParametric(Data=,Var=,By=);
proc anova data = &Data;
	class &By;
	model &Var = &By;
	means &By;
	ods output means = continuous;
	ods output ModelANOVA = Anovatest;
Run;

proc means data=&Data;
  var &Var;
  ods output Summary=Totals;
run;

data continuous (keep= &By descriptive);
  set continuous;
  length descriptive $40.;
  descriptive=trim(left(put(Mean_&Var,8.2)))||" "||byte(177)||" "||trim(left(put(SD_&Var,8.2)));
run;

Proc Transpose Data = continuous Out = continuous;
	Var Descriptive;
	Id &By;
Run;
	
Data AnovaTest; Set AnovaTest;
	Call Symput ("PVal", put(ProbF,PVALUE6.4));
Run;
	
Data Totals; Set Totals;
	Call Symput ("NTot", put(&Var._N,BEST3.));
Run; 

Data continuous (Drop =_NAME_); Set continuous;     
	length variable $40. NTotal $12.;
	variable = "%upcase(&Var)";
	Pvalue = "&Pval";
	NTotal = "&NTot";
Run;

Proc Append Base = ByDescriptives Data = continuous Force; Run;
%Mend ByParametric;

%Macro NonParametric(Data=,Var=,By=);
proc means data=&Data median p25 p75;
  class &By;
  var &Var;
  ods output Summary=continuous;
run;

proc means data=&Data;
  var &Var;
  ods output Summary=Totals;
run;

data continuous (keep= &By Descriptive);
  set continuous;
  length descriptive $40.;
  descriptive=trim(left(put(&Var._median,8.2)))||" ("||trim(left(put(&Var._P25,8.2)))||"-"||trim(left(put(&Var._P75,8.2)))||")";
run;

Proc Transpose Data = continuous Out = continuous;
	Var descriptive;
	Id &By;
Run;

proc npar1way data = &Data;
	var &Var;
	class &By;
	ods output  KruskalWallisTest = KWTest;
Run;

Data KWTest; Set KWTest;
	Where label1 = "Pr > Chi-Square";
	Call Symput ("PVal", cValue1);
Run;

Data Totals; Set Totals;
	Call Symput ("NTot", put(&Var._N,BEST3.));
Run; 

Data continuous (Drop =_NAME_); Set continuous;     
	length variable $40. NTotal $12.;
	variable = "%upcase(&Var)";
	Pvalue = "&Pval";
	NTotal = "&NTot";
Run;

proc append base=bydescriptives data=continuous force; run;
%mend NonParametric;

%Macro NonParametricBinary(Data=,Var=,By=);
proc means data=&Data median p25 p75;
  class &By;
  var &Var;
  ods output Summary=continuous;
run;

proc means data=&Data;
  var &Var;
  ods output Summary=Totals;
run;

data continuous (keep= &By Descriptive);
  set continuous;
  length descriptive $40.;
  descriptive=trim(left(put(&Var._median,8.2)))||" ("||trim(left(put(&Var._P25,8.2)))||"-"||trim(left(put(&Var._P75,8.2)))||")";
run;

Proc Transpose Data = continuous Out = continuous;
	Var descriptive;
	Id &By;
Run;

proc npar1way data = &Data;
	var &Var;
	class &By;
	ods output  WilcoxonTest = WTest;
Run;

Data WTest; Set WTest;
	Where Name1 = "P2_WIL";
	If nValue1 <= 0.0001 then Call Symput ("PVal", "<.0001");
	If nValue1 > 0.0001 then Call Symput ("PVal", nValue1);
Run;

Data Totals; Set Totals;
	Call Symput ("NTot", put(&Var._N,BEST3.));
Run; 

Data continuous (Drop =_NAME_); Set continuous;     
	length variable $40. NTotal $12.;
	variable = "%upcase(&Var)";
	Pvalue = "&Pval";
	NTotal = "&NTot";
Run;

proc append base=bydescriptives data=continuous force; run;
%mend NonParametricBinary;
