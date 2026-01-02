{
  description = "Base system configuration - locale, environment variables, and core settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Locale configuration
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ALL = "en_US.UTF-8";
        LANG = "en_US.UTF-8";
      };

      # Console configuration
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      # Time zone (can be overridden)
      time.timeZone = lib.mkDefault "UTC";

      # Enable documentation
      documentation.enable = true;
      documentation.man.enable = true;

      # Base environment variables
      environment.variables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      # Session variables
      environment.sessionVariables = {
        # Ensure proper locale is set
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };

      # System state version (adjust as needed)
      system.stateVersion = lib.mkDefault "24.05";
    };

    # Optional: Provide a devShell for testing
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "base-config-shell";
        buildInputs = with pkgs; [ ];
        shellHook = ''
          echo "Base configuration loaded"
          echo "Locale: en_US.UTF-8"
        '';
      }
    );
  };
}
