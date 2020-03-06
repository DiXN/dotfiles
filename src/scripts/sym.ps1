#Requires -RunAsAdministrator
$ErrorActionPreference = 'SilentlyContinue'

function Format-Result {
  Param(
    [Parameter(ValueFromPipeline)]
    $item
  )

  if ($item) {
    Write-Host "[Symlinks] Successfully creating symlink for `"$item`" ..."
  }
}

$syncRoot = $env:SYNC_ROOT

#.gitconfig
New-Item -ItemType SymbolicLink -Path "$env:UserProfile\.gitconfig" -Target "$syncRoot\config\.gitconfig" -Force `
  | Select-Object -ExpandProperty Name `
  | Format-Result

#.aws
Remove-Item "$env:UserProfile\.aws" -Force -Recurse | Out-Null
New-Item -ItemType SymbolicLink -Path "$env:UserProfile\.aws" -Target "$syncRoot\config\.aws" -Force `
  | Select-Object -ExpandProperty Name `
  | Format-Result

#vscode config
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\Code\User\settings.json" `
  -Target "$syncRoot\config\settings.json" -Force `
  | Select-Object -ExpandProperty Name `
  | Format-Result

#Microsoft.PowerShell_profile
New-Item -ItemType SymbolicLink -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" `
         -Target "$syncRoot\config\Microsoft.PowerShell_profile.ps1" -Force `
  | Select-Object -ExpandProperty Name `
  | Format-Result

#.ssh
Remove-Item "$env:UserProfile\.ssh" -Force -Recurse | Out-Null
New-Item -ItemType SymbolicLink -Path "$env:UserProfile\.ssh" -Target "$syncRoot\config\.ssh" -Force `
  | Select-Object -ExpandProperty Name `
  | Format-Result

#eMClient settings
try {
  Invoke-Expression "mailclient.exe /importsettings $syncRoot\config\em_client\settings.xml -s"
  Write-Host '[Symlinks] Successfully importing "eMClient" settings.'
}
catch {
  Write-Error '[Symlinks] Failed importing "eMClient" settings.'
}
