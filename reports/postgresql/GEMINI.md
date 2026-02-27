# PostgreSQL Report Update Process (Automated by Gemini CLI)

**Last Updated**: February 27, 2026  
**Report Version**: PostgreSQL 18.3 Analysis  
**Tool Versions**: geol 2.7.1, trivy 0.69.1, gemini-cli 0.30.0

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
   - Example output: `0.30.0`
   - Update in LaTeX: Line ~214 in `\subsection{\texttt{gemini-cli}: AI Assistant}`

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

*   **Methodology**: Scans were performed using major version Docker tags (e.g., `postgres:18`, `postgres:17`). It's important to note that these major version tags on Docker Hub typically point to the *latest patch release* within that major version series (e.g., `postgres:18` refers to `postgres:18.3`). This ensures the analysis reflects the security posture of the most current image a user would pull. To find the latest tags, you can search for the official `postgres` image on Docker Hub.
*   **Command Example**: `trivy image --format template --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' postgres:18.3 2>/dev/null | sort | uniq -c`
*   **Scanned Versions**: `postgres:18.3`, `postgres:17.9`, `postgres:16.13`, `postgres:15.17`, `postgres:14.22`, `postgres:13`, `postgres:12`, `postgres:11`, `postgres:10`, `postgres:9.6`.

## 4. LaTeX Report (`rapport_postgresql_EN.tex`) Updates

The `rapport_postgresql_EN.tex` file was updated to reflect the latest data and improve presentation:

*   **Tool Versions**: Updated current versions of `geol` (2.7.1), `trivy` (0.69.1, DB v2), `gemini-cli` (0.30.0), and `xelatex` in the "Introduction to the Tools" section and footer.
*   **PostgreSQL Lifecycle Table**: Updated all supported versions with February 23, 2026 patch releases:
    *   PostgreSQL 18.3, 17.9, 16.13, 15.17, 14.22
    *   All release dates and EOL dates verified with `geol`
*   **Vulnerability Summary Table**: Updated with the latest `trivy` scan results:
    *   PostgreSQL 18.3: 1 Critical, 16 High, 39 Medium, 111 Low (Risk Score: 269)
    *   PostgreSQL 18.2: Corrected actual scan data (was 17 High → 16 High, 102 Low → 111 Low)
    *   All other versions rescanned and verified
*   **Vulnerability Comparison Section**: Enhanced to compare four versions (18.0, 18.1, 18.2, 18.3):
    *   Updated table with 18.3 data
    *   Bar chart modified with vertical labels to prevent overlap
    *   Analysis showing 18.2 and 18.3 have identical vulnerability profiles
*   **Vulnerability Chart (`tikzpicture`)**: Updated all charts with new patch version numbers (18.3, 17.9, 16.13, 15.17, 14.22) for consistency.
*   **Docker Image Metadata Section**: NEW section added (Line ~792-870):
    *   Table of SHA256 manifest digests (truncated format for readability)
    *   Docker Hub URLs for all 18.x images
    *   Scanning with digest references examples
    *   Best practices for reproducible security scans
*   **Trivy Scanning Techniques Section**: NEW comprehensive section added (Line ~248-340):
    *   Template-based extraction methods
    *   JSON + jq processing examples
    *   Risk score calculation with jq
    *   Batch scanning scripts
    *   Best practices callout box
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
*   **Character Encoding Issue**: Fixed Unicode multiplication symbol (×) appearing as "Œ" by replacing with `$\times$` (LaTeX math mode) in all instances (lines 135, 185, 449, 915).
*   **Overfull Hbox Warnings**: Resolved long SHA256 digest warnings by truncating hashes to format `192a387c...ebb3aed` in the Docker digest table.
*   **Overlapping Chart Labels**: Added vertical rotation (`rotate=90`) to bar chart labels to prevent overlap when identical values exist (18.2 and 18.3).

## 6. Update Summary for PostgreSQL 18.3 Release (February 2026)

### Latest Updates Applied:

**PostgreSQL 18.3 Release (2026-02-23):**
*   Scanned postgres:18.3 image (digest: sha256:5aa97b304990f15e4625725b124c47df65746ec249bd3e2fdf3cf9dbd458326d)
*   Vulnerability counts: 1 Critical, 16 High, 39 Medium, 111 Low (Total: 167, Risk Score: 269)
*   **Key finding**: Identical vulnerability profile to 18.2, indicating stable security posture
*   Updated all tables, charts, and analysis text

**All Supported Versions Updated (2026-02-23 patch release):**
*   PostgreSQL 18: 18.2 → **18.3**
*   PostgreSQL 17: 17.7 → **17.9**
*   PostgreSQL 16: 16.11 → **16.13**
*   PostgreSQL 15: 15.15 → **15.17**
*   PostgreSQL 14: 14.20 → **14.22**

**Document Statistics:**
*   Pages: 18 (expanded from original 17)
*   New sections: 2 major additions (Trivy techniques, Docker metadata)
*   Charts: 4 updated with latest version numbers
*   Tool versions: gemini-cli 0.28.2 → 0.30.0

This detailed process ensures that the report is accurate, up-to-date, and well-formatted, providing a clear record for future maintenance.

## 7. Quick Reference Commands

### Version Check Commands
```bash
# Check all tool versions
geol version
trivy --version
gemini --version
xelatex --version | head -1
```

### PostgreSQL Lifecycle Data
```bash
# Get lifecycle data for all PostgreSQL versions
geol product extended psql -n0
```

### Vulnerability Scanning
```bash
# Scan specific version
trivy image postgres:18.3 --format template \
  --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' \
  2>/dev/null | sort | uniq -c

# Calculate risk score with jq
trivy image postgres:18.3 --quiet --format json 2>/dev/null | \
  jq '[.Results[].Vulnerabilities[] | .Severity] | 
    (map(select(. == "CRITICAL")) | length) * 10 + 
    (map(select(. == "HIGH")) | length) * 5 + 
    (map(select(. == "MEDIUM")) | length) * 2 + 
    (map(select(. == "LOW")) | length) * 1'

# Scan all supported versions in batch
for version in 18.3 17.9 16.13 15.17 14.22; do
  echo -n "postgres:$version - "
  trivy image --format template \
    --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' \
    postgres:$version 2>/dev/null | \
    awk '{crit+=($1=="CRITICAL"); high+=($1=="HIGH"); 
         med+=($1=="MEDIUM"); low+=($1=="LOW")} 
         END {printf "C:%d H:%d M:%d L:%d Score:%d\n", 
              crit, high, med, low, (crit*10+high*5+med*2+low)}'
done
```

### LaTeX Compilation
```bash
cd /home/adriens/Github/geol-showcase/reports/postgresql
# Run 3 times to resolve all cross-references
xelatex -interaction=nonstopmode rapport_postgresql_EN.tex
xelatex -interaction=nonstopmode rapport_postgresql_EN.tex
xelatex -interaction=nonstopmode rapport_postgresql_EN.tex
```

### Verify Image Digest
```bash
# Get actual digest from pulled image
docker inspect postgres:18.3 --format='{{.RepoDigests}}'
# Or using crane
crane digest postgres:18.3
```

## 8. Future Maintenance Workflow

When new PostgreSQL versions are released:

1. **Update tool versions** (run version commands, update LaTeX lines 57, 64, 214)
2. **Get lifecycle data** (`geol product extended psql -n0`)
3. **Scan new images** with trivy for all new patch releases
4. **Calculate risk scores** using the formula
5. **Update LaTeX tables**:
   - Version lifecycle table (line ~390)
   - Vulnerability summary table (line ~333)
   - Patch comparison table (line ~747)
   - Docker digest table (line ~819)
6. **Update charts** with new version coordinates
7. **Update analysis text** to reflect new findings
8. **Compile PDF** (3 passes) and verify
9. **Update this GEMINI.md** with new version info

---

**This detailed process ensures that the report is accurate, up-to-date, and well-formatted, providing a clear record for future maintenance.**
