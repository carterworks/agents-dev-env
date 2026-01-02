{
  description = "System Utilities - jq, vim, tmux, ripgrep, fd, etc.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Essential system utilities
      environment.systemPackages = with pkgs; [
        # Text processing
        jq
        yq-go

        # Editors
        vim
        neovim

        # Terminal multiplexer
        tmux
        screen

        # Modern Unix tools
        ripgrep      # Better grep
        fd           # Better find
        bat          # Better cat
        exa          # Better ls
        fzf          # Fuzzy finder

        # Archive tools
        unzip
        zip
        gzip
        bzip2
        xz
        p7zip

        # Network tools
        curl
        wget

        # System monitoring
        htop
        btop

        # File tools
        tree
        file

        # Other utilities
        less
        which
        gnused
        gnugrep
        coreutils
        findutils
      ];

      # Configure programs
      programs.vim.defaultEditor = true;
      programs.tmux.enable = true;
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "utilities";
        buildInputs = with pkgs; [
          ripgrep
          fd
          jq
          vim
          tmux
        ];
        shellHook = ''
          echo "🔨 System Utilities"
          echo "  ripgrep: $(rg --version | head -1)"
          echo "  fd: $(fd --version)"
          echo "  jq: $(jq --version)"
        '';
      }
    );
  };
}
