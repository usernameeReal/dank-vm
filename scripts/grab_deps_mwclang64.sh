#!/bin/bash
CVM_HOME=$(pwd)

log(){
	printf "$1\n"
}

triplet_install(){
	pacman -S --noconf mingw-w64-clang-x86_64-$1;
}

main(){
	log "Dependency grab started on $(date +"%x %I:%M %p").";
	triplet_install "libvncserver";
	triplet_install "cairo";
	triplet_install "dlfcn";
	triplet_install "boost";
	triplet_install "sqlite3";
#	triplet_install "cyrus-sasl"; # clang32 and clang64 don't define LIBVNCSERVER_HAVE_SASL?
	triplet_install "winpthreads-git";

	log "Dependency grab finished.";
};main;
