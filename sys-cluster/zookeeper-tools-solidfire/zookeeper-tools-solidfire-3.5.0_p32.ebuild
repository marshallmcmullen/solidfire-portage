# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 solidfire

DESCRIPTION="Collection of ZooKeeper tools."
HOMEPAGE="http://zookeeper.apache.org/"
SRC_URI="https://bitbucket.org/solidfire/${UPSTREAM_PN//-tools}/get/solidfire/${PV}.tar.bz2 -> ${P//-tools}.tar.bz2"

LICENSE="Apache-2.0"
KEYWORDS="amd64 ~amd64"

DEPEND="dev-libs/boost
    dev-libs/libxml2
    dev-libs/log4cxx
    =sys-cluster/zookeeper-solidfire-${PV}"
RDEPEND="${DEPEND}"

#----------------------------------------------------------------------------------------------------------------------
# WRAPPERS FOR EACH TOOL
#----------------------------------------------------------------------------------------------------------------------

ZKTOOLS=(
	zktreeutil
	zkpython
)

src_configure()
{
	for tool in ${ZKTOOLS[@]}; do
		phase "Configuring ${tool}"
		pushd src/contrib/${tool}
		src_configure_${tool} || die
		popd
	done
}

src_compile()
{
	append-cxxflags "-I/sf/packages/zookeeper-solidfire-${PV}/include"

	for tool in ${ZKTOOLS[@]}; do
		phase "Compiling ${tool}"
		pushd src/contrib/${tool}
		src_compile_${tool} || die
		popd
	done
}

src_install()
{
	for tool in ${ZKTOOLS[@]}; do
		phase "Installing ${tool}"
		pushd src/contrib/${tool}
		src_install_${tool} || die
		popd
	done
}

#----------------------------------------------------------------------------------------------------------------------
# ZKTREEUTIL
#----------------------------------------------------------------------------------------------------------------------

src_configure_zktreeutil()
{
	sed -e 's|#include <log4cxx/logger.h>|#include <log4cxx/logger.h>\
		#include <unistd.h>|' \
		-i src/ZkAdaptor.cc || die
	
	sed -e "s|zookeeper_mt|zookeeper_mt-solidfire-${PV}|g" \
		-e 's|ZOOKEEPER_PATH=${BUILD_PATH}/../../c|ZOOKEEPER_PATH=/sf/packages/zookeeper-solidfire-'${PV}'|g' \
		-e 's|${ZOOKEEPER_PATH}/.libs|/sf/packages/zookeeper-solidfire-'${PV}'/lib|g' \
		-e "s|-lzookeeper_mt-${PV}|-lzookeeper_mt-solidfire-${PV} -Wl,-rpath,/sf/packages/zookeeper-solidfire-${PV}|g" \
		-i configure.ac || die

    eautoreconf -if
    econf
}

src_compile_zktreeutil()
{
    emake
}

src_install_zktreeutil()
{
	emake DESTDIR="${D}" install
	dobinlinks ${DP}/bin/*
}

#----------------------------------------------------------------------------------------------------------------------
# ZKPYTHON
#----------------------------------------------------------------------------------------------------------------------

src_configure_zkpython()
{
    sed -e 's|libraries=|runtime_library_dirs=["/sf/packages/zookeeper-solidfire-'${PV}'/lib"],libraries=|g' \
		-e 's|zookeeper_basedir = "../../../"|zookeeper_basedir = "/sf/packages/zookeeper-solidfire-'${PV}'/"|' \
		-e 's|"/src/c/include"|"/include"|g'                                             \
		-e 's|"/src/c/.libs/"|"/lib"|g'                                                  \
		-e 's|zookeeper_mt|zookeeper_mt-solidfire-'${PV}'|g'                             \
        -e 's|version = "0.4"|version = "solidfire-'${PV}'"|g'                           \
		-i src/python/setup.py || die
}

src_compile_zkpython()
{ :; }

src_install_zkpython()
{
	cp src/python/setup.py .
	sp src/c/* .
	dopython_install
}
