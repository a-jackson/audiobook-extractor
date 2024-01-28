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
        packages.audiobook-extractor = pkgs.callPackage ./nix/package.nix { };
        devShells = rec {
          default = with pkgs; mkShell {
            packages = [
              packages.audiobook-extractor
              audible-cli
            ];
          };
        };
      })) // {
      nixosModules.default = { pkgs, config, lib, ... }:
        with lib;
        let
          cfg = config.services.audiobook-extractor;
          package = self.packages.${pkgs.system}.audiobook-extractor;
        in
        {
          options.services.audiobook-extractor = mkOption {
            default = { };
            type = types.attrsOf
              (types.submodule ({ config, name, ... }: {
                options = {
                  configDir = mkOption {
                    type = types.str;
                    default = "/var/lib/audiobook-extractor";
                  };
                  tempDir = mkOption {
                    type = types.str;
                    default = "/tmp/audiobook-extractor";
                  };
                  destinationDir = mkOption {
                    type = types.str;
                  };
                  completeDir = mkOption {
                    type = types.str;
                  };
                  startAt = mkOption {
                    type = types.str;
                    default = "06:00:00";
                  };
                };
              }));
          };

          config = {
            systemd.services =
              mapAttrs'
                (name: abe:
                  let

                  in
                  nameValuePair "audiobook-extractor-${name}" ({
                    environment = {
                      AUDIBLE_CONFIG_DIR = abe.configDir;
                      AUDIBLE_DEST = abe.destinationDir;
                      AUDIBLE_COMPLETE = abe.completeDir;
                      TEMP_DOWNLOAD = abe.tempDir;
                      AUDIBLE_PROFILE = name;
                    };
                    restartIfChanged = false;
                    wants = [ "network-online.target" ];
                    after = [ "network-online.target" ];
                    startAt = [ abe.startAt ];
                    serviceConfig = {
                      ExecStart = "${package}/bin/audiobook-extractor download";
                    };
                  }))
                cfg;

            environment.systemPackages = (lib.mapAttrsToList
              (name: abe:
                let
                  abeCmd = "${package}/bin/audiobook-extractor";
                in
                pkgs.writeShellScriptBin "audiobook-extractor-${name}" ''
                  set -a
                  ${lib.pipe config.systemd.services."audiobook-extractor-${name}".environment [
                    (lib.filterAttrs (n: v: v != null && n != "PATH"))
                    (lib.mapAttrsToList (n: v: "${n}=${v}"))
                    (lib.concatStringsSep "\n")
                  ]}

                  exec ${abeCmd} $@
                '')
              cfg) ++ [
                pkgs.audible-cli
              ];
          };
        };
    };
}
