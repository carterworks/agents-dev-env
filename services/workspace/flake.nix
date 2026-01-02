{
  description = "Workspace Setup - workspace directory and check-versions script";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Create check-versions script
      environment.systemPackages = [
        (pkgs.writeScriptBin "check-versions" ''
          #!/usr/bin/env bash
          set -e
          echo "==========================================="
          echo "            Dev Environment                "
          echo "==========================================="
          echo ""
          echo "System:"
          echo "  OS:      $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'NixOS')"
          echo "  Kernel:  $(uname -r)"
          echo "  Arch:    $(uname -m)"
          echo ""
          echo "Languages:"
          command -v python3 >/dev/null && echo "  Python:  $(python3 --version 2>&1 | awk '{print $2}')" || echo "  Python:  not installed"
          command -v node >/dev/null && echo "  Node.js: $(node --version)" || echo "  Node.js: not installed"
          command -v go >/dev/null && echo "  Go:      $(go version 2>&1 | awk '{print $3}')" || echo "  Go:      not installed"
          command -v rustc >/dev/null && echo "  Rust:    $(rustc --version 2>&1 | awk '{print $2}')" || echo "  Rust:    not installed"
          command -v java >/dev/null && echo "  Java:    $(java --version 2>&1 | head -1)" || echo "  Java:    not installed"
          command -v ruby >/dev/null && echo "  Ruby:    $(ruby --version 2>&1 | awk '{print $2}')" || echo "  Ruby:    not installed"
          echo ""
          echo "AI Coding Agents (via mise):"
          command -v claude >/dev/null && echo "  claude:   $(claude --version 2>&1 | head -1)" || echo "  claude:   not installed"
          command -v codex >/dev/null && echo "  codex:    $(codex --version 2>&1 | head -1)" || echo "  codex:    not installed"
          command -v opencode >/dev/null && echo "  opencode: $(opencode --version 2>&1 | head -1)" || echo "  opencode: not installed"
          echo ""
          echo "Package Managers:"
          command -v npm >/dev/null && echo "  npm:     $(npm --version)" || echo "  npm:     not installed"
          command -v pnpm >/dev/null && echo "  pnpm:    $(pnpm --version)" || echo "  pnpm:    not installed"
          command -v yarn >/dev/null && echo "  yarn:    $(yarn --version)" || echo "  yarn:    not installed"
          command -v bun >/dev/null && echo "  bun:     $(bun --version)" || echo "  bun:     not installed"
          command -v pip3 >/dev/null && echo "  pip:     $(pip3 --version 2>&1 | awk '{print $2}')" || echo "  pip:     not installed"
          command -v uv >/dev/null && echo "  uv:      $(uv --version 2>&1 | awk '{print $2}')" || echo "  uv:      not installed"
          command -v cargo >/dev/null && echo "  cargo:   $(cargo --version 2>&1 | awk '{print $2}')" || echo "  cargo:   not installed"
          echo ""
          echo "Build Tools:"
          command -v gcc >/dev/null && echo "  gcc:     $(gcc --version | head -1)" || echo "  gcc:     not installed"
          command -v clang >/dev/null && echo "  clang:   $(clang --version | head -1)" || echo "  clang:   not installed"
          command -v cmake >/dev/null && echo "  cmake:   $(cmake --version | head -1 | awk '{print $3}')" || echo "  cmake:   not installed"
          command -v make >/dev/null && echo "  make:    $(make --version | head -1)" || echo "  make:    not installed"
          echo ""
          echo "==========================================="
        '')
      ];

      # Create workspace directory
      system.activationScripts.workspace = ''
        mkdir -p /workspace
        chmod 755 /workspace
      '';

      # Ensure workspace is safe for git
      programs.git.config = {
        safe.directory = "/workspace";
      };
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "workspace";
        shellHook = ''
          echo "📁 Workspace Environment"
          echo "  Workspace: /workspace"
        '';
      }
    );
  };
}
