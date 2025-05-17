{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    nixpkgs.pkgs = import <nixpkgs> { };

    enable = true;
    enableMan = true; # install man pages for nixvim options

    clipboard.register = "unnamedplus"; # use system clipboard instead of internal registers

  };  
}