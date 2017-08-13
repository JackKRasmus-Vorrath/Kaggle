FILENAME REFFILE '/home/jrasmusvorrath0/HousingTest.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=Ames_newtest;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=Ames_newtest; RUN;


data Ames_newtest2 (drop=old); set Ames_newtest (rename=(LotFrontage=old));
   LotFrontage = input(old, 8.0);
run;

proc contents data = Ames_newtest2; run;

data Ames_newtest3(drop= Alley PoolQC Fence MiscFeature); set Ames_newtest2;
run;

proc contents data = Ames_newtest3; run;

data Ames_newtest4; set Ames_newtest3(rename=(Functional="Functio-1l"n KitchenAbvGr="Kitche-1bvGr"n));
run;

proc contents data = Ames_newtest4; run;

data Ames_newtest5; set Ames_newtest4;
if KitchenQual = "Ex" then dKQ_3 = 1; else dKQ_3 = 0;
if MSZoning = "FV" then dMS_3 = 1; else dMS_3 = 0;
if MSZoning = "RL" then dMS_6 = 1; else dMS_6 = 0;
if Neighborhood = "NridgHt" then d5 = 1; else d5 = 0;
if Neighborhood = "StoneBr" then d10 = 1; else d10 = 0;
if Neighborhood = "NoRidge" then d14 = 1; else d14 = 0;
if Neighborhood = "CollgCr" then d18 = 1; else d18 = 0;
if Neighborhood = "Crawfor" then d19 = 1; else d19 = 0;
if Exterior1st = "BrkFace" then dE1_3 = 1; else dE1_3 = 0;
if Foundation = "PConc" then dF_3 = 1; else dF_3 = 0;
if BsmtQual = "Ex" then dBQ_1 = 1; else dBQ_1 = 0;
if BsmtExposure = "Gd" then dBE_1 = 1; else dBE_1 = 0;
if GarageQual = "Ex" then dGQ_1 = 1; else dGQ_1 = 0;
if Condition1 = "Artery" then dC1_2 = 1; else dC1_2 = 0;
if Condition1 = "RRAe" then dC1_7 = 1; else dC1_7 = 0;
log_SalePrice = log(SalePrice);
log_GrLivArea = log(GrLivArea);
log_LotArea = log(LotArea);
run;

data Ames_newtrain2; set Ames_train;
if _n_ = 524 then delete;
if _n_ = 1299 then delete;
if KitchenQual = "Ex" then dKQ_3 = 1; else dKQ_3 = 0;
if MSZoning = "FV" then dMS_3 = 1; else dMS_3 = 0;
if MSZoning = "RL" then dMS_6 = 1; else dMS_6 = 0;
if Neighborhood = "NridgHt" then d5 = 1; else d5 = 0;
if Neighborhood = "StoneBr" then d10 = 1; else d10 = 0;
if Neighborhood = "NoRidge" then d14 = 1; else d14 = 0;
if Neighborhood = "CollgCr" then d18 = 1; else d18 = 0;
if Neighborhood = "Crawfor" then d19 = 1; else d19 = 0;
if Exterior1st = "BrkFace" then dE1_3 = 1; else dE1_3 = 0;
if Foundation = "PConc" then dF_3 = 1; else dF_3 = 0;
if BsmtQual = "Ex" then dBQ_1 = 1; else dBQ_1 = 0;
if BsmtExposure = "Gd" then dBE_1 = 1; else dBE_1 = 0;
if GarageQual = "Ex" then dGQ_1 = 1; else dGQ_1 = 0;
if Condition1 = "Artery" then dC1_2 = 1; else dC1_2 = 0;
if Condition1 = "RRAe" then dC1_7 = 1; else dC1_7 = 0;
log_SalePrice = log(SalePrice);
log_GrLivArea = log(GrLivArea);
log_LotArea = log(LotArea);
run;

data Ames_newtrain3; set Ames_newtrain2;
if _n_ = 31 then delete;
run;

data Ames_newtrain4; set Ames_newtrain3;
if _n_ = 410 then delete;
if _n_ = 999 then delete;
run;


data Ames_newfull; set Ames_newtrain4 Ames_newtest5;
run;

proc contents data = Ames_newfull; run;

proc print data = Ames_newfull;
run;


proc glm data = Ames_newfull plots = all outstat = new_reg_est5;							
model log_SalePrice = log_GrLivArea log_LotArea OverallQual OverallCond YearBuilt 
	GarageCars Fireplaces "Kitche-1bvGr"n
	TotalBsmtSF BsmtFullBath 
	dKQ_3 dMS_3 dMS_6
	BsmtFinSF1

d5 d10 d14 d18 d19
dE1_3
dF_3
dBQ_1
dBE_1
dGQ_1
dC1_2
dC1_7 / cli solution;
output out = result7 p = predict7;
run;

proc print data = result7;
run;

proc contents data = result7; run;

data new_finalp; set result7 (where=(Id > 1460));
if exp(predict7) <= 30000 then Sale_P = 32000;
else Sale_P = exp(predict7);
keep Id Sale_P;
rename Sale_P = SalePrice;
run;

proc print data = new_finalp;
run;

proc export data= new_finalp
     outfile="/home/jrasmusvorrath0/Ames_Kaggle_Submission2.csv"
     dbms=csv 
     replace;
run;