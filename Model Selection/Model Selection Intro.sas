/**Find a "best" glm for predicting per-capita income based on CDI data**/
libname SASData '~/SASData';

/**For GLM, choosing the best model amounts to choosing a best predictor set--
  predictors may come directly from collected data, or may be constructed
  from them

  We presume all of the candidate predictors are assembled with the data
    at the outset.**/

data CDI;
  set sasdata.cdi;
  popDensity = pop/land;
  CrimeRate = crimes/pop*1000;
run;

proc glm data=sashelp.cars;
  model horsepower = weight engineSize msrp invoice mpg:;
run;
proc glm data=sashelp.cars;
  model horsepower = weight engineSize invoice mpg_Highway;
run;