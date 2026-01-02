{
  description = "C/C++ Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # C/C++ compilers and build tools
      environment.systemPackages = with pkgs; [
        # Compilers
        gcc
        clang
        llvm

        # Build systems
        cmake
        ninja
        gnumake

        # Build tools
        pkg-config
        autoconf
        automake
        libtool

        # Language servers
        clang-tools  # Includes clangd
        ccls

        # Debuggers
        gdb
        lldb
      ];

      # C/C++ environment variables
      environment.variables = {
        CC = "gcc";
        CXX = "g++";
      };
    };

    # Development shell for C/C++ projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "cpp-dev";
        buildInputs = with pkgs; [
          gcc
          clang
          cmake
          ninja
        ];
        shellHook = ''
          echo "⚙️  C/C++ Development Environment"
          echo "  GCC: $(gcc --version | head -1)"
          echo "  Clang: $(clang --version | head -1)"
          echo "  CMake: $(cmake --version | head -1 | awk '{print $3}')"
        '';
      }
    );
  };
}
