{ config, pkgs, ... }:

let
  sources = import ./nix/sources.nix;
  pkgsUnstable = import sources.nixpkgs {};
  pkgs = import sources.nixpkgs-stable { config.allowUnfree = true; };
  python-environment = python-packages: with python-packages; [
    i3ipc
  ];
  python3 = pkgs.python311.withPackages python-environment;
  keepassxc-prompt = pkgs.writeShellScriptBin "keepassxc-prompt" ''
  # see https://peterbabic.dev/blog/make-ssh-prompt-password-keepassxc/
  until ssh-add -l &> /dev/null
  do
    echo "Waiting for agent. Please unlock the database."
    ${pkgs.keepassxc}/bin/keepassxc & &> /dev/null
    sleep 1
  done

  ${pkgs.netcat}/bin/nc "$1" "$2"
  '';
  diffviewer = pkgs.writeScriptBin "show-diff" (
    builtins.replaceStrings ["difft"] ["${pkgs.difftastic}/bin/difft"]
      (builtins.readFile ../bin/show-diff));

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
      # We need to make sure the nixpkgs path in the shell.nix is
      # identical to our normal environment
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

    navi.enable = true;

    fzf.enable = true;

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userEmail = "benko@kober-systems.com";
      userName = "Benjamin Kober";
      extraConfig = {
        pull = {
          ff = "only";
        };
        diff = {
          external = "${diffviewer}/bin/show-diff";
        };
      };
    };

    ssh = {
      enable = true;
      extraConfig = ''
      ProxyCommand ${keepassxc-prompt}/bin/keepassxc-prompt %h %p
      '';
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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
    ];
  };

  home = {
    # packages I need
    packages = with pkgs; [
      # coding
      (kakoune.override {
        plugins = with pkgs.kakounePlugins; [
          kakoune-vertical-selection
          kak-ansi # improves usage as a pager
        ];
      })
      kak-lsp kakoune-cr
      xsel # needed for kakoune clipboard support
      html-tidy
      jq jless
      elvish
      watchexec entr
      mob
      # language servers
      python311Packages.python-lsp-server nodePackages.bash-language-server
      nodePackages.typescript-language-server rust-analyzer
      # vcs
      pijul

      # tools needed for coding at work and office
      libreoffice hunspellDicts.de_DE hunspellDicts.en_US
      hunspell proselint
      pkgsUnstable.kdePackages.okular

      # system tools
      alacritty kitty
      ranger
      fd
      carapace
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      feh xorg.xev xcwd python3
      i3-layout-manager rofi fzf
      w3m htop p7zip xarchiver ripgrep bat
      borgbackup
      ncdu
      difftastic
      keepassxc
      keepassxc-prompt

      gnome-pomodoro
      ktimetracker

      # documentation and analysis
      asciidoctor-with-extensions
      graphviz
      # I need yed. But building it is to unstable since
      # they often change their download packages. So I
      # install it manuallly with nix-env
      #pkgsUnstable.yed

      # web, mail and multimedia
      chromium
      firefox
      thunderbird
      vlc

      # networking tools
      openvpn
      sshfs

      wireshark # nmap-graphical # is rustscan a better alternative to nmap?

      # video and image editing
      blender
      inkscape

      # nix administration tools
      niv
      nix-tree

      # other personal stuff
      anki
      tuhi
    ];
  };
}
