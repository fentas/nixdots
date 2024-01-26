{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    kernelModules = [ "v4l2loopback" ]; # Autostart kernel modules on boot
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ]; # loopback module to make OBS virtual camera work
    kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = false;
      timeout = 10;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 3;
        theme =
          pkgs.fetchFromGitHub
            {
              owner = "Lxtharia";
              repo = "minegrub-theme";
              rev = "193b3a7c3d432f8c6af10adfb465b781091f56b3";
              sha256 = "1bvkfmjzbk7pfisvmyw5gjmcqj9dab7gwd5nmvi8gs4vk72bl2ap";
            };
      };
    };
  };

  # Change systemd stop job timeout in NixOS configuration (Default = 90s)
  systemd = {
    services.NetworkManager-wait-online.enable = false;
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
    # no need to wait interfaces to have an IP to continue booting
    dhcpcd.wait = "background";
    # avoid checking if IP is already taken to boot a few seconds faster
    dhcpcd.extraConfig = "noarp";
    hostName = "gravitas"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set your time zone.
  time.timeZone = "Europe/Ljubljana";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Enable programs
  programs = {
    zsh.enable = true;
    steam.enable = true;
    dconf.enable = true;
    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };
  };

  # Allow unfree packages + use overlays
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (
        final: prev: {
          sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation rec {
            pname = "sf-mono-liga-bin";
            version = "dev";
            src = inputs.sf-mono-liga-src;
            dontConfigure = true;
            installPhase = ''
              mkdir -p $out/share/fonts/opentype
              cp -R $src/*.otf $out/share/fonts/opentype/
            '';
          };
          monolisa = prev.stdenvNoCC.mkDerivation rec {
            pname = "monolisa";
            version = "dev";
            src = inputs.monolisa;
            dontConfigure = true;
            installPhase = ''
              mkdir -p $out/share/fonts/opentype
              cp -R $src/*.ttf $out/share/fonts/opentype/
            '';
          };
        }
      )
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      sf-mono-liga-bin
      monolisa
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Times, Noto Serif" ];
        sansSerif = [ "Helvetica Neue LT Std, Helvetica, Noto Sans" ];
        monospace = [ "Courier Prime, Courier, Noto Sans Mono" ];
      };
    };
  };

  # Enables docker in rootless mode
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # Enables virtualization for virt-manager
    libvirtd.enable = true;
  };

  environment = {
    variables = {
      # GBM_BACKEND = "nvidia-drm";
      # LIBVA_DRIVER_NAME = "nvidia";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "0"; # Controls if Adaptive Sync should be used. Recommended to set as “0” to avoid having problems on some games.
      XCURSOR_THEME = "macOS-BigSur";
      XCURSOR_SIZE = "32";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      EDITOR = "nvim";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      # WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issue on wlr nvidia.
      DEFAULT_BROWSER = "${pkgs.brave}/bin/firefox"; # Set default browser
    };
    systemPackages = with pkgs; [
      git
      wget
      playerctl
      inputs.xdg-portal-hyprland.packages.${system}.xdg-desktop-portal-hyprland
    ];
  };

  hardware = {
    nvidia = {
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        xfce.enable = true;
      };
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
        };
      };
      videoDrivers = [ "nvidia" ];
      layout = "us";
      xkbVariant = "";
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
        };
        touchpad = {
          accelProfile = "flat";
        };
      };
    };
    logmein-hamachi.enable = false;
    flatpak.enable = false;
  };

  console.keyMap = "us";

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    wireplumber.enable = true;
  };

  users = {
    users = {
      fentas = {
        isNormalUser = true;
        description = "fentas";
        initialPassword = "123456";
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
      };
    };
  };

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [
        {
          users = [ "fentas" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  system.stateVersion = "22.11"; # Did you read the comment?
}
