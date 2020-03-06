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

$downloadLocation = [System.IO.Path]::GetTempPath() + "dotfiles"
#create folder in TEMP path if not exists
mkdir -Force $downloadLocation | Out-Null

Set-Location $downloadLocation

if (${env:CI} -ne 'true') {
  $Credentials = Get-Credential admin
  $Credentials.Password | ConvertFrom-SecureString | Set-Content credential.txt
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}

Get-ExecutionPolicy -List

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

scoop install aria2 git sudo dotnet-sdk

scoop bucket add extras
scoop bucket add versions
scoop bucket add java
scoop bucket add JetBrains
scoop bucket add nonportable
scoop bucket add Ash258 'https://github.com/Ash258/Scoop-Ash258.git'
scoop bucket add DiXN 'https://github.com/DiXN/scoop.git'

#install Chocolatey
Write-Output "[Installing Chocolatey ...]"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install dotnet-script
dotnet tool install -g dotnet-script

#check if notebook or desktop
$templatePrefix = ""

if (Has-Battery) {
  $templatePrefix = "notebook"
}
else {
  $templatePrefix = "desktop"
}

Write-Output "[dotfiles running on $templatePrefix ...]"

# merge universal with platform yaml file
Get-Content "$downloadLocation\templates\base\choco.yaml"    | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\$templatePrefix\choco.yaml"
Get-Content "$downloadLocation\templates\base\scoop.yaml"    | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\$templatePrefix\scoop.yaml"
Get-Content "$downloadLocation\templates\base\commands.yaml" | Select-Object -Skip 2 | Add-Content "$downloadLocation\templates\$templatePrefix\commands.yaml"

#invoke dotnet-script
Write-Output "[Installing dotfiles ...]"
Invoke-Expression ("${env:userprofile}\.dotnet\tools\dotnet-script.exe -c release $downloadLocation\scripts\dotnet\main.csx -- $downloadLocation\templates\$templatePrefix\choco.yaml $downloadLocation\templates\$templatePrefix\scoop.yaml $downloadLocation\templates\$templatePrefix\commands.yaml")

if (${env:CI} -ne 'true') {
  #sync files
  Write-Output "[Syncing files ...]"
  Invoke-Expression ("${env:userprofile}\.dotnet\tools\dotnet-script.exe -c release $downloadLocation\scripts\dotnet\sync-files.csx")
}
