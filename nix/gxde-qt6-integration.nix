{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt6,
  dtk2widget-qt6,
  dtk6core,
  dtk6gui,
  dtk6log,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gxde-qt6-integration";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "gxde-qt6-integration";
    rev = "5c5216efb4b9c065645990a89dafa9b81a231f89";
    hash = "sha256-yHKLJW/wMSew9Oki3B8yMGKMyLnuXC2rP5SVXyLV8NE=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [ pkg-config qt6.qtbase ];

  buildInputs = [
    qt6.qtbase
    dtk2widget-qt6
    dtk6core
    dtk6gui
    dtk6log
  ];

  postPatch = ''
    substituteInPlace dstyleplugin-qt6/dstyleplugin-qt6.pro \
      --replace-fail 'target.path = $$[QT_INSTALL_PLUGINS]/styles/' \
      'target.path = $$PLUGIN_INSTALL_DIR/styles/'
  '';

  configurePhase = ''
    runHook preConfigure

    qmake6 qt6integration.pro \
      PLUGIN_INSTALL_DIR=${placeholder "out"}/${qt6.qtbase.qtPluginPrefix}

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    make install INSTALL_ROOT=

    runHook postInstall
  '';

  meta = {
    description = "GXDE style plugin for Qt 6 applications (DTK2)";
    homepage = "https://github.com/GXDE-OS/gxde-qt6-integration";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
