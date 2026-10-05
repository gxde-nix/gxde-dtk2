{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt5,
  gsettings-qt,
  glib,
  gtk2,
  librsvg,
  libxcb-util,
  libstartup_notification,
  libXi,
  libXext,
  libXrender,
  wayland,
  dtk2core,
  dtk5core,
  dtklog,
  dde-qt-dbus-factory,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dtk2widget";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "dtk2widget";
    rev = "62628ba1798a7efaf19d23c72350c67900de776e";
    hash = "sha256-4oWQv7a/YX7pURACKDx53kEOiCasutP3TCtQqt2LAxk=";
  };

  outputs = [ "out" "dev" ];

  env.NIX_CFLAGS_COMPILE = "-I${gsettings-qt.dev}/include/qt5";

  dontWrapQtApps = true;

  patches = [ ./patches/dtk2widget/0001-isolate-dtk2-cmake.patch ];

  nativeBuildInputs = [
    pkg-config
    qt5.qtbase
    qt5.qttools
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtx11extras
    qt5.qtsvg
    gsettings-qt
    glib
    gtk2
    librsvg
    libxcb-util
    libstartup_notification
    libXi
    libXext
    libXrender
    wayland
    dtk5core
    dtklog
    dde-qt-dbus-factory
  ];

  propagatedBuildInputs = [ dtk2core ];

  preConfigure = ''
    export QMAKEMODULES="${dtk5core.dev}/lib/qt5/mkspecs/modules:${dtklog.dev}/lib/qt5/mkspecs/modules''${QMAKEMODULES:+:$QMAKEMODULES}"
  '';

  configurePhase = ''
    runHook preConfigure

    qmake dtkwidget.pro \
      PREFIX=$out \
      VERSION=${finalAttrs.version} \
      DTK_MODULE=dtk2widget \
      LIB_INSTALL_DIR=$out/lib \
      INCLUDE_INSTALL_DIR=$dev/include/dtk2-qt5 \
      BIN_INSTALL_DIR=$out/libexec/dtk2-qt5 \
      TOOL_INSTALL_DIR=$out/libexec/dtk2-qt5 \
      MKSPECS_INSTALL_DIR=$out/lib/qt5/mkspecs

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    make install INSTALL_ROOT=

    mv $out/lib/libdtkwidget.so $out/lib/libdtk2widget-qt5.so
    mv $out/lib/pkgconfig/dtkwidget.pc $out/lib/pkgconfig/dtk2widget-qt5.pc
    sed -i 's|-ldtkwidget|-ldtk2widget-qt5|g' $out/lib/pkgconfig/dtk2widget-qt5.pc
    sed -i 's|\.module = dtkwidget|.module = dtk2widget-qt5|' \
      $out/lib/qt5/mkspecs/modules/qt_lib_dtk2widget.pri

    runHook postInstall
  '';

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/cmake" "$dev"
    moveToOutput "lib/pkgconfig" "$dev"
    moveToOutput "lib/qt5/mkspecs" "$dev"
  '';

  meta = {
    description = "Original GXDE DTK2 widget compatibility library (Qt5)";
    homepage = "https://github.com/GXDE-OS/dtk2widget";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
