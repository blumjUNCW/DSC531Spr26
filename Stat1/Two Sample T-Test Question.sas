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
