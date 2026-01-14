data cars;
  set sashelp.cars;
  select(type);
    when('Sedan','Wagon') car=1;/**dummy code these as cars...**/
    when('Truck','SUV') car=0;/**...these as not cars...**/
    otherwise delete;/**..get rid of the rest**/
  end;
run;

proc standard data=cars out=carsSTD mean=0;
  var weight enginesize;
run;/**center a couple of predictors,
      mostly for interpretation pupooses,
      not absolutely necessary.**/

ods graphics off;
proc glm data=carsSTD;
  model car = weight enginesize / solution;
    /**dummy variable is the response**/
  ods select ParameterEstimates;
  output out=pred predicted=Pcar;/**We will output predicted values
          of the car dummy variable**/
run;

proc sgplot data=pred;
  scatter x=weight y=enginesize /
    markerattrs=(symbol=circlefilled) colorresponse=Pcar
    colormodel=(red yellow green);
run;/**scatterplot of the predictors, heatmapped with
    the predicted value**/

data class;
  set pred;

  length PredType $5;
  if Pcar gt 0.5 then PredType='Car';
    else PredType='Truck';
run;/**Classify the prediction as car or truck 
    based on a 50/50 or closer to 0/1 metric**/

proc format;
  value $type
  'Sedan','Wagon'='Car'
  'Truck','SUV'='Truck'
  ;
run;/**I'll use a formatted version of the
    type variable to set the original case**/ 

proc freq data=class order=formatted;
  table type*PredType;
  format type $type.;
run;/**this puts actual case on the rows,
    predicted case on the columns
    (confusion matrix)**/

proc sgplot data=class;
  scatter x=weight y=enginesize /
    markerattrs=(symbol=circlefilled) group=PredType name='Scatter';
  /**This is a scatterplot of the points, colored by classification*/
  lineparm x=0 y=%sysevalf((0.5-0.7766)/0.099159)
          slope=%sysevalf(0.000402/0.099159);
  /**Line determined from GLM equation (see math in the pdf)**/
  yaxis values=(-2 to 4 by 1);
  keylegend 'Scatter' / position=topleft location=inside title='' across=1;
run;
/**Changing the 50/50 split in the DATA step above moves the line,
  making it easier or harder to classify things as cars**/
