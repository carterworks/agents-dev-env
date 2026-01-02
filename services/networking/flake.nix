{
  description = "Networking Services - Tailscale VPN";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Tailscale VPN service
      services.tailscale = {
        enable = true;
        package = pkgs.tailscale;
      };

      # Open firewall for Tailscale
      networking.firewall = {
        checkReversePath = "loose";
        allowedUDPPorts = [ config.services.tailscale.port ];
        trustedInterfaces = [ "tailscale0" ];
      };

      # Tailscale package in system packages
      environment.systemPackages = with pkgs; [
        tailscale
      ];

      # NOTE: To authenticate Tailscale, run after system activation:
      # sudo tailscale up --authkey=YOUR_AUTH_KEY
      # Or use environment variable TAILSCALE_AUTHKEY
      # For automated setup, consider using sops-nix or agenix for secrets management
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "networking-services";
        buildInputs = with pkgs; [
          tailscale
        ];
        shellHook = ''
          echo "🌐 Networking Services"
          echo "  Tailscale: $(tailscale version)"
        '';
      }
    );
  };
}
