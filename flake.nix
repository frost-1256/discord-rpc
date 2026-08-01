{
  description = "Discord RPC server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    server = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      zip = pkgs.fetchurl {
        url = "https://github.com/lolamtisch/Discord-RPC-Extension/releases/download/0.3.0/linux_no_tray.zip";
        sha256 = "sha256-2/vMMSNWTT9R1ZzAuIWgTXnbXVQE7/85e2bTYiqBJ50=";
      };
      bin = pkgs.stdenv.mkDerivation {
        pname = "rpc-server-bin";
        version = "0.3.0";
        src = zip;
        sourceRoot = ".";
        nativeBuildInputs = [ pkgs.unzip ];
        dontConfigure = true;
        dontBuild = true;
        dontStrip = true;
        dontPatchELF = true;
        installPhase = ''
          mkdir -p $out/bin
          unzip $src -d $out/bin
          chmod +x $out/bin/server_linux_no_tray_debug
        '';
      };
    in pkgs.buildFHSEnv {
      name = "rpc-server";
      targetPkgs = pkgs: [ pkgs.glibc pkgs.stdenv.cc.cc.lib ];
      runScript = "${bin}/bin/server_linux_no_tray_debug";
    };
  in {
    packages = forAllSystems (system: {
      rpc-server = server system;
      default = server system;
    });

    apps = forAllSystems (system: {
      rpc-server = {
        type = "app";
        program = "${self.packages.${system}.rpc-server}/bin/rpc-server";
      };
      default = self.apps.${system}.rpc-server;
    });

    nixosModules.default = { pkgs, lib, ... }: {
      imports = [ ./module.nix ];
      services.rpc-server.package = lib.mkDefault
        self.packages.${pkgs.system}.rpc-server;
    };
  };
}
