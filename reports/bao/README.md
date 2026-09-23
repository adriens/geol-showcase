# OpenBao Security Evolution Report

[![PDF Report](https://img.shields.io/badge/PDF-Download%20Report-red?style=for-the-badge&logo=adobe)](vulnerability_report.pdf)
[![OpenBao](https://img.shields.io/badge/OpenBao-v2.4.0--v2.7.0-blue?style=for-the-badge)](https://openbao.org/)
[![Trivy](https://img.shields.io/badge/Trivy-v0.74.0-green?style=for-the-badge)](https://trivy.dev/)

> **Comprehensive security analysis of OpenBao container images from v2.4.0 to v2.7.0**

## 📊 Executive Summary

This report provides an in-depth analysis of OpenBao's security evolution across 15 versions, demonstrating a **99.6% reduction in vulnerabilities** from the earliest to the latest version.

### Key Findings

| Metric | Value |
|--------|-------|
| **Best Version** | v2.7.0 (Security Score: 100.0/100) |
| **Worst Version** | v2.4.0/v2.4.1 (Security Score: 29.1/100) |
| **Overall Improvement** | 99.6% reduction (235 → 1 vulnerabilities) |
| **Critical Vulnerabilities** | 0 since v2.6.0 (was 9 in v2.4.0) |
| **Recommended for Production** | v2.6.3+ (Score ≥ 97.0/100) |
| **Most CVEs Fixable** | 97-99% have patches available through v2.6.2; only GO-2026-5932 (unmaintained `x/crypto/openpgp`) remains in v2.7.0, with no upstream fix |

## 🎯 What's Inside

The **17-page report** includes:

- **📈 Executive Summary Dashboard**: KPI cards with security scores (0-100 scale)
- **📊 Vulnerability Evolution Charts**: Line and stacked area charts showing trends
- **🔍 Detailed CVE Analysis**: Top 5 persistent vulnerabilities with CVSS scores
- **📅 Release Timeline**: Visualization of release cadence and improvement velocity
- **⚖️ Version-to-Version Comparison**: Reduction rates between consecutive releases
- **📋 Risk Level Matrix**: Color-coded assessment for each version
- **📖 Versioning Policy**: OpenBao's semantic versioning approach (PostgreSQL-like)
- **📉 CVE Database Drift**: The same images re-measured across 5 scan dates, separating real security work from measurement artifact

## 📸 Report Preview

The report analyzes the following OpenBao versions:

```
2.4.0 → 2.4.1 → 2.4.3 → 2.4.4 → 2.5.0 → 2.5.1 → 2.5.2 → 2.5.3 → 2.5.4 → 2.5.5
→ 2.6.0 → 2.6.1 → 2.6.2 → 2.6.3 → 2.7.0
```

### Security Score Evolution

| Version | Critical | High | Medium | Low | Total | Score/100 | Risk Level |
|---------|----------|------|--------|-----|-------|-----------|------------|
| 2.4.0   | 9        | 79   | 79     | 66  | 235   | 29.1      | 🔴 HIGH    |
| 2.5.0   | 9        | 71   | 48     | 44  | 174   | 41.5      | 🔴 HIGH    |
| 2.5.3   | 1        | 45   | 36     | 37  | 121   | 65.6      | 🟠 MEDIUM  |
| 2.5.5   | 1        | 23   | 15     | 15  | 55    | 83.0      | 🟢 LOW     |
| 2.6.1   | 0        | 20   | 13     | 13  | 47    | 86.1      | 🟢 LOW     |
| 2.6.2   | 0        | 11   | 12     | 13  | 37    | 90.8      | 🟢 LOW     |
| 2.6.3   | 0        | 5    | 2      | 1   | 9     | 97.0      | 🟢 LOW     |
| 2.7.0   | 0        | 0    | 0      | 0   | 1     | 100.0     | 🟢 LOW     |

> **Scoring:** `Score = 100 − (weighted points / 1000) × 100`, weights Critical=10, High=5, Medium=2, Low=1. The denominator is a **fixed constant**, not the worst version in the corpus — so scores are stable across editions and comparable with other products' reports. (Earlier editions normalized against the worst version, which pinned it to 0 by construction.)

> All 15 tags were rescanned in one session against a single Trivy DB (2026-09-24). Counts are **higher** than the previous edition for every version (v2.6.1: 10 → 47, v2.5.5: 15 → 55) purely because the CVE database is four months newer — no image changed. See the drift section below.

## 🛠️ Methodology

### Tools Used

- **[Trivy v0.74.0](https://trivy.dev/)**: Container vulnerability scanner
  - CVE Database updated: 2026-09-24
  - Format: JSON output for reproducibility
- **[Geol v2.21.4](https://github.com/adriens/geol)**: Product lifecycle information
- **LaTeX (XeLaTeX)**: Professional PDF report generation

### Scan Process

Each version was scanned with:

```bash
trivy image --format json --output openbao_vX.Y.Z.json openbao/openbao:X.Y.Z
```

All scan results (JSON files) are included in this repository for full transparency and reproducibility.

## 📁 Repository Structure

```
.
├── vulnerability_report.pdf       # Final report (17 pages)
├── vulnerability_report.tex       # LaTeX source
├── openbao_v*.json               # Trivy scan results (15 versions)
├── *.sh                          # Analysis scripts
├── .gitignore                    # Git ignore patterns
├── README.md                     # This file
└── CLAUDE.md                     # Maintenance guide for AI agents
```

## 🔄 Update Process

This report is maintained with the help of AI agents. See [CLAUDE.md](CLAUDE.md) for detailed maintenance instructions.

### Quick Update for New Versions

```bash
# 1. Scan new version
trivy image --format json --output openbao_vX.Y.Z.json openbao/openbao:X.Y.Z

# 2. Extract vulnerability counts
./extract_vulns.sh

# 3. Update LaTeX document (see CLAUDE.md for details)

# 4. Compile report
xelatex -interaction=nonstopmode vulnerability_report.tex
xelatex -interaction=nonstopmode vulnerability_report.tex
```

## 🔑 Key Insights

### Major Security Milestones

1. **v2.5.3 (Apr 2026)**: 27.1% reduction - Alpine 3.23.4 rebase plus a large application-layer cut
2. **v2.5.5 (Jun 2026)**: 50.9% reduction - Alpine upgrade to 3.24.1 more than halves the OS layer (50 → 20)
3. **v2.6.2 (Aug 2026)**: 21.3% reduction - Application-layer hardening halves the High count (20 → 11)
4. **v2.6.3 (Sep 2026)**: 75.7% reduction - Alpine 3.24.2 rebase **eliminates all OS-layer vulnerabilities** (20 → 0)
5. **v2.7.0 (Sep 2026)**: 88.9% reduction - Closes every outstanding OpenBao core advisory; perfect 100.0/100 score

> **v2.6.3 and v2.7.0 shipped the same day** (2026-09-23). v2.6.3 is the final 2.6-line patch carrying the Alpine rebase to users who must stay on 2.6.x; v2.7.0 opens the new minor line with the application fixes as well.

### Versioning Philosophy

OpenBao follows **Semantic Versioning** with a philosophy similar to PostgreSQL:

> "Minor releases only contain fixes for frequently-encountered bugs, low-risk fixes, security issues, and data corruption problems. The community considers performing minor upgrades to be less risky than continuing to run an old minor version."

This approach is empirically validated by our findings: **consistent minor version updates demonstrate significant vulnerability reduction without introducing breaking changes**.

## 📊 Data Transparency

All raw scan data (JSON files) are committed to this repository to ensure:

- **Reproducibility**: Data reflects CVE database state on 2026-09-24
- **Auditability**: Full traceability for compliance and security audits
- **Verifiability**: Anyone can verify the reported numbers

**Note**: CVE databases evolve daily. Rescanning the same versions at different times will yield different results. The committed JSON files preserve the historical security state — and because they're in git, the report can *measure* that drift rather than just warn about it.

### Measured Drift

Because every scan is committed, git history holds the same image measured on several dates. Run `./drift_analysis.sh` to reproduce:

| Image | Window | First | Latest | Change | Per 30 days |
|-------|--------|-------|--------|--------|-------------|
| 2.4.0 | 126 d  | 125   | 235    | +110 (+88%)  | +26.2 |
| 2.5.0 | 126 d  | 66    | 174    | +108 (+164%) | +25.7 |
| 2.5.5 | 98 d   | 9     | 55     | +46 (+511%)  | +14.1 |
| 2.6.1 | 63 d   | 10    | 47     | +37 (+370%)  | +17.6 |

None of these images was rebuilt. An unchanged OpenBao image accrues roughly **14–26 newly-disclosed findings per month**.

This matters for reading any single number. Comparing the previous edition's best version (v2.6.1 at 10) with this edition's best (v2.7.0 at 1) suggests a 9-finding gain. Scanning both on the same day shows the real figure is **46** — five times larger — with +37 of drift masking it.

## 📚 References

- [OpenBao Official Website](https://openbao.org/)
- [Trivy Documentation](https://trivy.dev/)
- [PostgreSQL Versioning Policy](https://www.postgresql.org/support/versioning/)
- [Geol Project](https://github.com/adriens/geol)

## 📝 License & Attribution

This report was generated with assistance from:
- **Claude Code**: Analysis, data extraction, and LaTeX generation
- **Trivy**: Vulnerability scanning
- **Geol**: Lifecycle information

---

**Last Updated**: 2026-09-24  
**Report Version**: v2.7.0  
**Scan Date**: 2026-09-24
