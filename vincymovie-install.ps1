param(
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\Vincymovie\bin",
    [switch]$Force,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$Repo = "renuah1142/MovieBox-Tui"
$Exe = Join-Path $InstallDir "Vincymovie.exe"
$ReleaseTag = "vincymovie-build"

function Say($Message) { Write-Host "  > $Message" -ForegroundColor Cyan }
function Ok($Message) { Write-Host "  + $Message" -ForegroundColor Green }

if ($Uninstall) {
    if (Test-Path $Exe) { Remove-Item $Exe -Force; Ok "Vincymovie removed." } else { Write-Host "Vincymovie is not installed." }
    exit 0
}

if ((Test-Path $Exe) -and -not $Force) {
    Ok "Vincymovie is already installed at $Exe"
    Write-Host "Use -Force to reinstall."
    exit 0
}

Say "Checking the latest Vincymovie Windows build..."
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/tags/$ReleaseTag" -Headers @{ "User-Agent" = "Vincymovie-Installer" }
} catch {
    throw "The Vincymovie Windows release is not available yet. Please wait for the GitHub Actions Windows build to finish, then try again."
}
$asset = $release.assets | Where-Object { $_.name -eq "Vincymovie_Windows_x64.zip" } | Select-Object -First 1
$hashAsset = $release.assets | Where-Object { $_.name -eq "Vincymovie_Windows_x64.sha256" } | Select-Object -First 1
if (-not $asset) { throw "No Windows x64 release asset is available yet. Run the GitHub Actions Windows build first." }

$temp = Join-Path ([IO.Path]::GetTempPath()) ("vincymovie-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $temp | Out-Null
try {
    $zip = Join-Path $temp "Vincymovie_Windows_x64.zip"
    Say "Downloading Vincymovie..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -UseBasicParsing

    if ($hashAsset) {
        $expected = (Invoke-RestMethod -Uri $hashAsset.browser_download_url -Headers @{ "User-Agent" = "Vincymovie-Installer" }).Trim().Split()[0].ToUpperInvariant()
        $actual = (Get-FileHash $zip -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($expected -ne $actual) { throw "SHA256 verification failed." }
        Ok "SHA256 verified."
    }

    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Expand-Archive -Path $zip -DestinationPath $temp\app -Force
    if (-not (Test-Path "$temp\app\Vincymovie.exe")) { throw "Vincymovie.exe was not found in the package." }
    Copy-Item "$temp\app\Vincymovie.exe" $Exe -Force
    Ok "Installed Vincymovie to $Exe"
    Ok "No Rust, Cargo, or other development dependencies are required to run it."
    Write-Host ""
    Write-Host "Run: $Exe" -ForegroundColor White
} finally {
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
}
