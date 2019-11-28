using BinaryBuilder

name = "LuaJIT"
version = v"2.0.5"

sources = [
    "https://luajit.org/download/LuaJIT-$(version).tar.gz" =>
        "874b1f8297c697821f561f9b73b57ffd419ed8f4278c82e05b48806d30c1e979",
    "./bundled",
]

script = raw"""
cd ${WORKSPACE}/srcdir/LuaJIT-*

atomic_patch -p1 "${WORKSPACE}/srcdir/patches/src_Makefile.patch"

# This is needed in order to avoid building "minilua," a tiny implementation of plain
# Lua included in LuaJIT's build system that requires building with the host system's
# compiler rather than a cross compiler.
apk add lua5.1 lua5.1-dev luarocks5.1
luarocks-5.1 install luabitop

make -j${nproc} amalg PREFIX="${prefix}" HOST_LUA="$(which lua)"
make install PREFIX="${prefix}"
"""

platforms = filter(supported_platforms()) do platform
    arch(platform) !== :aarch64 && arch(platform) !== :powerpc64le
end

products = [
    ExecutableProduct("luajit", :luajit),
    LibraryProduct(["libluajit-5.1", "lua51"], :libluajit),
]

dependencies = []

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)