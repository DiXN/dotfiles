param([string]$apiKey, [string]$platform)

$downloadLocation = [System.IO.Path]::GetTempPath() + "dotfiles"
#create folder in TEMP path if not exists
mkdir -Force $downloadLocation | Out-Null

#download DotfilesWrapper
Write-Output "Downloading DotfilesWrapper..."
Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/scripts/download-artifact.ps1" | Out-File "download-artifact.ps1"
Invoke-Expression ".\download-artifact.ps1 -apiKey $apiKey"

#extract DotfilesWrapper
Write-Output "Extracting DotfilesWrapper..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$downloadLocation\dotfiles.zip", $downloadLocation)

Remove-Item "$downloadLocation\dotfiles.zip"

#disable UAC
Write-Output 'Disabling UAC ...'
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "1"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value "0"

#show file extensions and hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"

#enable developer mode
$registryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

if (-not(Test-Path -Path $registryKeyPath)) {
    New-Item -Path $registryKeyPath -ItemType Directory -Force
}

New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
New-ItemProperty -Path $RegistryKeyPath -Name AllowAllTrustedApps -PropertyType DWORD -Value 1

#disable windows defender real time monitoring during installation
Set-MpPreference -DisableRealtimeMonitoring $true

#install Chocolatey
Write-Output "Installing Chocolatey..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))

if ($platform -eq 'notebook') {
  Write-Output "Downloading YAML files..."
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/notebook/choco.yaml" | Out-File -filepath "$downloadLocation\choco.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/notebook/commands.yaml" | Out-File "$downloadLocation\commands.yaml"
} else {
  Write-Output "Downloading YAML files..."
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/desktop/choco.yaml" | Out-File "$downloadLocation\choco.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/desktop/commands.yaml" | Out-File "$downloadLocation\commands.yaml"
}

Remove-Item download-artifact.ps1
Set-Location $downloadLocation

Write-Output "Invoking DotfilesWrapper..."
Invoke-Expression "$downloadLocation\DotfilesWrapper.exe $downloadLocation\choco.yaml $downloadLocation\commands.yaml"
