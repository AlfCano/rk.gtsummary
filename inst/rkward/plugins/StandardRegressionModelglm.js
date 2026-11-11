// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(gtsummary)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var df_object = getValue("var_glm_data");
    var dep_raw = getValue("var_glm_dep").split("\n").filter(function(n){ return n != "" })[0];
    var indeps_raw = getValue("var_glm_indep").split("\n").filter(function(n){ return n != "" });
    var family = getValue("drp_glm_family");

    if(!df_object || !dep_raw || indeps_raw.length === 0) return;

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
    var formula = "`" + dep + "` ~ `" + indep_names.join("` + `") + "`";

    echo("require(gtsummary)\n\n");

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

    var exp_arg = getValue("cbox_glm_exp") == "TRUE" ? "exponentiate = TRUE" : "exponentiate = FALSE";

    // ---> INYECCIÓN: Construir pipeline de tbl_regression como variable JS <---
    var reg_pipeline = "gtsummary::tbl_regression(" + exp_arg + ")";
    if(getValue("cbox_glm_global_p") == "TRUE"){ reg_pipeline += " %>%\n      gtsummary::add_global_p()"; }
    if(getValue("cbox_glm_glance") == "TRUE"){ reg_pipeline += " %>%\n      gtsummary::add_glance_table()"; }

    var conversion_suffix = "";
    if(convert_save == "gt") conversion_suffix = " %>%\n  gtsummary::as_gt()";
    if(convert_save == "flextable") conversion_suffix = " %>%\n  gtsummary::as_flex_table()";
    if(convert_save == "huxtable") conversion_suffix = " %>%\n  gtsummary::as_hux_table()";

    var is_split = getValue("cbox_glm_split") == "1";
    var split_var_raw = getValue("var_glm_strata");

    if (is_split && split_var_raw != "") {
        var split_var = getColumnName(split_var_raw);
        echo("# 1. Fit models by group and create stratified table\n");
        echo("std_reg_table <- " + df_object + " %>%\n");
        echo("  gtsummary::tbl_strata(\n");
        echo("    strata = " + split_var + ",\n");
        echo("    .tbl_fun = ~ .x %>% glm(formula = " + formula + ", data = ., family = " + family + ") %>%\n");
        echo("      " + reg_pipeline + "\n");
        echo("  )" + conversion_suffix + "\n\n");
    } else {
        echo("# 1. Fit the standard regression model\n");
        echo("std_model <- glm(formula = " + formula + ", data = " + df_object + ", family = " + family + ")\n\n");
        echo("# 2. Create the gtsummary regression table\n");
        echo("std_reg_table <- std_model %>%\n  " + reg_pipeline + conversion_suffix + "\n\n");
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Standard Regression Model (glm) results")).print();

    echo("rk.header(\"Standard Regression Table (glm & tbl_regression)\", level=3);\n");
    echo("print(std_reg_table);\n");

    if(getValue("sav_glm_model.active") || getValue("sav_glm_table.active")) { echo("rk.print(\"<hr>\")\n"); }
    if(getValue("sav_glm_model.active") && getValue("cbox_glm_split") != "1"){
        echo("rk.print(paste0(\"<b>glm model saved as: </b><code>\", \"" + getValue("sav_glm_model") + "\", \"</code><br>\"))\n");
    }
    if(getValue("sav_glm_table.active")){
        echo("rk.print(paste0(\"<b>gtsummary table saved as: </b><code>\", \"" + getValue("sav_glm_table") + "\", \"</code>\"))\n");
    }
  
	//// save result object
	// read in saveobject variables
	var savGlmModel = getValue("sav_glm_model");
	var savGlmModelActive = getValue("sav_glm_model.active");
	var savGlmModelParent = getValue("sav_glm_model.parent");	var savGlmTable = getValue("sav_glm_table");
	var savGlmTableActive = getValue("sav_glm_table.active");
	var savGlmTableParent = getValue("sav_glm_table.parent");
	// assign object to chosen environment
	if(savGlmModelActive) {
		echo(".GlobalEnv$" + savGlmModel + " <- std_model\n");
	}
	if(savGlmTableActive) {
		echo(".GlobalEnv$" + savGlmTable + " <- std_reg_table\n");
	}

}

