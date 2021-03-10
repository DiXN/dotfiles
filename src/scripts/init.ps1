param (
  [string]$platform
)

#Requires -RunAsAdministrator
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

Function Has-Battery {
  Param([string]$computer = "localhost")

  if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}) {
    return $true
  }

  if(Get-WmiObject -Class win32_battery -ComputerName $computer) {
    return $true
  }

  return $false
}

#check platform
$templatePrefix = ""

if ([string]::IsNullOrEmpty($platform)) {
  if (Has-Battery) {
    $templatePrefix = "notebook"
  } else {
    $templatePrefix = "desktop"
  }
} else {
  $templatePrefix = $platform
}

Write-Output "[dotfiles running on $templatePrefix ...]"

if (${env:CI} -ne 'true') {
  $Credentials = Get-Credential admin
  $Credentials.Password | ConvertFrom-SecureString | Set-Content credential.txt
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}

Get-ExecutionPolicy -List

$downloadLocation = [System.IO.Path]::GetTempPath() + "dotfiles"
#create folder in TEMP path if not exists
mkdir -Force $downloadLocation | Out-Null

Set-Location $downloadLocation

#download repo
Write-Output "[Downloading Repo ...]"
Invoke-Expression ((new-object net.webclient).downloadstring("https://raw.githubusercontent.com/DiXN/dotfiles/master/src/scripts/download-repo.ps1"))

#configure settings
Write-Output "[Configure Settings ...]"
Invoke-Expression ((new-object net.webclient).downloadstring("https://raw.githubusercontent.com/DiXN/dotfiles/master/src/scripts/settings.ps1"))

#disable windows defender real time monitoring during installation
Write-Output "[Disable windows defender ...]"
Set-MpPreference -DisableRealtimeMonitoring $true

#install scoop
Write-Output "[Installing Scoop ...]"
Invoke-Expression ((new-object net.webclient).downloadstring("https://get.scoop.sh"))

scoop bucket add extras
scoop bucket add versions
scoop bucket add java
scoop bucket add JetBrains
scoop bucket add nonportable
scoop bucket add Ash258 'https://github.com/Ash258/Scoop-Ash258.git'
scoop bucket add DiXN 'https://github.com/DiXN/scoop.git'

scoop install aria2 git sudo dotnet-sdk

if (${env:CI} -ne 'true') {
  scoop install pwsh
}

dotnet tool install -g dotnet-script

#install Chocolatey
Write-Output "[Installing Chocolatey ...]"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# merge base with platform yaml file
Get-Content "$downloadLocation\templates\$templatePrefix\choco.yaml"    | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\base\choco.yaml"
Get-Content "$downloadLocation\templates\$templatePrefix\scoop.yaml"    | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\base\scoop.yaml"
Get-Content "$downloadLocation\templates\$templatePrefix\commands.yaml" | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\base\commands.yaml"

#invoke dotnet-script
Write-Output "[Installing dotfiles ...]"
Invoke-Expression ("dotnet script -c release $downloadLocation\scripts\dotnet\main.csx -- $downloadLocation\templates\base\choco.yaml $downloadLocation\templates\base\scoop.yaml $downloadLocation\templates\base\commands.yaml")

if (${env:CI} -ne 'true') {
  #sync files
  Write-Output "[Syncing files ...]"
  Invoke-Expression ("dotnet script -c release $downloadLocation\scripts\dotnet\sync-files.csx")
}
