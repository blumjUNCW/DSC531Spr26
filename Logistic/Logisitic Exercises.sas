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
proc logistic data=sasdata.cdi;
  model region = ba_bs inc_per_cap pop18_34 / link=glogit;
run;
