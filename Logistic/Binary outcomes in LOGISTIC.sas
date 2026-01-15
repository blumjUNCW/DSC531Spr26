proc format;
  value $type
  'Sedan','Wagon'='Car'
  'Truck','SUV'='Truck'
  ;
run;/**Reduce some of the types to two categories...**/

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');/**...making sure to get rid of the rest**/
  model type = weight enginesize;
    /**In the MODEL statement in LOGISTIC, the variable on the left of the =
      is presumed to be categorical.
      
      Any active format is used to determine the categories 
      It does not have to be put in a CLASS statement (categorical predictors do)
        but you can if you really want**/ 
  format type $type.;
run;
proc logistic data=sashelp.cars descending;
  where type not in ('Sports','Hybrid');/**...making sure to get rid of the rest**/
  model type = weight enginesize;
  format type $type.;
run;

proc standard data=sashelp.cars out=carsSTD mean=0 std=1;
  var weight enginesize;
run;

proc logistic data=carsSTD;
  where type not in ('Sports','Hybrid');
  model type = weight enginesize;
  format type $type.;
run;
proc logistic data=carsSTD descending;
  where type not in ('Sports','Hybrid');
  model type = weight enginesize;
  format type $type.;
run;

proc genmod data=sashelp.cars descending;
  where type not in ('Sports','Hybrid');
  format type $type.;
  model type = weight enginesize / dist=binomial;
    /**in GENMOD you get to pick the distribution
    and the link function you want**/
run;

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin;
  model type = origin weight enginesize;
  format type $type.;
  ods select ParameterEstimates;
run;/**Logisitic uses effects parameterization
      for categorical predictors...***/
proc genmod data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  format type $type.;
  class origin;
  model type = origin weight enginesize / dist=binomial link=logit;
  ods select ParameterEstimates;
run;/**Genmod does GLM style...**/

/**In general, I want GLM style...**/
proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin / param=glm;
    /**we will take this as a "required option"**/
  model type = origin weight enginesize;
  format type $type.;
  ods select ParameterEstimates;
run;


proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin;
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

ods graphics off;
proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin / param=glm;
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

proc standard data=sashelp.cars out=CarsCenter mean=0;
  where type not in ('Sports','Hybrid');
  var weight enginesize;
run;

ods graphics off;
proc logistic data=CarsCenter;
  class origin / param=glm;
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin / exp diff adjust=tukey;
run;

ods graphics off;
proc logistic data=CarsCenter;
  class origin / param=glm;
  model type = origin weight enginesize;
  format type $type.;
  output out=predictions predprobs=(I);
run;

proc freq data=predictions;
  table _from_*_into_;
run;
