FILENAME REFFILE '/home/jrasmusvorrath0/HousingTest.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=Ames_test;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=Ames_test; RUN;


data Ames_test2 (drop=old); set Ames_test (rename=(LotFrontage=old));
   LotFrontage = input(old, 8.0);
run;

proc contents data = Ames_test2; run;

data Ames_test3(drop= Alley PoolQC Fence MiscFeature); set Ames_test2;
run;

proc contents data = Ames_test3; run;

data Ames_test4; set Ames_test3(rename=(Functional="Functio-1l"n KitchenAbvGr="Kitche-1bvGr"n));
run;

proc contents data = Ames_test4; run;

data Ames_test5; set Ames_test4;
if SaleCondition = "Normal" then dSC_1 = 1; else dSC_1 = 0;
if SaleCondition = "Partial" then dSC_3 = 1; else dSC_3 = 0;
if KitchenQual = "Ex" then dKQ_3 = 1; else dKQ_3 = 0;
if MSZoning = "C" then dMS_2 = 1; else dMS_2 = 0;
if MSZoning = "FV" then dMS_3 = 1; else dMS_3 = 0;
if MSZoning = "RL" then dMS_6 = 1; else dMS_6 = 0;
if HeatingQC = "Ex" then dHQ_1 = 1; else dHQ_1 = 0;
log_SalePrice = log(SalePrice);
log_GrLivArea = log(GrLivArea);
log_LotArea = log(LotArea);
run;

data Ames_train2; set Ames_train;
if _n_ = 31 then delete;
if _n_ = 524 then delete;
if SaleCondition = "Normal" then dSC_1 = 1; else dSC_1 = 0;
if SaleCondition = "Partial" then dSC_3 = 1; else dSC_3 = 0;
if KitchenQual = "Ex" then dKQ_3 = 1; else dKQ_3 = 0;
if MSZoning = "C" then dMS_2 = 1; else dMS_2 = 0;
if MSZoning = "FV" then dMS_3 = 1; else dMS_3 = 0;
if MSZoning = "RL" then dMS_6 = 1; else dMS_6 = 0;
if HeatingQC = "Ex" then dHQ_1 = 1; else dHQ_1 = 0;
log_SalePrice = log(SalePrice);
log_GrLivArea = log(GrLivArea);
log_LotArea = log(LotArea);
run;

data Ames_train3; set Ames_train2;
if _n_ = 1299 then delete;
run;


data Ames_full; set Ames_train3 Ames_test5;
run;

proc contents data = Ames_full; run;

proc print data = Ames_full;
run;


proc glm data = Ames_full plots = all outstat = reg_est15;							
model log_SalePrice = log_GrLivArea log_LotArea OverallQual OverallCond YearBuilt 
	GarageCars Fireplaces "Kitche-1bvGr"n
	TotalBsmtSF BsmtFullBath 
	dKQ_3 dSC_1 dSC_3 dMS_2 dMS_3 dMS_6
	dHQ_1 BsmtFinSF1 / cli solution;
output out = result6 p = predict6;
run;

proc print data = result6;
run;

proc contents data = result6; run;

data finalp; set result6 (where=(Id > 1460));
if exp(predict6) <= 30000 then Sale_P = 40000;
else Sale_P = exp(predict6);
keep Id Sale_P;
rename Sale_P = SalePrice;
run;

proc print data = finalp;
run;

proc export data= finalp
     outfile="/home/jrasmusvorrath0/Ames_Kaggle_Submission.csv"
     dbms=csv 
     replace;
run;