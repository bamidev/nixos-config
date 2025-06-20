{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    package = pkgs.librewolf;
    policies = {
	  DisableTelemetry = true;
	  DisableFirefoxStudies = true;
	  Cookies = {
	    Allow = ["https://therp.nl"];
	    BehaviorPrivateBrowsing = "reject-foreign";
	  };
	  Preferences = {
		#"browser.theme.content-theme" = 0;
		#"browser.theme.toolbar-theme" = 0;
		#"extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
	    #"cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
	    #"cookiebanners.service.mode" = 2; # Block cookie banners
	    "privacy.donottrackheader.enabled" = true;
	    "privacy.fingerprintingProtection" = true;
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
	    "uBlock0@raymondhill.net" = {
		  install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
		  installation_mode = "force_installed";
	    };
	    "Authenticator" = {
		  install_url = "https://addons.mozilla.org/firefox/downloads/latest/auth-helper/latest.xpi";
		  installation_mode = "force_installed";
	    };
	  };
    };
  };
}

