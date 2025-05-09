{
  inputs,
  lib,
  config,
  ...
}:
{

  programs.git = {
    enable = true;
    userName = "Daseeds";
    userEmail = "cyril.jean@gmail.com";

    extraConfig = {
      core = {
        sshCommand = "ssh -o 'IdentitiesOnly=yes' -i ~/.ssh/daseeds";
      };
    };
  };
}