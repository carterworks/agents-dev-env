{
  description = "AI Development Tools - Configure mise for AI coding agents";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mise.url = "path:../mise";
    mise.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mise }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Import mise module
      imports = [ mise.nixosModules.default ];

      # Create mise config for AI tools
      system.activationScripts.mise-ai-config = ''
        # Ensure mise directories exist
        mkdir -p ${config.environment.variables.MISE_CONFIG_DIR}

        # Create mise config for AI tools if it doesn't exist
        if [ ! -f ${config.environment.variables.MISE_CONFIG_DIR}/config.toml ]; then
          cat > ${config.environment.variables.MISE_CONFIG_DIR}/config.toml <<'EOF'
[tools]
# AI Coding Agents (frequently updated, managed via mise)
# Uncomment and install as needed:
# claude = "latest"
# codex = "latest"
# opencode = "latest"
# aider = "latest"
# cursor = "latest"

# Additional development tools available via mise:
# python = "3.12"    # Override system Python
# node = "22"        # Override system Node
# go = "1.22"        # Override system Go
# uv = "latest"      # Fast Python package manager

[settings]
experimental = true
EOF
        fi

        # Trust the config
        ${pkgs.mise}/bin/mise trust ${config.environment.variables.MISE_CONFIG_DIR}/config.toml || true

        # Install tools defined in config
        ${pkgs.mise}/bin/mise install --yes || true
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
          echo "🤖 AI Development Tools (mise-based)"
          echo "  Configure AI tools in ${config.environment.variables.MISE_CONFIG_DIR or "/etc/mise"}/config.toml"
          echo "  Run 'mise install' to install configured tools"
          eval "$(mise activate bash)"
        '';
      }
    );
  };
}
