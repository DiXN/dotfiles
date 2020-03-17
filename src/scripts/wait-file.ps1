param (
  [Parameter(Mandatory = $true)]
  [String] $app,
  [bool] $scoop = $false
)

Write-Output "Waiting for $app ..."

$count = 0

while ($scoop ? !(Get-ChildItem "~\scoop\apps\$app" -ErrorAction SilentlyContinue) `
              : !(Get-Command $app -ErrorAction SilentlyContinue)) {
  Start-Sleep -Milliseconds 250
  $count++

  if ($count -eq 240) {
    Write-Output "Still waiting for $app ..."
    $count = 0
  }
}

Start-Sleep -Milliseconds 1000
