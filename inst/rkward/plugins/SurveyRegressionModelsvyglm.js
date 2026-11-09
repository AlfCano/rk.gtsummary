// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(gtsummary)\n");	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var svy_object = getValue("var_reg_svy_data");
    // Obtenemos los nombres puros de las variables
    var dep_raw = getValue("var_reg_dep").split("\n").filter(function(n){ return n != "" })[0];
    var indeps_raw = getValue("var_reg_indep").split("\n").filter(function(n){ return n != "" });
    var family = getValue("drp_reg_family");

    if(!svy_object || !dep_raw || indeps_raw.length === 0) return;

    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\[\[\"(.*?)\"\]\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    var dep = getColumnName(dep_raw);
    var indep_names = indeps_raw.map(function(item) { return getColumnName(item); });

    // Construimos la fórmula Y ~ X1 + X2
    var formula = "`" + dep + "` ~ `" + indep_names.join("` + `") + "`";

    echo("require(survey)\nrequire(gtsummary)\n\n");
    echo("# 1. Fit the survey-weighted regression model\n");
    echo("svy_model <- survey::svyglm(formula = " + formula + ", design = " + svy_object + ", family = " + family + ")\n\n");

    // Lógica de Temas compartida
    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
    var convert_save = getValue("drp_save_conversion");

    // NUEVO: Leemos los valores del idioma y decimales
    var lang = getValue("drp_lang");
    var dec_mark = getValue("inp_dec_mark");
    var big_mark = getValue("inp_big_mark");

    if(journal && journal != "none") { echo("gtsummary::theme_gtsummary_journal(journal = \"" + journal + "\");\n"); }
    if(compact == "1") { echo("gtsummary::theme_gtsummary_compact();\n"); }
    if(printer && printer != "none") { echo("gtsummary::theme_gtsummary_printer(print_engine = \"" + printer + "\");\n"); }

    // NUEVO: Aplicamos el tema de idioma a gtsummary
    var lang_opts = new Array();
    if(lang) { lang_opts.push("language = \"" + lang + "\""); }
    if(dec_mark) { lang_opts.push("decimal.mark = \"" + dec_mark + "\""); }
    if(big_mark) { lang_opts.push("big.mark = \"" + big_mark + "\""); }
    if(lang_opts.length > 0) { echo("gtsummary::theme_gtsummary_language(" + lang_opts.join(", ") + ");\n"); }

    echo("# 2. Create the gtsummary regression table\n");
    var exp_arg = getValue("cbox_reg_exp") == "TRUE" ? "exponentiate = TRUE" : "exponentiate = FALSE";
    echo("svy_reg_table <- gtsummary::tbl_regression(svy_model, " + exp_arg + ")");

    if(getValue("cbox_reg_global_p") == "TRUE"){
        echo(" %>%\n  gtsummary::add_global_p()");
    }

    // MAGIA DE ESTADÍSTICAS DEL MODELO: Inyectamos el cálculo manual del R2 para svyglm
    if(getValue("cbox_reg_glance") == "TRUE"){
        echo(" %>%\n  gtsummary::add_glance_table(\n");
        echo("    glance_fun = function(x) {\n");
        echo("      gl <- broom::glance(x)\n");
        echo("      if(x$family$family == \"gaussian\") {\n");
        // R2 tradicional para regresión lineal de encuestas
        echo("        gl$r.squared <- 1 - (x$deviance / x$null.deviance)\n");
        echo("      } else if (x$family$family %in% c(\"binomial\", \"quasibinomial\")) {\n");
        // Pseudo-R2 de Nagelkerke para regresión logística
        echo("        try(gl$pseudo.r.squared <- survey::psrsq(x), silent = TRUE)\n");
        echo("      }\n");
        echo("      gl\n");
        echo("    }\n");
        echo("  )");
    }

    var conversion_suffix = "";
    if(convert_save == "gt") conversion_suffix = " %>%\n  gtsummary::as_gt()";
    if(convert_save == "flextable") conversion_suffix = " %>%\n  gtsummary::as_flex_table()";
    if(convert_save == "huxtable") conversion_suffix = " %>%\n  gtsummary::as_hux_table()";

    echo(conversion_suffix + "\n\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Regression Model (svyglm) results")).print();

    echo("rk.header(\"Survey Regression Table (svyglm & tbl_regression)\", level=3);\n");
    echo("print(svy_reg_table);\n");

    if(getValue("sav_reg_model.active") || getValue("sav_reg_table.active")) {
       echo("rk.print(\"<hr>\")\n");
    }
    if(getValue("sav_reg_model.active")){
      echo("rk.print(paste0(\"<b>svyglm model saved as: </b><code>\", \"" + getValue("sav_reg_model") + "\", \"</code><br>\"))\n");
    }
    if(getValue("sav_reg_table.active")){
      echo("rk.print(paste0(\"<b>gtsummary table saved as: </b><code>\", \"" + getValue("sav_reg_table") + "\", \"</code>\"))\n");
    }
  
	//// save result object
	// read in saveobject variables
	var savRegModel = getValue("sav_reg_model");
	var savRegModelActive = getValue("sav_reg_model.active");
	var savRegModelParent = getValue("sav_reg_model.parent");	var savRegTable = getValue("sav_reg_table");
	var savRegTableActive = getValue("sav_reg_table.active");
	var savRegTableParent = getValue("sav_reg_table.parent");
	// assign object to chosen environment
	if(savRegModelActive) {
		echo(".GlobalEnv$" + savRegModel + " <- svy_model\n");
	}
	if(savRegTableActive) {
		echo(".GlobalEnv$" + savRegTable + " <- svy_reg_table\n");
	}

}

