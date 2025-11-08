// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(gtsummary)\n");	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var svy_object = getValue("var_svy_data");
    if(!svy_object) return;

    if(getValue("cbox_svy_lonely_psu") == "1"){
      echo("options(survey.lonely.psu = \"adjust\")\n\n");
    }

    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
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

    var strata_var_full = getValue("var_svy_strata");
    var include_vars_full = getValue("var_svy_include");
    var by_var_full = getValue("var_svy_by");
    var statistic = getValue("inp_statistic");
    var digits = getValue("inp_digits");
    var type = getValue("inp_type");
    var use_rk_labels = getValue("cbox_use_rk_labels");
    var custom_label = getValue("inp_label");
    var missing = getValue("drp_missing");
    var missing_text = getValue("inp_missing_text");
    var percent = getValue("drp_percent");

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

    var options = new Array();
    var include_array = include_vars_full.split(/\s+/).filter(function(n){ return n != "" });
    if(include_array.length > 0){
        var include_names = include_array.map(function(item) { return getColumnName(item); });
        options.push("include = c(" + include_names.map(function(s) { return "\"" + s + "\""; }).join(", ") + ")");
    }

    if(use_rk_labels == "1" && include_array.length > 0) {
        var label_formulas = include_array.map(function(item) {
            var colName = getColumnName(item);
            return colName + " ~ rk.get.label(" + item + ")";
        });
        options.push("label = list(" + label_formulas.join(", ") + ")");
    } else if (custom_label) {
        options.push("label = " + custom_label);
    }

    if(by_var_full){ options.push("by = \"" + getColumnName(by_var_full) + "\""); }
    if(statistic){ options.push("statistic = " + statistic); }
    if(digits){ options.push("digits = " + digits); }
    if(type){ options.push("type = " + type); }
    if(missing){ options.push("missing = \"" + missing + "\""); }
    if(missing_text){ options.push("missing_text = \"" + missing_text + "\""); }
    if(percent){ options.push("percent = \"" + percent + "\""); }

    if(strata_var_full) {
      var strata_var = getColumnName(strata_var_full);
      var inner_call = ".x %>% gtsummary::tbl_svysummary(" + options.join(", ") + ")";
      var final_call = svy_object + " %>% gtsummary::tbl_strata(strata = \"" + strata_var + "\", .tbl_fun = ~ " + inner_call + ")";
      echo("svy_gtsummary_result <- " + final_call + ";\n");
    } else {
      options.unshift("data = " + svy_object);
      echo("svy_gtsummary_result <- gtsummary::tbl_svysummary(" + options.join(", ") + ");\n");
    }

}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Summary Table (gtsummary) results")).print();

    echo("rk.header(\"Survey Summary Table (gtsummary::tbl_svysummary)\", level=3);\n");
    echo("print(svy_gtsummary_result);\n");
    if(getValue("sav_svy_result")){
      echo("rk.print(paste(\"Object svy_gtsummary_result saved.\"))\n");
    }

	//// save result object
	// read in saveobject variables
	var savSvyResult = getValue("sav_svy_result");
	var savSvyResultActive = getValue("sav_svy_result.active");
	var savSvyResultParent = getValue("sav_svy_result.parent");
	// assign object to chosen environment
	if(savSvyResultActive) {
		echo(".GlobalEnv$" + savSvyResult + " <- svy_gtsummary_result\n");
	}

}

