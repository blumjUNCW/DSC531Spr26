proc format;
  value $chol
  'Desirable' = '1. Desirable'
  'Borderline' = '2. Borderline'
  'High' = '3. High'
  ;
  value $Weight
  'Underweight' = '1. Under'
  'Normal' = '2. Normal'
  'Overweight' = '3. Over'
  ;
run;

proc freq data=sashelp.heart order=formatted;
  table chol_status*weight_status / chisq measures cl;
  format chol_status $chol. weight_status $Weight.;
run;

libname stat1 '/export/viya/homes/blumj@uncw.edu/ECST142/data';
ods graphics off;
options fmtsearch=(stat1);
proc format;
    value bonus
      1='Bonus'
      0='No Bonus'
      ;
run;
proc freq data=STAT1.ameshousing3 order=formatted;
    tables (Lot_Shape_2 Fireplaces)*Bonus
          / chisq expected cellchi2 nocol nopercent 
            relrisk;
    format Bonus bonus.;
    title 'Associations with Bonus';
run;

proc logistic data=stat1.ameshousing3;
  *class Lot_Shape_2(param=ref);
  *class Lot_Shape_2;
  class Lot_Shape_2 / param=glm;
  model bonus(event='1') = Lot_Shape_2;
run;

ods graphics on;
proc logistic data=STAT1.ameshousing3 alpha=0.05
              plots(only)=(effect oddsratio);
    model Bonus(event='1')=Basement_Area / clodds=pl;
    title 'LOGISTIC MODEL (1):Bonus=Basement_Area';
    output out=predict predprobs=(I);
run;

/**Get the pairings of any bonus to any non-bonus*/
proc sql;
  create table pairs as 
  select bonus.Basement_Area as bonusArea, bonus.IP_1 as bonusProb,
         nonbonus.Basement_Area as nonbonusArea, nonbonus.IP_1 as nonbonusProb
  from predict(where=(bonus eq 1)) as bonus,
        predict(where=(bonus eq 0)) as nonBonus
  ;
quit;

data pairs;
    set pairs;
    if bonusArea gt nonBonusArea and bonusArea gt nonBonusArea then pairType='C';
      else if bonusArea eq nonBonusArea or bonusArea eq nonBonusArea then pairType='T';
        else pairType='D';
run;

proc freq data=pairs;
  table pairType;
run;
