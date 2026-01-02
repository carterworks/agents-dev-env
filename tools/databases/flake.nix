{
  description = "Database Client Tools - PostgreSQL, Redis, SQLite";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Database client tools
      environment.systemPackages = with pkgs; [
        # PostgreSQL client
        postgresql

        # Redis client
        redis

        # SQLite
        sqlite

        # Additional database tools
        dbeaver-bin        # Universal database tool
        pgcli              # Better PostgreSQL CLI
        litecli            # Better SQLite CLI
      ];
    };

    # Development shell
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        name = "database-tools";
        buildInputs = with pkgs; [
          postgresql
          redis
          sqlite
        ];
        shellHook = ''
          echo "🗄️  Database Tools"
          echo "  PostgreSQL: $(psql --version | awk '{print $3}')"
          echo "  Redis: $(redis-cli --version)"
          echo "  SQLite: $(sqlite3 --version | awk '{print $1}')"
        '';
      }
    );
  };
}
