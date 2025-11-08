
local({
  # Require "rkwarddev"
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  # --- GLOBAL SETTINGS ---
  plugin_name <- "rk.gtsummary"
  plugin_version <- "0.1.1"

  # =========================================================================================
  # PACKAGE DEFINITION (GLOBAL METADATA)
  # =========================================================================================
  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin to generate summary tables using the 'gtsummary' package, supporting both standard data.frames (tbl_summary) and survey design objects (tbl_svysummary).",
      version = plugin_version,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/rkward-community",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # COMMON UI ELEMENTS (WITH EXPLICIT IDs)
  # =========================================================================================
  statistic_input <- rk.XML.input(id.name = "inp_statistic", label = "Statistic formula", initial = "list(all_continuous() ~ '{median} ({p25}, {p75})', all_categorical() ~ '{n} ({p}%)')")
  digits_input <- rk.XML.input(id.name = "inp_digits", label = "Digits formula")
  type_input <- rk.XML.input(id.name = "inp_type", label = "Type formula")
  percent_dropdown <- rk.XML.dropdown(id.name = "drp_percent", label = "Percentage basis (percent)", options = list(
    "Column" = list(val = "column", chk = TRUE), "Row" = list(val = "row"), "Cell" = list(val = "cell")
  ))

  use_rk_labels_cbox <- rk.XML.cbox(id.name = "cbox_use_rk_labels", label = "Use RKWard variable labels (rk.get.label)", value="1", chk=TRUE)
  label_input <- rk.XML.input(id.name = "inp_label", label = "Custom label formula")

  missing_dropdown <- rk.XML.dropdown(id.name = "drp_missing", label = "Show missing values (missing)", options = list(
    "If any present" = list(val = "ifany", chk = TRUE), "Never" = list(val = "no"), "Always" = list(val = "always")
  ))
  missing_text_input <- rk.XML.input(id.name = "inp_missing_text", label = "Missing value text (missing_text)", initial = "Unknown")

  journal_theme_dropdown <- rk.XML.dropdown(id.name="drp_journal", label="Journal Theme", options=list(
      "None" = list(val="none", chk=TRUE), "JAMA" = list(val="jama"), "Lancet" = list(val="lancet"), "NEJM" = list(val="nejm"), "QJ Econ" = list(val="qjecon")
  ))
  compact_theme_cbox <- rk.XML.cbox(id.name="cbox_compact", label="Use compact theme", value="1")
  printer_engine_dropdown <- rk.XML.dropdown(id.name="drp_printer", label="Printer Friendly Engine", options=list(
      "None" = list(val="none", chk=TRUE), "gt" = list(val="gt"), "kable" = list(val="kable"), "flextable" = list(val="flextable"), "huxtable" = list(val="huxtable")
  ))
  language_dropdown <- rk.XML.dropdown(id.name="drp_lang", label="Language", options=list(
      "System Default (en)" = list(val="en", chk=TRUE), "German (de)"=list(val="de"), "Spanish (es)"=list(val="es"), "French (fr)"=list(val="fr"),
      "Portuguese (pt)"=list(val="pt"), "Chinese (zh-cn)"=list(val="zh-cn")
  ))
  decimal_mark_input <- rk.XML.input(id.name="inp_dec_mark", label="Decimal mark")
  big_mark_input <- rk.XML.input(id.name="inp_big_mark", label="Big number mark")

  themes_tab_content <- rk.XML.col(
      rk.XML.frame(journal_theme_dropdown, compact_theme_cbox, label="Appearance"),
      rk.XML.frame(printer_engine_dropdown, label="Output Engine"),
      rk.XML.frame(language_dropdown, decimal_mark_input, big_mark_input, label="Language & Localization")
  )

  # =========================================================================================
  # COMPONENT 1 DEFINITION: tbl_summary
  # =========================================================================================
  tbl_summary_df_selector <- rk.XML.varselector(id.name = "slc_tbl_summary_source", label = "Data frames")
  tbl_summary_data_slot <- rk.XML.varslot(id.name = "var_tbl_summary_data", label = "Data frame to summarize", source = "slc_tbl_summary_source", required = TRUE, classes = "data.frame")
  tbl_summary_include_slot <- rk.XML.varslot(id.name = "var_tbl_summary_include", label = "Variables to include", source = "slc_tbl_summary_source", multi = TRUE)
  tbl_summary_strata_slot <- rk.XML.varslot(id.name = "var_tbl_summary_strata", label = "Outer stratification (strata)", source = "slc_tbl_summary_source")
  tbl_summary_by_slot <- rk.XML.varslot(id.name = "var_tbl_summary_by", label = "Inner stratification (by)", source = "slc_tbl_summary_source")
  tbl_summary_save_object <- rk.XML.saveobj(id.name = "sav_tbl_summary_result", label = "Save result to new object", chk = TRUE, initial = "gtsummary_result")

  tbl_summary_tabbook <- rk.XML.tabbook(tabs = list(
      "Data" = rk.XML.col(tbl_summary_data_slot, tbl_summary_include_slot, tbl_summary_strata_slot, tbl_summary_by_slot),
      "Statistics" = rk.XML.col(statistic_input, digits_input, percent_dropdown, type_input),
      "Labels & Missing" = rk.XML.col(rk.XML.frame(use_rk_labels_cbox, label_input, label="Variable Labels"), rk.XML.frame(missing_dropdown, missing_text_input, label="Missing Values")),
      "Themes & Formatting" = themes_tab_content
  ))

  tbl_summary_dialog <- rk.XML.dialog(
    label = "Summary Table (tbl_summary)",
    child = rk.XML.row(
      rk.XML.col(tbl_summary_df_selector),
      rk.XML.col(tbl_summary_tabbook, tbl_summary_save_object)
    )
  )

  tbl_summary_help <- rk.rkh.doc(
    summary = rk.rkh.summary("Creates a descriptive summary table for a data frame using gtsummary::tbl_summary()."),
    usage = rk.rkh.usage("Select a data frame and the variables to include."),
    sections = list(rk.rkh.section(title = "Key Arguments", text = "<p>Use the tabs to customize statistics, formatting, themes, and handling of missing data. Use 'Outer stratification' to create grouped tables with <code>tbl_strata()</code>.</p>")),
    title = rk.rkh.title("Table of Summary Statistics")
  )

  js_tbl_summary_logic <- '
    var data_frame = getValue("var_tbl_summary_data");
    if(!data_frame) return;

    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
    var lang = getValue("drp_lang");
    var dec_mark = getValue("inp_dec_mark");
    var big_mark = getValue("inp_big_mark");

    if(journal && journal != "none") { echo("gtsummary::theme_gtsummary_journal(journal = \\"" + journal + "\\");\\n"); }
    if(compact == "1") { echo("gtsummary::theme_gtsummary_compact();\\n"); }
    if(printer && printer != "none") { echo("gtsummary::theme_gtsummary_printer(print_engine = \\"" + printer + "\\");\\n"); }

    var lang_opts = new Array();
    if(lang) { lang_opts.push("language = \\"" + lang + "\\""); }
    if(dec_mark) { lang_opts.push("decimal.mark = \\"" + dec_mark + "\\""); }
    if(big_mark) { lang_opts.push("big.mark = \\"" + big_mark + "\\""); }
    if(lang_opts.length > 0) { echo("gtsummary::theme_gtsummary_language(" + lang_opts.join(", ") + ");\\n"); }

    var strata_var_full = getValue("var_tbl_summary_strata");
    var include_vars_full = getValue("var_tbl_summary_include");
    var by_var_full = getValue("var_tbl_summary_by");
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
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    var options = new Array();
    var include_array = include_vars_full.split(/\\s+/).filter(function(n){ return n != "" });
    if(include_array.length > 0){
        var include_names = include_array.map(function(item) { return getColumnName(item); });
        options.push("include = c(" + include_names.map(function(s) { return "\\"" + s + "\\""; }).join(", ") + ")");
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

    if(by_var_full){ options.push("by = \\"" + getColumnName(by_var_full) + "\\""); }
    if(statistic){ options.push("statistic = " + statistic); }
    if(digits){ options.push("digits = " + digits); }
    if(type){ options.push("type = " + type); }
    if(missing){ options.push("missing = \\"" + missing + "\\""); }
    if(missing_text){ options.push("missing_text = \\"" + missing_text + "\\""); }
    if(percent){ options.push("percent = \\"" + percent + "\\""); }

    if(strata_var_full) {
      var strata_var = getColumnName(strata_var_full);
      var inner_call = ".x %>% gtsummary::tbl_summary(" + options.join(", ") + ")";
      var final_call = data_frame + " %>% gtsummary::tbl_strata(strata = \\"" + strata_var + "\\", .tbl_fun = ~ " + inner_call + ")";
      echo("gtsummary_result <- " + final_call + ";\\n");
    } else {
      options.unshift("data = " + data_frame);
      echo("gtsummary_result <- gtsummary::tbl_summary(" + options.join(", ") + ");\\n");
    }
'
  js_tbl_summary_printout <- '
    echo("rk.header(\\"Summary Table (gtsummary::tbl_summary)\\", level=3);\\n");
    echo("print(gtsummary_result);\\n");
    if(getValue("sav_tbl_summary_result")){
      echo("rk.print(paste(\\"Object gtsummary_result saved.\\"))\\n");
    }
'
  # =========================================================================================
  # COMPONENT 2 DEFINITION: tbl_svysummary
  # =========================================================================================
  svy_selector <- rk.XML.varselector(id.name = "slc_svy_source", label = "Survey design objects")
  attr(svy_selector, "classes") <- "survey.design"
  svy_data_slot <- rk.XML.varslot(id.name = "var_svy_data", label = "Survey object to summarize", source = "slc_svy_source", required = TRUE)
  svy_include_slot <- rk.XML.varslot(id.name = "var_svy_include", label = "Variables to include", source = "slc_svy_source", multi = TRUE)
  attr(svy_include_slot, "source_property") <- "variables"
  svy_strata_slot <- rk.XML.varslot(id.name = "var_svy_strata", label = "Outer stratification (strata)", source = "slc_svy_source")
  attr(svy_strata_slot, "source_property") <- "variables"
  svy_by_slot <- rk.XML.varslot(id.name = "var_svy_by", label = "Inner stratification (by)", source = "slc_svy_source")
  attr(svy_by_slot, "source_property") <- "variables"
  svy_save_object <- rk.XML.saveobj(id.name = "sav_svy_result", label = "Save result to new object", chk = TRUE, initial = "svy_gtsummary_result")

  # MODIFIED: Added lonely PSU checkbox to the data tab
  svy_tabbook <- rk.XML.tabbook(tabs = list(
      "Data" = rk.XML.col(
        svy_data_slot,
        svy_include_slot,
        svy_strata_slot,
        svy_by_slot,
        rk.XML.cbox(id.name = "cbox_svy_lonely_psu", label = "Adjust for lonely PSUs (survey.lonely.psu = 'adjust')", value = "1")
      ),
      "Statistics" = rk.XML.col(statistic_input, digits_input, percent_dropdown, type_input),
      "Labels & Missing" = rk.XML.col(rk.XML.frame(use_rk_labels_cbox, label_input, label="Variable Labels"), rk.XML.frame(missing_dropdown, missing_text_input, label="Missing Values")),
      "Themes & Formatting" = themes_tab_content
  ))

  svy_dialog <- rk.XML.dialog(
    label = "Survey Summary Table (tbl_svysummary)",
    child = rk.XML.row(
      rk.XML.col(svy_selector),
      rk.XML.col(svy_tabbook, svy_save_object)
    )
  )

  svy_help <- rk.rkh.doc(
    summary = rk.rkh.summary("Creates a descriptive summary table for a survey design object using gtsummary::tbl_svysummary()."),
    usage = rk.rkh.usage("Select a survey.design object and the variables to include."),
    sections = list(rk.rkh.section(title = "Key Difference", text = "This dialog requires an object of class <code>survey.design</code>.")),
    title = rk.rkh.title("Table of Survey Summary Statistics")
  )

  # MODIFIED: Added logic to handle lonely PSU option
  js_svy_logic <- '
    var svy_object = getValue("var_svy_data");
    if(!svy_object) return;

    if(getValue("cbox_svy_lonely_psu") == "1"){
      echo("options(survey.lonely.psu = \\"adjust\\")\\n\\n");
    }

    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
    var lang = getValue("drp_lang");
    var dec_mark = getValue("inp_dec_mark");
    var big_mark = getValue("inp_big_mark");

    if(journal && journal != "none") { echo("gtsummary::theme_gtsummary_journal(journal = \\"" + journal + "\\");\\n"); }
    if(compact == "1") { echo("gtsummary::theme_gtsummary_compact();\\n"); }
    if(printer && printer != "none") { echo("gtsummary::theme_gtsummary_printer(print_engine = \\"" + printer + "\\");\\n"); }

    var lang_opts = new Array();
    if(lang) { lang_opts.push("language = \\"" + lang + "\\""); }
    if(dec_mark) { lang_opts.push("decimal.mark = \\"" + dec_mark + "\\""); }
    if(big_mark) { lang_opts.push("big.mark = \\"" + big_mark + "\\""); }
    if(lang_opts.length > 0) { echo("gtsummary::theme_gtsummary_language(" + lang_opts.join(", ") + ");\\n"); }

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
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    var options = new Array();
    var include_array = include_vars_full.split(/\\s+/).filter(function(n){ return n != "" });
    if(include_array.length > 0){
        var include_names = include_array.map(function(item) { return getColumnName(item); });
        options.push("include = c(" + include_names.map(function(s) { return "\\"" + s + "\\""; }).join(", ") + ")");
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

    if(by_var_full){ options.push("by = \\"" + getColumnName(by_var_full) + "\\""); }
    if(statistic){ options.push("statistic = " + statistic); }
    if(digits){ options.push("digits = " + digits); }
    if(type){ options.push("type = " + type); }
    if(missing){ options.push("missing = \\"" + missing + "\\""); }
    if(missing_text){ options.push("missing_text = \\"" + missing_text + "\\""); }
    if(percent){ options.push("percent = \\"" + percent + "\\""); }

    if(strata_var_full) {
      var strata_var = getColumnName(strata_var_full);
      var inner_call = ".x %>% gtsummary::tbl_svysummary(" + options.join(", ") + ")";
      var final_call = svy_object + " %>% gtsummary::tbl_strata(strata = \\"" + strata_var + "\\", .tbl_fun = ~ " + inner_call + ")";
      echo("svy_gtsummary_result <- " + final_call + ";\\n");
    } else {
      options.unshift("data = " + svy_object);
      echo("svy_gtsummary_result <- gtsummary::tbl_svysummary(" + options.join(", ") + ");\\n");
    }
'
  js_svy_printout <- '
    echo("rk.header(\\"Survey Summary Table (gtsummary::tbl_svysummary)\\", level=3);\\n");
    echo("print(svy_gtsummary_result);\\n");
    if(getValue("sav_svy_result")){
      echo("rk.print(paste(\\"Object svy_gtsummary_result saved.\\"))\\n");
    }
'

  svy_summary_component <- rk.plugin.component(
    "Survey Summary Table (gtsummary)", xml = list(dialog = svy_dialog),
    js = list(
      require = c("gtsummary", "survey"), calculate = js_svy_logic, printout = js_svy_printout
    ),
    rkh = list(help = svy_help), hierarchy = list("analysis", "gt Summaries")
  )

  # =========================================================================================
  # PACKAGE CREATION (THE MAIN CALL)
  # =========================================================================================
  plugin.dir <- rk.plugin.skeleton(
    about = package_about, path = ".",
    xml = list(dialog = tbl_summary_dialog),
    js = list(
      require = "gtsummary", calculate = js_tbl_summary_logic, printout = js_tbl_summary_printout,
      results.header = "Summary Tables (gtsummary)"
    ),
    rkh = list(help = tbl_summary_help),
    pluginmap = list(
      name = "Summary Table (gtsummary)", hierarchy = list("analysis", "gt Summaries")
    ),
    components = list(svy_summary_component),
    create = c("pmap", "xml", "js", "desc", "rkh"), load = TRUE, overwrite = TRUE, show = FALSE
  )

  message(
    paste0('Plugin package \'', plugin_name, '\' created successfully in \'', plugin.dir, '\'!\n\n'),
    'NEXT STEPS:\n', '1. Open RKWard.\n', '2. In the R console, run:\n',
    paste0('   rk.updatePluginMessages(pluginmap="inst/rkward/', plugin_name, '.rkmap")\n'),
    '3. Then, to install the plugin, run:\n', '   # devtools::install()'
  )
})
