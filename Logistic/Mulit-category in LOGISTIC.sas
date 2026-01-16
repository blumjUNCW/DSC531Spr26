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

proc logistic data=sashelp.cars;
  model origin = horsepower weight mpg_city msrp length / link=glogit;
  output out=predict predprobs=(I);
run;

proc freq data=predict;
  table _from_*_into_;
run;

proc report data=predict;
  where _from_ ne _into_ and (_from_ ne 'Europe' and _into_ ne 'Europe');
  column _from_ _into_ make model;
run;
