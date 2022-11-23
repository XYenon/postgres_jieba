FROM postgres:15-bullseye AS builder

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

COPY --from=builder /usr/lib/postgresql/15/lib/pg_jieba.so                 /usr/lib/postgresql/15/lib/pg_jieba.so
COPY --from=builder /usr/share/postgresql/15/extension/pg_jieba.control    /usr/share/postgresql/15/extension/pg_jieba.control
COPY --from=builder /usr/share/postgresql/15/extension/pg_jieba--1.1.1.sql /usr/share/postgresql/15/extension/pg_jieba--1.1.1.sql
COPY --from=builder /usr/share/postgresql/15/tsearch_data/jieba_base.dict  /usr/share/postgresql/15/tsearch_data/jieba_base.dict
COPY --from=builder /usr/share/postgresql/15/tsearch_data/jieba_hmm.model  /usr/share/postgresql/15/tsearch_data/jieba_hmm.model
COPY --from=builder /usr/share/postgresql/15/tsearch_data/jieba_user.dict  /usr/share/postgresql/15/tsearch_data/jieba_user.dict
COPY --from=builder /usr/share/postgresql/15/tsearch_data/jieba.stop       /usr/share/postgresql/15/tsearch_data/jieba.stop
COPY --from=builder /usr/share/postgresql/15/tsearch_data/jieba.idf        /usr/share/postgresql/15/tsearch_data/jieba.idf
