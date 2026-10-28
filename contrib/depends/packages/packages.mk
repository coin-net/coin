packages:=boost openssl zeromq libiconv expat unbound

# Coin GUI: build Qt from pinned source into the same Depends sysroot.
# CLI-only builds do not download or compile Qt.
ifeq ($(COIN_GUI),1)
  ifeq ($(host_os),linux)
    packages += freetype fontconfig
  else ifneq ($(host_os),mingw32)
    $(error Coin static Qt Depends recipe supports Linux and Windows x64 only: $(HOST))
  endif
  packages += qt5 libgpg-error libgcrypt
endif

# ccache is useless in gitian builds
ifneq ($(GITIAN),1)
native_packages := native_ccache
endif

hardware_packages := hidapi protobuf libusb
hardware_native_packages := native_protobuf

android_native_packages = android_ndk
android_packages = ncurses readline sodium

darwin_native_packages = $(hardware_native_packages)
darwin_packages = ncurses readline sodium $(hardware_packages)

# not really native...
freebsd_native_packages = freebsd_base
freebsd_packages = ncurses readline sodium

linux_packages = eudev ncurses readline sodium $(hardware_packages)
linux_native_packages = $(hardware_native_packages)

ifeq ($(build_tests),ON)
packages += gtest
endif

ifneq ($(host_arch),riscv64)
linux_packages += unwind
endif

mingw32_packages = icu4c sodium $(hardware_packages)
mingw32_native_packages = $(hardware_native_packages)

ifneq ($(build_os),darwin)
darwin_native_packages += darwin_sdk native_clang native_cctools native_libtapi
endif

