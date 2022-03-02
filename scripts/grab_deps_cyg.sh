#!/bin/bash
# This script is quite old, and may need a rework.
CVM_HOME=$(pwd)

log(){
	printf "$1\n"
}


main(){
	log "Dependency grab started on $(date +"%x %I:%M %p").";
        if [[ ! -f "$CVM_HOME/setup.exe" ]];then log "Please copy the Cygwin setup file to $CVM_HOME/setup.exe before running this script.";else
	$CVM_HOME/setup.exe -X -q -W -P libvncserver-devel,libcairo-devel,libboost-devel,libsqlite3-devel,libsasl2-devel,libturbojpeg-devel,libjpeg-devel,wget,git,make,unzip
	if [ "$(uname -m)" == "x86_64" ]; then
		$CVM_HOME/setup.exe -X -q -W -s http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/64bit/2016/08/30/104235 -P gcc-core,gcc-g++
	else
		$CVM_HOME/setup.exe -X -q -W -s http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223 -P gcc-core,gcc-g++
	fi

	log "Dependency grab finished.";
        fi
		log "You might want to obtain a pthread equivalent that provides libpthread.a";
};main;
