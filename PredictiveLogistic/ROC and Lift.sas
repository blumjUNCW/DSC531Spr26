proc freq data=sashelp.heart;
  table status;
run;

proc logistic data=sashelp.heart descending;
  class weight_status;
  *model status = weight_status systolic;
  *model status = weight_status systolic diastolic ageAtStart;
  model status = mrw systolic diastolic ageAtStart;
  output out=results predprobs=(I);
run;

proc sort data=results;
    by descending _from_ descending _into_;
run;

proc freq data=results order=data;
  table _from_*_into_;
run;

data thresholds;/**classify with different C levels*/
  set results;
  where IP_Dead ne .;
  do c = 0 to 1 by .1;
    if IP_Dead gt c then PDead = 1; else PDead = 0;
    output;
  end;
run;

ods select none;
proc freq data=thresholds;
  table c*status*PDead / nofreq nocol nopercent;
  /*Confusion matrix for each C*/
  ods output crossTabFreqs=summaries;
run;

data roc;
  set summaries;
  by c;
  retain TrueP FalseP;
  if status='Dead' and PDead eq 1 then TrueP=RowPercent;
    else if status='Alive' and PDead eq 1 then FalseP=RowPercent;
  if last.c then output;
  keep c TrueP FalseP;
run;

ods select all;
ods graphics / height=4in width=4in;/*square graph box*/
proc sgplot data=roc noautolegend;
  pbspline x=FalseP y=trueP / datalabel=c;
  lineparm x=0 y=0 slope=1 / lineattrs=(color=red);/*ref line*/
  xaxis offsetmax=0 offsetmin=0 grid gridattrs=(color=grayAA)
          values=(0 to 100 by 10);
  yaxis offsetmax=0 offsetmin=0 grid gridattrs=(color=grayAA)
          values=(0 to 100 by 10);
run;

/**Gain and lift*/
proc sort data=results out=targets;
  by descending IP_Dead;
  where IP_Dead ne .;
run;/*descending order of predicted prob--most likely responders first*/

proc sql;
  select sum(status eq 'Dead'), count(status)
  into :responses, :rows
  from targets
  ;
quit;


data gains;
    set targets;
    if status eq 'Dead' then pos+1;/*keep a count of positives*/
    gain = pos/&responses;/*gain is % of acutal positives at any point*/
    percentile = _n_/&rows;/*current percentile in the data*/
    random = percentile;
    lift = gain/random;/*ratio of model finding of positives to random finding*/
run;

ods select all;
ods graphics / height=4in width=4in;/*square graph box*/
proc sgplot data=gains noautolegend;
  pbspline x=percentile y=gain / nomarkers;
  lineparm x=0 y=0 slope=1 / lineattrs=(color=red);/*ref line*/
  xaxis offsetmax=0 offsetmin=0 grid gridattrs=(color=grayAA)
          values=(0 to 1 by .1);
  yaxis offsetmax=0 offsetmin=0 grid gridattrs=(color=grayAA)
          values=(0 to 1 by .1);
run;

ods graphics / height=4in width=4in;/*square graph box*/
proc sgplot data=gains noautolegend;
  pbspline x=percentile y=lift / nomarkers;
  refline 1 / axis=y lineattrs=(color=red);/*ref line*/
  xaxis offsetmax=0 offsetmin=0 grid gridattrs=(color=grayAA)
          values=(0 to 1 by .1);
  yaxis offsetmax=0 offsetmin=0.05 grid gridattrs=(color=grayAA);
run;