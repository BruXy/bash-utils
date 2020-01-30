#!/bin/bash
AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A"
URL_FORMAT="http://example/image_%04d.jpg"

function prepare_cookie() {
    jq -r '.[] | "\(.name)=\(.value)" ' < init_cookie.json | tr '\n' ';'
}

COOKIE=$(prepare_cookie)

for i in {0..128}
do
    printf -v URL "$URL_FORMAT" $i
    printf -v counter "%04d" $i
    ret_code=$(curl --user-agent "$AGENT" --silent --cookie "$COOKIE" \
         --write-out "%{http_code}" "$URL" --output ${counter}.jpg)

    echo Retrieving: $URL
    echo Return $ret_code

    if [[ $ret_code == "200" ]] ; then
        echo Saving to: ${counter}.jpg
    else
        echo Non-OK status received.
        exit 1
    fi
done

