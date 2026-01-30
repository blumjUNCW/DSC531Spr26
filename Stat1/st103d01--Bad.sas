/*st103d01.sas*/  /*Part A*/
libname stat1 '~/ECST142/data';
options fmtsearch=(stat1.myfmts);
ods graphics off;
proc means data=STAT1.ameshousing3
           mean var std nway;
    class Season_Sold Heating_QC;
    var SalePrice;
    format Season_Sold Season.;
    title 'Selected Descriptive Statistics';
    ways 1 2;
run;

/*st103d01.sas*/  /*Part B*/
proc sgplot data=STAT1.ameshousing3;
    vline Season_Sold / group=Heating_QC 
                        stat=mean 
                        response=SalePrice 
                        markers;
    format Season_Sold season.;
run; 

proc sgplot data=STAT1.ameshousing3;
    vline Heating_QC  / group=Season_Sold
                        stat=mean 
                        response=SalePrice 
                        markers;
    format Season_Sold season.;
run; 

/*st103d01.sas*/  /*Part C*/
ods graphics on;
/**This is a bad idea...**/
proc glm data=STAT1.ameshousing3 order=internal;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold;
    lsmeans Season_Sold / diff adjust=tukey;
    format Season_Sold season.;
    title "Model with Heating Quality and Season as Predictors";
run;
quit;

title;

