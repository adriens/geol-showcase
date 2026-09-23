#!/bin/bash
# Security Posture Score.
#
# Score = 100 - (weighted / MAX_WEIGHTED) * 100     [clamped at 0]
# Weights: Critical=10, High=5, Medium=2, Low=1
#
# MAX_WEIGHTED is a FIXED CONSTANT, deliberately *not* derived from the corpus.
# An earlier version of this script used the worst version present as the
# denominator, which meant (a) the worst version always scored exactly 0 by
# construction, (b) every score silently re-scaled whenever a version was
# added or the CVE database changed, and (c) scores could not be compared
# against other products' reports. A fixed reference ceiling fixes all three.
MAX_WEIGHTED=1000

VERSIONS="2.4.0 2.4.1 2.4.3 2.4.4 2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5 2.6.0 2.6.1 2.6.2 2.6.3 2.7.0"

# Risk bands, expressed on the weighted scale (round numbers by design):
#   weighted > 550  -> HIGH    (score < 45)
#   weighted 250-550-> MEDIUM  (score 45-75)
#   weighted < 250  -> LOW     (score > 75)
band() {
  if   [ "$1" -gt 550 ]; then echo "HIGH"
  elif [ "$1" -ge 250 ]; then echo "MEDIUM"
  else echo "LOW"; fi
}

echo "Version,Critical,High,Medium,Low,Total,Weighted,Score,Risk"
for version in $VERSIONS; do
  file="openbao_v${version}.json"
  [ -f "$file" ] || continue
  read c h m l <<<"$(jq -r '
    [.Results[].Vulnerabilities[]?] as $a |
    [ ([$a[]|select(.Severity=="CRITICAL")]|length),
      ([$a[]|select(.Severity=="HIGH")]|length),
      ([$a[]|select(.Severity=="MEDIUM")]|length),
      ([$a[]|select(.Severity=="LOW")]|length) ] | @tsv' "$file")"
  weighted=$((c * 10 + h * 5 + m * 2 + l))
  score=$(echo "scale=1; s=100 - ($weighted * 100 / $MAX_WEIGHTED); if (s<0) 0 else s" | bc)
  echo "$version,$c,$h,$m,$l,$((c+h+m+l)),$weighted,$score,$(band $weighted)"
done

echo
echo "Fixed reference ceiling: $MAX_WEIGHTED weighted points = score 0"
