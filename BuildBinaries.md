Last build Feb. 2022

## Buildinstructions libdatachannel

### Windows
##### x86_64

##### arm64


### Linux

### Mac
##### arm64
cmake -B build_arm64 -DCMAKE_OSX_ARCHITECTURES="arm64" -DNO_TESTS=1 -DNO_EXAMPLES=1 -DUSE_GNUTLS=0 -DUSE_NICE=0 -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3 -DOPENSSL_USE_STATIC_LIBS=1
cd build_arm64
make -j2 datachannel-static

##### x86_64
cmake -B build_x86_64 -DCMAKE_OSX_ARCHITECTURES="x86_64" -DNO_TESTS=1 -DNO_EXAMPLES=1 -DUSE_GNUTLS=0 -DUSE_NICE=0 -DOPENSSL_ROOT_DIR=/usr/local/homebrew/opt/openssl@3 -DOPENSSL_USE_STATIC_LIBS=1
cd build_x86_64
make -j2 datachannel-static


### Android
##### x86_64
##### arm64