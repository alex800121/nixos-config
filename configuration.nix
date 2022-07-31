# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Kernel fix
  boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.kernelPatches = [
    {
      name = "keyboard";
      patch = ./patches/keyboard.patch;
    }
  ];
  hardware.enableAllFirmware = true; 

  # Bootloader.
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        devices = [ "nodev" ];
        efiSupport = true;
        enable = true;
        version = 2;
        useOSProber = true;
        fontSize = 40;
      };
    };
  };

  # fileSystems."/media/alex800121/Asus" = {
  #   device = "/dev/disk/by-uuid/F2D200EBD200B63F";
  #   fsType = "ntfs";
  #   options = [ "rw" "uid=1000" ];
  # };

  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.overlays = [ (self: super: {
    auto-cpufreq = super.auto-cpufreq.overridePythonAttrs(old: rec{
      # pname = "auto-cpufreq";
      # version = "1.9.4";
      # src = super.fetchFromGitHub {
      #   owner = "AdnanHodzic";
      #   repo = "auto-cpufreq";
      #   rev = "v1.9.4";
      #   sha256 = "sha256-JwhKBNZFIBCfF2qDIqQ6mZaHVyOARbG1Y15TLIqMVNY=";
      # };
      patches = old.patches ++ [
        # ./auto-cpufreq/fix-version-output.patch
        # /home/alex800121/.config/nixos/patches/detect_charging.patch
        ./patches/detect_charging.patch
      ];
    } );
    # wine = super.wineWowPackages.waylandFull;
  } ) ];

  # powerManagement = {
  #   enable = true;
  #   # cpuFreqGovernor = "performance";
  #   powertop.enable = true;
  # };
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "auto-cpufreq";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "auto-cpufreq";
  #   };
  # };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # i18n.inputMethod = {
  #   enabled = "hime";
  # };
  # i18n.inputMethod = {
  #   enabled = "fcitx";
  #   fcitx.engines = with pkgs.fcitx-engines; [ chewing rime ];
  # };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      enableRimeData = true;
      addons = with pkgs; [
        fcitx5-chewing
        fcitx5-chinese-addons
        fcitx5-configtool
        fcitx5-gtk
        fcitx5-rime
      ];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    # enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = false;
    media-session.enable = true;

    media-session.config = {
      alsa-monitor = {
        properties = { };
        rules = [
          {
            actions.update-props = {
              session.suspend-timeout-seconds = 0;
              api.alsa.ignore-dB = false;
              api.alsa.start-delay = 1024;
            };
          }
          {
            actions = {
              update-props = {
                api.acp.auto-port = false;
                api.acp.auto-profile = false;
                api.alsa.use-acp = true;
              };
            };
            matches = [
              {
                device.name = "~alsa_card.*";
              }
            ];
          }
          {
            actions = {
              update-props = {
                node.pause-on-idle = false;
              };
            };
            matches = [
              {
                node.name = "~alsa_input.*";
              }
              {
                node.name = "~alsa_output.*";
              }
            ];
          }
        ];
      };
    };
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
      middleEmulation = true;
      horizontalScrolling = true;
      clickMethod = "clickfinger";
      accelProfile = "adaptive";
      tappingDragLock = true;
      sendEventsMode = "enabled";
      disableWhileTyping = false;
    };
    mouse.additionalOptions = "Option \"HighResolutionWheelScrolling\" \"false\"\n";
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_zenhei
      wqy_microhei
      hack-font
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK TC" "Ubuntu" ];
        sansSerif = [ "Noto Sans CJK TC" "Ubuntu" ];
        monospace = [ "Noto Sans Mono CJK TC" "Ubuntu" ];
      };
    };
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex800121 = {
    isNormalUser = true;
    description = "alex800121";
    extraGroups = [ "sudo" "networkmanager" "wheel" ];
    packages = with pkgs; [
    # firefox
    # thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    htop tmux curl unzip wget neovim alacritty
    git vimPlugins.packer-nvim gcc
    microsoft-edge google-chrome firefox
    cargo rustc go
    vmware-horizon-client
    python39
    dmidecode
    spotify
    libchewing
    gtk3
    sumneko-lua-language-server
    rust-analyzer
    libreoffice
  # ]);
  ]) ++ (with pkgs.python39Packages; [
    pip
    distro psutil distutils_extra distlib  devtools click power py-dmidecode
    setuptools setuptools-git
  ]);

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the Locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
  };
  

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
