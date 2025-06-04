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
      
      "private_keys/github" = {
        path = "${config.home.homeDirectory}/.ssh/github";
        mode = "0600";
      };

      # Git configuration with sensitive data
      "git/signing_key" = {
        path = "${config.home.homeDirectory}/.config/git/signing_key";
        mode = "0600";
      };

      # Application credentials
      "credentials/github_token" = {};
      "credentials/docker_config" = {
        path = "${config.home.homeDirectory}/.docker/config.json";
        mode = "0600";
      };

      # Environment variables for development
      "env/development" = {};
      
      # GPG keys
      "gpg/private_key" = {};
    };
  };

  # Ensure SSH directory exists with correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    target = ".ssh/.keep";
  };

  home.file.".ssh/config" = {
    text = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/github
        IdentitiesOnly yes

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