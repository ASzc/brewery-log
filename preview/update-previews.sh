#!/bin/bash

set -euo pipefail

cd render
for i in {1..4}
do
    pdf2svg "../biab.pdf" "biab-$i.svg" "$i"
done
