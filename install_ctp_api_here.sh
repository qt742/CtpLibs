#!/bin/bash


function print_usage(){
	echo ""	
	echo "Usage:"
	echo "     install_ctp_api_here.sh platform version"	
	echo ""
}


function gbk_to_utf8() {
  echo "gbk_to_utf8 ... $1"
  enc=$(file -I $1)
  if [[ $enc =~ "utf-8" ]]; then
  	cat $1 >  $2
  fi

  if [[ $enc =~ "iso-8859-1" ]]; then
  	/usr/bin/iconv -f GBK -t UTF-8 $1 >  $2
  fi
}


function macos_install() {
	ver=$2
	from="$1/$ver"
	to="$3/api-macos"
	echo "macos_install $from   to   $to"
	if [ -d $from ]; then
		echo ""
		test -d "$to" && rm -fr "$to"
		mkdir $to
		cp -fr $from/thosttraderapi_se.framework $to/
		cp -fr $from/thostmduserapi_se.framework $to/

		ln -s $to/thosttraderapi_se.framework/Versions/A/thosttraderapi_se $to/libthosttraderapi_se.dylib
		ln -s $to/thostmduserapi_se.framework/Versions/A/thostmduserapi_se $to/libthostmduserapi_se.dylib		

		gbk_to_utf8 $from/thosttraderapi_se.framework/Versions/A/Headers/ThostFtdcTraderApi.h $to/ThostFtdcTraderApi.h
		gbk_to_utf8 $from/thosttraderapi_se.framework/Versions/A/Headers/ThostFtdcUserApiDataType.h $to/ThostFtdcUserApiDataType.h
		gbk_to_utf8 $from/thosttraderapi_se.framework/Versions/A/Headers/ThostFtdcUserApiStruct.h $to/ThostFtdcUserApiStruct.h
		gbk_to_utf8 $from/thostmduserapi_se.framework/Versions/A/Headers/ThostFtdcMdApi.h $to/ThostFtdcMdApi.h
	else
		echo "Error: NOT FOUND macos-$ver"
	fi 	
	
	
}


function linux_install() {
	libs=$1
	ver=$2
	to=$3
	echo "linux_install $libs $ver to $to"
	test -d $libs/linux/$ver || echo "Error: NOT FOUND linux-$ver"; exit 2



}

function windows_install() {
	libs=$1
	ver=$2
	to=$3
	echo "windows_install $libs $ver to $to"
	test -d $libs/windows/$ver || echo "Error: NOT FOUND windows-$ver"; exit 2


}


PLATFORM=$1
VERSION=$2

if [ "" == "$PLATFORM" ]; then
	echo "Error: Missing Platform"
	print_usage
	exit 1
fi

if [ "" == "$VERSION" ]; then
	echo "Eroror: Missing Version"
	print_usage	
	exit 1
fi


echo "PLATFORM: $PLATFORM"
echo "VERSION: $VERSION"


LIBS_DIR="$(cd "$(dirname $0)" && pwd)"
echo "LIBS_DIR: $LIBS_DIR"
HERE=`pwd`

case $PLATFORM in 
	macos)
	  echo "calling... macos_install"	
	  macos_install $LIBS_DIR/macos $VERSION $HERE
	;;

	cp-macos)
	  echo "calling... macos_install"	
	  macos_install $LIBS_DIR/cp-macos $VERSION $HERE
	;;

	linux)
	  echo "calling... linux_install"
	  linux_install $LIBS_DIR/linux $VERSION $HERE
	;;

	windows)
	  echo "calling... windows_install"
	  windows_install $LIBS_DIR/windws $VERSION $HERE
	;;

esac




