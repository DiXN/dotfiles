Get-ExecutionPolicy -List

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

#download DotfilesWrapper
Write-Output "Downloading DotfilesWrapper..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/DiXN/dotfiles/master/src/scripts/download-github-release.ps1"))

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

#exec powershell scripts on double click
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Set-ItemProperty -Path "HKCR:\Microsoft.PowerShellScript.1\Shell\open\command" -Name "(Default)" -Value "'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -noLogo -ExecutionPolicy unrestricted -file '%1'"

#enable developer mode
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
Set-MpPreference -DisableRealtimeMonitoring $true

#install Scoop
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
Set-ExecutionPolicy Undefined -scope Process -Force
Set-ExecutionPolicy Undefined -scope LocalMachine -Force
Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force

scoop install git
scoop install aria2
scoop bucket add extras

#install Chocolatey
Write-Output "Installing Chocolatey..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))

#download YAML files
if (Detect-Notebook) {
  Write-Output "Downloading YAML files..."
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/notebook/choco.yaml" | Out-File -filepath "$downloadLocation\choco.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/notebook/scoop.yaml" | Out-File "$downloadLocation\scoop.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/notebook/commands.yaml" | Out-File "$downloadLocation\commands.yaml"
} else {
  Write-Output "Downloading YAML files..."
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/desktop/choco.yaml" | Out-File "$downloadLocation\choco.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/desktop/scoop.yaml" | Out-File "$downloadLocation\scoop.yaml"
  Invoke-RestMethod "https://raw.githubusercontent.com/DiXN/dotfiles/master/src/templates/desktop/commands.yaml" | Out-File "$downloadLocation\commands.yaml"
}

Set-Location $downloadLocation

Write-Output "Invoking DotfilesWrapper..."
Invoke-Expression "$downloadLocation\DotfilesWrapper.exe $downloadLocation\choco.yaml $downloadLocation\commands.yaml $downloadLocation\scoop.yaml"
