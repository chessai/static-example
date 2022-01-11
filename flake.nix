{
  description = "static linking example with haskell.nix";

  inputs = {
    nixpkgs = {
      follows = "haskell-nix/nixpkgs-unstable";
    };

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.nixpkgs.follows = "haskell-nix/nixpkgs-2111";
    };
  };

  outputs =
    { self
    , nixpkgs
    , haskell-nix
    , ...
    }:
    let
      supportedSystems =
        [ "x86_64-linux" ];

      nixpkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ haskell-nix.overlay ];
          inherit (haskell-nix) config;
        };

      perSystem = nixpkgs.lib.genAttrs supportedSystems;

      projectFor = system:
        let
          deferPluginErrors = true;
          pkgs = (nixpkgsFor system).pkgsCross.musl64;
        in pkgs.haskell-nix.cabalProject' {
          src = ./.;
          compiler-nix-name = "ghc8107";
          cabalProjectFileName = "cabal.project";
          modules = [{
            packages = { };
          }];
          shell = {
            withHoogle = true;

            exactDeps = true;

            nativeBuildInputs = [
              pkgs.cabal-install
              pkgs.ghcid
            ];
          };
          sha256map = { };
        };
    in {
      pkgs = perSystem nixpkgsFor;
      project = perSystem projectFor;
      flake = perSystem (system: (projectFor system).flake { });

      devShell = perSystem (system: self.flake.${system}.devShell);
    };
}
