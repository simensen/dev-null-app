{
  description = "devnull app: PHP 8.4 and Composer for running the tests, Pint and Boost";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (
        pkgs:
        let
          # The extensions CI installs in .github/workflows/tests.yml.
          php = pkgs.php84.buildEnv {
            extensions =
              { enabled, all }:
              enabled
              ++ (with all; [
                curl
                dom
                mbstring
                pcntl
                pdo
                pdo_sqlite
                sodium
                zip
              ]);
            extraConfig = "memory_limit = 1G";
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              php
              php.packages.composer
            ];
          };
        }
      );
    };
}
