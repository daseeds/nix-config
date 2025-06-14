{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    # User-level secrets
    secrets = {
      # SSH private keys
      "private_keys/daseeds" = {
        path = "${config.home.homeDirectory}/.ssh/daseeds";
        mode = "0600";
      };
    };
  };
  # Ensure SSH directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    target = ".ssh/.keep";
  };

  home.file.".ssh/config" = {
    text = ''
      Host personal
        HostName your-server.com
        User daseeds
        IdentityFile ~/.ssh/daseeds
        IdentitiesOnly yes
    '';
    target = ".ssh/config";
  };

  # Set proper permissions for SSH directory
  home.activation.fixSshPermissions = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD chmod 700 ${config.home.homeDirectory}/.ssh
    $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/config
  '';
}