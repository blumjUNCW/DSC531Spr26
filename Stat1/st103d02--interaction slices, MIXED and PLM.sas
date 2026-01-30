/*st103d02.sas*/  /*Part A*/
ods graphics on;
libname stat1 '~/ECST142/data';
options fmtsearch=(stat1.myfmts);
proc glm data=STAT1.ameshousing3 
         order=internal 
         plots(only)=intplot;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold Heating_QC*Season_Sold;    
                      /**Heating_QC|Season_Sold**/
    lsmeans Heating_QC*Season_Sold / diff slice=Heating_QC
                                      slice=Season_Sold;
    format Season_Sold Season.
           Heating_QC $Heating_QC.;
    store out=interact;
    title "Model with Heating Quality and Season as Interacting Predictors";
run;
quit;/**OK, but incomplete**/

proc contents data=work._all_;
run;

ods graphics on;
proc mixed data=STAT1.ameshousing3;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold Heating_QC*Season_Sold;    
                      /**Heating_QC|Season_Sold**/
    *lsmeans Heating_QC*Season_Sold / diff slice=Heating_QC
                                      slice=Season_Sold;
    slice Heating_QC*Season_Sold / diff adjust=tukey;
    format Season_Sold Season.
           Heating_QC $Heating_QC.;
run;
quit;

/*st103d02.sas*/  /*Part B*/
proc plm restore=interact plots=all;
    slice Heating_QC*Season_Sold / diff adjust=tukey;
    effectplot interaction(sliceby=Heating_QC) / clm;
run; /**I can get slices from GLM by storing the result
      and running it through PLM**/

title;

