# rk.gtsummary: Publication-Ready Summary & Regression Tables for RKWard

![Version](https://img.shields.io/badge/Version-0.2.0-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.gtsummary/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.gtsummary/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**A Zero-Code GUI Wrapper for the `gtsummary` Package: From Descriptive Stats to Advanced Regression Modeling**

`rk.gtsummary` empowers researchers to generate beautiful, highly customizable, and publication-ready tables directly from the RKWard GUI. Whether you are summarizing simple data frames or running predictive regression models on complex, weighted survey designs (like IPUMS or demographic censuses), this plugin handles the heavy lifting, formatting, and statistical extraction automatically.

---

## 🚀 What's New in Version 0.2.0 (The Regression Update)

*   **Full Regression Suite (`tbl_regression`):** The plugin now goes beyond descriptive statistics by introducing two powerful new modules for predictive modeling: **Standard Regression (`glm`)** and **Survey Regression (`svyglm`)**.
*   **The Survey $R^2$ Solution:** Fitting models to weighted survey data in base R usually strips away the $R^2$ metric in the summary output. This plugin elegantly solves this notorious pain point by integrating `add_glance_table()`, automatically calculating and appending the pseudo-$R^2$, AIC, and unweighted N to the bottom of your complex survey models.
*   **One-Click Odds Ratios:** Easily fit Logistic Regression models (Binomial or Quasi-binomial) and simply check a box to exponentiate your coefficients into Odds Ratios automatically.
*   **Global P-Values:** Automatically compute and display global p-values for categorical predictors (using Wald tests for surveys and ANOVA for standard data) with a single click.
*   **Unified Output Formats:** Just like the summary tables, your regression outputs can be converted instantly to `gt` (HTML/PDF), `flextable` (Word), or `huxtable` (LaTeX) to match your exact publication needs.


## 🚀 What's New in Version 0.1.4

* **Dynamic Data Filtering (`subset()`):** A highly requested feature! You can now filter your data directly from the plugin interface. A new "Optional: subset() condition" field has been added to the Data tab for both the **Data Frame (`tbl_summary`)** and **Survey (`tbl_svysummary`)** components.
* **Cleaner Workspaces:** Instead of manually creating multiple pre-filtered datasets or survey designs in your R environment, simply type your condition (e.g., `age > 18` or `gender == 'Female'`) and the plugin will automatically apply base R's `subset()` function on-the-fly during table generation.
* **i18n Updates:** The new filtering interface has been fully translated into Spanish, French, German, and Portuguese (Brazil).


## What's New in Version 0.1.3

*   **File Size Optimization (Output Formats):** Summary tables can be huge because they store a copy of the raw dataset. You can now choose to **convert** the table before saving it to a lightweight format:
    *   `gt` (Best for HTML/PDF)
    *   `flextable` (Best for Word)
    *   `huxtable` (Best for LaTeX/RTF)
    *   *Or keep it as a raw `gtsummary` object for further modification.*
*   **Improved Workflow:** A new **"Output"** tab has been added to separate the calculation logic from the saving/exporting logic.
*   **Safe Defaults:** The "Save object" checkbox is now unchecked by default to prevent accidental overwriting or workspace clutter.

## What's New in Version 0.1.2

*   **New Statistics Interface:** The "Statistics" tab has been completely overhauled. You can now select standard statistical formats (e.g., `Mean (SD)`, `Median (IQR)`, `n (%)`) using simple **dropdown menus**. Advanced users can still switch to **"Custom Formula"** mode to type complex glue strings.
*   **Multilingual Support:** The interface is now fully localized in:
    *   🇺🇸 English (Default)
    *   🇪🇸 Spanish (`es`)
    *   🇫🇷 French (`fr`)
    *   🇩🇪 German (`de`)
    *   🇧🇷 Portuguese (Brazil) (`pt_BR`)

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
-   **Workspace Management**: Option to strip raw data from output objects to keep your `.RData` files small and manageable.

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R packages. The plugin will automatically attempt to load them when required:

```R
install.packages(c("gtsummary", "survey"))

```

## Installation

This plugin is not yet on CRAN. To install it, you need the `{remotes}` (or `{devtools}`) package.

1.  **Open RKWard**.
2.  **Run the following command** in the R console:

    ```R
    # If you don't have remotes installed:
    # install.packages("remotes")
    
    local({
      require(remotes)
      install_github("AlfCano/rk.gtsummary", force = TRUE)
    })
    ```

3.  **Activate the Plugin**:
    Restart RKWard to load the new menu items and translations.

---

## 🛠️ Usage Workflow

This plugin adds a comprehensive suite of 4 analytical tools under the **Analysis > gt Summaries** menu in RKWard:

### 1. Summary Table (tbl_summary)
*For standard Data Frames.*
*   Select your dataset and variables.
*   Apply outer/inner stratification (`tbl_strata`) to create grouped summary tables.
*   Customize statistics formats, missing values, and variable labels on the fly.

### 2. Survey Summary Table (tbl_svysummary)
*   For weighted survey design objects.*
*   Maintains the exact same clean interface as the standard table, but mathematically handles complex sampling weights and primary sampling units (PSUs) in the background.

### 3. Standard Regression Model (glm)
*Build predictive models from standard Data Frames.*
*   Select your Target (Y) and Predictors (X).
*   Choose your model family: Gaussian (Linear), Binomial (Logistic), or Poisson.
*   Extract regression coefficients, 95% Confidence Intervals, P-values, and model fit statistics ($R^2$, AIC).

### 4. Survey Regression Model (svyglm)
*Build predictive models from weighted survey designs.*
*   Automatically protects your weighted structures while fitting regression models.
*   Choose between Gaussian, Quasi-binomial, and Quasi-poisson families.
*   Seamlessly extracts the much-needed pseudo-$R^2$ for your social science or demographic research.

---

**Workflow:**
1.  **Data Tab:** Select your dataset and variables.
2.  **Statistics Tab:** Choose how to present means, medians, or percentages.
3.  **Themes Tab:** Apply journal themes or languages.
4.  **Output Tab:** Choose whether to convert the object (e.g., to `flextable` for Word export) and save it to your workspace.

## Suggestion

This plugin requires the following R packages to be installed:
-   `gtsummary`
-   `survey`

*Optional but recommended for export features:*
-   `gt`
-   `flextable`
-   `huxtable`

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
