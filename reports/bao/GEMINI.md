# OpenBao Security Report Maintenance Guidelines

This document provides the methodology and technical guidelines for the Gemini CLI Agent to update the `vulnerability_report.tex` when new versions of OpenBao are released.

## 1. Vulnerability Scanning (Trivy)

For each new version `vX.Y.Z`, run a Trivy scan in JSON format:

```bash
trivy image --format json --output openbao_vX.Y.Z.json openbao/openbao:vX.Y.Z
```

## 2. Data Extraction

### 2.1 Vulnerability Counts
Extract counts by severity to update the evolution table and chart:

```bash
jq -r '.Results[].Vulnerabilities[]?.Severity' openbao_vX.Y.Z.json | sort | uniq -c
```

### 2.2 Base Image Metadata
Identify the Alpine Linux version used:

```bash
jq -r '.Metadata.OS.Name' openbao_vX.Y.Z.json
```

## 3. Lifecycle Information (Geol)

Check for EOL dates or current version status using `geol`:

```bash
geol product openbao
```

## 4. LaTeX Document Updates

Update the following sections in `vulnerability_report.tex`:

- **`Base Image Analysis` Table:** Add the new version and its Alpine base.
- **`Vulnerability Evolution` Table:** Add the new version's counts (Critical, High, Medium, Low, Unknown).
- **`Overall Security Trend Chart` (PGFPlots):** 
    - Add the version to `symbolic x coords`.
    - Add the new data point to each `\addplot` coordinates list.
- **Title/Abstract:** Ensure the version range (e.g., `v2.4.1 to v2.5.x`) is current.

## 5. Compilation

Always compile the report using `xelatex` (twice to resolve references):

```bash
xelatex -interaction=nonstopmode vulnerability_report.tex
xelatex -interaction=nonstopmode vulnerability_report.tex
```

## 6. Consistency Rules

- **Naming Convention:** Use `openbao_vX.Y.Z.json` for scan results.
- **Chart Style:** Maintain the color scheme (Red for Critical, Orange for High, Yellow for Medium, Blue for Low).
- **Validation:** Always verify the PDF output after compilation to ensure charts and tables are correctly rendered.
