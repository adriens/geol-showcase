#!/bin/bash

echo "=== Security Posture Scores ==="
echo "Version,Critical,High,Medium,Low,Total,WeightedScore,NormalizedScore"

max_weighted=0
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5 2.6.0; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    critical=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$file")
    high=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$file")
    medium=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$file")
    low=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$file")
    total=$((critical + high + medium + low))
    
    # Weighted score: Critical=10, High=5, Medium=2, Low=1
    weighted=$((critical * 10 + high * 5 + medium * 2 + low * 1))
    
    if [ $weighted -gt $max_weighted ]; then
      max_weighted=$weighted
    fi
    
    echo "$version,$critical,$high,$medium,$low,$total,$weighted,TBD"
  fi
done

echo ""
echo "Max weighted score: $max_weighted"
echo ""
echo "=== Normalized Scores (0-100) ==="
for version in 2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5 2.6.0; do
  file="openbao_v${version}.json"
  if [ -f "$file" ]; then
    critical=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$file")
    high=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$file")
    medium=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$file")
    low=$(jq -r '[.Results[].Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$file")
    
    weighted=$((critical * 10 + high * 5 + medium * 2 + low * 1))
    normalized=$(echo "scale=1; 100 - ($weighted * 100 / $max_weighted)" | bc)
    
    echo "$version: Score $normalized/100 (weighted: $weighted)"
  fi
done

