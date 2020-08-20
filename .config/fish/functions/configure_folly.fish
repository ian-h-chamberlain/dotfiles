function configure_folly
    pushd ~/Documents/workspace/thirdparty/folly/folly
    autoreconf -ivf
    ./configure \
        CPPFLAGS="-I/opt/local/include -I/usr/local/opt/boost@1.55/include" \
        LDFLAGS="-L/opt/local/lib -L/usr/local/opt/boost@1.55/lib" \
        --with-boost=/usr/local/opt/boost@1.55
    popd
end
