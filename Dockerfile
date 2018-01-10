FROM fedora:latest

RUN useradd -ms /bin/bash rust

# pre-compiled from https://github.com/gsauthof/pe-util
ADD peldd /usr/bin/peldd
ADD package.sh /usr/bin/package.sh

RUN dnf install -y mingw64-gcc mingw64-freetype mingw64-cairo mingw64-harfbuzz mingw64-pango mingw64-poppler mingw64-gtk3 mingw64-winpthreads-static mingw64-glib2-static gcc boost zip && dnf clean all -y

USER rust

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN . ~/.cargo/env && \
    rustup install nightly && \
    rustup default nightly && \
    rustup target add x86_64-pc-windows-gnu

ADD cargo.config /home/rust/.cargo/config
ADD Windows10 /home/rust/Windows10

ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
ENV GTK_INSTALL_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/
VOLUME /home/rust/src
WORKDIR /home/rust/src
CMD ["/usr/bin/package.sh"]

# So one could build a project in the current directory, where this Dockerfile is by
#   1) Modifying the Dockerfile to add all your native dependencies
#   2) Building the image:
#       $ docker build . -t PROJECTNAME-build-image
#   3) Creating a container with the source mounted the image (which kicks off the build):
#       $ docker create -v `pwd`:/home/rustacean/src --name PROJECTNAME-build PROJECTNAME-build-image
#   4) Each time you want to build the project, start the Docker container. 
#      Add "-ai" to watch the build progress.
#       $ docker start PROJECTNAME-build
