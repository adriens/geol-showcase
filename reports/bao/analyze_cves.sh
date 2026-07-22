#!/bin/bash
# Extract all CVEs from all versions and count occurrences
echo "CVE_ID,Count" > cve_counts.csv
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5 2.6.0 2.6.1; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    jq -r '.Results[].Vulnerabilities[]?.VulnerabilityID' "$file" 2>/dev/null
  fi
done | sort | uniq -c | sort -rn | head -20 | awk '{print $2","$1}'
