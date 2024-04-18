FROM fedora:38 AS updated_image
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

RUN dnf -y update                      \
    && dnf -y upgrade                  \
    && dnf -y install dnf-plugins-core

FROM updated_image AS installed_basic_libs
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

RUN dnf -y --refresh install              \
    --setopt=tsflags=nodocs               \
    --setopt=deltarpm=false               \
    allegro5                              \
    allegro5-devel.aarch64                \
    SDL2                                  \
    SDL2-devel.aarch64                    \
    SDL2-static.aarch64                   \
    SDL2_image.aarch64                    \
    SDL2_image-devel.aarch64              \
    SDL2_ttf                              \
    SDL2_ttf-devel.aarch64                \
    SDL2_mixer                            \
    SDL2_mixer-devel.aarch64              \
    SDL2_gfx                              \
    SDL2_gfx-devel.aarch64                \
    libcaca.aarch64                       \
    libcaca-devel.aarch64                 \
    SFML.aarch64                          \
    SFML-devel.aarch64                    \
    CSFML.aarch64                         \
    CSFML-devel.aarch64                   \
    autoconf                              \
    automake                              \
    boost                                 \
    boost-devel.aarch64                   \
    boost-graph                           \
    boost-math                            \
    boost-static.aarch64                  \
    ca-certificates.noarch                \
    clang.aarch64                         \
    clang-analyzer                        \
    cmake.aarch64                         \
    curl.aarch64                          \
    elfutils-libelf-devel.aarch64         \
    gcc-c++.aarch64                       \
    gcc.aarch64                           \
    gdb.aarch64                           \
    git                                   \
    glibc-devel.aarch64                   \
    glibc-locale-source.aarch64           \
    glibc.aarch64                         \
    gmp-devel.aarch64                     \
    ksh.aarch64                           \
    langpacks-en                          \
    libconfig                             \
    libconfig-devel                       \
    libX11-devel.aarch64                  \
    libXext-devel.aarch64                 \
    libXrandr-devel.aarch64               \
    libXinerama-devel.aarch64             \
    libXcursor-devel.aarch64              \
    libXi-devel.aarch64                   \
    libjpeg-turbo-devel.aarch64           \
    libtsan                               \
    llvm.aarch64                          \
    llvm-devel.aarch64                    \
    ltrace.aarch64                        \
    make.aarch64                          \
    meson                                 \
    nasm.aarch64                          \
    ncurses-devel.aarch64                 \
    ncurses-libs                          \
    ncurses.aarch64                       \
    net-tools.aarch64                     \
    nc                                    \
    ninja-build                           \
    openal-soft-devel.aarch64             \
    openssl-devel                         \
    patch                                 \
    procps-ng.aarch64                     \
    python3.aarch64                       \
    python3-devel.aarch64                 \
    rlwrap.aarch64                        \
    ruby.aarch64                          \
    strace.aarch64                        \
    sudo.aarch64                          \
    systemd-devel                         \
    tar.aarch64                           \
    tcsh.aarch64                          \
    tmux.aarch64                          \
    tree.aarch64                          \
    unzip.aarch64                         \
    diffutils                             \
    valgrind.aarch64                      \
    wget.aarch64                          \
    which.aarch64                         \
    xcb-util-image-devel.aarch64          \
    xcb-util-image.aarch64                \
    xz.aarch64                            \
    zip.aarch64                           \
    zsh.aarch64                           \
    vim

FROM installed_basic_libs AS installed_intermediate_libs
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

RUN dnf -y --refresh install     \
    cargo                        \
    rust                         \
    ghc                          \
    nodejs                       \
    php.aarch64                  \
    php-devel.aarch64            \
    php-bcmath.aarch64           \
    php-cli.aarch64              \
    php-devel.aarch64            \
    php-gd.aarch64               \
    php-mbstring.aarch64         \
    php-mysqlnd.aarch64          \
    php-pdo.aarch64              \
    php-pear.noarch              \
    php-pdo.aarch64              \
    php-xml.aarch64              \
    php-gettext-gettext.noarch   \
    php-phar-io-version.noarch   \
    php-theseer-tokenizer.noarch \
    libuuid libuuid-devel        \
    java-17-openjdk              \
    java-17-openjdk-devel        \
    bc

FROM installed_intermediate_libs AS installed_external_libs
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

RUN python3 -m pip install --upgrade pip               \
    && python3 -m pip install -Iv gcovr==6.0           \
                                  pycryptodome==3.18.0 \
                                  requests==2.31.0     \
                                  pyte==0.8.1          \
                                  numpy==1.25.2        \
    && npm install -g npm                              \
    && npm install -g bun

# Install Cabal, GHC and Stack using GHCup
RUN cd /tmp                                                                    \
    && curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

RUN cd /tmp                                                     \
    && git clone https://github.com/Snaipe/Criterion.git        \
    && cd Criterion                                             \
    && /usr/bin/meson setup build                               \
    && /usr/bin/meson install -C build                          \
    && mv build/src/libcriterion* /usr/lib                      \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf \
    && ldconfig

FROM installed_external_libs as all_setup
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

ENV LANG=en_US.utf8                          \
    LANGUAGE=en_US:en                        \
    LC_ALL=en_US.utf8                        \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

FROM all_setup as cleaned_up
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

RUN cd /tmp            \
    && rm -rf /tmp/*   \
    && chmod 1777 /tmp

RUN dnf clean all -y

WORKDIR /usr/app
