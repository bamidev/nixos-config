{ pkgs, ... }:
let
  latestPkgs = (import ../pins.nix).nixpkgsUnstable;
in {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    configPath = ".librewolf";

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Cookies = {
        BehaviorPrivateBrowsing = "reject-foreign";
        Locked = true;
      };
      Preferences = {
        "browser.policies.runOncePerModification.setDefaultSearchEngine" = "DuckDuckGo";
        "browser.toolbars.bookmarks.visibility" = "newtab";
        "browser.translations.enable" = false;
        "extensions.activeThemeID" = "{dfb93b31-21ba-46fc-977d-46300ce0a76b}";
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.clearOnShutdown_v2.histroyFormDataAndDownloads" = true;
        "privacy.clearOnShutdown_v2.siteSettings" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = false;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        FormData = true;
        History = true;
        Sessions = true;
        SiteSettings = true;
        Locked = true;
      };

      ExtensionSettings = {
        "{dfb93b31-21ba-46fc-977d-46300ce0a76b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/3783661/running_foxes_by_madonna-8.0.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "authenticator@mymindstorm" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/auth-helper/latest.xpi";
          installation_mode = "force_installed";
        };
        "floccus@handmadeideas.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.default = {
      isDefault = true;

      search = {
        default = "SearXNG";
        force = true;

        order = [
          "policy-DuckDuckGo Lite"
          "wikipedia"
          "Nix Packages"
          "Nix Options"
          "NixOS Wiki"
          "bing"
          "google"
        ];

        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query";   value = "{searchTerms}"; }
                ];
              }
            ];
            icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query";   value = "{searchTerms}"; }
                ];
              }
            ];
            icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  { name = "search"; value = "{searchTerms}"; }
                ];
              }
            ];
            icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };

          "SearXNG" = {
            urls = [
              {
                template = "https://search.rhscz.eu/search";
                params = [
                  { name = "q"; value = "{searchTerms}"; }
                ];
              }
            ];
            definedAliases = [ "@s" ];
          };

          bing.metaData.alias = "@b";
          google.metaData.alias = "@g";
          ddg.metaData.alias = "@ddg";
          "policy-DuckDuckGo Lite".metaData.alias = "@d";
          wikipedia.metaData.alias = "@w";
        };
      };
    };
  };
}

