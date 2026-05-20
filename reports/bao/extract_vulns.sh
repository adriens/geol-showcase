#!/bin/bash
echo "Version,Critical,High,Medium,Low,Unknown,OS,App,Total"
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    critical=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$file")
    high=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$file")
    medium=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$file")
    low=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$file")
    unknown=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="UNKNOWN")] | length' "$file")
    
    os=$(jq -r '[.Results[] | select(.Class=="os-pkgs") | .Vulnerabilities[]?] | length' "$file")
    app=$(jq -r '[.Results[] | select(.Class=="lang-pkgs") | .Vulnerabilities[]?] | length' "$file")
    total=$((critical + high + medium + low + unknown))
    
    echo "$version,$critical,$high,$medium,$low,$unknown,$os,$app,$total"
  fi
done
