{ pkgs, dtk5, dtk6 }:

let
  inherit (pkgs) lib;

  dtk5core = dtk5.dtk5core;
  dtklog = dtk5.dtklog;
  dtk6core = dtk6.dtk6core;
  dtk6gui = dtk6.dtk6gui;
  dtk6log = dtk6.dtk6log;

  dtk2core = pkgs.callPackage ./nix/dtk2core.nix {
    inherit dtk5core;
  };

  dde-qt-dbus-factory = pkgs.callPackage ./nix/dde-qt-dbus-factory.nix { };

  dtk2widget = pkgs.callPackage ./nix/dtk2widget.nix {
    inherit dtk2core dde-qt-dbus-factory dtk5core dtklog;
  };

  gxde-qt5integration = pkgs.callPackage ./nix/gxde-qt5integration.nix {
    inherit dtk2widget dtk5core dtklog;
  };

  dtk2widget-qt6 = pkgs.callPackage ./nix/dtk2widget-qt6.nix {
    inherit dtk6core dtk6gui dtk6log;
    gsettings-qt6 = pkgs.lomiri-qt6.gsettings-qt;
  };

  gxde-qt6-integration = pkgs.callPackage ./nix/gxde-qt6-integration.nix {
    inherit dtk2widget-qt6 dtk6core dtk6gui dtk6log;
  };

  modules = [
    dtk2core
    dde-qt-dbus-factory
    dtk2widget
    gxde-qt5integration
    dtk2widget-qt6
    gxde-qt6-integration
  ];

  all = pkgs.symlinkJoin {
    name = "gxde-dtk2-${dtk2widget.version}";
    paths = lib.concatMap (p: [ p (lib.getDev p) ]) modules;
  };
in
{
  inherit
    dtk2core
    dde-qt-dbus-factory
    dtk2widget
    gxde-qt5integration
    dtk2widget-qt6
    gxde-qt6-integration
    all
    ;

  gxde-dtk2 = all;

  default = all;
}
