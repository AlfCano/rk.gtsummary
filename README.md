# rk.gtsummary: Publication-Ready Summary Tables

![Version](https://img.shields.io/badge/Version-0.1.2-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.gtsummary/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.gtsummary/actions/workflows/lintr.yml)

An RKWard plugin for creating beautiful, publication-ready summary tables using the powerful `{gtsummary}` package.

This plugin provides a user-friendly graphical interface for the `tbl_summary` and `tbl_svysummary` functions, allowing for easy generation of descriptive statistics tables for both standard data frames and complex survey designs.

## What's New in Version 0.1.2

*   **New Statistics Interface:** The "Statistics" tab has been completely overhauled. You can now select standard statistical formats (e.g., `Mean (SD)`, `Median (IQR)`, `n (%)`) using simple **dropdown menus**. Advanced users can still switch to **"Custom Formula"** mode to type complex glue strings.
*   **Multilingual Support:** The interface is now fully localized in:
    *   🇺🇸 English (Default)
    *   🇪🇸 Spanish (`es`)
    *   🇫🇷 French (`fr`)
    *   🇩🇪 German (`de`)
    *   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## What's New in Version 0.1.1

*   **Survey Data Support:** Added a **checkbox** to "Adjust for lonely PSUs (`survey.lonely.psu = 'adjust'`)" in the Data tab of the Survey Summary Table dialog.

## Features

-   **Standard Summaries**: Generate descriptive summary tables (`tbl_summary`) from any `data.frame`.
-   **Survey Data Support**: Full support for weighted survey data via `tbl_svysummary`, correctly handling `survey.design` objects from the `{survey}` package.
-   **Powerful Stratification**:
    -   Easily stratify tables by one variable (`by=`).
    -   Create deeply nested tables by adding a second, outer stratification variable (`strata=`).
-   **Extensive Customization**:
    -   **Statistics**: Switch between "Standard Presets" for quick configuration or "Custom Formulas" for granular control over continuous and categorical statistics.
    -   **Labels**: Automatically use RKWard's built-in variable labels (`rk.get.label()`) for clear, descriptive tables, or provide your own custom label formulas.
    -   **Missing Values**: Control how missing data is displayed in the summary.
-   **Publication-Ready Theming**:
    -   Apply pre-built journal themes (JAMA, Lancet, NEJM).
    -   Use a compact theme for a condensed look.
    -   Set a printer-friendly output engine (`gt`, `kable`, etc.).
    -   Easily configure language and localization settings (e.g., decimal marks).

## Installation

This plugin is not yet on CRAN. To install it, you need the `{devtools}` (or `{remotes}`) package.

1.  **Open RKWard**.
2.  **Run the following command** in the R console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(devtools)
      install_github("AlfCano/rk.gtsummary", force = TRUE)
    })
    ```

3.  **Activate the Plugin**:
    Restart RKWard to load the new menu items and translations.

## Usage

Once installed, the plugin will be available in the RKWard menu under:

**`Analysis` -> `gt Summaries`**

You will see two options:

-   **Summary Table (gtsummary)**: Use this for standard `data.frame` objects.
-   **Survey Summary Table (gtsummary)**: Use this for `survey.design` objects.

Select the appropriate option, choose your data and variables in the dialog, customize the options in the tabs, and click "Submit" to generate the table.

## Dependencies

This plugin requires the following R packages to be installed:
-   `gtsummary`
-   `survey`

## Author

Alfonso Cano
<alfonso.cano@correo.buap.mx>

*Code generation and iterative debugging assisted by Gemini, a large language model from Google.*

## License

GPL (>= 3)
