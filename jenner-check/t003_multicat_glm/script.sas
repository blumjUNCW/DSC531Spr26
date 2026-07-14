data cars;
  set sashelp.cars;
  
  Asia=0;Europe=0;USA=0;
  /**three dummy variables, one for each origin (actually, I only need 2)
    set them all to zero to start...**/
  select(origin);
    when('Asia') Asia=1;
    when('Europe') Europe=1;
    when('USA') USA=1;
  end;/**Flip the correct case to 1**/
run;

ods graphics off;
ods select none;
proc glm data=cars;
  model Asia Europe USA = horsepower weight mpg_city msrp length;
    /**In GLM, multiple response variables are interpreted as 
      a request for a model for each response variable individually
      (using the same predictors)**/
  output out=predictions predicted=PAsia PEurope PUSA;
  where type ne 'Hybrid';
run;

ods select all;
proc sgplot data=predictions;
  scatter y=origin x=PASIA / jitter legendlabel='PAsia'
        markerattrs=(symbol=circle color=blue);
  scatter y=origin x=PEurope / jitter legendlabel='PEurope'
        markerattrs=(symbol=square color=red);
  scatter y=origin x=PUSA / jitter legendlabel='PUSA'
        markerattrs=(symbol=triangle color=green);
  xaxis label='Predicted';
  keylegend / across=1 position=topright location=inside;
run;
/**Scatterplots of the prediction within each category (jittering
  moves points vertically that would have otherwise landed on another point)
  Looks like we would do better classifying vehicles from Europe...**/

data class;
  set predictions;
  
  max=max(PEurope,PAsia,PUSA);
  /**we will take the predicted origin as the max
    value of each of the predictions--get the value...**/
  if PEurope = max then POrigin='Europe';
  if PAsia = max then POrigin='Asia';
  if PUSA = max then POrigin='USA';
  /**make the assignment**/
run;

proc freq data=class;
  table origin*Porigin;
run;/**Here's our classification matrix**/