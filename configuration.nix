# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    systemd.enable = true;
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daseeds = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTSDCWQn/+uOELLgIG5eYuQk+t8hRn9NzSYNaLaFBPTs2vwcjlGwbFhA4dCE42wcQWjp0b7tr2O5AUtVw1kh1WGN04VrgVaof8/R8yprmh8eNsfcww8Iw3qfR+/acJp4zVoTuCMqsgu89G8GnJDJ5hjJ5xMYTz1e6CFF2fQCK74pDaS9Nk5a+ClB/EIdI5JN98CocfoPq4RYVKyVW/X3P02ZRm4Fs/GJKiaLkiy8XqqQTxjF1KuV2X3pZPZG2bvB1DRJd+9ZqWSsvzyoEX7w5aouRcGdNNRHKvm1H+EU5pZez5snuhxXV+HW/ofoi8cNpRBJfA1VTcavhmboIFMhVATzBlPYd8pEt06KB3TMqNBqr37gvzH2iwQJIw+J9diSP0sdFPwCbsL4cXEths/rEasvSwBvpmf6+NSZj9d5b0adKYR37e7iTp3EsDK5dCOXPkNX2KuVHZ0sdpgSvf5IJ/e9pHkt/WqS/ooZju1G/Jzym7iG3vVGJ+DA7F7f15CwMdDISMuyhLCzKsLN5w9NijIQbb09SDbuXq4kzy96ZVkxrd3CouHFCSJL72Va3cAx9kO4CcEWJl0ngAbvtgxGjNfE6S3tga2I7iZsY9Ot/HPWP+4lZ2EVGpPm8Os4H5R29cOiwapTeeU2c51NtiskoMvdlrujDl+nFxMjWQ0XE77Q== cyril.jean@gmail.com"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

