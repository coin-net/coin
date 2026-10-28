# CoinGUI OpenPGP dependency: reproducible static libgpg-error.
package=libgpg-error
$(package)_version=1.50
$(package)_download_path=https://gnupg.org/ftp/gcrypt/libgpg-error
$(package)_file_name=libgpg-error-$($(package)_version).tar.bz2
$(package)_sha256_hash=69405349e0a633e444a28c5b35ce8f14484684518a508dc48a089992fe93e20a

define $(package)_set_vars
  $(package)_config_opts=--enable-static --disable-shared --disable-nls
  $(package)_config_opts+=--enable-install-gpg-error-config
  $(package)_cflags_linux=-fPIC
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
  test -s lib/libgpg-error.a && test -s include/gpg-error.h && \
  test -x bin/gpg-error-config && test -x bin/gpgrt-config
endef
