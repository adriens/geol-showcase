#!/bin/bash
# Check which versions have specific CVEs
for cve in "CVE-2026-4878" "CVE-2026-6042" "CVE-2026-40200" "CVE-2026-34986" "CVE-2026-31790"; do
  echo "=== $cve ==="
  count=0
  versions=""
  for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5; do
    file="openbao_v${version}.json"
    if [ -f "$file" ]; then
      found=$(jq -r ".Results[].Vulnerabilities[]? | select(.VulnerabilityID==\"$cve\") | .VulnerabilityID" "$file" 2>/dev/null | wc -l)
      if [ "$found" -gt 0 ]; then
        count=$((count + 1))
        if [ -z "$versions" ]; then
          versions="$version"
        else
          versions="$versions, $version"
        fi
      fi
    fi
  done
  echo "Found in $count versions: $versions"
  echo ""
done
