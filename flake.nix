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
        ldflags = [
          "-s"
        ];
        src = ./.;
        vendorHash = "sha256-RhP9bp2GQd5SyAQ8IzpOiUhPEZqkxhmcEESC9E6AfRM=";
        meta.mainProgram = "prometheus-plex-exporter";
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
      inherit
        (lib)
        getExe
        mkEnableOption
        mkIf
        mkOption
        optional
        optionalString
        toString
        ;

      inherit
        (lib.types)
        bool
        nullOr
        package
        path
        port
        str
        ;

      cfg = config.services.prometheus-plex-exporter;
    in {
      options.services.prometheus-plex-exporter = {
        enable = mkEnableOption "prometheus exporter for plex media server";

        package = mkOption {
          type = package;
          default = pkgs.prometheus-plex-exporter;
          description = "Package to use for prometheus-plex-exporter.";
        };

        bindAddress = mkOption {
          type = str;
          default = "";
          description = "Address to bind to, defaults to all interfaces.";
        };

        port = mkOption {
          type = port;
          default = 9000;
        };

        user = mkOption {
          type = str;
          default = "nobody";
        };

        group = mkOption {
          type = str;
          default = "nogroup";
        };

        plexServer = mkOption {
          type = str;
          default = "http://localhost:32400";
          description = "The URL of the Plex server to monitor. Ignored if environmentFile is set.";
        };

        plexToken = mkOption {
          type = str;
          description = "The Plex token to use to authenticate with the Plex server. Ignored if environmentFile is set.";
        };

        environmentFile = mkOption {
          type = nullOr path;
          default = null;
          description = "Path to a file containing environment variables to set for the service. Setting this ignores plexServer and plexToken options. Must set PLEX_SERVER and PLEX_TOKEN variables.";
        };

        openFirewall = mkOption {
          type = bool;
          default = false;
          description = "Whether to open the firewall for the prometheus-plex-exporter port.";
        };
      };

      config = mkIf cfg.enable {
        nixpkgs.overlays = [self.overlays.default];
        networking.firewall.allowedTCPPorts = optional cfg.openFirewall [cfg.port];

        systemd.services.prometheus-plex-exporter = {
          description = "Prometheus Plex Exporter";
          after = ["network.target"];
          wants = ["network.target"];
          environment = mkIf (cfg.environmentFile == null) {
            PLEX_SERVER = cfg.plexServer;
            PLEX_TOKEN = cfg.plexToken;
          };
          serviceConfig = {
            EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
            User = "${cfg.user}";
            Group = "${cfg.group}";
            ExecStart = ''
              ${getExe cfg.package} \
              ${optionalString (cfg.bindAddress != "") "--bind-addr ${cfg.bindAddress}"} \
              ${optionalString (cfg.port != 9000) ("--port " + toString cfg.port)}
            '';
            Restart = "on-failure";
          };
          wantedBy = ["multi-user.target"];
        };
      };
    };
  };
}
