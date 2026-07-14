/* mock data for external libref STAT1 (course library ~/ECST142/data) */
data AmesHousing3;
  do PID = 1 to 60;
    Gr_Liv_Area   = 800 + ranuni(11)*2200;
    Basement_Area = 400 + ranuni(12)*1600;
    Garage_Area   = 200 + ranuni(13)*600;
    Deck_Porch_Area = ranuni(14)*400;
    Lot_Area      = 5000 + ranuni(15)*10000;
    Age_Sold      = int(ranuni(16)*100);
    Bedroom_AbvGr = 1 + int(ranuni(17)*4);
    Total_Bathroom = 1 + int(ranuni(18)*3);
    SalePrice = 30000 + 60*Gr_Liv_Area + 25*Basement_Area + 40*Garage_Area
                - 300*Age_Sold + 8000*Bedroom_AbvGr + ranuni(19)*20000;
    output;
  end;
run;

%let interval=Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
         Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;

ods graphics / reset=all imagemap;
proc corr data=AmesHousing3 rank
          plots(only)=scatter(nvar=all ellipse=none);
   var &interval;
   with SalePrice;
   id PID;
   title "Correlations and Scatter Plots with SalePrice";
run;
title;

ods graphics off;
proc corr data=AmesHousing3 nosimple best=3;
   var &interval;
   title "Correlations and Scatter Plot Matrix of Predictors";
run;
title;

proc glm data=AmesHousing3;
  model SalePrice = Basement_Area;
  ods output ParameterEstimates=Params;
run;
