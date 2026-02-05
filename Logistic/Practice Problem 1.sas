libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);

proc sql;
  create table GradRates as 
    select Grads.UnitId, Grads.Total/Cohort.Total as GradRate
    from ipeds.Graduation(where=(group contains 'Completers')) as Grads
            inner join
         ipeds.Graduation(where=(group contains 'Incoming')) as Cohort
      on Grads.UnitID eq Cohort.UnitID
  ;
  create table use as
    select GradRate, cbsatype, tuition2/1000 as tuition
    from GradRates, ipeds.characteristics(where=(cbsatype gt 0)), ipeds.tuitionandcosts
    where GradRates.UnitID eq Characteristics.UnitID eq tuitionandcosts.UnitID
  ;
quit;

proc means data=use median;
  var GradRate;
run;
  
proc format;
  value mid
  low-0.566 = 'Below Median'
  other = 'Above Median'
  ;
run;

proc logistic data=use;
  format GradRate mid. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition;
run;
/**Irrespective of metro/micropolitan, a $1000 increase in tuition corresponds
    to a 6.8% increase in odds of graduation rate being above the median

  At at fixed tuition, metropolitan instituions have 87% greater odds of having an
    above median graduation rate versus micropolitan institutions**/

proc logistic data=use;
  format GradRate mid. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition;
run;/**don't need/want the cross product**/

proc means data=use q1 median q3;
  var GradRate;
run;
  
proc format;
  value quarters
  low-.421 = '4. Bottom Q'
  .421-.566 = '3. 3rd Q'
  .566-.699 = '2. 2nd Q'
  .699-high = '1. Top Q'
  ;
run;

Title 'All Proportional Odds';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition;
  ods select FitStatistics;
run;/**Proportional odds assumption fails**/

Title 'No Proportional Odds';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / unequalslopes;
  ods select FitStatistics;
run;

Title 'Proportional Odds for Tuition';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / unequalslopes=cbsatype;
  ods select FitStatistics;
run;

Title 'Proportional Odds for Micro/Metro';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / unequalslopes=tuition;
  ods select FitStatistics;
run;

/**AIC says no proportional odds, SBC says fully proportional odds**/
ods trace on;
Title 'All Proportional Odds';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / link=alogit;
  ods select ParameterEstimates OddsRatios;
run;

Title 'No Proportional Odds';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / unequalslopes link=alogit;
  ods select ParameterEstimates OddsRatios;
run;/**assessing the actual odds/likelihood ratios, I'd choose...**/

Title 'Proportional Odds on Tuition';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype tuition / unequalslopes=cbsatype link=alogit;
  ods select ParameterEstimates OddsRatios;
run;

Title 'None unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition;
  ods select fitStatistics;
run;

Title 'All unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes;
  ods select fitStatistics;
run;

Title 'Type unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=cbsatype;
  ods select fitStatistics;
run;

Title 'Tuition unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=tuition;
  ods select fitStatistics;
run;

Title 'Interaction unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=cbsatype*tuition;
  ods select fitStatistics;
run;

Title 'Type and Tuition unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=(cbsatype tuition);
  ods select fitStatistics;
run;

Title 'Type and Interaction unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=(cbsatype cbsatype*tuition);
  ods select fitStatistics;
run;

Title 'Tuition and Interaction unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes=(tuition cbsatype*tuition);
  ods select fitStatistics;
run;

/**Again, we get a different picture from AIC and SBC...**/
Title 'None unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / link=logit;
  oddsratio cbsatype / at(tuition=15 20 25);
  *ods select ParameterEstimates OddsRatiosWald;
  estimate 'Slope diff' cbsatype*tuition 1 -1 / cl;
    /**estimate works in cumulative with proportional odds only**/
run;

Title 'All unequal';
proc logistic data=use;
  format GradRate quarters. cbsatype cbsatype.;
  class cbsatype / param=glm;
  model GradRate = cbsatype|tuition / unequalslopes link=logit;
  oddsratio cbsatype / at(tuition=15 20 25);
  *ods select ParameterEstimates OddsRatiosWald;
  estimate 'Slope diff' cbsatype*tuition 1 0 0 -1 0 0 / cl;
run;
