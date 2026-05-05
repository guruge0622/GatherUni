#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID=${1:-gatheruni-58fa7}

echo "Deploying Firestore rules for project: ${PROJECT_ID}"

if command -v firebase >/dev/null 2>&1; then
  echo "Using global firebase CLI"
  firebase deploy --only firestore:rules --project "${PROJECT_ID}"
else
  echo "Global firebase CLI not found — using npx firebase-tools"
  npx firebase-tools deploy --only firestore:rules --project "${PROJECT_ID}"
fi

echo "Firestore rules deployed."
