param(
	[string]$Library = ".\bluesky_ui.lua",
	[string]$Output = ".\dist\bluesky_ui.lua",
	[switch]$Check
)

$ErrorActionPreference = "Stop"

function Resolve-OutputPath([string]$Path) {
	if (Test-Path -LiteralPath $Path) {
		return (Resolve-Path -LiteralPath $Path).Path
	}

	return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Ensure-ParentFolder([string]$Path) {
	$parent = Split-Path -Parent $Path
	if ($parent -and -not (Test-Path -LiteralPath $parent)) {
		New-Item -ItemType Directory -Path $parent | Out-Null
	}
}

$libraryPath = (Resolve-Path -LiteralPath $Library).Path
$outputPath = Resolve-OutputPath $Output
$libraryText = [System.IO.File]::ReadAllText($libraryPath).TrimEnd()

$versionMatch = [regex]::Match($libraryText, 'Bluesky\.Version\s*=\s*"([^"]+)"')
$version = if ($versionMatch.Success) { $versionMatch.Groups[1].Value } else { "unknown" }

$release = "-- Bluesky UI`r`n-- Version: $version`r`n-- Release build generated from bluesky_ui.lua.`r`n`r`n" + $libraryText + "`r`n"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
Ensure-ParentFolder $outputPath
[System.IO.File]::WriteAllText($outputPath, $release, $utf8NoBom)
Write-Host "Built pure library $Output with Bluesky UI v$version"

$checkTargets = @($Library, $Output)

if (Test-Path -LiteralPath ".\bluesky_smoke.lua") {
	$checkTargets += ".\bluesky_smoke.lua"
}

if ($Check) {
	$checker = Join-Path (Get-Location) "check-luau.cmd"
	if (Test-Path -LiteralPath $checker) {
		& $checker $checkTargets
	} else {
		Write-Warning "check-luau.cmd not found; skipped compile check."
	}
}
