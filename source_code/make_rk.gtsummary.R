local({
  # Require "rkwarddev"
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  # --- GLOBAL SETTINGS ---
  plugin_name <- "rk.gtsummary"
  plugin_version <- "0.1.3"

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
  # 1. SHARED UI RESOURCES
  # =========================================================================================

  # --- STATISTICS TAB UI ---
  # 1. Selection Mode
  stat_mode_radio <- rk.XML.radio(label="Statistics Definition Mode", id.name="rad_stat_mode", options=list(
    "Standard Presets (Recommended)" = list(val="preset", chk=TRUE),
    "Custom Formula (Advanced)" = list(val="custom")
  ))

  # 2. Preset Options (GUI)
  # Continuous
  cont_stats_drop <- rk.XML.dropdown(label="Continuous Variables", id.name="drp_stat_cont", options=list(
    "Median (IQR)" = list(val="median_iqr", chk=TRUE),
    "Median (Range)" = list(val="median_range"),
    "Mean (SD)" = list(val="mean_sd"),
    "Mean ± SD" = list(val="mean_pm_sd"),
    "Mean (CI)" = list(val="mean_ci"),
    "Min - Max" = list(val="min_max")
  ))

  # Categorical
  cat_stats_drop <- rk.XML.dropdown(label="Categorical Variables", id.name="drp_stat_cat", options=list(
    "n (%)" = list(val="n_p", chk=TRUE),
    "n / N (%)" = list(val="n_N_p"),
    "n" = list(val="n"),
    "Percent only (%)" = list(val="p")
  ))

  presets_frame <- rk.XML.frame(cont_stats_drop, cat_stats_drop, label="Standard Formats")
  # Only show presets frame if mode is 'preset'
  attr(presets_frame, "dependencies") <- list(active = list(string = "rad_stat_mode.string == 'preset'"))

  # 3. Custom Option (Text Input)
  custom_stat_input <- rk.XML.input(id.name = "inp_statistic_custom", label = "Custom formula (e.g., all_continuous() ~ '{mean}')", initial = "list(all_continuous() ~ '{mean} ({sd})', all_categorical() ~ '{n} / {N} ({p}%)')")
  custom_frame <- rk.XML.frame(custom_stat_input, label="Custom Definition")
  # Only show custom frame if mode is 'custom'
  attr(custom_frame, "dependencies") <- list(active = list(string = "rad_stat_mode.string == 'custom'"))

  # 4. Other Stats Options
  digits_input <- rk.XML.input(id.name = "inp_digits", label = "Digits formula (optional)")
  type_input <- rk.XML.input(id.name = "inp_type", label = "Type formula (optional)")
  percent_dropdown <- rk.XML.dropdown(id.name = "drp_percent", label = "Percentage basis (percent)", options = list(
    "Column" = list(val = "column", chk = TRUE), "Row" = list(val = "row"), "Cell" = list(val = "cell")
  ))

  # Combine into one Column for the tab
  stats_tab_content <- rk.XML.col(
    stat_mode_radio,
    presets_frame,
    custom_frame,
    rk.XML.stretch(),
    digits_input,
    percent_dropdown,
    type_input
  )

  # --- LABELS & MISSING TAB UI ---
  use_rk_labels_cbox <- rk.XML.cbox(id.name = "cbox_use_rk_labels", label = "Use RKWard variable labels (rk.get.label)", value="1", chk=TRUE)
  label_input <- rk.XML.input(id.name = "inp_label", label = "Custom label formula")

  missing_dropdown <- rk.XML.dropdown(id.name = "drp_missing", label = "Show missing values (missing)", options = list(
    "If any present" = list(val = "ifany", chk = TRUE), "Never" = list(val = "no"), "Always" = list(val = "always")
  ))
  missing_text_input <- rk.XML.input(id.name = "inp_missing_text", label = "Missing value text (missing_text)", initial = "Unknown")

  labels_tab_content <- rk.XML.col(rk.XML.frame(use_rk_labels_cbox, label_input, label="Variable Labels"), rk.XML.frame(missing_dropdown, missing_text_input, label="Missing Values"))

  # --- THEMES TAB UI ---
  journal_theme_dropdown <- rk.XML.dropdown(id.name="drp_journal", label="Journal Theme", options=list(
      "None" = list(val="none", chk=TRUE), "JAMA" = list(val="jama"), "Lancet" = list(val="lancet"), "NEJM" = list(val="nejm"), "QJ Econ" = list(val="qjecon")
  ))
  compact_theme_cbox <- rk.XML.cbox(id.name="cbox_compact", label="Use compact theme", value="1")

  # NEW: Save conversion dropdown (Output format) - Moved to Output Tab later, but defined here for reuse?
  # Actually, since rk.XML objects are nodes, we should ideally create fresh nodes or use the same definition if inserted once.
  # I will define it here but insert it into the 5th tab logic.
  save_conversion_dropdown <- rk.XML.dropdown(id.name="drp_save_conversion", label="Convert object format (Reduces file size)", options=list(
      "No conversion (gtsummary object)" = list(val="none", chk=TRUE),
      "gt object (HTML/PDF)" = list(val="gt"),
      "flextable (Word)" = list(val="flextable"),
      "huxtable (LaTeX/RTF)" = list(val="huxtable")
  ))

  printer_engine_dropdown <- rk.XML.dropdown(id.name="drp_printer", label="Printer Friendly Engine (Preview)", options=list(
      "None" = list(val="none", chk=TRUE), "gt" = list(val="gt"), "kable" = list(val="kable"), "flextable" = list(val="flextable"), "huxtable" = list(val="huxtable")
  ))
  language_dropdown <- rk.XML.dropdown(id.name="drp_lang", label="Language", options=list(
      "System Default (en)" = list(val="en", chk=TRUE), "German (de)"=list(val="de"), "Spanish (es)"=list(val="es"), "French (fr)"=list(val="fr"),
      "Portuguese (pt)"=list(val="pt"), "Chinese (zh-cn)"=list(val="zh-cn")
  ))
  decimal_mark_input <- rk.XML.input(id.name="inp_dec_mark", label="Decimal mark")
  big_mark_input <- rk.XML.input(id.name="inp_big_mark", label="Big number mark")

  # Removed save_conversion_dropdown from here
  themes_tab_content <- rk.XML.col(
      rk.XML.frame(journal_theme_dropdown, compact_theme_cbox, label="Appearance"),
      rk.XML.frame(printer_engine_dropdown, label="Display Options"),
      rk.XML.frame(language_dropdown, decimal_mark_input, big_mark_input, label="Language & Localization")
  )

  # --- SHARED JS HELPER FOR STATISTICS ---
  # This string is injected into both calculate blocks to handle the GUI logic
  js_stats_builder <- '
    var stat_mode = getValue("rad_stat_mode");
    var statistic_arg = "";

    if (stat_mode == "custom") {
        var raw_cust = getValue("inp_statistic_custom");
        if(raw_cust) statistic_arg = "statistic = " + raw_cust;
    } else {
        var cont_style = getValue("drp_stat_cont");
        var cat_style = getValue("drp_stat_cat");
        var cont_str = "";
        var cat_str = "";

        // Continuous logic
        if (cont_style == "median_iqr")   cont_str = "{median} ({p25}, {p75})";
        if (cont_style == "median_range") cont_str = "{median} ({min}, {max})";
        if (cont_style == "mean_sd")      cont_str = "{mean} ({sd})";
        if (cont_style == "mean_pm_sd")   cont_str = "{mean} \u00B1 {sd}"; // Unicode Plus-Minus
        if (cont_style == "mean_ci")      cont_str = "{mean} ({conf.low}, {conf.high})";
        if (cont_style == "min_max")      cont_str = "{min} - {max}";

        // Categorical logic
        if (cat_style == "n_p")     cat_str = "{n} ({p}%)";
        if (cat_style == "n_N_p")   cat_str = "{n} / {N} ({p}%)";
        if (cat_style == "n")       cat_str = "{n}";
        if (cat_style == "p")       cat_str = "{p}%";

        if(cont_str && cat_str) {
            statistic_arg = "statistic = list(all_continuous() ~ \\"" + cont_str + "\\", all_categorical() ~ \\"" + cat_str + "\\")";
        }
    }
  '

  # =========================================================================================
  # COMPONENT 1 DEFINITION: tbl_summary
  # =========================================================================================
  tbl_summary_df_selector <- rk.XML.varselector(id.name = "slc_tbl_summary_source", label = "Data frames")
  tbl_summary_data_slot <- rk.XML.varslot(id.name = "var_tbl_summary_data", label = "Data frame to summarize", source = "slc_tbl_summary_source", required = TRUE, classes = "data.frame")
  tbl_summary_include_slot <- rk.XML.varslot(id.name = "var_tbl_summary_include", label = "Variables to include", source = "slc_tbl_summary_source", multi = TRUE)
  tbl_summary_strata_slot <- rk.XML.varslot(id.name = "var_tbl_summary_strata", label = "Outer stratification (strata)", source = "slc_tbl_summary_source")
  tbl_summary_by_slot <- rk.XML.varslot(id.name = "var_tbl_summary_by", label = "Inner stratification (by)", source = "slc_tbl_summary_source")

  # CHANGED: chk = FALSE
  tbl_summary_save_object <- rk.XML.saveobj(id.name = "sav_tbl_summary_result", label = "Save result to new object", chk = FALSE, initial = "gtsummary_result")

  # NEW: Output Tab Content
  tbl_summary_output_tab <- rk.XML.col(
    rk.XML.frame(save_conversion_dropdown, label="Output Format"),
    rk.XML.frame(tbl_summary_save_object, label="Save Object")
  )

  tbl_summary_tabbook <- rk.XML.tabbook(tabs = list(
      "Data" = rk.XML.col(tbl_summary_data_slot, tbl_summary_include_slot, tbl_summary_strata_slot, tbl_summary_by_slot),
      "Statistics" = stats_tab_content,
      "Labels & Missing" = labels_tab_content,
      "Themes & Formatting" = themes_tab_content,
      "Output" = tbl_summary_output_tab  # Added Tab 5
  ))

  tbl_summary_dialog <- rk.XML.dialog(
    label = "Summary Table (tbl_summary)",
    child = rk.XML.row(
      rk.XML.col(tbl_summary_df_selector),
      rk.XML.col(tbl_summary_tabbook) # Removed Save Object from here, it's inside Tab 5
    )
  )

  tbl_summary_help <- rk.rkh.doc(
    summary = rk.rkh.summary("Creates a descriptive summary table for a data frame using gtsummary::tbl_summary()."),
    usage = rk.rkh.usage("Select a data frame and the variables to include."),
    sections = list(rk.rkh.section(title = "Key Arguments", text = "<p>Use the tabs to customize statistics, formatting, themes, and handling of missing data. Use 'Outer stratification' to create grouped tables with <code>tbl_strata()</code>.</p>")),
    title = rk.rkh.title("Table of Summary Statistics")
  )

  js_tbl_summary_logic <- paste0(
    '
    var data_frame = getValue("var_tbl_summary_data");
    if(!data_frame) return;

    var journal = getValue("drp_journal");
    var compact = getValue("cbox_compact");
    var printer = getValue("drp_printer");
    var lang = getValue("drp_lang");
    var dec_mark = getValue("inp_dec_mark");
    var big_mark = getValue("inp_big_mark");
    var convert_save = getValue("drp_save_conversion");

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

    // Statistics logic injected here
    ', js_stats_builder, '

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

    // Use the variable generated by js_stats_builder
    if(statistic_arg){ options.push(statistic_arg); }

    if(digits){ options.push("digits = " + digits); }
    if(type){ options.push("type = " + type); }
    if(missing){ options.push("missing = \\"" + missing + "\\""); }
    if(missing_text){ options.push("missing_text = \\"" + missing_text + "\\""); }
    if(percent){ options.push("percent = \\"" + percent + "\\""); }

    // Construct the conversion pipe suffix if needed
    var conversion_suffix = "";
    if(convert_save == "gt") conversion_suffix = " %>% gtsummary::as_gt()";
    if(convert_save == "flextable") conversion_suffix = " %>% gtsummary::as_flex_table()";
    if(convert_save == "huxtable") conversion_suffix = " %>% gtsummary::as_hux_table()";

    if(strata_var_full) {
      var strata_var = getColumnName(strata_var_full);
      var inner_call = ".x %>% gtsummary::tbl_summary(" + options.join(", ") + ")";
      var final_call = data_frame + " %>% gtsummary::tbl_strata(strata = \\"" + strata_var + "\\", .tbl_fun = ~ " + inner_call + ")";
      // Strict assignment to initial object name
      echo("gtsummary_result <- " + final_call + conversion_suffix + ";\\n");
    } else {
      options.unshift("data = " + data_frame);
      echo("gtsummary_result <- gtsummary::tbl_summary(" + options.join(", ") + ")" + conversion_suffix + ";\\n");
    }
    ')

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

  # CHANGED: chk = FALSE
  svy_save_object <- rk.XML.saveobj(id.name = "sav_svy_result", label = "Save result to new object", chk = FALSE, initial = "svy_gtsummary_result")

  # NEW: Output Tab Content (Survey)
  svy_output_tab <- rk.XML.col(
    rk.XML.frame(save_conversion_dropdown, label="Output Format"),
    rk.XML.frame(svy_save_object, label="Save Object")
  )

  svy_tabbook <- rk.XML.tabbook(tabs = list(
      "Data" = rk.XML.col(
        svy_data_slot,
        svy_include_slot,
        svy_strata_slot,
        svy_by_slot,
        rk.XML.cbox(id.name = "cbox_svy_lonely_psu", label = "Adjust for lonely PSUs (survey.lonely.psu = 'adjust')", value = "1")
      ),
      "Statistics" = stats_tab_content,
      "Labels & Missing" = labels_tab_content,
      "Themes & Formatting" = themes_tab_content,
      "Output" = svy_output_tab # Added Tab 5
  ))

  svy_dialog <- rk.XML.dialog(
    label = "Survey Summary Table (tbl_svysummary)",
    child = rk.XML.row(
      rk.XML.col(svy_selector),
      rk.XML.col(svy_tabbook) # Removed Save Object from here, it's inside Tab 5
    )
  )

  svy_help <- rk.rkh.doc(
    summary = rk.rkh.summary("Creates a descriptive summary table for a survey design object using gtsummary::tbl_svysummary()."),
    usage = rk.rkh.usage("Select a survey.design object and the variables to include."),
    sections = list(rk.rkh.section(title = "Key Difference", text = "This dialog requires an object of class <code>survey.design</code>.")),
    title = rk.rkh.title("Table of Survey Summary Statistics")
  )

  js_svy_logic <- paste0(
    '
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
    var convert_save = getValue("drp_save_conversion");

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

    // Statistics logic injected here
    ', js_stats_builder, '

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

    // Use the variable generated by js_stats_builder
    if(statistic_arg){ options.push(statistic_arg); }

    if(digits){ options.push("digits = " + digits); }
    if(type){ options.push("type = " + type); }
    if(missing){ options.push("missing = \\"" + missing + "\\""); }
    if(missing_text){ options.push("missing_text = \\"" + missing_text + "\\""); }
    if(percent){ options.push("percent = \\"" + percent + "\\""); }

    // Construct the conversion pipe suffix if needed
    var conversion_suffix = "";
    if(convert_save == "gt") conversion_suffix = " %>% gtsummary::as_gt()";
    if(convert_save == "flextable") conversion_suffix = " %>% gtsummary::as_flex_table()";
    if(convert_save == "huxtable") conversion_suffix = " %>% gtsummary::as_hux_table()";

    if(strata_var_full) {
      var strata_var = getColumnName(strata_var_full);
      var inner_call = ".x %>% gtsummary::tbl_svysummary(" + options.join(", ") + ")";
      var final_call = svy_object + " %>% gtsummary::tbl_strata(strata = \\"" + strata_var + "\\", .tbl_fun = ~ " + inner_call + ")";
      // Strict assignment to initial object name
      echo("svy_gtsummary_result <- " + final_call + conversion_suffix + ";\\n");
    } else {
      options.unshift("data = " + svy_object);
      echo("svy_gtsummary_result <- gtsummary::tbl_svysummary(" + options.join(", ") + ")" + conversion_suffix + ";\\n");
    }
    ')

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
  # REMOVED: po_id
  plugin.dir <- rk.plugin.skeleton(
    about = package_about, path = ".",
    xml = list(dialog = tbl_summary_dialog),
    js = list(
      require = "gtsummary", calculate = js_tbl_summary_logic, printout = js_tbl_summary_printout,
      results.header = "Summary Tables (gtsummary)"
    ),
    rkh = list(help = tbl_summary_help),
    pluginmap = list(
      name = "Summary Table (gtsummary)",
      hierarchy = list("analysis", "gt Summaries")
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
