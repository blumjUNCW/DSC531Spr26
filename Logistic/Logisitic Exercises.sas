libname SASData '~/SASData';

proc format;
  value poverty
    10 - high = 'Above 10%'
    other = 'Below 10%'
    ;
run;

proc logistic data=sasdata.cdi descending;
  format poverty poverty.;
  class region / param=glm;
  model poverty = region ba_bs over65;
run;