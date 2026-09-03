{ pkgs, zen-browser, ... }:

{
  imports = [
    zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;

      ExtensionSettings = builtins.mapAttrs (_: install_url: {
        inherit install_url;
        installation_mode = "force_installed";
      }) {
        "uBlock0@raymondhill.net" = "file://${pkgs.firefox-addons.ublock-origin}";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "file://${pkgs.firefox-addons.bitwarden}";
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "file://${pkgs.firefox-addons.return-youtube-dislikes}";
        "videoresumer@jetpack" = "file://${pkgs.firefox-addons.video-resumer}";
        "BraveSearchExtension@io.Uvera" = "https://addons.mozilla.org/firefox/downloads/file/4278495/brave_search-1.3.0.xpi";
        "{6505e807-3fe7-447e-99df-1f2aa51b443f}" = "https://addons.mozilla.org/firefox/downloads/file/4376806/indexeddb_manager-0.0.1.xpi";
        "{bd490218-d863-45c9-8ffa-490ba0a91577}" = "https://addons.mozilla.org/firefox/downloads/file/4466501/rotate_image-2.0.0.xpi";
        "nordvpnproxy@nordvpn.com" = "https://addons.mozilla.org/firefox/downloads/file/4638627/nordvpn_proxy_extension-5.2.2.xpi";
        "myallychou@gmail.com" = "file://${pkgs.firefox-addons.youtube-recommended-videos}";
        "firefox@tampermonkey.net" = "file://${pkgs.firefox-addons.tampermonkey}";
        "@testpilot-containers" = "file://${pkgs.firefox-addons.multi-account-containers}";
        "enhancerforyoutube@maximerf.addons.mozilla.org" = "file://${pkgs.firefox-addons.enhancer-for-youtube}";
        "unhook-reddit@example.com" = "https://addons.mozilla.org/firefox/downloads/file/4750081/unhook_for_reddit-1.2.3.xpi";
        "webextension@metamask.io" = "file://${pkgs.firefox-addons.metamask}";
        "languagetool-webextension@languagetool.org" = "file://${pkgs.firefox-addons.languagetool}";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "file://${pkgs.firefox-addons.refined-github}";
      };
    };

    profiles.mk = {
      isDefault = true;
      id = 0;
      settings = {
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        "privacy.resistFingerprinting" = true;

        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.sessionstore.interval" = 15000;
        "browser.startup.homepage" = "https://rss.kaltschm.id/i/";
        "browser.tabs.loadInBackground" = true;
        "browser.urlbar.suggest.searches" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.openpage" = true;

        "zen.view.sidebar-expanded" = false;
        "zen.view.sidebar-expanded.on-hover" = false;
        "zen.view.compact.enable-at-startup" = true;
        "zen.view.compact.should-enable-at-startup" = false;
        "zen.welcome-screen.seen" = true;

        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.history.custom" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
      };

    mods = [
      "2e3369c7-e450-46ba-8794-75ccb0de5e48" # Now playing indicator
      "570afd9d-96fa-48b5-bad3-0c106757cce9" # Super Sleek UI
      "58649066-2b6f-4a5b-af6d-c3d21d16fc00" # Private Mode Highlighting
      "5941aefd-67b0-453d-9b62-9071a31cbb0d" # Ultra compact mode
      "6f11c932-b992-433e-8c80-56a613cc511e" # Left close button
    ];
    };
  };
}
