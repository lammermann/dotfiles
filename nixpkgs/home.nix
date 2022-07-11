{ config, pkgs, ... }:

let

  sources = import ./nix/sources.nix;
  pkgsUnstable = import sources.nixpkgs {};
  python-environment = python-packages: with python-packages; [
    i3ipc
  ];
  python3 = pkgs.python38.withPackages python-environment;
  mynerdfonts = pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; };

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
      initExtra = builtins.readFile ../bashrc.sh;
      bashrcExtra = ''
        export NIX_PATH="nixpkgs=${sources."nixpkgs-stable"}:home-manager=${sources."home-manager"}"
      '';
    };

    readline = {
      enable = true;
      extraConfig = builtins.readFile ../inputrc;
    };

    bat.enable = true;

    starship.enable = true;

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      delta.enable = true;
      userEmail = "kober@optisense.com";
      userName = "Benjamin Kober";
      extraConfig = {
        pull = {
          ff = "only";
        };
      };
    };

    obs-studio = {
      enable = true;
    };

    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ fugitive ];
      extraConfig = ''
      set nocompatible
      set nobackup
      set virtualedit=block
      set whichwrap=b,s,h,l
      '';
    };
  };

  services.pasystray.enable = true;

  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  fonts.fontconfig.enable = true;

  home = {
    # packages I need
    packages = with pkgs; [
      # coding
      kakoune kak-lsp kakoune-cr
      xclip # needed for kakoune clipboard support
      html-tidy
      jq
      watchexec # or entr?
      # language servers
      python-language-server nodePackages.bash-language-server
      nodePackages.typescript-language-server rls
      # vcs
      pkgsUnstable.pijul

      # tools needed for coding at work and office
      vscodium
      libreoffice hunspellDicts.de_DE

      # system tools
      alacritty
      mynerdfonts
      feh xorg.xev dex xcwd python python3
      i3-layout-manager rofi fzf
      w3m htop tmux p7zip xarchiver ripgrep bat
      borgbackup
      keepassxc

      # documentation and analysis
      asciidoctor
      graphviz
      # I need yed. But building it is to unstable since
      # they often change their download packages. So I
      # install it manuallly with nix-env
      #pkgsUnstable.yed

      # web, mail and multimedia
      firefox qutebrowser
      thunderbird
      vlc

      # networking tools
      openvpn
      sshfs

      wireshark # nmap-graphical # is rustscan a better alternative to nmap?

      # video and image editing
      openshot-qt
      blender
      gimp inkscape

      # cad and eda
      kicad freecad

      # nix administration tools
      niv
      nix-tree

      pkgsUnstable.zoom-us

      # other personal stuff
      anki
      pkgsUnstable.tuhi
    ];

  };
}
