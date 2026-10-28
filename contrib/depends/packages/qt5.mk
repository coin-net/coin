# Coin GUI static Qt 5.15.19 (LGPL open-source release).
# Verified upstream SHA-256:
# https://download.qt.io/archive/qt/5.15/5.15.19/single/
# COIN_GUI=1 enables Linux native or MinGW-w64 Windows cross-build.
package=qt5
$(package)_version=5.15.19
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/single
$(package)_file_name=qt-everywhere-opensource-src-$($(package)_version).tar.xz
$(package)_sha256_hash=173c2326dae138bbb0d98921e9d911e55c00163d93a6db29f294b5e19ff306ae
ifeq ($(host_os),mingw32)
$(package)_dependencies=openssl expat
else
$(package)_dependencies=openssl expat freetype fontconfig
endif

# Windows: use the same pinned Qt 5.15.19 source and Depends prefix.
# Building Qt's host tools and cross-target DLL-free archives uses a Linux
# build platform and the existing x86_64-w64-mingw32 POSIX toolchain.
ifeq ($(host_os),mingw32)

# Qt Quick's optional D3D12 scenegraph plugin requires Windows-only fxc.exe.
# Disable that plugin in MinGW cross-build; normal OpenGL rendering remains.
define $(package)_preprocess_cmds
  test -f qtbase/mkspecs/win32-g++/qmake.conf && \
  grep -qx 'qtConfig(d3d12): SUBDIRS += d3d12' qtdeclarative/src/plugins/scenegraph/scenegraph.pro && \
  sed -i '/^qtConfig(d3d12): SUBDIRS += d3d12/s/^/# /' qtdeclarative/src/plugins/scenegraph/scenegraph.pro && \
  printf '%s\n' \
    'QMAKE_CC = $(host_CC)' \
    'QMAKE_CXX = $(host_CXX)' \
    'QMAKE_LINK = $(host_CXX)' \
    'QMAKE_LINK_SHLIB = $(host_CXX)' \
    'QMAKE_AR = $(host_AR) cqs' \
    'QMAKE_RANLIB = $(host_RANLIB)' \
    'QMAKE_RC = $(host)-windres' \
    >> qtbase/mkspecs/win32-g++/qmake.conf
endef

define $(package)_config_cmds
  test -s "$(host_prefix)/lib/libssl.a" && \
  test -s "$(host_prefix)/lib/libcrypto.a" && \
  test -f "$(host_prefix)/include/openssl/ssl.h" && \
  PKG_CONFIG_LIBDIR="$(host_prefix)/lib/pkgconfig:$(host_prefix)/share/pkgconfig" \
  PKG_CONFIG_PATH="$(host_prefix)/lib/pkgconfig:$(host_prefix)/share/pkgconfig" \
  CC="$(host_CC)" CXX="$(host_CXX)" \
  ./configure \
    -prefix "$(host_prefix)" \
    -extprefix "$($(package)_staging_prefix_dir)" \
    -opensource -confirm-license -release -static -recheck-all \
    -platform linux-g++ -xplatform win32-g++ -no-pch -no-avx \
    -opengl desktop -qpa windows -no-angle \
    -no-fontconfig -qt-freetype \
    -openssl-linked -no-dbus -no-glib -no-use-gold-linker \
    -I "$(host_prefix)/include" -L "$(host_prefix)/lib" \
    OPENSSL_PREFIX="$(host_prefix)" \
    OPENSSL_LIBS="-L$(host_prefix)/lib -lssl -lcrypto -lws2_32 -lcrypt32 -lbcrypt -ladvapi32" \
    -qt-harfbuzz -qt-libjpeg -qt-libpng -qt-pcre -qt-zlib \
    -nomake examples -nomake tests -nomake tools \
    -skip qttools -skip qtactiveqt -skip qt3d -skip qtandroidextras -skip qtcharts -skip qtconnectivity \
    -skip qtdatavis3d -skip qtdoc -skip qtgamepad -skip qtlocation \
    -skip qtmacextras -skip qtnetworkauth -skip qtpurchasing -skip qtscript \
    -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport \
    -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel \
    -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qtwinextras \
    -skip qtx11extras
endef

define $(package)_build_cmds
  $(MAKE) -j$(or $(COIN_QT_JOBS),4)
endef

define $(package)_stage_cmds
  $(MAKE) install
endef

define $(package)_postprocess_cmds
  test -s lib/libQt5Core.a && test -s lib/libQt5Quick.a && \
  test -s lib/libQt5Qml.a && test -s lib/libQt5Svg.a && \
  test -f lib/cmake/Qt5/Qt5Config.cmake && \
  test -s plugins/platforms/libqwindows.a
endef

else

# Qt uses pinned static Depends FreeType/Fontconfig, not host copies.
# X11/XCB/OpenGL are Linux platform development interfaces as in Monero.
# COIN_QT_FREETYPE_QMAKE_CLOSURE
# Qt's own executables need the dependencies of static FreeType.
define $(package)_preprocess_cmds
  test -f qtbase/mkspecs/linux-g++/qmake.conf && printf '%s\n' 'QMAKE_LIBS += -lpng16 -lbz2 -lz' >> qtbase/mkspecs/linux-g++/qmake.conf
endef

define $(package)_config_cmds
  test -s "$(host_prefix)/lib/libfreetype.a" && \
  test -s "$(host_prefix)/lib/libfontconfig.a" && \
  PKG_CONFIG_LIBDIR="$(host_prefix)/lib/pkgconfig:/usr/lib/$(shell gcc -dumpmachine)/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig" \
  PKG_CONFIG_PATH="$(host_prefix)/lib/pkgconfig:$(host_prefix)/share/pkgconfig" \
  CC="$($(package)_cc)" CXX="$($(package)_cxx)" \
  ./configure \
    -prefix "$(host_prefix)" \
    -extprefix "$($(package)_staging_prefix_dir)" \
    -opensource -confirm-license -release -static -recheck-all \
    -platform linux-g++ -no-avx -no-pch \
    -opengl desktop -qpa xcb -xcb -xcb-xlib -feature-xlib \
    -fontconfig -system-freetype \
    -openssl-linked -no-dbus -no-glib -no-kms -no-use-gold-linker \
    -qt-harfbuzz -qt-libjpeg -qt-libpng -qt-pcre -qt-zlib \
    -nomake examples -nomake tests -nomake tools \
    -skip qttools -skip qt3d -skip qtandroidextras -skip qtcharts -skip qtconnectivity \
    -skip qtdatavis3d -skip qtdoc -skip qtgamepad -skip qtlocation \
    -skip qtmacextras -skip qtnetworkauth -skip qtpurchasing -skip qtscript \
    -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport \
    -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel \
    -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qtwinextras \
    -skip qtx11extras
endef

define $(package)_build_cmds
  $(MAKE) -j$(or $(COIN_QT_JOBS),4) && \
  cd qttools/src/linguist/lrelease && \
  ../../../../qtbase/bin/qmake && \
  $(MAKE) -j$(or $(COIN_QT_JOBS),4)
endef

define $(package)_stage_cmds
  $(MAKE) install && \
  cd qttools/src/linguist/lrelease && \
  $(MAKE) install
endef

define $(package)_postprocess_cmds
  test -f lib/libQt5Core.a && test -f lib/libQt5Quick.a && \
  test -f lib/libQt5Qml.a && test -f lib/libQt5Svg.a && \
  test -f lib/cmake/Qt5/Qt5Config.cmake && \
  test -x bin/qmake && test -x bin/lrelease
endef

endif # linux/windows Qt5 Depends recipes
