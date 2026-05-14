#!/usr/bin/env bash
# Set the Gherkin definition on an Xray Cloud test via GraphQL.
# Usage: echo "<gherkin>" | ./scripts/xray-set-gherkin.sh <numeric_issue_id>
# Requires: XRAY_CLIENT_ID and XRAY_CLIENT_SECRET in environment.

set -euo pipefail

ISSUE_ID="${1:?Error: numeric Jira issue ID required (e.g. 538180, not SQA-21639)}"

if [ -z "${XRAY_CLIENT_ID:-}" ] || [ -z "${XRAY_CLIENT_SECRET:-}" ]; then
  echo "Error: XRAY_CLIENT_ID and XRAY_CLIENT_SECRET must be set in environment" >&2
  exit 1
fi

GHERKIN=$(cat)

TOKEN=$(curl -sf -H "Content-Type: application/json" -X POST \
  --data "{\"client_id\": \"$XRAY_CLIENT_ID\", \"client_secret\": \"$XRAY_CLIENT_SECRET\"}" \
  https://xray.cloud.getxray.app/api/v2/authenticate | tr -d '"')

GHERKIN_JSON=$(printf '%s' "$GHERKIN" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

curl -sf -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"query\": \"mutation { updateGherkinTestDefinition(issueId: \\\"${ISSUE_ID}\\\", gherkin: ${GHERKIN_JSON}) { issueId } }\"}" \
  https://xray.cloud.getxray.app/api/v2/graphql \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
if 'errors' in d:
    print('ERROR:', d['errors'], file=sys.stderr)
    sys.exit(1)
print('OK — issueId:', d['data']['updateGherkinTestDefinition']['issueId'])
"
