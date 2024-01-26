{ lib
, pkgs
, config
, modulesPath
, ...
}: {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "red";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  users = {
    mutableUsers = true;
    users = {
      red = {
        isNormalUser = true;
        description = "red";
        password = "123456";
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "input" "docker" ];
      };
    };
  };

  wsl.nativeSystemd = true;
  networking = {
    hostName = "wsl";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Set your time zone.
  time.timeZone = "Europe/Ljubljana";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
  };

  # Enable programs
  programs = {
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Enables docker in rootless mode
  # virtualisation = {
  #   docker.rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };

  # Enables flakes + garbage collector
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

  system.stateVersion = "22.05";
}
