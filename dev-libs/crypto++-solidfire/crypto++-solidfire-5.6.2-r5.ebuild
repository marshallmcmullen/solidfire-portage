# Copyright 2017-2018 NetApp, Inc. All rights reserved.

EAPI=5
inherit solidfire

DESCRIPTION="C++ class library of cryptographic schemes"
HOMEPAGE="http://cryptopp.com/"
SRC_URI="http://www.cryptopp.com/cryptopp${PV//.}.zip"

LICENSE="Boost-1.0"
KEYWORDS="~amd64 amd64"

DEPEND="app-arch/unzip
	sys-devel/libtool"
RDEPEND="${DEPEND}"

S=${WORKDIR}

PATCHES="makefile-${PV}.patch"

BUILD_PATHS="DESTDIR=${D} INCLUDEDIR=${PREFIX}/include LIBDIR=${PREFIX}/lib BINDIR=${PREFIX}/bin LIBSUFFIX=${PS} LIBTOOL=./libtool"

# Define a src_unpack() function to skip the solidfire_src_unpack()
# function, which does the wrong thing with our distfile's zip archive.
src_unpack()
{
	default_src_unpack
}

src_prepare()
{
	# Generate our own libtool script for building.
	cat <<-EOF > configure.ac
	AC_INIT(lt, 0)
	AM_INIT_AUTOMAKE
	AC_PROG_CXX
	LT_INIT
	AC_CONFIG_FILES(Makefile)
	AC_OUTPUT
	EOF
	touch NEWS README AUTHORS ChangeLog Makefile.am

	solidfire_src_prepare
	eautoreconf
}

src_compile()
{
    # higher optimizations cause problems
    replace-flags -O? -O1
    filter-flags -fomit-frame-pointer

	# Doesn't compile with C++11
	filter-flags -std=c++11
	
	# Add some package specific flags. In particular, needs -fPIC enabled to compile properly.
	append-cxxflags -DNDEBUG -g -fPIC

	# NOTE: Disable narrowing errors as this is a known bug in this older version of crypto++ which is now a fatal
	#       error in newer GCC.
	append-cxxflags -Wno-narrowing

	emake CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS}" ${BUILD_PATHS}
}

src_test()
{
	# ensure that all test vectors have Unix line endings
	local file
	for file in TestVectors/* ; do
		edos2unix ${file}
	done

	if ! emake CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS}" test ; then
		eerror "Crypto++ self-tests failed."
		eerror "Try to remove some optimization flags and reemerge Crypto++."
		die "emake test failed"
	fi
}

src_install()
{
	emake ${BUILD_PATHS} install

	# All our code expects the include and lib directories to be named 'cryptopp' and not 'crypto++' so create alias
	mkdir -p "${DP}/eselect"
	echo "cryptopp" > "${DP}/eselect/aliases"
}
