{
  description = "My personal website, blog, and digital garden";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = import nixpkgs { inherit system; };
        package = "brudel-dev";
      in {
        packages.${package} = pkgs.stdenv.mkDerivation {
          pname = package;
          version = "1.0";
          src = ./.;
          buildPhase = ''
            JEKYLL_ENV=production ${pkgs.jekyll}/bin/jekyll build --destination $out
          '';
          installPhase = "true";
        };
        defaultPackage = self.packages.${system}."${package}";

        apps.${package} = let
          serve = pkgs.writeShellScriptBin "serve" ''
						${pkgs.jekyll}/bin/jekyll serve --livereload --trace
          '';
        in {
          type = "app";
          program = "${serve}/bin/serve";
        };
        defaultApp = self.apps.${system}.${package};

        devShell =
          pkgs.mkShell { buildInputs = with pkgs; [ jekyll nodePackages.prettier sass scss-lint ]; };
      });
}
