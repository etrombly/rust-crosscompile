#!/bin/bash

source ~/.cargo/env
cargo build --target=x86_64-pc-windows-gnu --release

if [ -d package ]
then
	rm -rf package
fi

mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package

export DLLS=`peldd package/*.exe -t --ignore-errors`
for DLL in $DLLS
    do cp "$DLL" package
done

mkdir -p package/share/{themes,gtk-3.0}
cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas package/share/glib-2.0
cp -r $GTK_INSTALL_PATH/share/icons package/share/icons

if [ -z "$WIN_THEME" ]
then
	cat <<-EOF > package/share/gtk-3.0/settings.ini
	[Settings]
	gtk-font-name = Segoe UI 10
	gtk-xft-rgba = rgb
	gtk-xft-antialias = 1
EOF
else
	cp -r /home/rust/Windows10 package/share/themes

	cat <<-EOF > package/share/gtk-3.0/settings.ini
	[Settings]
	gtk-theme-name = Windows10
	gtk-font-name = Segoe UI 10
	gtk-xft-rgba = rgb
	gtk-xft-antialias = 1
	EOF
fi

find package -maxdepth 1 -type f -exec mingw-strip {} +

zip -qr package.zip package/*
