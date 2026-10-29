{
  description = "My simple C library";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/26.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkAxiom =
        {
          lib,
          stdenv,
        }:
        stdenv.mkDerivation {
          pname = "axiom";
          version = "0.2.0";

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
            platforms = [ system ];
          };
        };
    in
    {
      packages.${system}.default = pkgs.callPackage mkAxiom { };

      overlays.default = final: _prev: {
        axiom = final.callPackage mkAxiom { };
      };

      checks.${system} = {
        build = self.packages.${system}.default;
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.default ];
        packages = with pkgs; [
          gcc
          gdb
        ];
      };
    };
}
