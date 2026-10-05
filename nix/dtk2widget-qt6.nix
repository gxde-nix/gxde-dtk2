{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt6,
  gsettings-qt6,
  glib,
  kdePackages,
  gtk2,
  librsvg,
  libxcb-util,
  libstartup_notification,
  libXi,
  libXext,
  libXrender,
  dtk6core,
  dtk6gui,
  dtk6log,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dtk2widget-qt6";
  version = "6.3.3";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "dtk2widget-qt6";
    rev = "682bbb4e9c3f0a9aed6f77c218b7116d6628a936";
    hash = "sha256-bRBAAszsq88Zlsi4FV6PhFl09JMsxORKR1NemG8PiZo=";
  };

  outputs = [ "out" "dev" ];

  env.NIX_CFLAGS_COMPILE = "-I${gsettings-qt6.dev}/include/qt6";

  dontWrapQtApps = true;

  patches = [ ./patches/dtk2widget-qt6/0001-use-qwidget-private-accessor.patch ];

  postPatch = ''
    substituteInPlace dtk_translation.prf \
      --replace-fail '!exists($$LRELEASE_BIN): LRELEASE_BIN = lrelease-qt6' \
      '!exists($$LRELEASE_BIN): LRELEASE_BIN = lrelease'

    substituteInPlace src/src.pro \
      --replace-fail 'VERSION = 6.0.1' "VERSION = ${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    pkg-config
    qt6.qtbase
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtmultimedia
    qt6.qtsvg
    gsettings-qt6
    glib
    kdePackages.layer-shell-qt
    gtk2
    librsvg
    libxcb-util
    libstartup_notification
    libXi
    libXext
    libXrender
    dtk6core
    dtk6gui
    dtk6log
  ];

  preConfigure = ''
    export QMAKEMODULES="${dtk6core.dev}/lib/qt6/mkspecs/modules:${dtk6gui.dev}/lib/qt6/mkspecs/modules:${dtk6log.dev}/lib/qt6/mkspecs/modules''${QMAKEMODULES:+:$QMAKEMODULES}"
  '';

  configurePhase = ''
    runHook preConfigure

    qmake6 dtkwidget.pro \
      PREFIX=$out \
      VERSION=${finalAttrs.version} \
      DTK_MODULE=dtk2widget \
      LIB_INSTALL_DIR=$out/lib \
      INCLUDE_INSTALL_DIR=$dev/include/dtk2 \
      BIN_INSTALL_DIR=$out/libexec/dtk2-qt6 \
      TOOL_INSTALL_DIR=$out/libexec/dtk2-qt6 \
      MKSPECS_INSTALL_DIR=$out/lib/qt6/mkspecs

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    make install INSTALL_ROOT=

    sed -i 's|^Requires: dtkcore$|Requires: dtk6core|' $out/lib/pkgconfig/dtk2widget.pc

    runHook postInstall
  '';

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/cmake" "$dev"
    moveToOutput "lib/pkgconfig" "$dev"
    moveToOutput "lib/qt6/mkspecs" "$dev"
  '';

  meta = {
    description = "Original GXDE DTK2 widget library ported to Qt6";
    homepage = "https://github.com/GXDE-OS/dtk2widget-qt6";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
