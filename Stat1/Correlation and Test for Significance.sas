libname stat1 '~/ECST142/data';
/*st102d04.sas*/  /*Part A*/
%let interval=Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
         Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;

ods graphics / reset=all imagemap;
proc corr data=STAT1.AmesHousing3 rank
          plots(only)=scatter(nvar=all ellipse=none);
   var &interval;
   with SalePrice;
   id PID;
   title "Correlations and Scatter Plots with SalePrice";
run;

title;

/*st102d04.sas*/  /*Part B*/
ods graphics off;
proc corr data=STAT1.AmesHousing3 
          nosimple 
          best=3;
   var &interval;
   title "Correlations and Scatter Plot Matrix of Predictors";
run;

title;

proc corr data=stat1.AmesHousing3;
  var Basement_Area;
  with SalePrice;
  ods output pearsonCorr=correlations;
run;

proc glm data=stat1.ameshousing3;
  model SalePrice = Basement_Area;
  ods output ParameterEstimates=Params;
run;/**test for parameter significance in bivariate regression
      and for correlation is exactly the same**/
