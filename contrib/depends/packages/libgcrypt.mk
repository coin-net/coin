# CoinGUI OpenPGP dependency: reproducible static libgcrypt.
package=libgcrypt
$(package)_version=1.11.0
$(package)_download_path=https://gnupg.org/ftp/gcrypt/libgcrypt
$(package)_file_name=libgcrypt-$($(package)_version).tar.bz2
$(package)_sha256_hash=09120c9867ce7f2081d6aaa1775386b98c2f2f246135761aae47d81f58685b9c
$(package)_dependencies=libgpg-error

define $(package)_set_vars
  $(package)_config_opts=--enable-static --disable-shared --disable-doc --disable-nls
  $(package)_config_opts+=--with-libgpg-error-prefix=$(host_prefix)
  $(package)_config_env=GPG_ERROR_CONFIG=$(host_prefix)/bin/gpg-error-config
  $(package)_config_env+=GPGRT_CONFIG=$(host_prefix)/bin/gpgrt-config
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

# libgcrypt 1.11.0's McEliece implementation exposes a global gf_mul symbol.
# OpenSSL 3 also defines gf_mul; a fully static CoinGUI link must retain BOTH
# implementations without either silently overriding the other. Rename only
# libgcrypt's archive symbol and its intra-archive relocations using objcopy.
# This changes no public gcrypt API and requires no source patch.
define $(package)_postprocess_cmds
  test -s lib/libgcrypt.a && test -s include/gcrypt.h && \
  objcopy --redefine-sym gf_mul=coin_gcrypt_mceliece_gf_mul lib/libgcrypt.a && \
  $(host_RANLIB) lib/libgcrypt.a && \
  $(host_NM) -g --defined-only lib/libgcrypt.a | grep -w coin_gcrypt_mceliece_gf_mul
endef
