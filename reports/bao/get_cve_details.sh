#!/bin/bash
for cve in "CVE-2026-4878" "CVE-2026-6042" "CVE-2026-40200" "CVE-2026-34986" "CVE-2026-31790"; do
  echo "=== $cve ==="
  jq -r ".Results[].Vulnerabilities[]? | select(.VulnerabilityID==\"$cve\") | 
    \"CVSS: \" + ((.CVSS.nvd.V3Score // .CVSS.redhat.V3Score // \"N/A\") | tostring) + \"\\n\" +
    \"Package: \" + .PkgName + \" \" + .InstalledVersion + \"\\n\" +
    \"Title: \" + (.Title // \"No title\") + \"\\n\" +
    \"Severity: \" + .Severity
  " openbao_v2.4.0.json 2>/dev/null | head -5
  echo ""
done
