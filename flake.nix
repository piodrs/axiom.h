{
  description = "My simple C library";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/26.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkAxiom =
        {
          lib,
          stdenv,
        }:
        stdenv.mkDerivation {
          pname = "axiom";
          version = "0.1.0";

          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./axiom.h
              ./test.c
            ];
          };

          dontConfigure = true;

          buildPhase = ''
            runHook preBuild
            $CC -Wall -Wextra -std=c11 -pedantic -Werror -o test test.c
            ./test
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm644 axiom.h $out/include/axiom.h
            runHook postInstall
          '';

          meta = {
            description = "My simple C library";
            license = lib.licenses.mit;
            platforms = lib.platforms.all;
          };
        };
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage mkAxiom { };
      });

      overlays.default = final: _prev: {
        axiom = final.callPackage mkAxiom { };
      };

      checks = forAllSystems (system: {
        build = self.packages.${system}.default;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.default ];
            packages = with pkgs; [
              gdb
              clang-tools
            ];
          };
        }
      );
    };
}
