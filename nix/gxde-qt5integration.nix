{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt5,
  dtk2widget,
  dtk5core,
  dtklog,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gxde-qt5integration";
  version = "0.3.12";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "gxde-qt5integration";
    rev = "bba746a070aab10271242e17548adce73f8dc5a9";
    hash = "sha256-lLYhJwnk2jDKrm6UAX8Pi5LKqaaAkfFQd2z36fTZGfM=";
  };

  dontWrapQtApps = true;

  patches = [ ./patches/gxde-qt5integration/0001-use-dtk2-development-namespace.patch ];

  nativeBuildInputs = [ pkg-config qt5.qtbase ];

  buildInputs = [
    qt5.qtbase
    dtk2widget
    dtk5core
    dtklog
  ];

  postPatch = ''
    substituteInPlace dstyleplugin/dstyleplugin.pro \
      --replace-fail 'target.path = $$[QT_INSTALL_PLUGINS]/styles/' \
      'target.path = $$PLUGIN_INSTALL_DIR/styles/'
  '';

  configurePhase = ''
    runHook preConfigure

    qmake qt5integration.pro \
      PLUGIN_INSTALL_DIR=${placeholder "out"}/${qt5.qtbase.qtPluginPrefix}

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    make install INSTALL_ROOT=

    runHook postInstall
  '';

  meta = {
    description = "GXDE style plugin for Qt 5.15 applications (DTK2)";
    homepage = "https://github.com/GXDE-OS/gxde-qt5integration";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
