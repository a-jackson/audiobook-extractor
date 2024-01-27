{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    resholve.url = "github:abathur/resholve";
    resholve.inputs.nixpkgs.follows = "nixpkgs";
    resholve.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, resholve, ... }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      rec
      {
        defaultPackage = packages.audiobook-extractor;
        packages.audiobook-extractor = pkgs.callPackage ./nix/package.nix {};
        devShells = rec {
          default = with pkgs; mkShell {
            packages = [
              packages.audiobook-extractor
            ];
          };
        };
      }));
}
