Get-ExecutionPolicy -List

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

Function Detect-Notebook {
  Param([string]$computer = "localhost")
  $isNotebook = $false

  if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}) {
    $isNotebook = $true
  }

  if(Get-WmiObject -Class win32_battery -ComputerName $computer) {
    $isNotebook = $true
  }

  $isNotebook
}

#https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
function Test-RegistryValue {
  param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Path,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Value
  )
  try {
  Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $true
  }
  catch {
    return $false
  }
}

$downloadLocation = [System.IO.Path]::GetTempPath() + "dotfiles"
#create folder in TEMP path if not exists
mkdir -Force $downloadLocation | Out-Null

Set-Location $downloadLocation

#download repo
Write-Output "[Downloading Repo ...]"
Invoke-Expression ((new-object net.webclient).downloadstring("https://raw.githubusercontent.com/DiXN/dotfiles/master/src/scripts/download-repo.ps1"))

#disable UAC
Write-Output "[Disabling UAC ...]"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value "0"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "1"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value "0"

#show file extensions and hidden files
Write-Output "[Enabling file extensions and hidden files ...]"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"

#exec powershell scripts on double click
Write-Output "[Enabling execution of powershell files on double click ...]"
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Set-ItemProperty -Path "HKCR:\Microsoft.PowerShellScript.1\Shell\open\command" -Name "(Default)" -Value "'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -noLogo -ExecutionPolicy unrestricted -file '%1'"

#enable developer mode
Write-Output "[Enabling developer mode ...]"
$registryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

if (-not(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock")) {
  New-Item -Path $registryKeyPath -ItemType Directory -Force
}

if (Test-RegistryValue -Path $registryKeyPath -Value "AllowDevelopmentWithoutDevLicense") {
  Set-ItemProperty -Path $registryKeyPath -Name "AllowDevelopmentWithoutDevLicense" -Value "1"
} else {
  New-ItemProperty -Path $registryKeyPath -Name "AllowDevelopmentWithoutDevLicense" -PropertyType DWORD -Value "1"
}

if (Test-RegistryValue -Path $registryKeyPath -Value "AllowAllTrustedApps") {
  Set-ItemProperty -Path $registryKeyPath -Name "AllowAllTrustedApps" -Value "1"
} else {
  New-ItemProperty -Path $registryKeyPath -Name "AllowAllTrustedApps" -PropertyType DWORD -Value "1"
}

#disable windows defender real time monitoring during installation
Write-Output "[Disable windows defender ...]"
Set-MpPreference -DisableRealtimeMonitoring $true

#install scoop
Write-Output "[Installing Scoop ...]"
Invoke-Expression ((new-object net.webclient).downloadstring("https://get.scoop.sh"))

scoop install git
scoop install aria2
scoop install sudo

scoop bucket add extras
scoop bucket add versions
scoop bucket add java
scoop bucket add Ash258 'https://github.com/Ash258/Scoop-Ash258.git'

scoop install dotnet-sdk

#install Chocolatey
Write-Output "[Installing Chocolatey ...]"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install dotnet-script
dotnet tool install -g dotnet-script

#check if notebook or desktop
$templatePrefix = ""

if (Detect-Notebook) {
  $templatePrefix = "notebook"
}
else {
  $templatePrefix = "desktop"
}

Write-Output "[dotfiles running on $templatePrefix ....]"

#invoke dotnet-script
Write-Output "[Installing dotfiles ...]"
dotnet script "$downloadLocation\scripts\dotnet\main.csx" -- "$downloadLocation\templates\$templatePrefix\choco.yaml" "$downloadLocation\templates\$templatePrefix\scoop.yaml" "$downloadLocation\templates\$templatePrefix\commands.yaml"
