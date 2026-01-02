{
  description = "Ruby Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Ruby and development tools
      environment.systemPackages = with pkgs; [
        ruby_3_3
        rubyPackages.bundler
        rubyPackages.rake
        rubyPackages.solargraph  # Ruby language server
      ];

      # Ruby environment variables
      environment.variables = {
        GEM_HOME = "$HOME/.gem";
        GEM_PATH = "$HOME/.gem";
      };

      # Add gem bin to PATH
      environment.sessionVariables = {
        PATH = [ "$HOME/.gem/bin" ];
      };
    };

    # Development shell for Ruby projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "ruby-dev";
        buildInputs = with pkgs; [
          ruby_3_3
        ];
        shellHook = ''
          echo "💎 Ruby Development Environment"
          echo "  Ruby: $(ruby --version | awk '{print $2}')"
        '';
      }
    );
  };
}
