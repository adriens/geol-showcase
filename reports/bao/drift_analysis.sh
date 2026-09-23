#!/bin/bash
# CVE-database drift analysis.
#
# The scan JSONs are committed, so git history holds the SAME container image
# measured at several points in time. Comparing an image against itself across
# scan dates isolates database drift from real security change: the image is
# byte-identical, so any movement is purely newly-disclosed CVEs.
#
# The scan date is read from .CreatedAt inside each committed blob, not from
# the commit date, so a late commit of an early scan is still dated correctly.
cd "$(dirname "$0")"

VERSIONS="${*:-2.4.0 2.5.0 2.5.5 2.6.0 2.6.1}"

printf "%-7s %-12s %-8s %6s %5s %5s %5s %5s\n" IMAGE SCAN_DATE TRIVY TOTAL CRIT HIGH MED LOW
for v in $VERSIONS; do
  f="openbao_v${v}.json"
  for sha in $(git log --format='%H' -- "$f"); do
    git show "$sha:./$f" 2>/dev/null | jq -r --arg v "$v" '
      [.Results[].Vulnerabilities[]?] as $a |
      [$v, (.CreatedAt|split("T")[0]), (.Trivy.Version // "?"), ($a|length),
       ([$a[]|select(.Severity=="CRITICAL")]|length),
       ([$a[]|select(.Severity=="HIGH")]|length),
       ([$a[]|select(.Severity=="MEDIUM")]|length),
       ([$a[]|select(.Severity=="LOW")]|length)] | @tsv'
  done | sort -u -t"$(printf '\t')" -k2,2 \
       | awk -F'\t' '{printf "%-7s %-12s %-8s %6s %5s %5s %5s %5s\n",$1,$2,$3,$4,$5,$6,$7,$8}'
done
