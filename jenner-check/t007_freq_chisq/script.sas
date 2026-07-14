proc format;
  value $chol
  'Desirable' = '1. Desirable'
  'Borderline' = '2. Borderline'
  'High' = '3. High'
  ;
  value $Weight
  'Underweight' = '1. Under'
  'Normal' = '2. Normal'
  'Overweight' = '3. Over'
  ;
run;

proc freq data=sashelp.heart order=formatted;
  table chol_status*weight_status / chisq measures cl;
  format chol_status $chol. weight_status $Weight.;
run;
