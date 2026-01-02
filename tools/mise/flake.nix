{
  description = "mise - Polyglot Runtime Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Install mise
      environment.systemPackages = with pkgs; [
        mise
      ];

      # mise environment variables
      environment.variables = {
        MISE_DATA_DIR = lib.mkDefault "/var/lib/mise";
        MISE_CONFIG_DIR = lib.mkDefault "/etc/mise";
        MISE_CACHE_DIR = lib.mkDefault "/var/cache/mise";
      };

      # Add mise shims to PATH
      environment.sessionVariables = {
        PATH = [ "/var/lib/mise/shims" ];
      };

      # Add mise activation to shell profiles
      programs.bash.interactiveShellInit = ''
        eval "$(${pkgs.mise}/bin/mise activate bash)"
      '';

      programs.zsh.interactiveShellInit = lib.mkIf config.programs.zsh.enable ''
        eval "$(${pkgs.mise}/bin/mise activate zsh)"
      '';

      # Create mise directories
      systemd.tmpfiles.rules = [
        "d /var/lib/mise 0755 root root -"
        "d /etc/mise 0755 root root -"
        "d /var/cache/mise 0755 root root -"
      ];
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "mise";
        buildInputs = with pkgs; [
          mise
        ];
        shellHook = ''
          echo "🔧 mise - Polyglot Runtime Manager"
          echo "  mise: $(mise --version)"
          eval "$(mise activate bash)"
        '';
      }
    );
  };
}
