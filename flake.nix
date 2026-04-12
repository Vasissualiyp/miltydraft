{
  description = "MiltyDraft — Twilight Imperium draft tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        php = pkgs.php82.buildEnv {
          extensions = ({ enabled, all }: enabled);
          extraConfig = ''
            memory_limit = 2G
          '';
        };

        composer = php.packages.composer;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            php
            composer
            pkgs.curl
          ];

          shellHook = ''
            mkdir -p tmp/test-drafts data/drafts

            if [ ! -f .env ]; then
              cp .env.example .env
              echo "Created .env from .env.example — edit it before running the server."
            fi
            if [ ! -d vendor ]; then
              echo "Run 'composer install' to install dependencies, then 'serve' to start."
            fi

            # Helper: start the PHP built-in dev server
            serve() {
              local env_port
              env_port=$(grep -m1 '^DEV_PORT=' .env 2>/dev/null | cut -d= -f2 | tr -d '"')
              local port=''${1:-''${env_port:-8080}}
              echo "Starting dev server on http://0.0.0.0:$port"
              echo "Set URL=\"http://localhost:$port/\" in .env (or your Tailscale address)."
              php -S 0.0.0.0:"$port" router.php
            }
            export -f serve

            echo "MiltyDraft dev environment  |  PHP $(php -r 'echo PHP_VERSION;')  |  run 'serve [port]' to start"
          '';
        };
      }
    );
}
