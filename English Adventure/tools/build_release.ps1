param(
    [ValidateSet("windows", "android_apk", "android_aab", "web", "all")]
    [string]$Target = "windows",
    [string]$GodotExe = "godot",
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$VersionMeta = Get-Content "data/release/version.json" -Raw | ConvertFrom-Json
$Version = $VersionMeta.version
$BuildNum = $VersionMeta.build_number
Write-Host "=== English Adventure Release Builder v$Version (Build $BuildNum) ==="

if (-not $SkipValidation) {
    $validators = @(
        "tests/content_validation/validate_prompt_02.py",
        "tests/content_validation/validate_prompt_03.py",
        "tests/content_validation/validate_prompt_04.py",
        "tests/content_validation/validate_prompt_05.py",
        "tests/content_validation/validate_prompt_06.py",
        "tests/content_validation/validate_prompt_07.py",
        "tests/content_validation/validate_prompt_08.py",
        "tests/content_validation/validate_prompt_09.py",
        "tests/content_validation/validate_prompt_10.py",
        "tests/content_validation/validate_3d_visual_direction.py",
        "tests/integration/run_p9_content_tests.py"
    )
    foreach ($v in $validators) {
        Write-Host "Validating $v ..."
        python $v
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Validation failed at $v"
            exit $LASTEXITCODE
        }
    }
}

$godotCmd = Get-Command $GodotExe -ErrorAction SilentlyContinue
if (-not $godotCmd) {
    Write-Error "Godot 4.3 CLI ('$GodotExe') is NOT installed or not in PATH. Install Godot 4.3 Standard + Export Templates before exporting binaries."
    exit 1
}

Write-Host "Importing Godot resources..."
& $godotCmd.Source --headless --import
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

function Export-Target([string]$PresetName, [string]$OutPath) {
    $outDir = Split-Path -Parent $OutPath
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    Write-Host "Exporting '$PresetName' -> $OutPath ..."
    & $godotCmd.Source --headless --verbose --export-release $PresetName $OutPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Godot export failed for '$PresetName'"
        exit $LASTEXITCODE
    }
    if (-not (Test-Path $OutPath)) {
        Write-Error "Expected build artifact missing: $OutPath"
        exit 1
    }
    $sizeBytes = (Get-Item $OutPath).Length
    if ($sizeBytes -le 0) {
        Write-Error "Build artifact is empty (0 bytes): $OutPath"
        exit 1
    }
    Write-Host "Verified artifact: $OutPath ($sizeBytes bytes)"
}

if ($Target -in @("windows", "all")) {
    Export-Target "Windows Desktop" "builds/windows/EnglishAdventure.exe"
    $zipPath = "builds/EnglishAdventure-v$Version-windows-x64.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path "builds/windows/*" -DestinationPath $zipPath
    $hash = (Get-FileHash $zipPath -Algorithm SHA256).Hash
    Set-Content -Path "$zipPath.sha256" -Value "$hash  $(Split-Path -Leaf $zipPath)"
    Write-Host "Created Windows portable ZIP: $zipPath (SHA256: $hash)"
}

if ($Target -in @("android_apk", "all")) {
    Export-Target "Android" "builds/android/EnglishAdventure.apk"
}

if ($Target -in @("android_aab", "all")) {
    Export-Target "Android AAB" "builds/android/EnglishAdventure.aab"
}

if ($Target -in @("web", "all")) {
    Export-Target "Web" "builds/web/index.html"
}

Write-Host "=== Release Build Pipeline Finished ==="
