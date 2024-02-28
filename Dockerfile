FROM alpine:latest as prereqisites

RUN apk add --no-cache \
    autoconf \
    automake \
    bash \
    bison \
    build-base \
    bzip2 \
    flex \
    gdk-pixbuf \
    gettext \
    git \
    gperf \
    intltool \
    libtool \
    linux-headers \
    lzip \
    openssl \
    openssl-dev \
    perl \
    python3 \
    py3-mako \
    ruby \
    unzip \
    wget \
    xz \
    zlib && \
    apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/v3.17/main \
    p7zip=17.04-r3

FROM prereqisites as builder
WORKDIR /opt/mxe
COPY . /opt/mxe/

ENV MXE_TARGETS="x86_64-w64-mingw32.static i686-w64-mingw32.static x86_64-w64-mingw32.shared i686-w64-mingw32.shared"
ENV mingw_w64_pthreads_CONFIGURE_OPTS="CFLAGS=-DWIN95_COMPAT_OVERRIDE CPPFLAGS=-DWIN95_COMPAT_OVERRIDE"
ENV THREADS="10"
ENV JOBS="2"
ENV PACKAGES="cc cmake"

RUN make ${PACKAGES} -j ${THREADS} JOBS=${JOBS} MXE_TARGETS="${MXE_TARGETS}" mingw-w64-pthreads_CONFIGURE_OPTS="${mingw_w64_pthreads_CONFIGURE_OPTS}" \
    && make clean-junk \
    && make clean-pkg

FROM scratch as output
COPY --from=builder /mxe/usr /

# invoke via
# docker build -o type=tar,dest=build/mxe.tar .
