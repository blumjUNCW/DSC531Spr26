libname stat1 '~/ECST142/data';

proc means data=stat1.garlic mean std;
  class fertilizer;
  var bulbWt;
run;

proc sgplot data=stat1.garlic;
  hbox bulbWt / group=fertilizer;
run;

ods graphics off;
proc glm data=stat1.garlic;
  class fertilizer;
  model bulbWt = fertilizer / solution;
  lsmeans fertilizer / diff adjust=tukey;
  means fertilizer / hovtest=levene;
  means fertilizer / hovtest=bartlett;
  /**hovtest asks for an equal variances test across
      all groups--generalization of the f-test
      given in PROC TTEST**/
run;

/**Normality got ignored here, but we can check it...**/
ods graphics off;
proc glm data=stat1.garlic;
  class fertilizer;
  model bulbWt = fertilizer / solution;
  output out=results r=residual;
  /*get out the estimated errors, residuals*/
run;

proc univariate data=results;
  var residual;
  qqplot residual / normal(mu=est sigma=est);
run;/**check them for normality**/

