#!/bin/bash

set -euo pipefail

cd preview

render() {
    name="$1"
    pages="$2"
    echo "==> $name" >&2
    for i in $(seq 1 "$pages")
    do
        echo " -> $i" >&2
        out="$name-$i.svg"
        tmp="$(mktemp XXXXXXXXXX.tmp.svg)"
        # Convert
        pdf2svg "../$name.pdf" "$out" "$i"

        # Add white background
        xmlstarlet ed \
            -L \
            -N "svg=http://www.w3.org/2000/svg" \
            -i '/svg:svg/*[1]' -t elem -n "rect" \
            -s '//rect' -t attr -n "width" -v "100%" \
            -s '//rect' -t attr -n "height" -v "100%" \
            -s '//rect' -t attr -n "fill" -v "white" \
            "$out"

        # Clean / Minify
        svgcleaner --quiet --multipass --indent 1 "$out" "$tmp"
        mv "$tmp" "$out"
    done
}

render biab 4

echo "==> Done" >&2
