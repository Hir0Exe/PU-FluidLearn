# Usar disco D: para temporales de Flutter/Dart (cuando C: esta lleno).
# Ejecutar desde PowerShell:  .\scripts\flutter_use_d_temp.ps1
# Opcional: .\scripts\flutter_use_d_temp.ps1 -RunChrome

param(
    [switch]$RunChrome,
    [switch]$RunWindows
)

$dRoot = "D:\FlutterBuildTemp"
$pubDir = "D:\PubCache"

New-Item -ItemType Directory -Force -Path $dRoot | Out-Null
New-Item -ItemType Directory -Force -Path $pubDir | Out-Null

$env:TEMP = $dRoot
$env:TMP = $dRoot
$env:PUB_CACHE = $pubDir

Write-Host "TEMP/TMP -> $dRoot"
Write-Host "PUB_CACHE -> $pubDir"
Write-Host ""

$proj = Split-Path -Parent $PSScriptRoot
Set-Location $proj

if ($RunChrome) {
    flutter run -d chrome
} elseif ($RunWindows) {
    flutter run -d windows
} else {
    Write-Host "Variables listas en esta sesion. Ejemplos:"
    Write-Host "  flutter pub get"
    Write-Host "  flutter run -d chrome"
    Write-Host "  .\scripts\flutter_use_d_temp.ps1 -RunChrome"
}
