{ inputs, config, lib, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      # Use multiple key sources for redundancy
      sshKeyPaths = [ 
        "/etc/ssh/ssh_host_ed25519_key" 
        "/etc/ssh/ssh_host_rsa_key"
      ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # System-level secrets
    secrets = {
      # User password hash
      "users/daseeds/password" = {
        neededForUsers = true;
      };
      
      # SSH host keys for consistent host identity
      "ssh/host_ed25519_key" = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      
      "ssh/host_ed25519_key.pub" = {
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        owner = "root";
        group = "root";
        mode = "0644";
      };

      # Network configuration secrets
      "network/wifi_password" = {};
      
      # Service credentials
      "services/backup_key" = {};
    };
  };

  # Ensure SSH service uses our managed keys
  services.openssh = {
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}