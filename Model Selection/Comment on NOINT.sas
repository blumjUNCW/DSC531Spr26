libname SASData '~/SASData';

data CDI;
  set sasdata.cdi;
  popDensity = pop/land;
  CrimeRate = crimes/pop*1000;
run;

proc glm data=cdi;
    model inc_per_cap =  unemp popDensity CrimeRate  ;
run;

proc glm data=cdi;
    model inc_per_cap =  unemp popDensity CrimeRate / noint;
    /**The lack of an intercept inflates R^2 when you have only
      quantitative predictors*/
run;
