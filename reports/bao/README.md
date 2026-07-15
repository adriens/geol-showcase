# OpenBao Security Evolution Report

[![PDF Report](https://img.shields.io/badge/PDF-Download%20Report-red?style=for-the-badge&logo=adobe)](vulnerability_report.pdf)
[![OpenBao](https://img.shields.io/badge/OpenBao-v2.4.0--v2.6.0-blue?style=for-the-badge)](https://openbao.org/)
[![Trivy](https://img.shields.io/badge/Trivy-v0.72.0-green?style=for-the-badge)](https://trivy.dev/)

> **Comprehensive security analysis of OpenBao container images from v2.4.0 to v2.6.0**

## 📊 Executive Summary

This report provides an in-depth analysis of OpenBao's security evolution across 11 versions, demonstrating a **94.3% reduction in vulnerabilities** from the earliest to the latest version.

### Key Findings

| Metric | Value |
|--------|-------|
| **Best Version** | v2.6.0 (Security Score: 94.7/100) |
| **Worst Version** | v2.4.0/v2.4.1 (Security Score: 0/100) |
| **Overall Improvement** | 94.3% reduction (195 → 11 vulnerabilities) |
| **Critical Vulnerabilities** | 0 since v2.5.3 (was 8 in v2.4.0) |
| **Recommended for Production** | v2.5.5+ (Score ≥ 93.4/100) |
| **Most CVEs Fixable** | 90-99% have patches available (1 unfixed Go module advisory since v2.5.5) |

## 🎯 What's Inside

The **12-page report** includes:

- **📈 Executive Summary Dashboard**: KPI cards with security scores (0-100 scale)
- **📊 Vulnerability Evolution Charts**: Line and stacked area charts showing trends
- **🔍 Detailed CVE Analysis**: Top 5 persistent vulnerabilities with CVSS scores
- **📅 Release Timeline**: Visualization of release cadence and improvement velocity
- **⚖️ Version-to-Version Comparison**: Reduction rates between consecutive releases
- **📋 Risk Level Matrix**: Color-coded assessment for each version
- **📖 Versioning Policy**: OpenBao's semantic versioning approach (PostgreSQL-like)

## 📸 Report Preview

The report analyzes the following OpenBao versions:

```
2.4.0 → 2.4.1 → 2.4.3 → 2.4.4 → 2.5.0 → 2.5.1 → 2.5.2 → 2.5.3 → 2.5.4 → 2.5.5 → 2.6.0
```

### Security Score Evolution

| Version | Critical | High | Medium | Low | Total | Score/100 | Risk Level |
|---------|----------|------|--------|-----|-------|-----------|------------|
| 2.4.0   | 8        | 63   | 68     | 52  | 191   | 0.0       | 🔴 HIGH    |
| 2.5.0   | 8        | 54   | 37     | 30  | 129   | 22.2      | 🟠 MEDIUM  |
| 2.5.3   | 0        | 28   | 25     | 23  | 76    | 63.5      | 🟠 MEDIUM  |
| 2.5.4   | 0        | 22   | 22     | 23  | 67    | 69.7      | 🟠 MEDIUM  |
| 2.5.5   | 0        | 6    | 4      | 1   | 11    | 93.4      | 🟢 LOW     |
| 2.6.0   | 0        | 5    | 3      | 0   | 8     | 94.7      | 🟢 LOW     |

> Scores were recalculated during the v2.6.0 homogeneous rescan (fresh Trivy DB); v2.5.3/v2.5.4 dropped out of the LOW band as newly-disclosed CVEs were found to retroactively affect them.

## 🛠️ Methodology

### Tools Used

- **[Trivy v0.72.0](https://trivy.dev/)**: Container vulnerability scanner
  - CVE Database updated: 2026-07-16
  - Format: JSON output for reproducibility
- **[Geol v2.14.0](https://github.com/adriens/geol)**: Product lifecycle information
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
├── vulnerability_report.pdf       # Final report (12 pages)
├── vulnerability_report.tex       # LaTeX source
├── openbao_v*.json               # Trivy scan results (11 versions)
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

1. **v2.5.0 (Feb 2026)**: 22.6% reduction - Alpine upgrade from 3.22 to 3.23
2. **v2.5.3 (Apr 2026)**: 36.0% reduction - Substantial cut across OS and application layers
3. **v2.5.5 (Jun 2026)**: 80.2% reduction - Alpine upgrade to 3.24.1 eliminates all OS-layer vulnerabilities
4. **v2.6.0 (Jul 2026)**: 21.4% reduction - Further application-layer hardening, lowest total to date

### Versioning Philosophy

OpenBao follows **Semantic Versioning** with a philosophy similar to PostgreSQL:

> "Minor releases only contain fixes for frequently-encountered bugs, low-risk fixes, security issues, and data corruption problems. The community considers performing minor upgrades to be less risky than continuing to run an old minor version."

This approach is empirically validated by our findings: **consistent minor version updates demonstrate significant vulnerability reduction without introducing breaking changes**.

## 📊 Data Transparency

All raw scan data (JSON files) are committed to this repository to ensure:

- **Reproducibility**: Data reflects CVE database state on 2026-07-16
- **Auditability**: Full traceability for compliance and security audits
- **Verifiability**: Anyone can verify the reported numbers

**Note**: CVE databases evolve daily. Rescanning the same versions at different times will yield different results. The committed JSON files preserve the historical security state.

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

**Last Updated**: 2026-07-16  
**Report Version**: v2.6.0  
**Scan Date**: 2026-07-16
