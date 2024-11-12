{
  description = "Update flakes using GitHub actions";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, git-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [
            (final: _: {
              prettierTOML = final.writeShellApplication {
                name = "prettier";
                text = ''
                  ${final.nodePackages.prettier}/bin/prettier \
                  --plugin-search-dir "${final.nodePackages.prettier-plugin-toml}/lib" \
                  "$@"
                '';
              };
            })
          ];
          inherit system;
        };
        inherit (pkgs.lib) mkForce;
      in
      {
        checks = {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              deadnix.enable = true;
              statix.enable = true;
              nixpkgs-fmt.enable = true;

              prettier = {
                enable = true;
                entry = mkForce "${pkgs.prettierTOML}/bin/prettier --check";
                types_or = [ "json" "toml" "yaml" ];
              };
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "flake-update-action";
          buildInputs = with pkgs; [
            deadnix
            git
            nixpkgs-fmt
            prettierTOML
            statix
          ];
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      });
}
