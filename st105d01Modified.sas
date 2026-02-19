libname stat1 '~/ECST142/data';


/*st105d01.sas*/  /*Part A*/
ods graphics on;
proc reg data=STAT1.ameshousing3;
    CONTINUOUS: model SalePrice 
                  = Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
    title 'SalePrice Model - Plots of Diagnostic Statistics';
run;
quit;

ods graphics on;
ods trace on;
proc reg data=STAT1.ameshousing3;
    CONTINUOUS: model SalePrice 
                  = Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
    title 'SalePrice Model - Plots of Diagnostic Statistics';
    output out=diagnostics p=pred r=resid rstudent=StudentRCV
            student=StudentR h=leverage;
    /**Output can be used to add some error diagnostic stats to the data 
        as a new output data set*/
run;
quit;

data diagnostics;
    set diagnostics;
    if leverage ge %sysevalf(16/300) then do;
        obs=_n_;
        w=1-leverage;
        end;
      else do;
        obs=.;
        w=1;
      end;
run;

proc reg data=diagnostics;
    CONTINUOUS: model SalePrice 
                  = Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
    title 'SalePrice Model - Plots of Diagnostic Statistics, Weighted';
    weight w;
run;
quit;

proc sgplot data=diagnostics;
    scatter x=pred y=StudentRCV;
    refline 0 3 -3 / axis=y;
run;

proc sgplot data=diagnostics;
    scatter x=leverage y=StudentRCV / datalabel=obs;
    refline 0 3 -3 / axis=y;
    refline %sysevalf(16/300)/axis=x;
run;

proc sgplot data=diagnostics;
    scatter x=obs y=leverage / datalabel=obs;
run;


/*st105d01.sas*/  /*Part B*/
proc reg data=STAT1.ameshousing3 
         plots(only)=(QQ RSTUDENTBYPREDICTED );
          
    CONTINUOUS: model SalePrice 
                  =Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
    title 'SalePrice Model - Plots of Diagnostic Statistics';
run;
quit;

proc reg data=STAT1.ameshousing3 
         plots(only)=(QQ RSTUDENTBYPREDICTED COOKSD
                    DFFITS DFBETAS);
         /**Plot requests require generation of some data*/
  ods output RSTUDENTBYPREDICTED=Rstud 
             COOKSDPLOT=Cook
             DFFITSPLOT=Dffits 
             DFBETASPANEL=Dfbs
             QQPLOT=qq;
    /**That data can be delivered to a SAS data set via ODS OUTPUT if
      you look up the table names*/
          
    CONTINUOUS: model SalePrice 
                  =Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
                    Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
    title 'SalePrice Model - Plots of Diagnostic Statistics';
run;
quit;
