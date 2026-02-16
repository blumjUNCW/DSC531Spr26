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

/**In HPGENSELECT, use quality as response and 
  find "best" model*/
proc hpgenselect data=sasdata.realestate;
  model quality = price--year lot highway / dist=multinomial
                                          link=logit;
  selection method=stepwise(slentry=0.2 slstay=0.2 choose=SBC);
run;

proc logistic data=sasdata.realestate;
  model quality = price sq_ft bedrooms bathrooms ac year;
run;/**This is the best proportional odds model, but it
    appears proportional odds is not satisfied*/

proc freq data=sasdata.realestate;
    table quality*garage_size;
run;/**When we put several predictors in, some response categories
    are underrepresented or not represented for particular 
    combinations of predictors*/

/**Generalized logit is the equivalent to no proportional odds*/
proc hpgenselect data=sasdata.realestate;
  model quality = price--year lot highway / dist=multinomial
                                          link=glogit;
  selection method=stepwise(slentry=0.2 slstay=0.2);
run;

proc logistic data=sasdata.realestate;
  model quality = price sq_ft bedrooms bathrooms year ac / link=glogit;
run;

proc freq data=sasdata.realestate;
  table ac*quality;
run;/**Clear separation here on AC at high quality*/

/**People often avoid multicategory logit in the predictor selection
problem*/

proc format;
    value HighOrNot
      1='A. High'
      2-3='B. Not High'
      ;
    value LowOrNot
      3='A. Low'
      1-2='B. Not Low'
      ;
run;

proc hpgenselect data=sasdata.realestate;
  format quality HighOrNot.;
  model quality = price--year lot highway / dist=multinomial
                                          link=logit;
  selection method=stepwise(slentry=0.2 slstay=0.2 choose=SBC);
run;
proc hpgenselect data=sasdata.realestate;
  format quality LowOrNot.;
  model quality = price--year lot highway / dist=multinomial
                                          link=logit;
  selection method=stepwise(slentry=0.2 slstay=0.2 choose=SBC);
run;/**Splitting the cumulative link choices.. */

proc hpgenselect data=sasdata.realestate;
  where quality in (1,2);
  model quality = price--year lot highway / dist=multinomial
                                          link=logit;
  selection method=stepwise(slentry=0.2 slstay=0.2 choose=SBC);
run;
proc hpgenselect data=sasdata.realestate;
  where quality in (2,3);
  model quality = price--year lot highway / dist=multinomial
                                          link=logit;
  selection method=stepwise(slentry=0.2 slstay=0.2 choose=SBC);
run;/**Splitting the adjacent link choices.. */