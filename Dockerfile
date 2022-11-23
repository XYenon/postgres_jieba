FROM postgres:15-bullseye AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates build-essential cmake postgresql-server-dev-$PG_MAJOR icu-devtools libicu-dev
RUN git clone https://github.com/jaiminpan/pg_jieba && \
    cd pg_jieba && git submodule update --init --recursive && \
    mkdir build && cd build && \
    cmake -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$PG_MAJOR/server .. && \
    make && make install


FROM postgres:15-bullseye AS prod
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8

RUN --mount=from=build,source=/,target=/build \
  cat /build/pg_jieba/build/install_manifest.txt | xargs -i cp /build{} {}
