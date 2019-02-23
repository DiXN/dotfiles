Set-ExecutionPolicy Bypass -Scope Process -Force

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

#install Scoop
Set-ExecutionPolicy remotesigned -s currentuser
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')

scoop install git
scoop install aria2
scoop bucket add extras

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
