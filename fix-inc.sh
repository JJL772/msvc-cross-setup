#!/usr/bin/env bash

# Fixer for fucked up windows includes
set -e
if [[ -z "$1" ]]; then
	echo "USAGE: $0 <prefix>"
	exit 1
fi

for kit in "$1/kits/10/Include/"*; do
	ln -svf "$kit/um/ole2.h" "$kit/um/Ole2.h"
	ln -svf "$kit/um/olectl.h" "$kit/um/OleCtl.h"
done

