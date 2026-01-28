/*st102d03.sas*/
libname STAT1 "~/ECST142/data";
options fmtsearch=(STAT1.myfmts);

*ods select lsmeans diff diffplot controlplot;
title "Post-Hoc Analysis of ANOVA - Heating Quality as Predictor";
proc glm data=STAT1.ameshousing3 
         plots(only)=(diffplot(center) controlplot);
    class Heating_QC;
    model SalePrice = Heating_QC;
    lsmeans Heating_QC / pdiff=all 
                         adjust=tukey cl;
    lsmeans Heating_QC / pdiff=control('Average/Typical') 
                         adjust=dunnett cl;
    format Heating_QC $Heating_QC.;
run;

proc freq data=stat1.ameshousing3;
  table heating_QC;
    format Heating_QC $Heating_QC.;
run;
title;



