#!/bin/sh

GANGLIA_VERSION=3.6.0
RRDTOOL_VERSION=1.4.8

pushd $(pwd)
cd /tmp

function install_rrdtool {
    BUILD_DIR=/tmp/rrdbuild
    RRDTOOL_BASE=rrdtool-$RRDTOOL_VERSION
    INSTALL_DIR=/opt/$RRDTOOL_BASE
    # Install prerequisites
    zypper addrepo -f http://download.opensuse.org/distribution/11.4/repo/oss/ opensuse_11_4
    zypper install cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel
    # Dependency hell breaks loose...
    
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR
    wget http://oss.oetiker.ch/rrdtool/pub/$RRDTOOL_BASE.tar.gz
    gunzip -c $RRDTOOL_BASE.tar.gz | tar xf -
    cd $RRDTOOL_BASE
    ./configure --prefix=$INSTALL_DIR && make && make install
}

function install_ganglia {
    GANGLIA_BASE=ganglia-$GANGLIA_VERSION
    wget http://sourceforge.net/projects/ganglia/files/ganglia%20monitoring%20core/$GANGLIA_VERSION/$GANGLIA_BASE.tar.gz/download
    tar xvf $GANGLIA_BASE.tar.gz
    cd $GANGLIA_BASE
    ./configure --with-gmetad
    make
    make install
}

install_rrdtool
install_ganglia