libname stat1 '~/ECST142/data';


ods graphics on;
proc reg data=STAT1.ameshousing3;
    CONTINUOUS: model SalePrice 
                  = Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom 
                    / vif;
    /*VIF-Variance Inflation Factor ... 5 or more is considered serious
        it's the variance multiplier due to correlation in the standardized
        regression case
    */
    title 'SalePrice Model - Plots of Diagnostic Statistics';
run;
quit;

proc reg data=sashelp.cars;
  model horsepower = msrp invoice mpg: wheelbase weight / vif;
run;

proc corr data=sashelp.cars;
  var msrp invoice mpg: wheelbase weight;
run;

proc factor data=sashelp.cars nfact=2 out=factors;
  var msrp invoice mpg: wheelbase weight;
run;  

proc corr data=factors;
  var msrp invoice mpg: wheelbase weight;
  with factor:;
run;

proc corr data=factors;
  var factor:;
run;

proc factor data=sashelp.cars nfact=2 rotate=varimax out=factors;
  var msrp invoice mpg: wheelbase weight;
run;  

proc reg data=factors;
  model horsepower = factor1 factor2 / vif; 
run;