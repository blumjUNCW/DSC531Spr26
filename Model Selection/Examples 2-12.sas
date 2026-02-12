libname sasdata '~/SASData';

proc glmselect data=sasdata.realestate;
  class ac highway quality;
  model price = sq_ft--highway /
    selection=stepwise(select=sl choose=cv) 
    stats=(AIC AICC BIC SBC) ;
run;

proc reg data=sasdata.realestate;
  model price = sq_ft--highway /
    selection=adjrsq AIC BIC SBC;
  ods output subsetSelSummary=subsets;
run;

data realEstate(drop=quality);
    set sasdata.realestate;

    high=(quality eq 1);
    medium=(quality eq 2);
  
run;


proc reg data=realestate;
  model price = sq_ft--medium /
    selection=adjrsq AIC BIC SBC;
  ods output subsetSelSummary=subsets;
run;

proc glmselect data=realestate;
  class ac highway;
  model price = sq_ft--medium /
    selection=stepwise(select=sl choose=cv slentry=.5 slstay=.5) 
    stats=(AIC AICC BIC SBC adjrsq rsquare) ;
run;

/**In HPGENSELECT, use quality as response and find "best" model*/