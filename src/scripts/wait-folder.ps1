param (
  [Parameter(Mandatory = $true)]
  [String] $path
)

Write-Output "Waiting for $path ..."

while (!(Test-Path $path)) {
  Start-Sleep -Milliseconds 250
}

Start-Sleep -Milliseconds 1000
