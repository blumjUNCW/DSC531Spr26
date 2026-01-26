libname STAT1 "~/ECST142/data";/**This is our library assignment for the Statistics 1 course**/

proc univariate data=stat1.normtemp;
  var bodytemp;
  histogram bodytemp / normal;
  inset n mean std;
  qqplot bodytemp / normal(mu=est sigma=est);
  inset n mean std;
run;

proc ttest data=stat1.normtemp h0=98.6 plots(showh0)=all;
  var bodytemp;
run;