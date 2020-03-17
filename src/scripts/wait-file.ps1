param (
  [Parameter(Mandatory = $true)]
  [String] $app
)

Write-Output "Waiting for $app ..."

while (!(Get-Command $app -ErrorAction SilentlyContinue)) {
  Start-Sleep -Milliseconds 250
}

Start-Sleep -Milliseconds 1000
