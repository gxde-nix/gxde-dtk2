{
  description = "Nix packaging of GXDE DTK2 (dtk2core, dde-qt-dbus-factory, dtk2widget, gxde-qt5integration, dtk2widget-qt6, gxde-qt6-integration)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gxde-dtk5 = {
      url = "github:gxde-nix/gxde-dtk5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gxde-dtk6 = {
      url = "github:gxde-nix/gxde-dtk6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gxde-dtk5, gxde-dtk6 }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];

      mkPackages = system: pkgs: import ./default.nix {
        inherit pkgs;
        dtk5 = gxde-dtk5.packages.${system};
        dtk6 = gxde-dtk6.packages.${system};
      };
    in
    {
      overlays.default = final: prev: {
        dtk2 = mkPackages final.stdenv.hostPlatform.system final;
      };
    }
    // flake-utils.lib.eachSystem systems
      (system:
        let
          packages = mkPackages system nixpkgs.legacyPackages.${system};
        in
        {
          inherit packages;
          checks.dtk2 = packages.all;
        });
}
