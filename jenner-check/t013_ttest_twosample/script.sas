/* mock data for external libref STAT1 (course library ~/ECST142/data) */
data german;
  input group $ change @@;
  datalines;
A 5.2 A 4.8 A 6.1 A 5.5 A 4.9 A 5.8 A 6.3 A 5.0 A 5.6 A 4.7
A 5.9 A 6.0 A 5.3 A 4.6 A 5.7 B 3.1 B 2.8 B 3.9 B 2.5 B 3.4
B 4.0 B 2.9 B 3.6 B 3.0 B 2.7 B 3.8 B 3.2 B 2.6 B 3.5 B 3.3
;
run;

proc univariate data=german;
  class group;
  var change;
  qqplot change / normal(mu=est sigma=est);
run;

proc ttest data=german;
  class group;
  var change;
run;

/**The two-sample t-test is also a GLM/ANOVA question**/
proc glm data=german;
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
