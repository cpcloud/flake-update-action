{
  description = "Update flakes using GitHub actions";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
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
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nix-linter = {
                enable = true;
                entry = mkForce "${pkgs.nix-linter}/bin/nix-linter";
                excludes = [ "nix/sources.nix" ];
              };

              nixpkgs-fmt = {
                enable = true;
                entry = mkForce "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check";
              };

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
            git
            nix-linter
            nixpkgs-fmt
            prettierTOML
          ];
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      });
}
