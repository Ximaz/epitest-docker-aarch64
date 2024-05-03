FROM arm64v8/fedora:40
LABEL maintainer="DURAND Malo <malo.durand@epitech.eu>"

COPY dnf.requirements.txt dnf.requirements.txt

ENV LANG=en_US.utf8 LANGUAGE=en_US:en LC_ALL=en_US.utf8 PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN dnf -y install $(cat "dnf.requirements.txt") \
    && dnf clean all -y                          \
    && rm -f "dnf.requirements.txt"

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

RUN python3 -m pip install --upgrade pip               \
    && python3 -m pip install -Iv gcovr==6.0           \
                                  pycryptodome==3.18.0 \
                                  requests==2.31.0     \
                                  pyte==0.8.1          \
                                  numpy==1.25.2        \
    && python3 -m pip cache purge                      \
    && npm install -g npm                              \
    && npm install -g bun

# Install Cabal, GHC and Stack using GHCup
RUN cd /tmp                                                                                                                               \
    && curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | GHCUP_CURL_OPTS="-k" BOOTSTRAP_HASKELL_GHC_VERSION="9.6.5" sh \
    && export PATH="/root/.ghcup/bin/:/root/.cabal/bin/:$PATH"

RUN cd /tmp                                                     \
    && git clone https://github.com/Snaipe/Criterion.git        \
    && cd Criterion                                             \
    && /usr/bin/meson setup build                               \
    && /usr/bin/meson install -C build                          \
    && mv build/src/libcriterion* /usr/lib                      \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf \
    && ldconfig

RUN cd /tmp            \
    && rm -rf /tmp/*   \
    && chmod 1777 /tmp

WORKDIR /usr/app
