/**Do a manual 5-fold on Heart Data*/
proc sql noprint;
  create table folding as
  select *, ranuni(2026) as rand /**ranuni(seed) is random uniform on (0,1)*/
  from sashelp.heart
  order by rand /**random sort of the rows*/
  ;
  select count(rand)
  into :rows /*into :Name puts value into a macro variable with chosen Name*/
  from folding
  ;
  %put &rows;
quit;

data folding;
  set folding;

  foldsize=&rows/5;/**5 is the k-value, I'll leave as a decimal...*/
  fold=min(floor(_n_/foldsize)+1,5);
  /**_n_ row counter
    create a fold count
    make sure it doesn't exceed 5*/
run;

proc freq data=folding;
  table fold weight_status*bp_status fold*weight_status*bp_status;
run;

proc freq data=sashelp.heart;
  table weight_status*bp_status / out=freqs(where=(percent ne .));
run;

proc sql noprint;
  create table StratFolding as
  select heart.*, count, ranuni(2026) as rand
  from sashelp.heart inner join freqs
        on freqs.weight_status eq heart.weight_status
            and
           freqs.bp_status eq heart.bp_status
  order by weight_status, bp_status, rand
  ;
run;

data StratFolding;
  set StratFolding;
  retain FoldSize;
  by weight_status bp_status;

  if first.bp_status then do;
    c=0;
    foldsize=count/5;
  end;
  c+1;
  fold=min(floor(c/foldsize)+1,5);
run;


proc freq data=StratFolding;
  table weight_status*bp_status fold*weight_status*bp_status;
run;

proc glmselect data=stratfolding;
  class weight_status bp_status;
  model cholesterol = weight_status bp_status diastolic systolic smoking 
    / selection=stepwise(select=cv) cvmethod=index(fold);
run;