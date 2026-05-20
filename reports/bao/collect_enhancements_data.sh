#!/bin/bash

echo "=== 1. Données pour graphique empilé ==="
echo "Version,Critical,High,Medium,Low"
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    critical=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$file")
    high=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$file")
    medium=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$file")
    low=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$file")
    echo "$version,$critical,$high,$medium,$low"
  fi
done

echo ""
echo "=== 2. Taux de réduction entre versions ==="
prev_total=0
prev_version=""
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    total=$(jq -r '[.Results[].Vulnerabilities[]?] | length' "$file")
    if [ "$prev_total" -ne 0 ]; then
      reduction=$(echo "scale=1; (($prev_total - $total) * 100) / $prev_total" | bc)
      echo "$prev_version → $version: ${reduction}% ($prev_total → $total)"
    fi
    prev_total=$total
    prev_version=$version
  fi
done

echo ""
echo "=== 4. Détails des top 5 CVEs persistants ==="
for cve in "CVE-2026-4878" "CVE-2026-6042" "CVE-2026-40200" "CVE-2026-34986" "CVE-2026-31790"; do
  echo ""
  echo "=== $cve ==="
  # Get details from first occurrence (2.4.0)
  jq -r ".Results[].Vulnerabilities[]? | select(.VulnerabilityID==\"$cve\") | 
    \"CVSS: \" + (.CVSS.nvd.V3Score // .CVSS.redhat.V3Score // \"N/A\" | tostring) + 
    \"\\nPackage: \" + .PkgName + 
    \"\\nTitle: \" + (.Title // \"N/A\") + 
    \"\\nDescription: \" + ((.Description // \"N/A\") | .[0:150])
  " openbao_v2.4.0.json 2>/dev/null | head -1
done

echo ""
echo "=== 5. Timeline des versions (dates de création des images) ==="
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    created=$(jq -r '.Metadata.ImageConfig.created // "N/A"' "$file")
    echo "$version: $created"
  fi
done

