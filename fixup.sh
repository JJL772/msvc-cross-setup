#!/usr/bin/env bash

# Fixer for fucked up windows includes
set -e
if [[ -z "$1" ]]; then
	echo "USAGE: $0 <prefix>"
	exit 1
fi

cd "$(dirname "$0")"

# Fixup kit includes
for kit in "$1/kits/10/Include/"*; do
	pushd "$kit/um" > /dev/null
	ln -svf "ole2.h" "Ole2.h"
	ln -svf "olectl.h" "OleCtl.h"
	ln -svf "windows.h" "Windows.h"
	popd > /dev/null
	./scripts/fixinclude "$kit/um/"
done

for kit in "$1/kits/10/Lib/"*; do
	# Fixups for various pragma comments we can't/don't want to change
	for arch in "$kit/um/"*; do
		pushd "$arch" > /dev/null
		ln -svf "imm32.lib" "Imm32.Lib"
		ln -svf "winmm.lib" "WinMM.Lib"
		ln -svf "d3dcompiler.lib" "D3DCompiler.lib"
		popd > /dev/null
	done
done

function fixup-rc {
	cp -fv "$1" "$1.old"
	chmod -w "$1.old"
	iconv -t UTF-8 -o "$1" "$1.old" || true # Some of these fail, so let's just ignore the error...
}

# Fixup MFC/ATL
for msvc in "$1/VC/Tools/MSVC/"*; do
	./msvc-wine/lowercase "$msvc/atlmfc/include"
	./scripts/fixinclude "$msvc/atlmfc/include"
	
	# re-encode resource files under UTF8
	for r in "$msvc/atlmfc/include/"*.rc; do
		if file -i "$r" | grep -oq utf-16; then
			echo "Re-encoding $r"
			fixup-rc "$r"
		fi
	done

	# Fix icon paths to use forward slash
	echo "Fixing icon paths"
	sed -i "s/\"res\\\\\\\\/\"res\//g" "$msvc/atlmfc/include/afxres.rc"
done

