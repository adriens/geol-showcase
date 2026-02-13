# PostgreSQL Report Update Process (Automated by Gemini CLI)

This document outlines the steps taken by the Gemini CLI agent to update the PostgreSQL security analysis report (`rapport_postgresql_EN.tex`). This process can be replicated for future updates to new PostgreSQL versions.

## 1. Tool Identification and Versioning ⚠️ CRITICAL STEP

**IMPORTANT**: Always verify and update tool versions at the start of any report update. Tool versions **MUST** be retrieved from the current shell environment, not hardcoded or assumed.

### Commands to Run (DO NOT SKIP):

1. **`geol`**: Run `geol version` to get the current version
   - Example output: `2.7.1`
   - Update in LaTeX: Line ~90 in `\subsection{\texttt{geol}: The Lifecycle Guardian}`

2. **`trivy`**: Run `trivy --version` to get the current version
   - Example output: `Version: 0.69.1` (also note Vulnerability DB version)
   - Update in LaTeX: Line ~93 in `\subsection{\texttt{trivy}: The Vulnerability Scanner}`

3. **`gemini-cli`**: Run `gemini --version` to get the current version
   - Example output: `0.28.2`
   - Update in LaTeX: Line ~96 in `\subsection{\texttt{gemini-cli}: AI Assistant}`

4. **`xelatex`**: Run `xelatex --version` to get the current version
   - Example output: `XeTeX 3.141592653-2.6-0.999995 (TeX Live 2023/Debian)`
   - Update in LaTeX: Line ~100 in `\subsection{\LaTeX{}: Report Generator}` (if mentioned)

### Verification Checklist:

- [ ] Run all four version commands
- [ ] Update LaTeX document with actual versions
- [ ] Build PDF to verify changes compile
- [ ] Verify versions appear correctly in the generated PDF

## 2. PostgreSQL Lifecycle Data Retrieval (`geol`)

The `geol` tool was used to fetch the latest PostgreSQL version lifecycle data:

*   `geol product extended psql -n0`

This command provided detailed information including release dates, latest patch versions, latest release dates, and End-of-Life (EOL) dates for all PostgreSQL cycles.

## 3. Vulnerability Analysis (`trivy`)

`trivy` was used to scan official PostgreSQL Docker images for vulnerabilities.

*   **Methodology**: Scans were performed using major version Docker tags (e.g., `postgres:18`, `postgres:17`). It's important to note that these major version tags on Docker Hub typically point to the *latest patch release* within that major version series (e.g., `postgres:18` refers to `postgres:18.1`). This ensures the analysis reflects the security posture of the most current image a user would pull. To find the latest tags, you can search for the official `postgres` image on Docker Hub.
*   **Command Example**: `trivy image --format template --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' postgres:18 | sort | uniq -c`
*   **Scanned Versions**: `postgres:18`, `postgres:17`, `postgres:16`, `postgres:15`, `postgres:14`, `postgres:13`, `postgres:12`, `postgres:11`, `postgres:10`, `postgres:9.6`.

## 4. LaTeX Report (`rapport_postgresql_EN.tex`) Updates

The `rapport_postgresql_EN.tex` file was updated to reflect the latest data and improve presentation:

*   **Tool Versions**: Added current versions of `geol`, `trivy` (including DB version), `gemini-cli`, and `xelatex` to the "Introduction to the Tools" section.
*   **PostgreSQL Lifecycle Table**: Updated the `\begin{table}[htbp]` for "PostgreSQL Version Lifecycle" to include "Latest" and "Latest Release" columns, using data from `geol`. The "Status" for PostgreSQL 13 was updated to `\textbf{Unsupported}` as its EOL date had passed.
*   **Vulnerability Summary Table**: Updated the `\begin{table}[htbp]` for "Vulnerability Summary by Version" with the latest `trivy` scan results for each major Docker tag.
*   **Vulnerability Comparison Section**: A new subsection was added to compare vulnerabilities between two specific versions (e.g., 18.0 and 18.1). This includes a new table and a bar plot (`tikzpicture`) to visualize the differences.
*   **Vulnerability Chart (`tikzpicture`)**: Modified the `\begin{figure}[htbp]` to update the `symbolic y coords` and `coordinates` to use the full patch version numbers (e.g., `18.1`, `17.7`) for consistency with the table. The style for `nodes near coords` was also updated for better readability.
*   **Summary and Conclusion**: Updated the text to reflect the new status of PostgreSQL 13 and the latest vulnerability trends.
*   **Document Title**: Modified to include the GitHub repository link: `github.com/adriens/geol-showcase` on a new line for clarity.
*   **Resources Section**: Added a new section with relevant links:
    *   `geol` blog post
    *   `geol` YouTube videos
    *   `geol-showcase` GitHub repository
    *   PostgreSQL latest releases news link

### 4.1 Risk Scoring System ⚠️ CRITICAL FORMULAS

**IMPORTANT**: The report includes a mathematical risk scoring framework with two key formulas that must be maintained:

#### Risk Score Calculation Formula (Line ~287-291)

The weighted risk score formula uses summation notation and must remain mathematically consistent:

```latex
\begin{equation}
\boxed{
\text{Risk Score} = \sum_{i} w_i \cdot n_i = 10 \cdot n_{\text{Critical}} + 5 \cdot n_{\text{High}} + 2 \cdot n_{\text{Medium}} + 1 \cdot n_{\text{Low}}
}
\end{equation}
```

**DO NOT change the weights** (10, 5, 2, 1) without recalculating all risk scores in:
- Main vulnerability table (Line ~320)
- Patch comparison table (Line ~590)
- Before/After migration table (Line ~660)
- Executive One-Pager (Line ~100-120)

#### Risk Classification Piecewise Function (Line ~297-308)

The risk classification uses severity-based override rules to prevent misclassification:

```latex
\begin{equation}
\boxed{
\text{Risk Level} = 
\begin{cases}
\textcolor{vuln-critical}{\textbf{High}} & \text{if } \text{Score} > 300 \text{ OR } n_{\text{Critical}} \geq 3 \\[0.3cm]
\textcolor{vuln-medium}{\textbf{Medium}} & \text{if } 150 \leq \text{Score} \leq 300 \text{ OR } n_{\text{Critical}} \geq 1 \\[0.3cm]
\textcolor{gantt-supported}{\textbf{Low}} & \text{if } \text{Score} < 150 \text{ AND } n_{\text{Critical}} = 0
\end{cases}
}
\end{equation}
```

**Key Rule**: Critical CVEs override score-based thresholds:
- Any version with **≥3 Critical CVEs** is automatically **High Risk**
- Any version with **≥1 Critical CVE** is at least **Medium Risk**
- Only versions with **0 Critical CVEs** can achieve **Low Risk**

#### When Updating Vulnerability Data:

1. **Scan all versions** with trivy and record: Critical, High, Medium, Low counts
2. **Calculate risk scores** for each version using the formula
3. **Apply classification rules** using the piecewise function
4. **Update all tables** with new scores and classifications:
   - Vulnerability Summary Table (with Risk Score column)
   - Patch Comparison Table (with Risk Score column)
   - Before/After Migration Table
   - Risk Score Bar Chart (Line ~360-390)
5. **Verify consistency** across Executive One-Pager, callout boxes, and text

#### Example Calculation:

PostgreSQL 12: 9 Critical, 70 High, 100 Medium, 124 Low
- **Score** = (9×10) + (70×5) + (100×2) + (124×1) = 90 + 350 + 200 + 124 = **764**
- **Classification** = High Risk (Score > 300 AND Critical ≥ 3)

PostgreSQL 17: 0 Critical, 6 High, 9 Medium, 98 Low
- **Score** = (0×10) + (6×5) + (9×2) + (98×1) = 0 + 30 + 18 + 98 = **146**
- **Classification** = Low Risk (Score < 150 AND Critical = 0)

## 5. LaTeX Warning/Error Resolution

*   **Float Specifier Warning**: Resolved `LaTeX Warning: !h' float specifier changed to !ht'` by changing all `[h!]` to `[htbp]` in `\begin{table}` and `\begin{figure}` environments, giving LaTeX more flexibility in placing floats.
*   **Undefined Color Error**: Corrected a typo from `v"uln-high` to `vuln-high` in the `tikzpicture` section.
*   **Template Parsing Error**: Corrected the `trivy` command's template to use a literal newline `\n` instead of an escaped one `\\n` to avoid parsing errors.

This detailed process ensures that the report is accurate, up-to-date, and well-formatted, providing a clear record for future maintenance.
