param(
    [string]$ProjectId = "gatheruni-58fa7"
)

Write-Host "Deploying Firestore rules for project: $ProjectId"

$firebase = Get-Command firebase -ErrorAction SilentlyContinue
if ($firebase) {
    Write-Host "Using global firebase CLI"
    firebase deploy --only firestore:rules --project $ProjectId
} else {
    Write-Host "Global firebase CLI not found — using npx firebase-tools"
    npx firebase-tools deploy --only firestore:rules --project $ProjectId
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Deployment failed. Check the output above for errors."
    exit $LASTEXITCODE
}

Write-Host "Firestore rules deployed."
