{ ... }:
let
  home = {
    username = "daseeds";
    homeDirectory = "/home/daseeds";
    stateVersion = "24.11";
  };
in
{

  nixpkgs = {
    overlays = [ ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = home;

  imports = [
    ../../dots/zsh/default.nix
    ./packages.nix
    ./gitconfig.nix
  ];

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}