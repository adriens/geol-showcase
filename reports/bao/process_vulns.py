import json
import collections

versions = ["2.4.1", "2.4.3", "2.4.4", "2.5.0", "2.5.1", "2.5.2", "2.5.3"]
all_cves = collections.defaultdict(set) # CVE -> set of versions it appears in
results = {}

for v in versions:
    try:
        with open(f"openbao_{v}.json", "r") as f:
            data = json.load(f)
            
            os_vulns = 0
            app_vulns = 0
            fixable = 0
            total = 0
            
            for res in data.get("Results", []):
                vulnerabilities = res.get("Vulnerabilities", [])
                count = len(vulnerabilities)
                total += count
                
                if res.get("Type") == "alpine":
                    os_vulns += count
                elif res.get("Type") in ["gobinary", "go"]:
                    app_vulns += count
                    
                for vuln in vulnerabilities:
                    vid = vuln.get("VulnerabilityID")
                    if vid:
                        all_cves[vid].add(v)
                    if vuln.get("FixedVersion"):
                        fixable += 1
            
            results[v] = {
                "os": os_vulns,
                "app": app_vulns,
                "fixable": fixable,
                "total": total
            }
    except FileNotFoundError:
        print(f"File openbao_{v}.json not found")

print("=== STATS BY VERSION ===")
for v in versions:
    if v in results:
        res = results[v]
        print(f"{v}: OS={res['os']}, App={res['app']}, Fixable={res['fixable']}, Total={res['total']}")

print("\n=== TOP 5 CVEs ===")
# Sort by number of versions it appears in
sorted_cves = sorted(all_cves.items(), key=lambda x: len(x[1]), reverse=True)
for cve, v_set in sorted_cves[:5]:
    print(f"{cve}: {len(v_set)} releases ({', '.join(sorted(list(v_set)))})")
