#!/bin/bash -e

export NAME=http-protocol-options

# shellcheck source=examples/verify-common.sh
. "$(dirname "${BASH_SOURCE[0]}")/../verify-common.sh"

set -e

path_list=( http11 http2 http3 )

run_log "Test HTTP1.1 -> HTTP1.1/HTTP2/HTTP3"
for path in "${path_list[@]}"; do
    run_log "HTTP1.1 -> $path"
    curl -svk -o /dev/null --http1.1 "https://localhost:10000/${path}" 2>&1 | grep "HTTP/1.1 200"
done

run_log "Test HTTP2 -> HTTP1.1/HTTP2/HTTP3"
for path in "${path_list[@]}"; do
    run_log "HTTP2 -> $path"
    curl -svk -o /dev/null --http2 --http2-prior-knowledge "https://localhost:10001/${path}" 2>&1 | grep "HTTP/2 200"
done

run_log "Test HTTP3 -> HTTP1.1/HTTP2/HTTP3"
for path in "http3"; do
    run_log "HTTP3 -> $path"
    # TODO(su225): find an official image for security purposes. Because using 
    #        random images found on the internet is a bad idea. Unfortunately,
    #        it seems that the official curl image does not support HTTP/3 yet.
    #        So using --http3 flag does not work
    docker run -it --rm --network=host dalgibbard/curl-http3 \
        -svk -o /dev/null --http3 --resolve test.proxy:10002:127.0.0.1 "https://test.proxy:10002/$path"
done
