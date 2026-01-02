{
  description = "Python Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Python 3 with development tools
      environment.systemPackages = with pkgs; [
        # Python runtime
        python3Full
        python3Packages.pip
        python3Packages.virtualenv
        python3Packages.setuptools
        python3Packages.wheel

        # Fast package manager
        uv

        # Python packages from Ansible
        python3Packages.pyyaml
        python3Packages.jinja2
        python3Packages.requests
        python3Packages.cryptography

        # Development libraries
        python3Packages.python-lsp-server
      ];

      # Development headers for Python C extensions
      environment.systemPackages = with pkgs; [
        libffi
        openssl
        zlib
        bzip2
        readline
        sqlite
        ncurses
        libxml2
        libxslt
        tk
        xz
      ];

      # Python environment variables
      environment.variables = {
        PYTHONPATH = lib.mkDefault "";
      };

      # Allow pip install --break-system-packages (mimicking Ansible behavior)
      environment.sessionVariables = {
        PIP_BREAK_SYSTEM_PACKAGES = "1";
      };
    };

    # Development shell for Python projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "python-dev";
        buildInputs = with pkgs; [
          python3Full
          uv
        ];
        shellHook = ''
          echo "🐍 Python Development Environment"
          echo "  Python: $(python3 --version)"
          echo "  pip: $(pip3 --version | awk '{print $2}')"
          echo "  uv: $(uv --version)"
        '';
      }
    );
  };
}
