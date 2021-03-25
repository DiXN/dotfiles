$templatePrefix = "vm"

Write-Output "[dotfiles running on $templatePrefix ...]"

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

scoop install aria2 git sudo dotnet-sdk

if (${env:CI} -ne 'true') {
  scoop install pwsh
}

scoop bucket add extras
scoop bucket add versions
scoop bucket add java
scoop bucket add JetBrains
scoop bucket add nonportable
scoop bucket add Ash258 'https://github.com/Ash258/Scoop-Ash258.git'
scoop bucket add DiXN 'https://github.com/DiXN/scoop.git'

dotnet tool install -g dotnet-script

#install Chocolatey
Write-Output "[Installing Chocolatey ...]"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#invoke dotnet-script
Write-Output "[Installing dotfiles ...]"
Invoke-Expression ("dotnet script -c release $downloadLocation\scripts\dotnet\main.csx -- $downloadLocation\templates\$templatePrefix\scoop.yaml")

