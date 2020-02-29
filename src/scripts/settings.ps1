#https://superuser.com/a/532109
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
function Test-RegistryValue {
  param (
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]$Path,
    [parameter(Mandatory = $true)]
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

#check if shell is elevated
if ((Test-Admin) -eq $false) {
  Write-Error "Run again in an elevated shell."
  exit
}
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

if (Get-PSDrive HKCR -ErrorAction SilentlyContinue) {
  Write-Output "Drive already exists."
} else {
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
  Set-ItemProperty -Path "HKCR:\Microsoft.PowerShellScript.1\Shell\open\command" -Name "(Default)" -Value "'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -noLogo -ExecutionPolicy unrestricted -file '%1'"
}

#enable developer mode
Write-Output "[Enabling developer mode ...]"
$registryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

if (-not(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock")) {
  New-Item -Path $registryKeyPath -ItemType Directory -Force
}

if (Test-RegistryValue -Path $registryKeyPath -Value "AllowDevelopmentWithoutDevLicense") {
  Set-ItemProperty -Path $registryKeyPath -Name "AllowDevelopmentWithoutDevLicense" -Value "1"
}
else {
  New-ItemProperty -Path $registryKeyPath -Name "AllowDevelopmentWithoutDevLicense" -PropertyType DWORD -Value "1"
}

if (Test-RegistryValue -Path $registryKeyPath -Value "AllowAllTrustedApps") {
  Set-ItemProperty -Path $registryKeyPath -Name "AllowAllTrustedApps" -Value "1"
}
else {
  New-ItemProperty -Path $registryKeyPath -Name "AllowAllTrustedApps" -PropertyType DWORD -Value "1"
}

Write-Output "[Disabling compression ...]"
#disable compression
fsutil behavior set disablecompression 1
