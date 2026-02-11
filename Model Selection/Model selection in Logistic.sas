proc format;
    value $CarOrTruck
    'SUV','Truck'='Truck'
    other = 'Car'
    ;
run;

proc logistic data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / selection=forward ;
    /**Default SL for Entry is 0.05, can set with SLENTRY= */
run;

proc logistic data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / selection=backward ;
    /**Default SL for Stay is 0.05, can set with SLSTAY= */
run;

proc logistic data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / selection=stepwise ;
    /**Default SLs are 0.05*/
run;

proc logistic data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / selection=score ;
    /**Score does not work for categorical predictors
        with more than 2 levels*/
run;


proc logistic data=sashelp.cars;
  format type $CarOrTruck.;
  model type = MSRP -- length / selection=score best=1 ;
    /**Gives chi-square statistics, which is helpful
        for models with same number of predictors, but
        not for different complexity*/
run;/**Logisitic doesn't offer much beyond stepwise selection with SL*/
