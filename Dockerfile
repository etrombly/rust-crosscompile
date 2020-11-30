FROM fedora:latest
WORKDIR /root
RUN dnf install -y git cmake gcc-c++ boost-devel
RUN git clone https://github.com/gsauthof/pe-util
WORKDIR pe-util
RUN git submodule update --init
RUN mkdir build
WORKDIR build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make

FROM fedora:latest
COPY --from=0 /root/pe-util/build/peldd /usr/bin/peldd
ADD package.sh /usr/bin/package.sh
RUN dnf install -y mingw64-gcc mingw64-freetype mingw64-cairo mingw64-harfbuzz mingw64-pango mingw64-poppler mingw64-gtk3 mingw64-winpthreads-static mingw64-glib2-static gcc boost zip && dnf clean all -y
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup install nightly && \
    rustup default nightly && \
    rustup target add x86_64-pc-windows-gnu
ADD cargo.config /home/rust/.cargo/config
ADD Windows-10 /home/rust/Windows10
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
ENV GTK_INSTALL_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/
VOLUME /home/rust/src
WORKDIR /home/rust/src
CMD ["/usr/bin/package.sh"]
