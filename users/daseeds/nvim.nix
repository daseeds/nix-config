{
  inputs,
  pkgs,
  ...
}:
{

  programs.nixvim = {
    enable = true;
    enableMan = true; # install man pages for nixvim options

    clipboard.register = "unnamedplus"; # use system clipboard instead of internal registers

  };  
}