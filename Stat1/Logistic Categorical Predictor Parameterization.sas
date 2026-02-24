proc format;
  value $type
  'Sedan','Wagon'='Car'
  'Truck','SUV'='Truck'
  ;
run;

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin;
  /*default parameterization is effects--
    parameter estimates sum to zero/last one in design matrix is -1*/
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

/**They do stuff like this...*/
proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin(param=ref);
  /*Last one in is forced zero in design matrix and 
      parameter estimate*/
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin / param=ref;
  /*Last one in is forced zero in design matrix and 
      parameter estimate*/
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;/**exponentials of these parameter estimates
    give default odds ratios*/

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin(param=ref ref='Europe');
  /*can change the reference category with ref=*/
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin(ref='Europe') / param=ref;
  /*can change the reference category with ref=*/
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;

/*we did...*/
proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin / param=glm;
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;
proc logistic data=sashelp.cars;
  where type not in ('Sports','Hybrid');
  class origin(ref='Europe') / param=glm;
  model type = origin weight enginesize;
  format type $type.;
  lsmeans origin;
run;/*things like lsmeans only work with GLM parameterization*/