#!/usr/bin/env bash
set -euo pipefail
REPO="$HOME/traffic-monitor"
LIVE="/opt/traffic-monitor/docker"
copy() { sudo cat "$1" > "$REPO/$2"; }
echo "== Syncing live config into $REPO =="
copy "$LIVE/compose.yaml"                              "compose.yaml"
copy "$LIVE/frigate/config/config.yml"                 "docker-frigate/frigate-config.yaml"
copy "$LIVE/frigate/docker-compose-frigate.yaml"        "docker-frigate/docker-compose-frigate.yaml"
copy "$LIVE/frigate/frigate.env"                        "docker-frigate/frigate.env"
copy "$LIVE/node-red-tm/config/config.yml"               "node-red-project/config.yml"
echo "== Redacting known secrets and GPS coordinates in the copies =="
sed -i 's/^PLUS_API_KEY=".*"/PLUS_API_KEY="REDACTED_SET_LOCALLY_IN_opt_traffic-monitor"/' "$REPO/docker-frigate/frigate.env"
sed -i 's/key: ".*"/key: "REDACTED_SET_LOCALLY_IN_opt_traffic-monitor"/' "$REPO/node-red-project/config.yml"
sed -i -E 's/lat: [0-9.-]+/lat: 0.0  # REDACTED - see live config on Pi/' "$REPO/node-red-project/config.yml"
sed -i -E 's/lon: [0-9.-]+/lon: 0.0  # REDACTED - see live config on Pi/' "$REPO/node-red-project/config.yml"
echo "== Done. Reviewing what changed (nothing has been committed): =="
cd "$REPO"
git status
echo
git diff --stat
