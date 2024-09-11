# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  sources = import ../../nix/sources.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (sources.nixos-hardware + "/system76")
      (sources.nixos-hardware + "/common/gpu/nvidia/disable.nix")
      (sources.home-manager + "/nixos")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot = {
    kernelParams =
      [ "acpi_rev_override" "mem_sleep_default=deep" "intel_iommu=igfx_off" ];
  };

  networking.hostName = "benjamin"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp5s0f1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.i3.enable = true;
  };
  services.displayManager.defaultSession = "xfce+i3";

  environment.xfce.excludePackages = with pkgs.xfce; [
    parole
    ristretto
    mousepad
    xfce4-terminal
  ];

  # Configure keymap in X11
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "de+poly";
    extraLayouts = {
      poly = {
        description = "custom german bulgarian coding xkb layout.";
        languages = [ "eng" "deu" "bul" ];
        keycodesFile = ./polyglot_keycodes.xkb;
        symbolsFile = ./polyglot_symbols.xkb;
        compatFile = ./polyglot_compat.xkb;
        typesFile = ./polyglot_types.xkb;
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Make sure the computer does not freeze under heavy load
  # note: This is needed because with a nixos update it could happen
  #       this tries to compile e.g. firefox eat up all memory and
  #       freeze
  # see:  https://superuser.com/questions/406101/is-it-possible-to-make-the-oom-killer-intervent-earlier
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # for a WiFi printer
    openFirewall = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.benjamin = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
      "nm-openvpn"
      "wireshark"
      "video"
      "dialout"
    ];
    # Enable sub uid ranges for podman
    autoSubUidGidRange = true;
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];

  };
  home-manager.users.benjamin = import ../../home.nix;

  services.arbtt.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };

    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "benjamin" ];

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git
    xfce.thunar-volman
    haskellPackages.arbtt
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.ssh.startAgent = true;

  # Add some udev rules for development
  services.udev = {
    extraRules = ''
      # set permissions for optisense hid devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0c90", GROUP="users", MODE="0664"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0c91", GROUP="users", MODE="0664"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0c92", GROUP="users", MODE="0664"
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
    packages = [ pkgs.teensy-udev-rules ];
  };

  # allow wireshark to be used by unprivileged users
  programs.wireshark.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # enable firewall and block all ports
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

