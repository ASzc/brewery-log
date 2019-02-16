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

        pdf="$name.pdf"
        out="$name-$i.svg"

        # Convert to PDF
        rm "$pdf"
        libreoffice --convert-to pdf "../$name.fodt"
        # Have to wait for async writing, libreoffice doesn't offer sync
        # convert-to at this time.
        while [ ! -f "$pdf" ]
        do
            sleep 0.5s
        done

        # Convert to SVG
        pdf2svg "$pdf" "$out" "$i"

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
        tmp="$(mktemp XXXXXXXXXX.tmp.svg)"
        svgcleaner --quiet --multipass --indent 1 "$out" "$tmp"
        mv "$tmp" "$out"
    done
}

render biab 4
render coverpage 1

echo "==> Done" >&2
