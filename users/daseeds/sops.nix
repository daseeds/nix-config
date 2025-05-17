{ inputs, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/daseeds/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "private_keys/daseeds" = {
        path = "~/.ssh/daseeds";
      };
    };
  };
}