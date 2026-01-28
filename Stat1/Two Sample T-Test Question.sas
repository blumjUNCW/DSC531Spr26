libname STAT1 "~/ECST142/data";

proc univariate data=stat1.german;
  class group;
  var change;
  qqplot change / normal(mu=est sigma=est);
run;

proc ttest data=stat1.german;
  class group;
  var change;
run;

/**The two-sample t-test is also a GLM/ANOVA question**/
proc glm data=stat1.german;
  class group;
  model change = group / solution;
  lsmeans group / diff cl;
  means group / hovtest=bartlett;
  output out=results r=residual;
run;

proc univariate data=results;
  var residual;
  qqplot residual / normal(mu=est sigma=est);
run;