# GXDE DTK2
GXDE's DTK2 library, both the original Qt5 stack and its Qt6 port.

## Version
| flake attr | Upstream | pin | Qt | out | dev |
| --- | --- | --- | --- | --- | --- |
| `dtk2core` | GXDE-OS/dtk2core | tag `2.2.8` | — | `lib/libdtkcore.so.2` (compatibility link to DTK5) | — |
| `dde-qt-dbus-factory` | GXDE-OS/dde-qt-dbus-factory | tag `6.1.0-gxde6` | Qt5 | `libdframeworkdbus.so.2*` | `include/libdframeworkdbus-2.0`, cmake, pc |
| `dtk2widget` | GXDE-OS/dtk2widget | tag `2.5-gxde2` | Qt5 | `libdtkwidget.so.2*`, `share/dtkwidget/translations`, `libexec/dtk2-qt5` | `include/dtk2-qt5`, cmake `Dtk2Qt5Widget`, `dtk2widget-qt5.pc`, qmake module |
| `gxde-qt5integration` | GXDE-OS/gxde-qt5integration | tag `0.3.12-2` | Qt5 | `lib/qt-5.15.19/plugins/styles/libdstyleplugin-gxde.so` | — |
| `dtk2widget-qt6` | GXDE-OS/dtk2widget-qt6 | tag `6.3.3-real6.3.0` | Qt6 | `libdtk2widget.so.6*`, `share/dtk2widget/translations`, `libexec/dtk2-qt6` | `include/dtk2/`, cmake `Dtk2widget`, `dtk2widget.pc`, qmake module |
| `gxde-qt6-integration` | GXDE-OS/gxde-qt6-integration | tag `6.0.1-5` | Qt6 | `lib/qt-6/plugins/styles/libdstyleplugin-gxde-qt6.so` | — |
| `all` (`default`, `gxde-dtk2`) | — | — | — | aggregate of the six modules' out + dev | |

## Notes
- The two plugin packages install into nixpkgs' Qt plugin prefix (`lib/qt-5.15.19/plugins` for Qt5, `lib/qt-6/plugins` for Qt6) instead of upstream's hardcoded `lib/qt5|qt6/plugins`, otherwise Qt cannot load them at runtime.
- `dtk2core` only ships the `libdtkcore.so.2 → libdtkcore.so.5` compatibility link plus the dependency on DTK5, exactly like the Fedora package; the DTK5 core comes from the [gxde-dtk5](https://github.com/gxde-nix/gxde-dtk5) flake input.
- The Qt6 port builds against the DTK6 core/gui/log packages from the [gxde-dtk6](https://github.com/gxde-nix/gxde-dtk6) flake input, and against nixpkgs' `lomiri-qt6.gsettings-qt` (which provides `gsettings-qt6.pc`).
- `dtk2widget` keeps the DTK2 runtime SONAMEs (`libdtkwidget.so.2`) and renames only the development aliases (`libdtkwidget.so` → `libdtk2widget-qt5.so`, `dtkwidget.pc` → `dtk2widget-qt5.pc`), so DTK2 and DTK5 can be installed side by side. That rename is what `0001-isolate-dtk2-cmake.patch` prepares.
- Nix-specific adaptations in the qmake builds, all in `postPatch`/`preConfigure`: `pkg-config` is added to `nativeBuildInputs` (`PKGCONFIG +=` needs the binary), `dtk_translation.prf` falls back to plain `lrelease` (`$$[QT_HOST_BINS]/lrelease` does not exist in nixpkgs and neither does `lrelease-qt6`), `QMAKEMODULES` is pointed at the DTK5/DTK6 `mkspecs/modules` directories (those install into `lib/qt5|qt6/mkspecs`, which nixpkgs' `qmakePathHook` does not pick up), and the `gsettings-qt`/`gsettings-qt6` pkg-config files point `includedir` one level too deep, so the parent directory is added to the compiler flags.
- `dtk2widget-qt6`'s `src/src.pro` hardcodes `VERSION = 6.0.1`, which would override the version passed on the qmake command line, so the build rewrites it to the pinned tag version (`6.3.3`); the SONAME stays `libdtk2widget.so.6`.
- The three patches under `nix/patches/` are taken from GXDE's Fedora packaging (the Qt6 integration patch is not needed at tag `6.0.1-5`, upstream already contains it).

## Building via Script
### Basic Instructions
```bash
$ chmod a+x ./build-nix
$ ./build-nix
```

### Usage
```
Usage: build-nix [options] [target]

Build a Nix package from the current directory.

Options:
  -L, --log       Show full build logs.
      --rebuild   Rebuild to check reproducibility.
      --cleanup   Cleanup results.
  -h, --help      Print help page.

Target:
  A .nix file or a flake installable, such as .#package.
  Defaults to the target where this script is in.
```

## Licensing
(C) 2026 CharOfString.

The packaging in this repository — the Nix expressions, `build-nix` and the documentation — is licensed under [MIT](./LICENSE).

The patches under [`nix/patches/`](./nix/patches) modify sources of the corresponding upstream projects and are provided under those projects' licenses:

| Patch | Upstream | License |
| --- | --- | --- |
| `dtk2widget/0001-isolate-dtk2-cmake.patch` | GXDE-OS/dtk2widget | LGPL-3.0-or-later |
| `gxde-qt5integration/0001-use-dtk2-development-namespace.patch` | GXDE-OS/gxde-qt5integration | LGPL-3.0-or-later |
| `dtk2widget-qt6/0001-use-qwidget-private-accessor.patch` | GXDE-OS/dtk2widget-qt6 | LGPL-3.0-or-later |
