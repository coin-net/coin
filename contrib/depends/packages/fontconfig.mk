# Fontconfig release used by the official Monero GUI v0.18.5.3 build.
# Strictly private, static Depends copy; no runtime host fontconfig dependency.
package=fontconfig
$(package)_version=2.13.92
$(package)_download_path=https://www.freedesktop.org/software/fontconfig/release
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=506e61283878c1726550bc94f2af26168f1e9f2106eac77eaaf0b2cdfad66e4e
$(package)_dependencies=freetype expat

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --enable-static --with-pic --disable-docs
  $(package)_config_opts+=--sysconfdir=/etc --localstatedir=/var
  # FreeType was built static with its PNG and bzip2 modules enabled on
  # FishTank. Fontconfig's own helper binaries (fc-cache, fc-list, etc.)
  # must link those transitive dependencies AFTER libfreetype.a. The
  # configure LIBS variable is propagated to all Automake executable links.
  # Keep the features enabled rather than silently disabling glyph formats.
  $(package)_config_opts+=LIBS="-lpng16 -lbz2 -lz -lm"
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
  test -s lib/libfontconfig.a && test -f lib/pkgconfig/fontconfig.pc && \
  sed -i '/^Libs:/s|.*|& -lexpat|' lib/pkgconfig/fontconfig.pc && \
  rm -f lib/libfontconfig.la
endef
