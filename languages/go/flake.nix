{
  description = "Go Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Go compiler and tools
      environment.systemPackages = with pkgs; [
        go
        gopls          # Go language server
        gotools        # Additional Go tools
        go-tools       # Static analysis tools
        delve          # Go debugger
      ];

      # Go environment variables
      environment.variables = {
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";
      };

      # Add Go bin to PATH
      environment.sessionVariables = {
        PATH = [ "$HOME/go/bin" ];
      };
    };

    # Development shell for Go projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "go-dev";
        buildInputs = with pkgs; [
          go
          gopls
        ];
        shellHook = ''
          echo "🐹 Go Development Environment"
          echo "  Go: $(go version | awk '{print $3}')"
        '';
      }
    );
  };
}
