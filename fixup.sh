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
	ln -svf "$kit/um/ole2.h" "$kit/um/Ole2.h"
	ln -svf "$kit/um/olectl.h" "$kit/um/OleCtl.h"
	./scripts/fixinclude "$kit/um/"
	ln -svf "$kit/um/windows.h" "$kit/um/Windows.h"
done

for kit in "$1/kits/10/Lib/"*; do
	# Fixups for various pragma comments we can't/don't want to change
	for arch in "$kit/um/"*; do
		ln -svf "$arch/imm32.lib" "$arch/Imm32.Lib"
		ln -svf "$arch/winmm.lib" "$arch/WinMM.Lib"
		ln -svf "$arch/d3dcompiler.lib" "$arch/D3DCompiler.lib"
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

