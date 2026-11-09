// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(gtsummary)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var model = getValue("var_gen_model");
    if(!model) return;

    echo("require(gtsummary)\n\n");

    // Reutilizamos la lógica de temas, idiomas y formatos
    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
    var convert_save = getValue("drp_save_conversion");

    var lang = getValue("drp_lang");
    var dec_mark = getValue("inp_dec_mark");
    var big_mark = getValue("inp_big_mark");

    if(journal && journal != "none") { echo("gtsummary::theme_gtsummary_journal(journal = \"" + journal + "\");\n"); }
    if(compact == "1") { echo("gtsummary::theme_gtsummary_compact();\n"); }
    if(printer && printer != "none") { echo("gtsummary::theme_gtsummary_printer(print_engine = \"" + printer + "\");\n"); }

    var lang_opts = new Array();
    if(lang) { lang_opts.push("language = \"" + lang + "\""); }
    if(dec_mark) { lang_opts.push("decimal.mark = \"" + dec_mark + "\""); }
    if(big_mark) { lang_opts.push("big.mark = \"" + big_mark + "\""); }
    if(lang_opts.length > 0) { echo("gtsummary::theme_gtsummary_language(" + lang_opts.join(", ") + ");\n"); }

    // Generar la tabla leyendo el modelo directamente
    echo("# Create the gtsummary table directly from the existing model\n");
    var exp_arg = getValue("cbox_gen_exp") == "TRUE" ? "exponentiate = TRUE" : "exponentiate = FALSE";

    echo("model_table <- gtsummary::tbl_regression(" + model + ", " + exp_arg + ")");

    if(getValue("cbox_gen_global_p") == "TRUE"){ echo(" %>%\n  gtsummary::add_global_p()"); }
     if(getValue("cbox_gen_glance") == "TRUE"){
        echo(" %>%\n  gtsummary::add_glance_table(\n");
        echo("    glance_fun = function(x) {\n");
        echo("      gl <- tryCatch(broom::glance(x), error = function(e) data.frame())\n");
        echo("      if(inherits(x, \"svyglm\")) {\n");
        echo("        if(x$family$family == \"gaussian\") {\n");
        echo("          gl$r.squared <- 1 - (x$deviance / x$null.deviance)\n");
        echo("        } else if (x$family$family %in% c(\"binomial\", \"quasibinomial\")) {\n");
        echo("          try(gl$pseudo.r.squared <- survey::psrsq(x), silent = TRUE)\n");
        echo("        }\n");
        echo("      }\n");
        echo("      gl\n");
        echo("    }\n");
        echo("  )");
    }

    // Aplicar conversiones si el usuario lo solicita
    var conversion_suffix = "";
    if(convert_save == "gt") conversion_suffix = " %>%\n  gtsummary::as_gt()";
    if(convert_save == "flextable") conversion_suffix = " %>%\n  gtsummary::as_flex_table()";
    if(convert_save == "huxtable") conversion_suffix = " %>%\n  gtsummary::as_hux_table()";

    echo(conversion_suffix + "\n\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Table for Existing Models (tbl_regression) results")).print();

    echo("rk.header(\"Summary Table for Existing Model (tbl_regression)\", level=3);\n");
    echo("print(model_table);\n");

    if(getValue("sav_gen_table.active")){
       echo("rk.print(\"<hr>\")\n");
       echo("rk.print(paste0(\"<b>gtsummary table saved as: </b><code>\", \"" + getValue("sav_gen_table") + "\", \"</code>\"))\n");
    }
  
	//// save result object
	// read in saveobject variables
	var savGenTable = getValue("sav_gen_table");
	var savGenTableActive = getValue("sav_gen_table.active");
	var savGenTableParent = getValue("sav_gen_table.parent");
	// assign object to chosen environment
	if(savGenTableActive) {
		echo(".GlobalEnv$" + savGenTable + " <- model_table\n");
	}

}

