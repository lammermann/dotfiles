{ config, pkgs, ... }:

let

  pkgsUnstable = import <nixpkgs-unstable> {};

in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  programs = {

    bash = {
      enable = true;
      historyControl = ["erasedups" "ignorespace"];
      historyIgnore = ["ls" "cd" "exit"];
      initExtra = builtins.readFile ../bashrc;
    };

    readline = {
      enable = true;
      extraConfig = builtins.readFile ../inputrc;
    };

    bat.enable = true;

    git = {
      enable = true;
      delta.enable = true;
      userEmail = "kober@optisense.com";
      userName = "Benjamin Kober";
    };

    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ fugitive ];
    };
  };

  services.pasystray.enable = true;

  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  home = {
    # packages I need
    packages = with pkgs; [
      xclip # needed for kakoune clipboard support
      jq

      openvpn

      nix-index

      pkgsUnstable.pijul

      pkgsUnstable.yed
      pkgsUnstable.zoom-us
    ];

    sessionVariables = {
      EDITOR = "kak";
    };
  };
}
