{
  description = "Version Control Tools - Git, Git LFS, GitHub CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Git and related tools
      environment.systemPackages = with pkgs; [
        git
        git-lfs
        gh          # GitHub CLI
        tig         # Text-mode interface for Git
        delta       # Better git diff
      ];

      # Git configuration
      programs.git = {
        enable = true;
        lfs.enable = true;

        config = {
          # Safe directory configuration
          safe.directory = "/workspace";

          # Default init branch
          init.defaultBranch = "main";

          # Better diff colors
          color.ui = "auto";
        };
      };

      # System activation to setup Git LFS
      system.activationScripts.gitLfs = ''
        ${pkgs.git-lfs}/bin/git lfs install --system
      '';
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "version-control-dev";
        buildInputs = with pkgs; [
          git
          gh
        ];
        shellHook = ''
          echo "🔧 Version Control Tools"
          echo "  Git: $(git --version | awk '{print $3}')"
          echo "  GitHub CLI: $(gh --version | head -1)"
        '';
      }
    );
  };
}
