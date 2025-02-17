# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "librdkafka"
version = v"2.0.3" # note: bumped from 2.0.2 for SASL integration

# Collection of sources required to complete build
sources = [
    # git rev-list -n 1 v2.0.2
    GitSource("https://github.com/confluentinc/librdkafka.git",
        "292d2a66b9921b783f08147807992e603c7af059",
    ),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/librdkafka*
if [[ "${target}" != *-freebsd* ]]; then
    rm -f /opt/${target}/${target}/sys-root/usr/lib/libcrypto.*
    rm -f /opt/${target}/${target}/sys-root/usr/lib/libssl.*
    rm -f /opt/${target}/${target}/sys-root/usr/lib/libsasl2.*
fi
mkdir build
cd build/
cmake -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DRDKAFKA_BUILD_EXAMPLES=OFF \
    -DRDKAFKA_BUILD_TESTS=OFF \
    ..
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(supported_platforms())


# The products that we will ensure are always built
products = [
    LibraryProduct("librdkafka", :librdkafka)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="Lz4_jll", uuid="5ced341a-0733-55b8-9ab6-a4889d929147")),
    Dependency(PackageSpec(name="Zstd_jll", uuid="3161d3a3-bdf6-5164-811a-617609db77b4")),
    Dependency(PackageSpec(name="Zlib_jll", uuid="83775a58-1f1d-513f-b197-d71354ab007a")),
    Dependency(PackageSpec(name="OpenSSL_jll", uuid="458c3c95-2e84-50aa-8efc-19380b2a3a95"); compat="1.1.10"),
    Dependency(PackageSpec(name="CyrusSASL_jll", uuid="6422fedd-75a7-50c2-a7c3-a11dad25a896")),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
    julia_compat="1.6")
