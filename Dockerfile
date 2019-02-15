FROM alpine:3.9 AS builder
RUN apk add --update --no-cache alpine-sdk openssl-dev cmake git zlib-dev

RUN git clone --single-branch --depth 1 https://github.com/giltene/wrk2.git
RUN git clone --single-branch --depth 1 https://github.com/HdrHistogram/HdrHistogram_c
WORKDIR /HdrHistogram_c
RUN cmake CMakeLists.txt
RUN make install

ENV LDFLAGS -static-libgcc
ENV CFLAGS -static-libgcc
WORKDIR /wrk2
RUN make
RUN mv wrk /usr/local/bin/wrk2

FROM alpine:3.9
RUN apk add --update --no-cache openssl ca-certificates gnuplot
COPY --from=builder /usr/local/bin/hdr_* /bin/
COPY --from=builder /usr/local/bin/wrk2 /bin/
ENTRYPOINT ["wrk2"]
# sample options:
#   using 2 threads, 
#   keeping 100 HTTP connections open, 
#   run for 30 seconds, 
#   with constant throughput of 12000 requests per second (total, across all connections combined)
#   add detailed latency percentile information (spreadsheets, gnuplot or http://hdrhistogram.org/)
#CMD ["-t2", "-c100", "-d30s", "-R12000", "--latency", "http://172.17.0.1/index.html"]
