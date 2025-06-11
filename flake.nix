{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # helix editor, use the master branch
    helix.url = "github:helix-editor/helix/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Removed agenix - consolidating on SOPS-nix
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };    
    secrets = {
      url = "git+ssh://git@github.com/daseeds/nix-private.git?shallow=1";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, home-manager, vscode-server, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations = {
      eurydice =  nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./hosts/eurydice
          # Use improved SOPS configuration
          ./hosts/common/sops.nix
          # Use improved user configuration with SOPS-managed password
          ./users/daseeds
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = false;

            home-manager.users.daseeds.imports = [
              inputs.nix-index-database.hmModules.nix-index
              inputs.nixvim.homeManagerModules.nixvim
              # Use improved SOPS configuration for user secrets
              ./users/daseeds/sops-minimal.nix
              ./users/daseeds/dots.nix
              ./users/daseeds/nvim.nix
            ];
          }
          
        ];
      };
    };
  };
}
