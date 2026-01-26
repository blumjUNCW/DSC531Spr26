libname SASData '~/SASData';

proc format;
  value poverty
    10 - high = 'High Poverty'
    other = 'Low Poverty'
    ;
run;

proc logistic data=sasdata.cdi descending;
  format poverty poverty.;
  class region / param=glm;
  model poverty = region ba_bs over65;
  lsmeans region / diff adjust=tukey exp cl;
    /**EXP translates log-odds and differences
        into odds and odds ratios**/
run;

ods graphics off;
proc logistic data=sasdata.cdi descending;
  format poverty poverty.;
  class region / param=glm;
  model poverty = region ba_bs over65;
  lsmeans region / diff adjust=tukey exp lines;
run;

proc logistic data=sasdata.cdi descending;
  format poverty poverty.;
  class region / param=glm;
  model poverty = region ba_bs over65;
  lsmeans region / exp at means;
    /**EXP translates log-odds and differences
        into odds and odds ratios**/
run;

data cdiMod;
  set sasdata.cdi;

  popDensity = pop/land;
  crimeRate = crimes/pop*1000;

  label popDensity = 'People per sq. mi.'
        crimeRate = 'Crimes per 1000 people';
run;

proc format;
  value BArate
    20-high = 'High'
    other = 'Low'
    ;
run;

proc logistic data=cdiMod;
  class region / param=glm;
  format ba_bs barate.;
  model ba_bs = region over65 popDensity crimeRate;
  lsmeans region / diff adjust=tukey exp;
  ods select responseProfile ParameterEstimates OddsRatios
            lsmeans diffs;
run;


proc logistic data=cdiMod;
  class region / param=glm;
  format ba_bs barate.;
  model ba_bs = region|over65|popDensity|crimeRate @2;
    /**interactions among predictors are possible at
      various levels of complexity**/
run;

proc logistic data=cdiMod;
  class region / param=glm;
  format ba_bs barate.;
  model ba_bs = region|popDensity|crimeRate @2 over65|region @2;
  lsmeans region / diff adjust=tukey exp at means;
  lsmeans region / diff adjust=tukey exp at over65=10;
  lsmeans region / diff adjust=tukey exp at over65=15;
run;


/**fit a model to predict region from BA/BS rate, income per capita, and
percentage of population 18 to 34**/
ods graphics off;
proc logistic data=sasdata.cdi;
  model region = ba_bs inc_per_cap pop18_34 / link=glogit;
  units inc_per_cap = 1000;
  oddsratio inc_per_cap / cl=wald;
  output out=results predprobs=(I);
run;

proc freq data=results;
  table _from_*_into_;
run;

ods graphics off;
proc logistic data=sasdata.cdi;
  where region ne 3;
  model region = ba_bs inc_per_cap pop18_34 / link=glogit;
  units inc_per_cap = 1000;
  oddsratio inc_per_cap / cl=wald;
  output out=results predprobs=(I);
run;

proc freq data=results;
  table _from_*_into_;
run;

proc format;
  value priceCat
    low-200000 = '1. Below $200K'
    200000-300000 = '2. $200-$300K'
    300000-high = '3. Above $300K'
    ;
run;

Title 'Proportional Odds';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms;
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'No Proportional Odds';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes;
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on sq ft';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=sq_ft;
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on bedrooms';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=bedrooms;
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on interaction';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=sq_ft*bedrooms;
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on sq ft and interaction';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=(sq_ft sq_ft*bedrooms);
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on bedrooms and interaction';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=(bedrooms sq_ft*bedrooms);
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'Unequal on sq ft and bedrooms';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=(sq_ft bedrooms);
  format price priceCat.;
  ods select fitStatistics;
run;

Title 'AIC says: No Proportional Odds';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes;
  format price priceCat.;
run;

Title 'SBC says: Unequal on sq ft';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms / unequalslopes=sq_ft;
  format price priceCat.;
run;

Title 'Proportional Odds';
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms;
  format price priceCat.;
run;
/**If an interaction is present, default odds ratios are 
suppressed...effects are inconsistent, so you are expected
to analyze them.**/

Title 'Proportional Odds';
ods graphics off;
proc logistic data=sasdata.realestate;
  model price = sq_ft|bedrooms;
  format price priceCat.;
  units sq_ft = 100;
  oddsratio sq_ft / at(bedrooms=1 2 3);
  oddsratio bedrooms / at(sq_ft=1500 2000 2500);
  /**Oddsratio performs a bit like LSMEANS or SLICE,
      but applies to any type of predictor, categorical or quantitative**/
run;