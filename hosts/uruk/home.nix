{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    cli.enable = true;
    desktop = {
      hyprland.enable = true;
    };
    direnv.enable = true;
    editor = {
      emacs.enable = true;
      neovim.enable = true;
    };
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };

  home = {
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };

    file = {
    };

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaRed;
      name = "Catppuccin-Mocha-Red-Cursors";
      size = 24;
    };
  };

  # Bluetooth
  services.blueman-applet.enable = true;

  services.network-manager-applet.enable = true;

  services.udiskie.enable = true;
  # workaround because udiskie requires this
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };

  fonts.fontconfig.enable = true;

  programs.chromium = {
    enable = true;
    extensions = [
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://djblue.github.io/portal/";
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "André Stylianos Ramos";
    userEmail = "andre.stylianos@protonmail.com";
    extraConfig = {
      user = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFjyP6503WFbZZTyo96oFtwdTlZH7Dq/gFBEaiPXlA5";
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
        ssh = {
          program = "${pkgs._1password-gui}/bin/op-ssh-sign";
        };
      };
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        privacy-badger
        proton-pass
        ublock-origin
      ];
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Regular Nerd Font Complete";
      size = 11;
    };
    extraConfig = ''
      modify_font underline_position +2
      modify_font underline_thickness +1
    '';
  };

  programs.obs-studio = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    extensions = with pkgs.unstable.vscode-extensions;
      [
        asvetliakov.vscode-neovim
        dracula-theme.theme-dracula
        mkhl.direnv
      ]
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "portal";
          publisher = "djblue";
          version = "0.37.0";
          sha256 = "kn9KCk0rlfF5LKTlidmDVc6VXCm2WKuu12JON0pNpCU=";
        }
        {
          name = "nix-ide";
          publisher = "jnoortheen";
          version = "0.2.1";
          sha256 = "yC4ybThMFA2ncGhp8BYD7IrwYiDU3226hewsRvJYKy4=";
        }
      ];
    userSettings = {
      "workbench.colorTheme" = "Default Dark+ Experimental";
      "workbench.editor.highlightModifiedTabs" = true;
      "window.zoomLevel" = -2;
      "editor" = {
        "guides" = {
          "bracketPairs" = true;
          "bracketPairsHorizontal" = true;
        };
        "fontSize" = 20;
        "fontLigatures" = true;
        "fontFamily" = "Iosevka, Fira Code, Menlo, Monaco, 'Courier New', monospace";
        #"fontWeight" = "bold";
        "minimap" = {
          "enabled" = false;
        };
        "accessibilitySupport" = "off";
      };
      "explorer.excludeGitIgnore" = true;
      "files.trimTrailingWhitespace" = true;
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
      "extensions.ignoreRecommendations" = true;
    };
  };

  services.playerctld.enable = true;
  services.kdeconnect.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = null;
    extraConfig = ''
      pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet
    '';
  };

  services.swayidle = {
    enable = true;
  };

  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    bitwarden
    brave
    cachix
    git
    git-crypt
    ghostscript
    flameshot
    killall
    pdfarranger
    kwalletcli
    discord
    obsidian
    vlc

    fuzzel

    coreutils
    gnutls
    clang

    gnome.nautilus

    unstable.flyctl
    # Nix
    nil
    nix-prefetch-github
    alejandra

    # lua
    sumneko-lua-language-server
    stylua

    #neovim
    xclip

    # Clojure
    clojure-lsp
    # KDE
    #libsForQt5.bismuth

    # Gnome
    #gnomeExtensions.appindicator
    #gnomeExtensions.pop-shell

    # Work
    unstable.slack

    # Fonts
    (pkgs.nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "Iosevka" "JetBrainsMono"];})

    # Compression
    atool
    zip
    unzip
    #tar
    #
    age
    sops
    wl-clipboard
    tldr

    deploy-rs
  ];

  xdg = {
    enable = true;
    configFile = {
      "clojure/deps.edn".source = ../../config/.clojure/deps.edn;

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };
  };
}
