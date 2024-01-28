{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.audiobook-extractor;
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
              ExecStart = "${pkgs.audiobook-extractor}/bin/audiobook-extractor download";
            };
          }))
        cfg;

    environment.systemPackages = lib.mapAttrsToList
      (name: abe:
        let
          abeCmd = "${packages.audiobook-extractor}/bin/audiobook-extractor";
        in
        pkgs.writeShellScriptBin "audiobook-exxtractor-${name}" ''
          set -a
          ${lib.pipe config.systemd.services."audiobook-extractor-${name}".environment [
            (lib.filterAttrs (n: v: v != null && n != "PATH"))
            (lib.mapAttrsToList (n: v: "${n}=${v}"))
            (lib.concatStringsSep "\n")
          ]}

          exec ${abeCmd} $@
        '')
      cfg;
  };
}
