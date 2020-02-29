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

#https://superuser.com/a/532109
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#check if shell is elevated
if ((Test-Admin) -eq $false) {
  Write-Error "Run again in an elevated shell."
  exit
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

Write-Output "[dotfiles running on $templatePrefix ...]"

#invoke dotnet-script
Write-Output "[Installing dotfiles ...]"
Invoke-Expression ("${env:userprofile}\.dotnet\tools\dotnet-script.exe -c release $downloadLocation\scripts\dotnet\main.csx -- $downloadLocation\templates\$templatePrefix\choco.yaml $downloadLocation\templates\$templatePrefix\scoop.yaml $downloadLocation\templates\$templatePrefix\commands.yaml")

if (${env:CI} -ne 'true') {
  #sync files
  Write-Output "[Syncing files ...]"
  Invoke-Expression ("${env:userprofile}\.dotnet\tools\dotnet-script.exe -c release $downloadLocation\scripts\dotnet\sync-files.csx")
}
