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

proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / selection=Forward;
    /**In REG, forward selection, backward elimination, and stepwise all
        use significance level as the criteria and they use threshhold values
        that are rather big...**/
run;

proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / selection=Forward slentry=0.05;
    /****/
run;

proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / selection=Backward slstay=0.05;
    /****/
run;

proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / 
            selection=Stepwise slentry=0.05  slstay=0.05;
    /****/
run;

ods graphics off;
proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / 
            selection=adjrsq;
    /**with AdjRsq you get an "All Subsets" selection
        (limited)**/
run;

ods graphics off;
proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / 
            selection=adjrsq best=10;
    /**with AdjRsq you get an "All Subsets" selection
        (limited with best=)**/
run;

ods graphics off;
ods trace on;
proc reg data=cdi;
  model inc_per_cap = land--unemp popDensity CrimeRate / 
            selection=adjrsq aic bic sbc;
  ods output SubsetSelSummary=candidates;
    /**You can add in other stats, but they are not the 
      selector...best to send it to a data set for sorting**/
run;
