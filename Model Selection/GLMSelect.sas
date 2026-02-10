libname SASData '~/SASData';

data CDI;
  set sasdata.cdi;
  popDensity = pop/land;
  CrimeRate = crimes/pop*1000;
run;

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / selection=Forward;
      /**default select criterion is SBC and it is also the default stop criterion**/
run;

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / selection=stepwise(select=SL);
      /**SL is significance level, defaults for stepwise are 0.15 for both entry and stay
          since I specified nothing else, it is also the stop criterion**/
run;

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=SL) slentry=0.05 slstay=0.05;
      /**SLENTRY and SLSTAY are available to go with SL, but they go outside the
          parentheses**/
run;

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=SL choose=SBC) slentry=0.8 slstay=0.8;
      /**Since you never get all possible models here--it's always in steps--
          you can let the process run through an excess selection method
          and then be more restrictive with your choose criterion**/
run;

ods trace on;
proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=SL stop=SBC) slentry=0.8 slstay=0.8;
    ods select selectionSummary;
run;
proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=SBC);
    ods select selectionSummary;
run;
/**So, criteria for the process, stopping, and choosing best can
    all be set to different things**/

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=SL stop=SBC) slentry=0.8 slstay=0.8
            details=all;
            /**Can get detailed information on each step if you want*/
run;

proc glmselect data=cdi seed=210;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv);
run;

proc glmselect data=cdi seed=210;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv);
run;/**Folding is random, if you want to ensure folding is the 
    same from one instance to another, use a specific seed value*/

proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=sl choose=cv)
            stats=(aic aicc bic sbc press);
run;

data rand;
    set cdi;
    rand=ranuni(0);
    /*rand is random uniform on (0,1)*/
run;

proc sgplot data=rand;
  histogram rand / binstart=0.05 binstart=0.1;
run;

proc sort data=rand;
  by rand;
run;/**random order, so cut into k folds*/

proc glmselect data=cdi seed=210;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv);
run;
proc glmselect data=cdi;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv) cvmethod=block;
            /**block divides the data set as is into k
              blocks of rows*/
run;

proc glmselect data=cdi seed=210;
    class region;
    model inc_per_cap = region land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv) cvmethod=random(10);
run;

proc glmselect data=cdi;
    model inc_per_cap = land--unemp popDensity CrimeRate / 
            selection=stepwise(select=cv) 
            cvmethod=index(region);
            /*Index uses a variable you've provided in the
                data to identify the folds (and 
                so the number of folds is implicit)*/
run;

proc glmselect data=sashelp.cars;
    class origin type;
    model msrp = type origin mpg: weight engineSize /
          selection=stepwise(select=cv);
run;