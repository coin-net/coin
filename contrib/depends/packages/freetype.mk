# FreeType release used by the official Monero GUI v0.18.5.3 build.
# Built as a static Depends package rather than picked up from the host.
package=freetype
$(package)_version=2.10.2
$(package)_download_path=https://download.savannah.gnu.org/releases/freetype
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=1543d61025d2e6312e0a1c563652555f17378a204a61e99928c9fcef030a2d8b

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --enable-static --with-zlib=no --with-pic
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  test -s lib/libfreetype.a && test -f lib/pkgconfig/freetype2.pc && \
  rm -f lib/libfreetype.la
endef
