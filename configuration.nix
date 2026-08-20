{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  myPackages = import ./packages/default.nix { inherit pkgs inputs; };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # ---- Bootloader ------
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # ---- Kernel -----
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "pci=realloc" "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];

  # ---- GPU -----
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  specialisation.gaming.configuration = {
    hardware.nvidia.prime = {
      sync.enable = lib.mkForce true;
      offload.enable = lib.mkForce false;
      offload.enableOffloadCmd = lib.mkForce false;
    };
  };

  # ---- ZRAM ------
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ---- Basics -----
  networking = {
    hostName = "nyxos";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  services.udisks2.enable = true;
  services.printing.enable = true;
  services.upower.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ------------- Power -------------
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # ------------- Fonts -------------
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ------------- Wayland & Hyprland -------------
  services.displayManager.ly.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "hyprland";
    config.hyprland.default = "hyprland";
  };

  # ------- Audio -----------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire = {
      "99-lowlatency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 512;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 512;
        };
      };
      "60-echo-cancel" = {
        context.modules = [
          {
            name = "libpipewire-module-echo-cancel";
            args = {
              source = "alsa_input.pci-0000_05_00.6.HiFi__Mic1__source";
              sink   = "alsa_output.pci-0000_05_00.6.HiFi__Speaker__sink";

              "library.name" = "aec/libspa-aec-webrtc";
              "aec.args" = {
                "webrtc.gain_control" = false;
                "webrtc.voice_detection" = true;
              };
              "source.props" = {
                "node.name" = "Echo Cancellation Source";
                "node.description" = "Echo-Cancelled Mic";
              };
              "sink.props" = {
                "node.name" = "Echo Cancellation Sink";
                "node.description" = "Echo-Cancel Sink";
              };
            };
          }
        ];
      };
    };
  };

  # -------- Gaming ---------------
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
      inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton
    ];
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };


  # ---------- System Programs ----------
  programs.git.enable = true;
  programs.zsh.enable = true;

  programs.nix-ld.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
    ];
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.firefox.enable = true;

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };


  # ------- Users -----------
  users.users.frenny = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "input" "video" "audio" "gamemode" "libvirtd" "kvm" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };


  # --------- virtualisation ---------
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  # SPICE for clipboard/USB passthrough between host and guest
  virtualisation.spiceUSBRedirection.enable = true;

  # --------- Packages -------------
  environment.systemPackages = myPackages;

  # ----------- Nix ------------------
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "~/.nyxos/nixos#nyxos";
    dates = "weekly";
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
