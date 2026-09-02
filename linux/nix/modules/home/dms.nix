{ system, dms, quickshell, ... }:

{
  programs.dank-material-shell = {
    enable = true;

    settings = {
      configVersion = 16;

      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";

      popupTransparency = 0.92;
      dockTransparency = 0.75;
      widgetBackgroundColor = "sth";

      cornerRadius = 12;

      animationSpeed = 2;

      centeringMode = "geometric";

      fontScale = 1.15;

      useAutoLocation = true;
      networkPreference = "ethernet";

      launcherLogoMode = "os";

      showDock = true;
      dockSmartAutoHide = true;
      dockGroupByApp = true;
      dockPosition = 3;
      dockMargin = 10;
      dockLauncherEnabled = true;

      notificationOverlayEnabled = true;

      mediaSize = 2;
      spotlightModalViewMode = "grid";

      showWorkspaceApps = true;
      runningAppsCurrentWorkspace = false;

      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0;
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            { id = "launcherButton"; enabled = true; }
            { id = "workspaceSwitcher"; enabled = true; }
            { id = "focusedWindow"; enabled = true; }
          ];
          centerWidgets = [
            { id = "music"; enabled = true; }
            { id = "clock"; enabled = true; }
            { id = "weather"; enabled = true; }
          ];
          rightWidgets = [
            { id = "privacyIndicator"; enabled = true; }
            { id = "systemTray"; enabled = true; }
            { id = "clipboard"; enabled = true; }
            { id = "notificationButton"; enabled = true; }
            { id = "battery"; enabled = true; }
            { id = "cpuUsage"; enabled = true; }
            { id = "controlCenterButton"; enabled = true; }
          ];
          spacing = 4;
          innerPadding = 8;
          bottomGap = 4;
          widgetTransparency = 0.85;
          borderEnabled = true;
          borderColor = "secondary";
          borderThickness = 1;
          fontScale = 1.15;
          showOnWindowsOpen = true;
          openOnOverview = true;
          maximizeDetection = true;
          clickThrough = true;
        }
      ];
    };

    systemd.enable = false;

    niri = {
      enableKeybinds = false;
      enableSpawn = true;

      includes = {
        enable = false;
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
          "wpblur"
        ];
      };
    };

    enableSystemMonitoring = true;
    quickshell.package = quickshell.packages.${system}.default;
  };
}
