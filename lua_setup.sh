#!/bin/tcsh

echo "Downloading pkg components"
pkg install lua54 autoconf automake libtool pkgconf wget git

echo "Downloading Rust"
curl https://sh.rustup.rs | sh

echo "Adding Rust to cshrc"
echo "setenv PATH $HOME/.cargo/bin:$PATH" >> ~/.cshrc
echo "setenv CARGO_HOME $HOME/.cargo" >> ~/.cshrc
source ~/.cshrc

echo "Downloading and unpacking Suricata 7.0.6"
wget https://github.com/OISF/suricata/archive/refs/tags/suricata-7.0.6.tar.gz 
mkdir suricata
tar -xzvf suricata-7.0.6.tar.gz -C suricata --strip-components

echo "Getting subcomponents"
git clone https://github.com/OISF/libhtp suricata/
cargo install --force cbindgen

alias autogens '\
  cd suricata/; \
  echo "Performing autogens"; \
  ./autogen.sh \
'

alias linkers '\
  echo "Creating links"; \
  ln -sf /usr/local/include/lua54/lua.h /usr/include/lua.h; \
  ln -sf /usr/local/include/lua54/lualib.h /usr/include/lualib.h; \
  ln -sf /usr/local/include/lua54/lauxlib.h /usr/include/lauxlib.h; \
  ln -sf /usr/local/include/lua54/luaconf.h /usr/include/luaconf.h; \
  ln -sf /usr/local/include/lua54/ /usr/local/include/lua; \
  ln -sf /usr/local/lib/liblua-5.4.a /usr/local/lib/liblua54.a; \
  ln -sf /usr/local/lib/liblua-5.4.so /usr/local/lib/liblua54.so; \
  ln -sf /usr/local/libdata/pkgconfig/lua-5.4.pc /usr/local/libdata/pkgconfig/lua.pc \
'

alias flags '\
  echo "Setting compiler flags"; \
  setenv LUA_CFLAGS "-I/usr/local/include/lua5.4"; \
  setenv LUA_LIBS "-L/usr/local/lib -llua-5.4" \
'

alias conf '\
  echo "Running configure"; \
  ./configure --enable-lua --with-lua=/usr/local/lib \
'

alias maker '\
  echo "Running make"; \
  make && make install-full \
'

autogens
linkers
flags
conf
maker
echo "All done, run source ~/.cshrc"
