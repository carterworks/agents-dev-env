{
  description = "JavaScript/TypeScript Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Node.js 22 and JavaScript ecosystem
      environment.systemPackages = with pkgs; [
        # Node.js runtime
        nodejs_22

        # Package managers
        nodePackages.npm
        nodePackages.pnpm
        nodePackages.yarn

        # TypeScript tooling
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.ts-node

        # Linting and formatting
        nodePackages.eslint
        nodePackages.prettier

        # Development tools
        nodePackages.nodemon
        nodePackages.http-server
        nodePackages.serve

        # Testing
        nodePackages.playwright

        # Bun - fast JavaScript runtime
        bun
      ];

      # Environment variables for Node.js
      environment.variables = {
        NODE_PATH = "${pkgs.nodejs_22}/lib/node_modules";
      };

      # Session variables
      environment.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      };
    };

    # Development shell for JavaScript projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "javascript-dev";
        buildInputs = with pkgs; [
          nodejs_22
          bun
        ];
        shellHook = ''
          echo "🟨 JavaScript Development Environment"
          echo "  Node.js: $(node --version)"
          echo "  npm: $(npm --version)"
          echo "  pnpm: $(pnpm --version)"
          echo "  Bun: $(bun --version)"
        '';
      }
    );
  };
}
