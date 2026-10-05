{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt5,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dde-qt-dbus-factory";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "dde-qt-dbus-factory";
    rev = "7278ee0df4eda911f2860d1a5d73979c4afe781d";
    hash = "sha256-izj1qJk9YFt8jd4xmwzQ3iRVs/Ku1bWDHA7tbLsbHno=";
  };

  outputs = [ "out" "dev" ];

  dontWrapQtApps = true;

  nativeBuildInputs = [
    pkg-config
    qt5.qtbase
    python3
  ];

  buildInputs = [ qt5.qtbase ];

  postPatch = ''
    substituteInPlace libdframeworkdbus/libdframeworkdbus.pro \
      --replace-fail '$$INSTALL_ROOT/usr/include' '$$INCLUDE_INSTALL_DIR'
  '';

  configurePhase = ''
    runHook preConfigure

    qmake dde-qt-dbus-factory.pro \
      PREFIX=$out \
      LIB_INSTALL_DIR=$out/lib \
      INCLUDE_INSTALL_DIR=$dev/include \
      MKSPECS_INSTALL_DIR=$out/lib/qt5/mkspecs

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    make install INSTALL_ROOT=

    runHook postInstall
  '';

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/cmake" "$dev"
    moveToOutput "lib/pkgconfig" "$dev"
  '';

  meta = {
    description = "Qt D-Bus interface factory used by the GXDE DTK2 stack";
    homepage = "https://github.com/GXDE-OS/dde-qt-dbus-factory";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
