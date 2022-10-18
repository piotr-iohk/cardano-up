{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gems = pkgs.bundlerEnv {
          name = "gemset";
          gemdir = ./.;
        };
        app = pkgs.bundlerApp {
          pname = "cardano-up";
          gemdir = ./.;
          exes = [ "cardano-up" ];
        };
      in
      {
        devShell = with pkgs;
          mkShell {
            buildInputs = [
              gems
              gems.wrappedRuby
            ];
          };
        defaultApp = app;
      });
}
