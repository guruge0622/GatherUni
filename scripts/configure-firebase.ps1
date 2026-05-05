<#
Helper script to prepare and run FlutterFire configuration for this project.

Usage (PowerShell):
  1. Open PowerShell and run: .\scripts\configure-firebase.ps1
  2. Follow prompts (you must be logged into Firebase via `firebase login`)

This script will:
  - Ensure FlutterFire CLI is activated via `dart pub global activate flutterfire_cli`
  - Add Pub cache bin to PATH for this session
  - Run `flutterfire configure --project gatheruni-58fa7`
#>

Write-Host "Starting Firebase configuration for GatherUni (project: gatheruni-58fa7)"

# Ensure flutter is available
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Warning "Flutter not found in PATH. Make sure Flutter SDK is installed and 'flutter' is on PATH."
}

# Activate FlutterFire CLI
Write-Host "Activating FlutterFire CLI (dart pub global activate flutterfire_cli)..."
dart pub global activate flutterfire_cli

# Temporarily add pub cache bin to PATH for this session if needed
$pubBin = "$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $pubBin })) {
  $env:PATH = "$env:PATH;$pubBin"
  Write-Host "Temporarily added $pubBin to PATH for this session"
}

Write-Host "Running: flutterfire configure --project gatheruni-58fa7"
flutterfire configure --project gatheruni-58fa7

Write-Host "If configuration completed, check android/app/google-services.json and ios/Runner/GoogleService-Info.plist"
