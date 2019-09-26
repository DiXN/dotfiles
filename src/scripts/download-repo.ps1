#ref original: https://gist.github.com/chrisbrownie/f20cb4508975fb7fb5da145d3d38024a#file-downloadfilesfromrepo-ps1
#ref edited: https://gist.github.com/zerotag/cfc7d57eef5df9ae29ef8a56a367e6dc#file-downloadfilesfromrepo-ps1

function DownloadRepo {
  Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
  )

  # REST Building
  $baseUri = "https://api.github.com";
  $argsUri = "repos/$Owner/$Repository/contents/$Path";
  $wr = Invoke-WebRequest -Uri ("$baseUri/$argsUri") -UseBasicParsing;

  # Data Handler
  $objects = $wr.Content | ConvertFrom-Json
  $files = $objects | Where-Object { $_.type -eq "file" } | Select-Object -exp download_url
  $directories = $objects | Where-Object { $_.type -eq "dir" }

  # Iterate Directory
  $directories | ForEach-Object {
    DownloadRepo -User $User -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath "$($DestinationPath)/$($_.name)"
  }

  # Destination Handler
  if (-not (Test-Path $DestinationPath)) {
    try {
      New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop;
    }
    catch {
      throw "Could not create path '$DestinationPath'!";
    }
  }

  # Iterate Files
  foreach ($file in $files) {
    $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
    $outputFilename = $fileDestination.Replace("%20", " ");
    try {
      Invoke-WebRequest -Uri "$file" -OutFile "$outputFilename" -UseBasicParsing -ErrorAction Stop -Verbose
      "Grabbed '$($file)' to '$outputFilename'";
    }
    catch {
      throw "Unable to download '$($file)'";
    }
  }
}

$downloadLocation = [System.IO.Path]::GetTempPath() + "dotfiles"

DownloadRepo -Owner "DiXN" -Repository "dotfiles" -Path "src" -DestinationPath $downloadLocation
