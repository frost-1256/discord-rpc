{ config, lib, pkgs, ... }:

let
  cfg = config.services.rpc-server;
in
{
  options.services.rpc-server = {
    enable = lib.mkEnableOption "Discord RPC server";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The rpc-server package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.rpc-server = {
      Unit = {
        Description = "Discord RPC server";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/rpc-server";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
