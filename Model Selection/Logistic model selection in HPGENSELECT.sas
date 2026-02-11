proc format;
    value $CarOrTruck
    'SUV','Truck'='Truck'
    other = 'Car'
    ;
run;


proc hpgenselect data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / dist=binomial;
      /*I do have to tell it what dist (and perhaps link) I want
          it does not try to make a choice if you give a character
            response*/
  selection method=stepwise;
  /*Selection is a statement here in which you specify a method option
    default criteria for forward, backward, and stepwise are SL*/
run;

proc hpgenselect data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / dist=binomial;
  selection method=stepwise(slentry=0.10 slstay=0.10 choose=SBC) ;
  /*forward, backward, and stepwise always run on select=SL
      but you can pick a CHOOSE= criterion (AIC,AICC,BIC,SBC)*/
run;

proc hpgenselect data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / dist=binomial;
  selection method=stepwise(slentry=0.10 slstay=0.10 choose=AIC) ;
  /*forward, backward, and stepwise always run on select=SL
      but you can pick a CHOOSE= criterion (AIC,AICC,BIC,SBC)*/
run;

proc hpgenselect data=sashelp.cars;
  format type $CarOrTruck.;
  class origin DriveTrain;
  model type = Origin -- length / dist=binomial;
  selection method=stepwise(slentry=0.10 slstay=0.10 choose=Validate) ;
  partition fraction(validate=0.25 test=.10);
  /**/
run;