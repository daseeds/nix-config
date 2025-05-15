{
  config,
  pkgs,
  inputs,
  ...
}:
{
#   imports = [
#     # Include the results of the hardware scan.
#     ./hardware-configuration.nix
#   ];   
  # Enable the Flakes feature and the accompanying new nix command-line tool
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common
  ];


    # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "eurydice"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.hostId = "d5960503";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "fr";
  #   useXkbConfig = true; # use xkb.options in tty.
   };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  services.hddfancontrol = {
    enable = true;
    disks = [
      "/dev/disk/by-label/main_pool"
    ];
    pwmPaths = [ "/sys/class/hwmon/hwmon1/device/pwm2" ];
    extraArgs = [
      "--pwm-start-value=50"
      "--pwm-stop-value=50"
      "--smartctl"
      "-i 30"
      "--spin-down-time=900"
    ];
  };

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    cpufrequtils
    gnumake
    gcc
    powertop
    git
    wget
    age
    # sops-nix
    ssh-to-age
    inputs.helix.packages."${pkgs.system}".helix
  ];


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  system.stateVersion = "24.11";
}