# OpenBao Security Report Maintenance Guidelines

This document provides comprehensive methodology and technical guidelines for Claude Code to update the `vulnerability_report.tex` when new versions of OpenBao are released.

**Last Updated**: 2026-09-24 (for OpenBao v2.7.0, Trivy 0.74.0)  
**Report Features**: 17 pages with Executive Summary, Security Scores, CVE Analysis, Timeline, Drift Analysis

## 1. Vulnerability Scanning (Trivy)

> **Important (methodology):** to keep version-to-version comparisons valid,
> **rescan ALL analyzed tags in a single session against the same Trivy DB.**
> Scanning versions weeks apart introduces database drift (a version looks
> "cleaner" only because its scan predates newly disclosed CVEs). Use the
> provided `Taskfile.yml`:
>
> ```bash
> task rescan        # download DB once, then scan every tag with --skip-db-update
> task verify        # confirm all JSON share the same CreatedAt / Trivy version
> ```
>
> Note: the Docker tag has no `v` prefix (`openbao/openbao:2.4.0`) while the
> JSON output keeps it (`openbao_v2.4.0.json`).

For a single new version `vX.Y.Z`, run a Trivy scan in JSON format (then
rerun a full `task rescan` so every version uses the refreshed DB):

```bash
trivy image --format json --output openbao_vX.Y.Z.json openbao/openbao:X.Y.Z
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

### 2.3 Base OS Freshness (Latest-Alpine-at-Release-Time Check)

`geol` only exposes Alpine's **current** cycle-level metadata (`releaseDate`,
`latest`, `latestReleaseDate` per cycle, e.g. `3.22`) — it does not retain
patch-level history, so it cannot answer "what was the latest Alpine patch
*on that specific past date*?" on its own.

```bash
geol product extended alpine-linux -n 0 --json
```

To get patch-level history, cross-reference with the Docker Hub tag API,
which timestamps every `alpine:X.Y.Z` tag push:

```bash
curl -s "https://hub.docker.com/v2/repositories/library/alpine/tags?page_size=100&name=3.2" \
  | jq -r '.results[] | select(.name | test("^3\\.(2[0-4])(\\.[0-9]+)?$")) | [.name, .tag_last_pushed] | @tsv' \
  | sort -V
```

For each OpenBao image, compare its `Metadata.ImageConfig.created` timestamp
against this Alpine tag-date list: the OpenBao build "used the latest Alpine
available" if no `alpine:3.x.y` tag newer than the one it shipped had been
published before the OpenBao image's own build date. Record this as a
Yes/No column in the Base Image Analysis table (Section 4 below).

## 3. Lifecycle Information (Geol)

Check for EOL dates or current version status using `geol`:

```bash
geol product openbao
```

## 4. LaTeX Document Updates

Update the following sections in `vulnerability_report.tex`:

- **`Base Image Analysis` Table:** Add the new version, its Alpine base, and the "Latest at Release?" freshness check (§2.3).
- **`Vulnerability Evolution` Table:** Add the new version's counts (Critical, High, Medium, Low, Unknown).
- **`Overall Security Trend Chart` (PGFPlots):** 
    - Add the version to `symbolic x coords`.
    - Add the new data point to each `\addplot` coordinates list.
- **Title/Abstract:** Ensure the version range (e.g., `v2.4.0 to v2.7.0`) is current.

## 5. Compilation

Always compile the report using `xelatex` (twice to resolve references):

```bash
xelatex -interaction=nonstopmode vulnerability_report.tex
xelatex -interaction=nonstopmode vulnerability_report.tex
```

## 6. Additional Data Extraction for Enhanced Sections

### 6.1 Security Posture Scores

Calculate weighted scores for the Security Posture Score table:

```bash
./calculate_scores.sh
```

Formula: `Score = 100 - (weighted_vulns / 1000) × 100`  
Weights: Critical=10, High=5, Medium=2, Low=1

**The denominator 1000 is a FIXED CONSTANT — never derive it from the corpus.**
An earlier version used the worst version present, which pinned that version to
0 by construction, re-scaled every score whenever a version was added or the CVE
DB moved, and made cross-product comparison impossible. Risk bands are set on
the weighted scale: `>550` HIGH, `250-550` MEDIUM, `<250` LOW.

### 6.2 CVE Details

Extract detailed information for top persistent CVEs:

```bash
./get_cve_details.sh
```

Includes: CVSS scores, package names, descriptions, severity levels.

### 6.3 Release Timeline

Extract image creation dates from JSON metadata:

```bash
jq -r '.Metadata.ImageConfig.created' openbao_vX.Y.Z.json
```

### 6.4 Reduction Rates

Calculate percentage reduction between versions:

```bash
./extract_vulns.sh  # Outputs CSV with counts
```

Formula: `((prev_total - current_total) / prev_total) × 100`

## 7. LaTeX Document Updates (Comprehensive)

Update the following sections in `vulnerability_report.tex`:

### 7.1 Version References (Multiple Locations)
- **Title**: Update version range (e.g., "v2.4.0 to v2.7.0")
- **Abstract**: Update version range
- **Header (fancyhdr)**: Update version range
- **PDF Metadata**: Update title, subject keywords
- **Introduction**: Update analyzed version range
- **Tooling section**: Add new version to "Analyzed Image Tags" list

### 7.2 Executive Summary Dashboard
- **KPI Cards**: Update current counts for the newest version
- **Key Takeaways**: Update best/worst versions, percentages
- **Security Posture Score table**: Add new version row
- **Risk Level Matrix**: Add new version row with colored cells

### 7.3 Main Analysis Sections
- **Base Image Analysis Table**: Add new version + Alpine version + freshness check (§2.3)
- **Vulnerability Evolution Table**: Add new version with all severity counts
- **Overall Security Trend Chart**: 
  - Add version to `symbolic x coords`
  - Add data points to each `\addplot` (Critical, High, Medium, Low)
- **Stacked Area Chart**: Add data points to all four layers
- **Reduction Rate Table**: Add new transition row (e.g., "2.6.3 → 2.7.0")

### 7.4 Deep Analysis Sections
- **OS vs. Application Table**: Add new version (OS count, App count, Total)
- **Fixable Vulnerabilities Table**: Add new version
- **Top Recurring CVEs**: Update if new persistent CVEs appear
- **Detailed CVE Analysis**: Update if CVE landscape changes
- **Release Timeline Table**: Add new version with date and interval

### 7.4b Drift Analysis (Section "Measuring CVE Database Drift")
Because scan JSONs are committed, `git log` holds the same image measured on
several dates. Run `./drift_analysis.sh` after a rescan and refresh:
- The per-scan-date table and the multi-line drift chart
- The drift-magnitude table (window, first, latest, change, per-30-days)
- The decomposition: naive cross-edition delta = real improvement + drift.
  Compute "real" by scanning both versions on the SAME date; compute "drift"
  by comparing one image against itself across dates.

### 7.5 Conclusion
- Update "latest version" reference
- Update overall statistics if significant

## 8. Compilation & Validation

Always compile twice to resolve all references:

```bash
xelatex -interaction=nonstopmode vulnerability_report.tex
xelatex -interaction=nonstopmode vulnerability_report.tex
```

### Validation Checklist
- [ ] PDF generated without errors (check file size ~100 KB)
- [ ] All charts render correctly
- [ ] All tables have correct data
- [ ] Version numbers consistent throughout
- [ ] Executive Summary KPIs match detailed tables
- [ ] Security scores calculated correctly
- [ ] Release timeline dates accurate
- [ ] Hyperlinks work (Table of Contents, URLs)

## 9. Git Workflow

### 9.1 Add Files
```bash
git add vulnerability_report.tex
git add vulnerability_report.pdf
git add openbao_vX.Y.Z.json  # New scan result
git add *.sh  # If scripts were modified
```

### 9.2 Commit Message Template
```
feat(bao): Update OpenBao security report to vX.Y.Z

- Add OpenBao vX.Y.Z security scan results
- Rescan all versions with updated CVE database (Trivy vX.Y.Z, DB YYYY-MM-DD)
- Update vulnerability data (v2.4.0: N vulns, vX.Y.Z: M vulns)

Key findings:
- Overall improvement: X.X% vulnerability reduction
- New version score: XX.X/100
- [Notable changes]

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```

### 9.3 Push
```bash
git push origin main
```

## 10. Available Scripts

All scripts are in the same directory:

| Script | Purpose |
|--------|---------|
| `extract_vulns.sh` | Extract vulnerability counts from all JSON files |
| `analyze_cves.sh` | Identify top recurring CVEs across versions |
| `calculate_scores.sh` | Calculate security posture scores (0-100) |
| `check_cve_versions.sh` | Check which versions contain specific CVEs |
| `collect_enhancements_data.sh` | Collect data for all enhancement sections |
| `get_cve_details.sh` | Extract detailed CVE information (CVSS, packages) |
| `drift_analysis.sh` | Re-read committed scans from git history to measure CVE DB drift |

## 11. Consistency Rules

- **Version list lives in 4 places** — keep them in sync when adding a release:
  `Taskfile.yml` (`VERSIONS`), the `for version in ...` loops in the `*.sh`
  scripts, the report's "Analyzed Image Tags" list, and every table/chart.
- **Naming Convention**: Use `openbao_vX.Y.Z.json` for scan results
- **Color Scheme**: 
  - Critical: Dark Red (#8B0000)
  - High: Dark Orange (#E65100)
  - Medium: Amber (#FFB300)
  - Low: Blue (#1976D2)
  - Unknown: Grey (#757575)
- **Trivy Version**: Always document the Trivy version used
- **CVE Database Date**: Always note the CVE database update date
- **Validation**: Verify PDF output, especially charts and colored tables

## 12. Common Pitfalls

1. **Forgetting to update symbolic x coords**: Charts won't render properly
2. **Mismatched data**: Ensure Executive Summary matches detailed tables
3. **Single compilation**: Always compile twice for cross-references
4. **Ignoring .gitignore**: Don't commit .aux, .log, .out files
5. **Base image not updated**: Check if Alpine version changed
6. **CVE database drift**: Note that rescanning produces different results over time.
   This is not hypothetical: the 2026-09-24 rescan raised *every* version's count
   against the previously published figures (v2.6.1: 10 → 47, v2.5.5: 15 → 55)
   with no image change. Always restate counts alongside the DB date.
7. **Same-day releases collide in charts**: v2.6.3 and v2.7.0 both shipped
   2026-09-23. `symbolic x coords` keys must be unique — use braced, qualified
   labels such as `{Sep-23 v2.6.3},{Sep-23 v2.7.0}`.
8. **Don't truncate `\end{document}`**: when replacing the trailing Conclusion
   section programmatically, slice to the `\end{document}` marker, not to EOF.

## 13. Report Sections Overview

Current report structure (14 pages):

1. **Title & Abstract** (1 page)
2. **Executive Summary** (2 pages)
   - KPI Dashboard
   - Key Takeaways
   - Security Posture Scores
   - Risk Level Matrix
3. **Introduction & Tooling** (1 page)
4. **Base Images** (1 page)
5. **Security Evolution** (2 pages)
   - Tables and Charts
   - Stacked Area Chart
   - Reduction Rates
6. **Deep Security Insights** (2 pages)
   - OS vs App vulnerabilities
   - Fixable analysis
   - Top CVEs with details
   - Release Timeline
7. **Glossary & Conclusion** (2 pages)

## 14. Future Enhancements Ideas

- Add exploitability context (EPSS scores, reachability, distro-vs-NVD severity
  disagreements -- e.g. CVE-2026-14457 is LOW per Alpine but CVSS 7.5 per NVD)
- Add trend prediction for next versions
- Compare with other secret management tools
- Add cost-of-vulnerability metrics
- Generate machine-readable SBOM output
- Automate with GitHub Actions
