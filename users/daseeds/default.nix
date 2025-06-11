{
  config,
  inputs,
  pkgs,
  ...
}:
{

  nix.settings.trusted-users = [ "daseeds" ];
  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  users = {
    users = {
      daseeds = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
#        hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
          "networkmanager"  # Added for network management
          "docker"          # Added for container management
        ];
        group = "daseeds";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTSDCWQn/+uOELLgIG5eYuQk+t8hRn9NzSYNaLaFBPTs2vwcjlGwbFhA4dCE42wcQWjp0b7tr2O5AUtVw1kh1WGN04VrgVaof8/R8yprmh8eNsfcww8Iw3qfR+/acJp4zVoTuCMqsgu89G8GnJDJ5hjJ5xMYTz1e6CFF2fQCK74pDaS9Nk5a+ClB/EIdI5JN98CocfoPq4RYVKyVW/X3P02ZRm4Fs/GJKiaLkiy8XqqQTxjF1KuV2X3pZPZG2bvB1DRJd+9ZqWSsvzyoEX7w5aouRcGdNNRHKvm1H+EU5pZez5snuhxXV+HW/ofoi8cNpRBJfA1VTcavhmboIFMhVATzBlPYd8pEt06KB3TMqNBqr37gvzH2iwQJIw+J9diSP0sdFPwCbsL4cXEths/rEasvSwBvpmf6+NSZj9d5b0adKYR37e7iTp3EsDK5dCOXPkNX2KuVHZ0sdpgSvf5IJ/e9pHkt/WqS/ooZju1G/Jzym7iG3vVGJ+DA7F7f15CwMdDISMuyhLCzKsLN5w9NijIQbb09SDbuXq4kzy96ZVkxrd3CouHFCSJL72Va3cAx9kO4CcEWJl0ngAbvtgxGjNfE6S3tga2I7iZsY9Ot/HPWP+4lZ2EVGpPm8Os4H5R29cOiwapTeeU2c51NtiskoMvdlrujDl+nFxMjWQ0XE77Q== cyril.jean@gmail.com"
        ];
      };
    };
    groups = {
      daseeds = {
        gid = 1000;
      };
    };
  };
  
  programs.zsh.enable = true;

  # Security improvements
  security = {
    # Enable sudo timeout
    sudo.extraConfig = ''
      Defaults timestamp_timeout=15
      Defaults passwd_timeout=0
    '';
   

  };

  # Additional security packages
  environment.systemPackages = with pkgs; [
    # Security tools
    fail2ban
    # lynis
    # rkhunter
  ];

  services.vscode-server.enable = true;

  # Enable fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          bantime = 3600;
        };
      };
    };
  };
}