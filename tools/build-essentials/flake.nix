{
  description = "Build Essentials - Development headers and libraries";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Build essentials and development libraries
      environment.systemPackages = with pkgs; [
        # Core build tools (some overlap with cpp module is intentional)
        gnumake
        patch

        # Development headers/libraries
        openssl
        openssl.dev
        zlib
        zlib.dev
        bzip2
        bzip2.dev
        readline
        readline.dev
        sqlite
        sqlite.dev
        ncurses
        ncurses.dev
        libffi
        libffi.dev
        libxml2
        libxml2.dev
        libxslt
        libxslt.dev
        xz
        xz.dev

        # SSL/crypto
        pkg-config

        # Conan package manager (from Ansible pip packages)
        conan
      ];

      # PKG_CONFIG_PATH for development
      environment.variables = {
        PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" (with pkgs; [
          openssl.dev
          zlib.dev
          libffi.dev
          sqlite.dev
          readline.dev
        ]);
      };
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "build-essentials";
        buildInputs = with pkgs; [
          pkg-config
          openssl.dev
          zlib.dev
        ];
        shellHook = ''
          echo "🔧 Build Essentials"
          echo "  pkg-config: $(pkg-config --version)"
          echo "  OpenSSL: $(pkg-config --modversion openssl)"
        '';
      }
    );
  };
}
