# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
	  ./librewolf.nix
      ./neovim.nix
	  ./syncthing.nix
    ];

  system.stateVersion = "24.11";


  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.efiInstallAsRemovable = true;
  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "baminix"; # Define your hostname.
  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.resolvconf = {
    enable = true;
    #package = pkgs.openresolv;
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";


  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services = {
    gnome.gnome-keyring.enable = true;

    # Keyboard remapping
    input-remapper.enable = true;

    # Touchpad
    libinput.enable = true;

    openvpn = {
      servers = {
        protonvpn = { config = '' config /root/nixos/openvpn/protonvpn.conf ''; };
      };
    };

    # Sound server
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    
    # Enable CUPS to print documents.
    printing.enable = true;


    # Give Vial access to all keyboard devices
	udev.extraRules = ''
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
'';
  };

  # Users
  users = {
    mutableUsers = true;
    users = {
      bamilab = {
        description = "Personal";
        home = "/home/bamilab";
        isNormalUser = true;
        extraGroups = [
          "video"
          "wheel"	# Enable ‘sudo’ for the user.
        ];
        #packages = with pkgs; [];
      };

      therp = {      
        description = "Work";
        home = "/home/therp";
        isNormalUser = true;
        extraGroups = [
          "video"
          "wheel"
        ];
      };
    };
  };

  home-manager.users = {
	  bamilab = import ./users/bamilab/home.nix;
	  therp = import ./users/therp/home.nix;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    chromium
    element-desktop
    git
    killall
    konsole
    libreoffice
    librewolf
    mako
    neovim
    pass
    protonmail-bridge
    protonmail-bridge-gui
    #python313Packages.pygls
    signal-desktop
    swayfx
    syncthing
    thunderbird
    vial
    wget
    wl-clipboard
    wlsunset
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
	  extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
'';
    };
  };

  security.polkit.enable = true;

  environment.shellAliases = {
    g = "git";
    gb = "git branch";
    gd = "git diff";
    gs = "git status";
    vi = "nvim";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.etc = {
    gitconfig = {
       text = ''
[alias]
a = "add"
b = "branch"
c = "checkout"
cm = "commit"
d = "diff"
l = "log"
p = "pull"
s = "status"

[core]
editor = "nvim"
'';
    };
  };
}

