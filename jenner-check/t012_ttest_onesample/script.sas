/* mock data for external libref STAT1 (course library ~/ECST142/data) */
data normtemp;
  input bodytemp @@;
  datalines;
98.6 98.2 97.8 99.0 98.4 98.0 97.6 98.8 99.2 98.1
98.5 97.9 98.3 98.7 99.1 97.7 98.9 98.2 98.4 98.6
97.5 98.0 98.8 99.0 98.3 98.1 97.9 98.7 98.5 98.2
98.4 98.6 97.8 99.1 98.0 98.9 98.3 97.7 98.5 98.7
;
run;

proc univariate data=normtemp;
  var bodytemp;
  histogram bodytemp / normal;
  inset n mean std;
  qqplot bodytemp / normal(mu=est sigma=est);
  inset n mean std;
run;

proc ttest data=normtemp h0=98.6 plots(showh0)=all;
  var bodytemp;
run;
