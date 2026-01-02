{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Rust toolchain
      environment.systemPackages = with pkgs; [
        # Rust via rustup (matches Ansible approach)
        rustup

        # Or use direct packages (more Nix-native):
        # rustc
        # cargo
        # clippy
        # rustfmt
        # rust-analyzer
      ];

      # Rust environment variables
      environment.variables = {
        RUSTUP_HOME = "/usr/local/rustup";
        CARGO_HOME = "/usr/local/cargo";
      };

      # Add Cargo bin to PATH
      environment.sessionVariables = {
        PATH = [ "/usr/local/cargo/bin" ];
      };

      # System activation script to install Rust components
      system.activationScripts.rustup = lib.mkIf (builtins.elem pkgs.rustup config.environment.systemPackages) ''
        # Install default toolchain if not present
        if [ ! -d /usr/local/rustup ]; then
          mkdir -p /usr/local/rustup /usr/local/cargo
          ${pkgs.rustup}/bin/rustup-init -y --default-toolchain stable --profile default
        fi

        # Ensure components are installed
        ${pkgs.rustup}/bin/rustup component add clippy rustfmt 2>/dev/null || true
      '';
    };

    # Development shell for Rust projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "rust-dev";
        buildInputs = with pkgs; [
          rustc
          cargo
          clippy
          rustfmt
          rust-analyzer
        ];
        shellHook = ''
          echo "🦀 Rust Development Environment"
          echo "  Rust: $(rustc --version)"
          echo "  Cargo: $(cargo --version)"
        '';
      }
    );
  };
}
