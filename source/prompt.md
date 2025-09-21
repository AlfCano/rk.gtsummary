# Golden Rules for RKWard Plugin Development (rkwarddev v0.10-3)

### 1. The R Script is the Single Source of Truth
*   Your sole output will be a single R script that defines all plugin components as R objects and uses `rk.plugin.skeleton()` to write the final files. This script **must** be wrapped in `local({})` to avoid polluting the user's global environment when sourced.
*   The script must begin with `require(rkwarddev)` and a `rkwarddev.required()` check.

### 2. The Sacred Structure of the Help File (`.rkh`)
*   The user will provide help text in a simple R list. Your script **must** translate this into `rkwarddev` objects using the fixed pattern: `plugin_help$summary` becomes `rk.rkh.summary()`, etc.
*   **CRITICAL:** The help document's main title **must** be created with `rk.rkh.title()`.

### 3. The Mandate of Explicit IDs (For Widgets Only)
*   **Every interactive UI element** (`varslot`, `input`, `cbox`, `dropdown`, `saveobj`, etc.) **must** be assigned a unique, hard-coded `id.name`. This is non-negotiable and is the primary defense against "Can't find an ID!" and "subscript out of bounds" errors.
*   **CRITICAL:** **Do not** assign an `id.name` to layout containers (`rk.XML.col`, `rk.XML.row`). The `rkwarddev` framework manages these automatically, and manual IDs will conflict with its internal system, causing errors.

### 4. The Inflexible One-`varselector`-to-Many-`varslot`s UI Pattern
*   The `source` argument of every `varslot` that depends on a selection **must** be the same `id.name` from the parent `varselector`.
*   To select variables from a data frame *inside* another object (like a `svydesign` object), you **must** use `attr(my_column_varslot, "source_property") <- "variables"`.

### 5. The `calculate`/`printout` Content Pattern (Revised and Stricter)
*   **The `calculate` Block:** This block generates the R code for the **entire computation sequence**.
    *   It **must** assign the final result to a hard-coded object name (e.g., `gtsummary_result <- ...`), which should match the `initial` argument of its `rk.XML.saveobj`.
    *   All conditional logic (like choosing to wrap a command in `tbl_strata()`) **must** be handled here using JavaScript `if` statements.
*   **The `printout` Block (Revised):**
    *   This block's only purpose is to display the final result object. It **must be minimalist and must not contain conditional `if` logic**.
    *   Its primary content should be `echo("rk.header(...)")` and `echo("print(final_result_object)")`.
    *   A simple, separate `echo("rk.print(...)")` can follow to confirm if a save object was created, but the main printout should be unconditional.

### 6. Strict Adherence to Legacy `rkwarddev` Syntax
*   You **must** use `rk.XML.cbox(..., value="1")`.
*   A proven, working set of arguments for `rk.plugin.skeleton` must be used.

### 7. The Immutable Raw JavaScript String Paradigm (Upgraded)
You **must avoid programmatic JavaScript generation** and write a self-contained, multi-line R character string for the `calculate` logic.

*   **Master `getValue()`:** Begin the script by declaring a JavaScript variable for every UI component's `id.name`.
*   **The `getColumnName` Helper is Mandatory (Upgraded Version):** For selecting variables from any object (simple or complex), you **must** include the following robust helper function inside your JavaScript string:
    ```javascript
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    ```
*   **Programmatically Build R Arguments in JavaScript:** For complex arguments like `label`, use JavaScript's `.map()` and `.join()` on arrays of variable names to dynamically construct the R `list()` syntax. This is the correct pattern for features like `rk.get.label()`.

### 8. The `<logic>` Section is Forbidden (Elevated in Importance)
*   The `<logic>` section, including `rk.XML.connect()`, is fragile and highly sensitive to the `rkwarddev` version. Its use is the most common source of obscure errors.
*   **All conditional behavior must be handled inside the `calculate` JavaScript string.** It is better to have a slightly less responsive UI (e.g., an input field that is always enabled) than a plugin that fails to load due to an incompatible `<logic>` tag.

### 9. Correct Component Architecture for Multi-Plugin Packages
*   The main component's definition is passed to `rk.plugin.skeleton()`. Other plugins **must** be defined with `rk.plugin.component()` and passed as a `list` to the `components` argument of the main call. The `hierarchy` must use the correct, case-sensitive names (e.g., `"analysis"`).

### 10. The Sanctity of XML Quoting (New Rule)
*   When defining R objects that generate XML, you **must** follow a strict quoting convention to produce valid files.
*   **The Pattern:** The R string literal should use single quotes (`'...'`). The XML attributes within that string must use double quotes (`"`). If the R code *inside* an attribute (like `initial`) needs its own string quotes, it **must** use single quotes (`'...'`).
*   **Example:** `rk.XML.input(initial = 'list(all_continuous() ~ "{median}")')` is valid.
*   **Invalid:** `rk.XML.input(initial = "list(all_continuous() ~ "{median}")")` will fail to parse.
