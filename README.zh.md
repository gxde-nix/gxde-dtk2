# GXDE DTK2
GXDE的DTK2库，包含原始的Qt5版本与其Qt6移植。

## 版本
| flake attr | 上游 | pin | Qt | out 内容 | dev 内容 |
| --- | --- | --- | --- | --- | --- |
| `dtk2core` | GXDE-OS/dtk2core | tag `2.2.8` | — | `lib/libdtkcore.so.2`（指向 DTK5 的兼容链接） | — |
| `dde-qt-dbus-factory` | GXDE-OS/dde-qt-dbus-factory | tag `6.1.0-gxde6` | Qt5 | `libdframeworkdbus.so.2*` | `include/libdframeworkdbus-2.0`、cmake、pc |
| `dtk2widget` | GXDE-OS/dtk2widget | tag `2.5-gxde2` | Qt5 | `libdtkwidget.so.2*`、`share/dtkwidget/translations`、`libexec/dtk2-qt5` | `include/dtk2-qt5`、cmake `Dtk2Qt5Widget`、`dtk2widget-qt5.pc`、qmake 模块 |
| `gxde-qt5integration` | GXDE-OS/gxde-qt5integration | tag `0.3.12-2` | Qt5 | `lib/qt-5.15.19/plugins/styles/libdstyleplugin-gxde.so` | — |
| `dtk2widget-qt6` | GXDE-OS/dtk2widget-qt6 | tag `6.3.3-real6.3.0` | Qt6 | `libdtk2widget.so.6*`、`share/dtk2widget/translations`、`libexec/dtk2-qt6` | `include/dtk2/`、cmake `Dtk2widget`、`dtk2widget.pc`、qmake 模块 |
| `gxde-qt6-integration` | GXDE-OS/gxde-qt6-integration | tag `6.0.1-5` | Qt6 | `lib/qt-6/plugins/styles/libdstyleplugin-gxde-qt6.so` | — |
| `all`（`default`、`gxde-dtk2`） | — | — | — | 六个模块 out+dev 的汇总 | |

## 说明
- 两个插件包按 nixpkgs 的 Qt 插件前缀安装（Qt5 为 `lib/qt-5.15.19/plugins`，Qt6 为 `lib/qt-6/plugins`），而不是上游写死的 `lib/qt5|qt6/plugins`，否则 Qt 运行时加载不到。
- `dtk2core` 与 Fedora 包一致：只提供 `libdtkcore.so.2 → libdtkcore.so.5` 兼容链接并依赖 DTK5；DTK5 core 来自 [gxde-dtk5](https://github.com/gxde-nix/gxde-dtk5) flake input。
- Qt6 移植链接 [gxde-dtk6](https://github.com/gxde-nix/gxde-dtk6) flake input 里的 dtk6core/dtk6gui/dtk6log，以及 nixpkgs 的 `lomiri-qt6.gsettings-qt`（它提供 `gsettings-qt6.pc`）。
- `dtk2widget` 保留 DTK2 的运行时 SONAME（`libdtkwidget.so.2`），只重命名开发用别名（`libdtkwidget.so` → `libdtk2widget-qt5.so`、`dtkwidget.pc` → `dtk2widget-qt5.pc`），这样 DTK2 与 DTK5 可共存；`0001-isolate-dtk2-cmake.patch` 就是为这套隔离准备的。
- qmake 构建里的 Nix 适配（都写在 `postPatch`/`preConfigure`）：把 `pkg-config` 加进 `nativeBuildInputs`（`PKGCONFIG +=` 需要这个二进制）；`dtk_translation.prf` 回退到普通 `lrelease`（nixpkgs 里没有 `$$[QT_HOST_BINS]/lrelease`，也没有 `lrelease-qt6`）；`QMAKEMODULES` 指向 DTK5/DTK6 的 `mkspecs/modules` 目录（它们装在 `lib/qt5|qt6/mkspecs`，nixpkgs 的 `qmakePathHook` 不认）；`gsettings-qt`/`gsettings-qt6` 的 pkg-config `includedir` 少一层，因此额外把其父目录加进编译参数。
- `dtk2widget-qt6` 的 `src/src.pro` 里硬编码了 `VERSION = 6.0.1`，会覆盖 qmake 命令行传的版本，因此构建时把它改写成 pin 的 tag 版本（`6.3.3`）；SONAME 仍是 `libdtk2widget.so.6`。
- `nix/patches/` 下的三个补丁取自 GXDE 的 Fedora 打包（Qt6 integration 那个在 tag `6.0.1-5` 上不需要，上游已包含）。

## 使用脚本构建
### 基本使用
```bash
$ chmod a+x ./build-nix
$ ./build-nix
```

### 使用说明
```
用法: build-nix [选项] [目标]

从本地目录构建Nix包。

选项:
  -L, --log       构建时打印日志
      --rebuild   重新构建以检查可复现性
      --cleanup   清理产物
  -h, --help      打印帮助

目标:
  一个.nix文件或者flake installable，例如.#package。
  默认在当前目录查找。
```

## 许可证
(C) 2026 CharOfString.

本仓库的打包部分（Nix 表达式、`build-nix`、文档）以 [MIT](./LICENSE) 协议授权。

[`nix/patches/`](./nix/patches) 下的补丁修改的是对应上游项目的源码，按**原仓库协议**提供：

| 补丁 | 上游 | 协议 |
| --- | --- | --- |
| `dtk2widget/0001-isolate-dtk2-cmake.patch` | GXDE-OS/dtk2widget | LGPL-3.0-or-later |
| `gxde-qt5integration/0001-use-dtk2-development-namespace.patch` | GXDE-OS/gxde-qt5integration | LGPL-3.0-or-later |
| `dtk2widget-qt6/0001-use-qwidget-private-accessor.patch` | GXDE-OS/dtk2widget-qt6 | LGPL-3.0-or-later |
