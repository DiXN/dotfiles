param (
  [Parameter(Mandatory = $true)]
  [String] $path
)

Write-Output "Waiting for $($path) ..."

while (!(Test-Path $path)) {
  Start-Sleep -Milliseconds 250
}
