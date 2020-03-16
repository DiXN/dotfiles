param (
  [Parameter(Mandatory = $true)]
  [String] $path
)

Write-Output "Waiting for $path ..."

$count = 0

while (!(Test-Path $path)) {
  Start-Sleep -Milliseconds 250
  $count++

  if ($count -eq 240) {
    Write-Output "Still waiting for $path ..."
    $count = 0
  }
}

Start-Sleep -Milliseconds 1000
