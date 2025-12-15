{
  description = "Development environment replicating agents-dev-env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build essentials
            gcc13
            gnumake
            cmake
            ninja
            pkg-config

            # Compilers & toolchains
            clang_18

            # Programming Languages
            python311
            python311Packages.pip
            python311Packages.virtualenv
            uv  # Fast Python package installer and resolver

            nodejs_22
            nodePackages.npm
            nodePackages.pnpm
            nodePackages.yarn
            bun

            go_1_24
            rustc
            cargo

            jdk21

            php84

            ruby_3_3

            perl538

            # Development tools
            git
            curl
            wget
            jq
            vim
            tmux

            # TypeScript & JavaScript tools
            nodePackages.typescript
            nodePackages.eslint
            nodePackages.prettier
            nodePackages.ts-node
            nodePackages.nodemon

            # Build tools
            gnupatch

            # System libraries
            openssl
            openssl.dev
            zlib
            zlib.dev
            libffi
            libffi.dev
            sqlite
            sqlite.dev

            # Databases
            postgresql_16
            redis

            # Python packages (install via pip in shell hook)
            # We'll let mise or pip handle most of these
          ];

          shellHook = ''
            echo "Development environment loaded!"
            echo ""
            echo "Languages available:"
            echo "  Python: $(python3 --version)"
            echo "  uv: $(uv --version)"
            echo "  Node.js: $(node --version)"
            echo "  Go: $(go version | cut -d' ' -f3)"
            echo "  Rust: $(rustc --version | cut -d' ' -f2)"
            echo "  Java: $(java -version 2>&1 | head -1)"
            echo "  PHP: $(php --version | head -1)"
            echo "  Ruby: $(ruby --version)"
            echo ""
            echo "Build tools:"
            echo "  GCC: $(gcc --version | head -1)"
            echo "  Clang: $(clang --version | head -1)"
            echo "  CMake: $(cmake --version | head -1)"
            echo ""
            echo "For additional tools and version overrides, use mise!"
            echo "  Run: mise install"

            # Set up a local pip environment
            export PIP_PREFIX="$PWD/.pip_packages"
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python311.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"

            # Ensure pip packages directory exists
            mkdir -p "$PIP_PREFIX"
          '';

          # Environment variables
          env = {
            # Ensure UTF-8 locale
            LANG = "C.UTF-8";
            LC_ALL = "C.UTF-8";

            # Python
            PYTHON_VERSION = "3.11";

            # Node.js
            NODE_VERSION = "22";
          };
        };

        # You can also define specific package outputs if needed
        packages.default = pkgs.hello;
      }
    );
}
