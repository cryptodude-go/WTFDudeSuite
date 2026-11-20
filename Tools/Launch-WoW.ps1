[CmdletBinding()]
param([switch]$CheckOnly)

$addonRoot = Split-Path -Parent $PSScriptRoot
try {
    & (Join-Path $PSScriptRoot 'Check-GitHub.ps1') -AddonPath $addonRoot | Format-Table -AutoSize
} catch {
    Write-Warning ("GitHub check could not finish. " + $_.Exception.Message)
}
if ($CheckOnly) { return }
$clientRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $addonRoot))
$gamePath = Join-Path $clientRoot 'Wow.exe'
if (-not (Test-Path -LiteralPath $gamePath)) {
    throw "WoW was not found at $gamePath. Run this launcher from the installed WTFDudeSuite\Tools folder."
}
if (Get-Process -Name Wow -ErrorAction SilentlyContinue) {
    Write-Host 'WoW is already running. A new GitHub-check result becomes visible after /reload or the next login.'
    return
}
Start-Process -FilePath $gamePath -WorkingDirectory $clientRoot
