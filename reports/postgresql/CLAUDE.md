# PostgreSQL Report Update Process (Automated by Claude Code)

**Last Updated**: August 24, 2026
**Report Version**: PostgreSQL 18.6 Analysis
**Tool Versions**: geol 2.21.0, trivy 0.74.0, skopeo 1.24.0, Claude Code (Claude Sonnet 5)

This document outlines the steps taken by Claude Code to update the PostgreSQL security analysis report (`rapport_postgresql_EN.tex`). This process can be replicated for future updates to new PostgreSQL versions. This file replaces the earlier `GEMINI.md`, which documented the same workflow when it was run via Gemini CLI.

## 1. Tool Identification and Versioning ⚠️ CRITICAL STEP

**IMPORTANT**: Always verify and update tool versions at the start of any report update. Tool versions **MUST** be retrieved from the current shell environment, not hardcoded or assumed.

### Commands to Run (DO NOT SKIP):

1. **`geol`**: Run `geol version` to get the current version
   - Update in LaTeX: `\subsection{\texttt{geol}: The Lifecycle Guardian}` and the footer/one-pager
2. **`trivy`**: Run `trivy --version` to get the current version (also note Vulnerability DB version)
   - Update in LaTeX: `\subsection{\texttt{trivy}: The Vulnerability Scanner}` and the footer/one-pager
3. **`skopeo`**: Run `skopeo --version` to get the current version
   - Update in LaTeX: `\subsection{\texttt{skopeo}: Remote Image Inspector}` and the footer/one-pager
4. **`xelatex`**: Run `xelatex --version | head -1` to get the current version
   - Update in LaTeX: `\subsection{\LaTeX{}: Report Generator}` (if mentioned)

### Verification Checklist:

- [ ] Run all four version commands
- [ ] Update LaTeX document with actual versions (title/author, footer x2, tool subsections, executive one-pager)
- [ ] Build PDF to verify changes compile
- [ ] Verify versions appear correctly in the generated PDF

## 2. PostgreSQL Lifecycle Data Retrieval (`geol`)

*   `geol product extended psql -n0`

This gives release dates, latest patch versions, latest release dates, and EOL dates for all PostgreSQL cycles. Trust this output as the source of record for the Lifecycle table (Section 5.1) — don't override its dates with dates found elsewhere (e.g. news articles), even if they differ by a day or two.

## 3. Vulnerability Analysis (`trivy`)

`trivy` works without a Docker daemon — it falls back to pulling directly from the registry (`remote` mode) when no `docker`/`containerd`/`podman` socket is available.

*   **Scanned Versions**: use the exact patch tags reported by `geol` for supported majors (e.g. `postgres:18.6`, `postgres:17.11`, ...) and for EOL majors 13/12/9.6. **Caveat**: for very old EOL branches (10, 11), Docker Hub may have stopped publishing images before the branch's actual final patch. Verify with:
    ```
    skopeo list-tags docker://docker.io/library/postgres | jq -r '.Tags[]' | grep '^11\.'
    ```
    As of this update, `postgres:11.22` and `postgres:10.23` (the true upstream-latest per `geol`) do **not** exist on Docker Hub; the last published tags are `11.16` and `10.21`. Use those for scanning and label them clearly in the report (with a footnote explaining the discrepancy) rather than silently mislabeling the scan as the upstream-latest patch.
*   **Command**: `trivy image --format template --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' postgres:TAG 2>/dev/null | sort | uniq -c`
*   **Important**: rescan the *entire* 18.x lineage (18.0 through current), not just the newest tag. Docker Hub does not rebuild superseded minor-version tags, so an old tag's vulnerability count grows over time even though the image digest never changes (its base OS packages fall further behind). This is the key finding driving Section 5.7/5.8 — check with `trivy image --format json postgres:TAG | jq -r '.Results[] | select(.Type=="debian" or .Type=="alpine") | .Target'` to see which Debian/Alpine point release each tag is currently built on.
*   **Watch for out-of-band releases**: check whether every expected patch number actually exists before assuming a linear sequence (e.g. `postgres:18.5` was skipped entirely in Aug 2026 due to a post-wrap regression — verify against the official postgresql.org announcement, not just the tag list, before writing a note about it).

## 4. Historical Trend Data (`src/update_history.py`)

`DEFAULT_IMAGES` in this script must be kept in sync with the current supported patch tags. Run:
```
task update-history          # appends today's scan for the 5 default (currently supported) images
uv run src/update_history.py postgres:18.0 postgres:18.1 postgres:18.2 postgres:18.3   # optional: refresh older 18.x history points for Section 5.8
```
This appends rows to `data/vulnerability_history.csv`, consumed by the "Risk Score Evolution" chart (Figure 6). The script has no dedup logic — re-running it for the same day/tag adds duplicate rows; this is harmless for the chart (duplicate points at the same x,y don't change its shape) but keep it in mind if the CSV is ever used elsewhere.

## 5. LaTeX Report Updates — Checklist

Every location that embeds numbers must be updated together; grep the file after editing to catch anything stale (e.g. `grep -n "18\.4\|<old scores>"`):

*   Title/author/footer (x2) and Executive One-Pager (versions, CVE counts, risk scores, tools-used line)
*   Section 1 Executive Summary bullets (must **recompute**, not just copy old ratios — e.g. a "2-10× more vulnerabilities" claim can become false if a base-image change hits supported versions harder than old EOL ones; verify every qualitative claim against the actual numbers, not just the numbers themselves)
*   Section 2 tool subsections
*   Section 4.1 Trivy Scanning Techniques inline examples (keep them referencing the current latest tag)
*   Table \ref{tab:geol} (Lifecycle), Table \ref{tab:trivy} (Vulnerability Summary + footnote for unavailable EOL tags)
*   Figures \ref{fig:vuln-chart}, \ref{fig:risk-score} (symbolic coords + all data points + ymax)
*   Table \ref{tab:cve-examples} — pull *real* current critical CVE IDs via `trivy image --format json postgres:12.X | jq` rather than reusing old ones (CVE numbering rolls over year to year)
*   \ref{fig:timeline} "Today" marker (compute fractional year: day-of-year / 365)
*   \ref{fig:heatmap} colorbar `point meta max` (recompute — it's the max single-cell value across the whole matrix, not a fixed constant) + all matrix values + node labels
*   Section 5.6 Cost-Benefit table
*   Section 5.7 Patch Comparison table/figure/analysis (Table \ref{tab:trivy-compare}, Figure \ref{fig:vuln-chart-18.x}) — **rescan all historical 18.x tags**, don't reuse old scan results, since they silently drift (see Section 3 above)
*   Section 5.8 Historical trend chart `ymax` and threshold-line end date
*   Section 5.9 Docker Image Metadata (digests via `skopeo inspect docker://docker.io/library/postgres:TAG | jq -r .Digest`, truncated as `first8...last6hex`)
*   Section 6.1 Migration Impact Before/After table
*   Section 6.3/6.2 Long-Term Strategy and Immediate Actions bullets (same "recompute claims" warning as Section 1)
*   Section 7 Summary and conclusion (same warning)
*   Section 8 Resources — link to the current release announcement on postgresql.org

## 6. Character Encoding Warnings

`xelatex` with `lmodern`/T1 encoding cannot render emoji (⚠️💡📊📈✓✗) or the Unicode arrow `→`/em-dash `—` typed directly as UTF-8 — they silently vanish from the PDF instead of erroring. This is a long-standing cosmetic issue for the emoji in `tcolorbox` titles (kept for visual style, low priority to fix). **However**, any `→` or `—` typed in body text as a raw Unicode character WILL silently disappear — always use `$\rightarrow$` and `---` (LaTeX's em-dash ligature) instead. After every edit pass, grep the file for stray `—` and bare `→` outside math mode:
```
grep -n "—" rapport_postgresql_EN.tex
grep -n "→" rapport_postgresql_EN.tex   # check each hit is inside $...$ or a \rightarrow macro
```

## 7. Build & Verify

```bash
task build       # xelatex x2, cleans aux/log/out/toc
task to-jpeg      # renders dist/img/*.jpg for visual review
```
Always render the PDF to JPEG and visually inspect at least: title page, executive one-pager, main vulnerability table, both bar charts, the heat map, the patch-comparison table/chart, and the historical trend chart. `grep -i "missing character\|! LaTeX Error"` on the build log — missing-character warnings for the known emoji/symbols are expected and acceptable, but any new one (e.g. from a freshly typed em-dash or arrow) must be fixed, not ignored.

## Quick Reference Commands

```bash
# Tool versions
geol version
trivy --version
skopeo --version
xelatex --version | head -1

# Lifecycle data
geol product extended psql -n0

# Vulnerability scan (single version)
trivy image postgres:18.6 --format template \
  --template '{{- range . -}}{{- range .Vulnerabilities -}}{{ .Severity }}{{ "\n" }}{{- end -}}{{- end -}}' \
  2>/dev/null | sort | uniq -c

# Verify digest
skopeo inspect docker://docker.io/library/postgres:18.6 | jq -r '.Digest'

# Check which Docker Hub tags actually exist for an old EOL branch
skopeo list-tags docker://docker.io/library/postgres | jq -r '.Tags[]' | grep '^11\.'

# Build
task build
```
