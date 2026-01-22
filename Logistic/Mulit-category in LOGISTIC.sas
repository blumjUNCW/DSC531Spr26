proc logistic data=sashelp.cars;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
    /**Default multi-category models in LOGISTIC use the cumulative link,
        that's not appropriate for a nominal variable like origin,
        so we'll use the generalized logit**/
  *ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

proc logistic data=sashelp.cars descending;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
  *ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

proc logistic data=sashelp.cars;
  model origin(ref='Europe') = horsepower weight mpg_city msrp length / link=glogit;
  *ods exclude ModelInfo Nobs ConvergenceStatus GlobalTests FitStatistics;
run;

ods trace on;
proc logistic data=sashelp.cars;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
  output out=predict predprobs=(I);
  ods output oddsRatios = oddsR;
run;

proc print data=oddsR;
  format oddsRatioEst lowerCL upperCL best12.;
run;

proc freq data=predict;
  table _from_*_into_;
run;

proc report data=predict;
  where _from_ ne _into_ and (_from_ ne 'Europe' and _into_ ne 'Europe');
  column _from_ _into_ make model;
run;

proc standard data=sashelp.cars out=carsSTD mean=0 std=1;
  var horsepower weight mpg_city msrp length;
run;
proc logistic data=carsSTD;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
  output out=predict predprobs=(I);
  ods output oddsRatios = oddsR;
run;

ods graphics off;
proc logistic data=sashelp.cars;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
  units msrp=1000 2000 sd  mpg_city = 1 3 5;
  oddsratio msrp / cl=wald;
  oddsratio mpg_city/ cl=wald;
  output out=predict predprobs=(I);
run;

/*Take BP_Status as response from heart with ageAtStart and Weight as predictors...
*/
proc freq data=sashelp.heart;
  table bp_status;
  /*ordinal, ordered worst to best by default (alphabetical)*/
run;

proc logistic data=sashelp.heart;
  model bp_status = AgeAtStart Weight / link=logit;
    /**For multi-category, logit is cumulative logit 
        this is ordinal, categories alphabetical ordering corresponds 
        to a ranking (worst to best)**/
  ods select ModelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=sashelp.heart descending;
  model bp_status = AgeAtStart Weight / link=logit;
  ods select ModelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

proc logistic data=sashelp.heart descending;
  model bp_status = AgeAtStart Weight / link=alogit;
  /**Adjacent categories link can also be used in cases like
    this**/
  *ods select ModelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

proc freq data=sashelp.heart;
  table chol_status;
run;/**Cholesterol Status is ordinal, but the alphabetical ordering
  of its values is not a proper ranking**/

proc format;
  value $CholReOrder
    'Desirable'='1. Desirable'
    'Borderline'='2. Borderline'
    'High'='3. High'
  ;
run;
Title "Proportional Odds, Both Predictors";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit;
  ods select FitStatistics;
run;

Title "No Proportional Odds on Either Predictor";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit unequalslopes;
  ods select FitStatistics;
run;

Title "Proportional Odds for Weight, not for Age";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit unequalslopes=AgeAtStart;
  ods select FitStatistics;
run;

Title "Proportional Odds for Age, not for Weight";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit unequalslopes=Weight;
  ods select FitStatistics;
run;
/**AIC says do proportional odds for Age (not Weight)
   SC/SBC says do both as proportional odds for both (original model)**/

Title "Proportional Odds, Both Predictors";
Title2 "from SBC";
proc logistic data=sashelp.heart descending;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit;
  ods select ResponseProfile CumulativeModelTest
             ParameterEstimates OddsRatios;
run;
Title "Proportional Odds for Age, not for Weight";
Title2 "from AIC";
proc logistic data=sashelp.heart descending;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=logit unequalslopes=Weight;
  ods select ResponseProfile CumulativeModelTest
             ParameterEstimates OddsRatios;
run;

Title "Proportional Odds, Both Predictors";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit;
  ods select FitStatistics;
run;

Title "No Proportional Odds on Either Predictor";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit unequalslopes;
  ods select FitStatistics;
run;

Title "Proportional Odds for Weight, not for Age";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit unequalslopes=AgeAtStart;
  ods select FitStatistics;
run;

Title "Proportional Odds for Age, not for Weight";
proc logistic data=sashelp.heart;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit unequalslopes=Weight;
  ods select FitStatistics;
run;
/**AIC says do proportional odds for Age (not Weight)
   SC/SBC says do both as proportional odds for both (original model)
  same as cumulative**/

Title "Proportional Odds, Both Predictors";
Title2 "from SBC";
proc logistic data=sashelp.heart descending;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit;
  ods select ResponseProfile CumulativeModelTest
             ParameterEstimates OddsRatios;
run;
Title "Proportional Odds for Age, not for Weight";
Title2 "from AIC";
proc logistic data=sashelp.heart descending;
  format chol_status $CholReOrder.;
  model chol_status = AgeAtStart Weight / link=alogit unequalslopes=Weight;
  ods select ResponseProfile CumulativeModelTest
             ParameterEstimates OddsRatios;
run;