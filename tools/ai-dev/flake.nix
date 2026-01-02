{
  description = "AI Development Tools - mise for AI coding agents";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # mise - polyglot runtime manager for AI coding agents
      environment.systemPackages = with pkgs; [
        mise
      ];

      # mise configuration directories
      environment.variables = {
        MISE_DATA_DIR = "/mise";
        MISE_CONFIG_DIR = "/mise";
        MISE_CACHE_DIR = "/mise/cache";
      };

      # Add mise shims to PATH
      environment.sessionVariables = {
        PATH = [ "/mise/shims" ];
      };

      # Create mise directories and config
      system.activationScripts.mise = ''
        # Create mise directories
        mkdir -p /mise /mise/cache

        # Create mise config if it doesn't exist
        if [ ! -f /mise/config.toml ]; then
          cat > /mise/config.toml <<'EOF'
[tools]
# AI Coding Agents (frequently updated, managed via mise)
# Uncomment and install as needed:
# claude = "latest"
# codex = "latest"
# opencode = "latest"

# Additional tools available via mise if needed:
# python = "3.12"    # Override system Python
# node = "20"        # Override system Node
# go = "1.22"        # Override system Go
# uv = "latest"      # Fast Python package manager

[settings]
experimental = true
EOF
        fi

        # Trust the config
        ${pkgs.mise}/bin/mise trust /mise/config.toml || true

        # Install tools defined in config
        ${pkgs.mise}/bin/mise install --yes || true
      '';

      # Add mise activation to shell profiles
      programs.bash.interactiveShellInit = ''
        eval "$(${pkgs.mise}/bin/mise activate bash)"
      '';

      programs.zsh.interactiveShellInit = lib.mkIf config.programs.zsh.enable ''
        eval "$(${pkgs.mise}/bin/mise activate zsh)"
      '';
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "ai-dev-tools";
        buildInputs = with pkgs; [
          mise
        ];
        shellHook = ''
          echo "🤖 AI Development Tools"
          echo "  mise: $(mise --version)"
          eval "$(mise activate bash)"
        '';
      }
    );
  };
}
