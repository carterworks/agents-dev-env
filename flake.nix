{
  description = "Modular Development Environment - Compose Your Stack";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Base configuration
    base.url = "path:./base";
    base.inputs.nixpkgs.follows = "nixpkgs";

    # Language flakes
    javascript.url = "path:./languages/javascript";
    javascript.inputs.nixpkgs.follows = "nixpkgs";

    python.url = "path:./languages/python";
    python.inputs.nixpkgs.follows = "nixpkgs";

    rust.url = "path:./languages/rust";
    rust.inputs.nixpkgs.follows = "nixpkgs";

    go.url = "path:./languages/go";
    go.inputs.nixpkgs.follows = "nixpkgs";

    ruby.url = "path:./languages/ruby";
    ruby.inputs.nixpkgs.follows = "nixpkgs";

    java.url = "path:./languages/java";
    java.inputs.nixpkgs.follows = "nixpkgs";

    cpp.url = "path:./languages/cpp";
    cpp.inputs.nixpkgs.follows = "nixpkgs";

    # Tool flakes
    version-control.url = "path:./tools/version-control";
    version-control.inputs.nixpkgs.follows = "nixpkgs";

    databases.url = "path:./tools/databases";
    databases.inputs.nixpkgs.follows = "nixpkgs";

    utilities.url = "path:./tools/utilities";
    utilities.inputs.nixpkgs.follows = "nixpkgs";

    build-essentials.url = "path:./tools/build-essentials";
    build-essentials.inputs.nixpkgs.follows = "nixpkgs";

    ai-dev.url = "path:./tools/ai-dev";
    ai-dev.inputs.nixpkgs.follows = "nixpkgs";

    # Service flakes
    networking.url = "path:./services/networking";
    networking.inputs.nixpkgs.follows = "nixpkgs";

    workspace.url = "path:./services/workspace";
    workspace.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Full development environment with all modules
    nixosConfigurations.full = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.base.nixosModules.default
        inputs.javascript.nixosModules.default
        inputs.python.nixosModules.default
        inputs.rust.nixosModules.default
        inputs.go.nixosModules.default
        inputs.ruby.nixosModules.default
        inputs.java.nixosModules.default
        inputs.cpp.nixosModules.default
        inputs.version-control.nixosModules.default
        inputs.databases.nixosModules.default
        inputs.utilities.nixosModules.default
        inputs.build-essentials.nixosModules.default
        inputs.ai-dev.nixosModules.default
        inputs.networking.nixosModules.default
        inputs.workspace.nixosModules.default
      ];
    };

    # Predefined stacks for common use cases
    nixosConfigurations = {
      # JavaScript/TypeScript focused stack
      javascript-stack = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.base.nixosModules.default
          inputs.javascript.nixosModules.default
          inputs.version-control.nixosModules.default
          inputs.databases.nixosModules.default
          inputs.utilities.nixosModules.default
          inputs.workspace.nixosModules.default
        ];
      };

      # Python data science stack
      python-stack = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.base.nixosModules.default
          inputs.python.nixosModules.default
          inputs.version-control.nixosModules.default
          inputs.databases.nixosModules.default
          inputs.utilities.nixosModules.default
          inputs.workspace.nixosModules.default
        ];
      };

      # Systems programming stack (Rust + C/C++)
      systems-stack = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.base.nixosModules.default
          inputs.rust.nixosModules.default
          inputs.cpp.nixosModules.default
          inputs.build-essentials.nixosModules.default
          inputs.version-control.nixosModules.default
          inputs.utilities.nixosModules.default
          inputs.workspace.nixosModules.default
        ];
      };

      # Backend/infrastructure stack
      backend-stack = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.base.nixosModules.default
          inputs.python.nixosModules.default
          inputs.go.nixosModules.default
          inputs.rust.nixosModules.default
          inputs.version-control.nixosModules.default
          inputs.databases.nixosModules.default
          inputs.utilities.nixosModules.default
          inputs.networking.nixosModules.default
          inputs.workspace.nixosModules.default
        ];
      };

      # Minimal stack (just essential tools)
      minimal-stack = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.base.nixosModules.default
          inputs.version-control.nixosModules.default
          inputs.utilities.nixosModules.default
          inputs.workspace.nixosModules.default
        ];
      };
    };

    # Export individual modules for custom composition
    nixosModules = {
      base = inputs.base.nixosModules.default;
      javascript = inputs.javascript.nixosModules.default;
      python = inputs.python.nixosModules.default;
      rust = inputs.rust.nixosModules.default;
      go = inputs.go.nixosModules.default;
      ruby = inputs.ruby.nixosModules.default;
      java = inputs.java.nixosModules.default;
      cpp = inputs.cpp.nixosModules.default;
      version-control = inputs.version-control.nixosModules.default;
      databases = inputs.databases.nixosModules.default;
      utilities = inputs.utilities.nixosModules.default;
      build-essentials = inputs.build-essentials.nixosModules.default;
      ai-dev = inputs.ai-dev.nixosModules.default;
      networking = inputs.networking.nixosModules.default;
      workspace = inputs.workspace.nixosModules.default;
    };
  };
}
