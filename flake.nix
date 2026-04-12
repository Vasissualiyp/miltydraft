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
            echo "MiltyDraft dev environment"
            echo "PHP: $(php --version | head -1)"
            echo "Composer: $(composer --version)"
            echo ""
            if [ ! -f .env ]; then
              cp .env.example .env
              echo "Created .env from .env.example"
            fi
            if [ ! -d vendor ]; then
              echo "Run 'composer install' to install dependencies."
            fi
          '';
        };
      }
    );
}
