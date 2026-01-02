{
  description = "Java Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Java JDK and build tools
      environment.systemPackages = with pkgs; [
        # Default JDK (OpenJDK)
        jdk

        # Build tools
        maven
        gradle

        # Java language server
        jdt-language-server
      ];

      # Java environment variables
      environment.variables = {
        JAVA_HOME = "${pkgs.jdk}";
      };

      # Add Java to PATH
      environment.sessionVariables = {
        PATH = [ "${pkgs.jdk}/bin" ];
      };
    };

    # Development shell for Java projects
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "java-dev";
        buildInputs = with pkgs; [
          jdk
          maven
        ];
        shellHook = ''
          echo "☕ Java Development Environment"
          echo "  Java: $(java --version 2>&1 | head -1)"
          echo "  Maven: $(mvn --version 2>&1 | head -1)"
        '';
      }
    );
  };
}
