{
  lib,
  stdenv,
  fetchFromGitHub,
  dtk5core,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dtk2core";
  version = "2.2.8";

  src = fetchFromGitHub {
    owner = "GXDE-OS";
    repo = "dtk2core";
    rev = "de146a9578347bcb002490907b344c748205c7d0";
    hash = "sha256-XjmT136Zwb5wXTe4i69D4DQ+wtzQxukCckjrHA2nwmY=";
  };

  dontConfigure = true;
  dontBuild = true;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    ln -s ${dtk5core}/lib/libdtkcore.so.5 $out/lib/libdtkcore.so.2

    install -Dm644 LICENSE $out/share/licenses/dtk2core/LICENSE
    install -Dm644 README.md $out/share/doc/dtk2core/README.md

    runHook postInstall
  '';

  propagatedBuildInputs = [ dtk5core ];

  meta = {
    description = "GXDE DTK2 Core compatibility link";
    homepage = "https://github.com/GXDE-OS/dtk2core";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
