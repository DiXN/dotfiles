Write-Output "Removing default apps ..."

# Uninstall useless default apps.
ForEach($appId in
  "Microsoft.3DBuilder",          # 3D Builder
  "Microsoft.BingFinance",        # Bing Finance
  "Microsoft.BingNews",           # Bing News
  "Microsoft.BingSports",         # Bing Sports
  "Microsoft.BingWeather",        # Bing Weather
  "king.com.BubbleWitch3Saga",    # Bubble Witch 3 Saga
  "king.com.CandyCrushSodaSaga",  # Candy Crush Soda Saga
  "*.DisneyMagicKingdoms",        # Disney Magic Kingdoms
  "*.DragonManiaLegends",         # Dragon Mania Legends
  "*.Facebook",                   # Facebook
  "Microsoft.GetHelp",            # Get Help
  "Microsoft.GetStarted",         # Get Started
  "*.HiddenCityMysteryofShadows", # Hidden City: Mystery of Shadows
  "Microsoft.WindowsMaps",        # Maps
  "*.MarchofEmpires",             # March of Empires
  "Microsoft.Messaging",          # Messaging
  "Microsoft.MinecraftUWP",       # Minecraft Windows 10 Edition
  "Microsoft.MicrosoftOfficeHub", # Office and “Get Office365” Notifications
  "flaregamesGmbH.RoyalRevolt2",  # Royal Revolt 2
  "Microsoft.SkypeApp",           # Skype
  "*.SlingTV",                    # SlingTV
  "Microsoft.Office.Sway",        # Sway
  "*.Twitter",                    # Twitter
  "*.Viber",                      # Viber
  "Microsoft.WindowsPhone"       # Windows Phone Companion
) {
  Get-AppxPackage "$appId" -AllUsers | Remove-AppxPackage
  Get-AppXProvisionedPackage -Online | Where-Object DisplayNam -like "$appId" | Remove-AppxProvisionedPackage -Online
}

# Uninstall Windows Media Player.
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null

#enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart -WarningAction SilentlyContinue | Out-Null

#enable Sandbox
Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart -WarningAction SilentlyContinue | Out-Null

#enable WSL
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null

# Prevent “Suggested Applications” from returning.
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent")) {
  New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Type Folder | Out-Null
}

Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
