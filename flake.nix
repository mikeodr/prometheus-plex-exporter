{
  description = "prometheus exporter for plex media server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
  }: let
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = eachSystem (pkgs: {
      default = pkgs.buildGo124Module {
        pname = "prometheus-plex-exporter";
        version =
          if (self ? shortRev)
          then self.shortRev
          else "dev";
        subPackages = [
          "cmd/prometheus-plex-exporter"
        ];
        src = ./.;
        vendorHash = "sha256-RhP9bp2GQd5SyAQ8IzpOiUhPEZqkxhmcEESC9E6AfRM=";
      };
    });

    overlays.default = final: prev: {
      prometheus-plex-exporter = self.packages.${prev.stdenv.hostPlatform.system}.default;
    };

    nixosModules.default = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.services.prometheus-plex-exporter;
    in {
      options.services.prometheus-plex-exporter = {
        enable = lib.mkEnableOption "prometheus exporter for plex media server";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.prometheus-plex-exporter;
          description = "Package to use for prometheus-plex-exporter.";
        };

        bindAddress = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Address to bind to, defaults to all interfaces.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 9000;
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "nobody";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "nogroup";
        };

        plexServer = lib.mkOption {
          type = lib.types.str;
          default = "http://localhost:32400";
          description = "The URL of the Plex server to monitor.";
        };

        plexToken = lib.mkOption {
          type = lib.types.str;
          description = "The Plex token to use to authenticate with the Plex server.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the firewall for the prometheus-plex-exporter port.";
        };
      };

      config = lib.mkIf cfg.enable {
        nixpkgs.overlays = [self.overlays.default];
        networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall [cfg.port];

        systemd.services.prometheus-plex-exporter = {
          description = "Prometheus Plex Exporter";
          after = ["network.target"];
          wants = ["network.target"];
          environment = {
            PLEX_SERVER = cfg.plexServer;
            PLEX_TOKEN = cfg.plexToken;
          };
          serviceConfig = {
            User = "${cfg.user}";
            Group = "${cfg.group}";
            ExecStart = ''
              ${cfg.package}/bin/prometheus-plex-exporter \
              ${lib.optionalString (cfg.bindAddress != "") "--bind-addr ${cfg.bindAddress}"} \
              ${lib.optionalString (cfg.port != 9000) ("--port " + toString cfg.port)}
            '';
            Restart = "on-failure";
          };
          wantedBy = ["multi-user.target"];
        };
      };
    };
  };
}
