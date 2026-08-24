# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import subprocess
import csv
import json
import datetime
import os
import sys

# Configuration
HISTORY_DIR = "data"
HISTORY_FILE = os.path.join(HISTORY_DIR, "vulnerability_history.csv")
# Default images to track
DEFAULT_IMAGES = ["postgres:18.6", "postgres:17.11", "postgres:16.15", "postgres:15.19", "postgres:14.24"]

def get_trivy_data(image_tag):
    """Executes trivy and returns severity counts and risk score."""
    print(f"🔍 Scanning {image_tag}...")
    try:
        cmd = ["trivy", "image", "--quiet", "--format", "json", image_tag]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error scanning {image_tag}: {e.stderr}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        return None

    counts = {"CRITICAL": 0, "HIGH": 0, "MEDIUM": 0, "LOW": 0}
    for report in data.get("Results", []):
        for vuln in report.get("Vulnerabilities", []):
            severity = vuln.get("Severity")
            if severity in counts:
                counts[severity] += 1
                
    # Standard formula: 10*C + 5*H + 2*M + 1*L
    risk_score = (counts["CRITICAL"] * 10 + counts["HIGH"] * 5 + 
                  counts["MEDIUM"] * 2 + counts["LOW"] * 1)
    
    return {
        "tag": image_tag,
        "critical": counts["CRITICAL"],
        "high": counts["HIGH"],
        "medium": counts["MEDIUM"],
        "low": counts["LOW"],
        "score": risk_score
    }

def update_csv(data_list):
    """Updates the CSV file with new data."""
    os.makedirs(HISTORY_DIR, exist_ok=True)
    file_exists = os.path.isfile(HISTORY_FILE)
    date_str = datetime.date.today().isoformat()
    
    with open(HISTORY_FILE, mode='a', newline='') as f:
        writer = csv.writer(f)
        if not file_exists:
            writer.writerow(["date", "tag", "critical", "high", "medium", "low", "score"])
        
        for data in data_list:
            writer.writerow([date_str, data["tag"], data["critical"], 
                             data["high"], data["medium"], data["low"], data["score"]])
    print(f"✅ History updated in {HISTORY_FILE}")

if __name__ == "__main__":
    images = sys.argv[1:] if len(sys.argv) > 1 else DEFAULT_IMAGES
    results = [get_trivy_data(img) for img in images]
    results = [r for r in results if r] # Filter None
    if results:
        update_csv(results)
