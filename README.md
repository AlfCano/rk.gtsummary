# rk.gtsummary

![Version](https://img.shields.io/badge/Version-0.1.1-blue.svg)

An RKWard plugin for creating beautiful, publication-ready summary tables using the powerful `{gtsummary}` package.

This plugin provides a user-friendly graphical interface for the `tbl_summary` and `tbl_svysummary` functions, allowing for easy generation of descriptive statistics tables for both standard data frames and complex survey designs.

## What is new on 0.1.1

* Added a **new checkbox**, "Adjust for lonely PSUs (survey.lonely.psu = 'adjust')", has been added to the Data tab of the "Survey Summary Table" dialog.

## Features

-   **Standard Summaries**: Generate descriptive summary tables (`tbl_summary`) from any `data.frame`.
-   **Survey Data Support**: Full support for weighted survey data via `tbl_svysummary`, correctly handling `survey.design` objects from the `{survey}` package.
-   **Powerful Stratification**:
    -   Easily stratify tables by one variable (`by=`).
    -   Create deeply nested tables by adding a second, outer stratification variable (`strata=`).
-   **Extensive Customization**:
    -   **Statistics**: Modify the default statistics shown for continuous and categorical variables.
    -   **Labels**: Automatically use RKWard's built-in variable labels (`rk.get.label()`) for clear, descriptive tables, or provide your own custom label formulas.
    -   **Missing Values**: Control how missing data is displayed in the summary.
-   **Publication-Ready Theming**:
    -   Apply pre-built journal themes (JAMA, Lancet, NEJM).
    -   Use a compact theme for a condensed look.
    -   Set a printer-friendly output engine (`gt`, `kable`, etc.).
    -   Easily configure language and localization settings (e.g., decimal marks).

## Screenshots

### Main Dialog (`tbl_summary`)

The dialog provides four clear tabs for specifying your data, statistics, labels, and themes.

*(Image: Screenshot of the main dialog showing the four tabs: Data, Statistics, Labels & Missing, Themes & Formatting)*

### Example Output

The plugin generates rich HTML tables that are displayed in RKWard's output viewer or an external browser.

*(Image: Screenshot of a finished gtsummary table, stratified, showing clear labels and statistics)*

## Installation

This plugin is not yet on CRAN. To install it, you need the `{devtools}` package and can install directly from its future GitHub repository.

1.  **Install `{devtools}`**:
    If you don't have it, open the R console in RKWard and run:
    ```R
    install.packages("devtools")
    ```

2.  **Install the Plugin**:
    Run the following command in the R console:
```R
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.gtsummary"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```

3.  **Activate the Plugin**:
    Restart RKWard, or go to `Settings -> R Packages -> Select loaded packages` and ensure that `rk.gtsummary` is checked.

## Usage

Once installed, the plugin will be available in the RKWard menu under:

**`analysis` -> `gt Summaries`**

You will see two options:

-   **Summary Table (gtsummary)**: Use this for standard `data.frame` objects.
-   **Survey Summary Table (gtsummary)**: Use this for `survey.design` objects.

Select the appropriate option, choose your data and variables in the dialog, customize the options in the tabs, and click "Submit" to generate the table.

## Dependencies

This plugin requires the following R packages to be installed:
-   `{gtsummary}`
-   `{survey}`

## Author

Alfonso Cano
<alfonso.cano@correo.buap.mx>

*Code generation and iterative debugging assisted by Gemini, a large language model from Google.*

## License

GPL (>= 3)

---

### Known Issues for v0.1.0

-   The `gtsummary` package produces rich HTML output. This output is not compatible with RKWard's standard code preview pane. Please use the "Submit" button to generate the final table, which will open in the appropriate viewer.
