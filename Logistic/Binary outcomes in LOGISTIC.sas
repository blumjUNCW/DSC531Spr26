proc format;
  value $type
  'Sedan','Wagon'='Car'
  'Truck','SUV'='Truck'
  ;
run;/**Reduce some of the types to two categories...**/

proc logistic data=sashelp.cars descending;
  where type not in ('Sports','Hybrid');/**...making sure to get rid of the rest**/
  model type = weight enginesize;
    /**In the MODEL statement in LOGISTIC, the variable on the left of the =
      is presumed to be categorical.
      
      Any active format is used to determine the categories 
      It does not have to be put in a CLASS statement (categorical predictors do)
        but you can if you really want**/ 
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