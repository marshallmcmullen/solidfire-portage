# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
VTAG="solidfire"
inherit gcc-${VTAG}-4.8.1 versionize

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="http://jsoncpp.sourceforge.net"
MY_P="${MY_PN}-src-${PV/_/-}"
SRC_URI="mirror://sourceforge/jsoncpp/${MY_P}-rc2.tar.gz"
S="${WORKDIR}/${MY_P}-rc2"

LICENSE="public-domain"
KEYWORDS="~amd64 amd64"

DEPEND="dev-util/scons"
RDEPEND=""

PATCHES=(
	"${FILESDIR}/compact_streaming.patch"
	"${FILESDIR}/convert_numbers_to_strings.patch"
	"${FILESDIR}/uint64.patch"
)

cxx_wrapper()
{
	set -- ${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} "$@"
	echo "$@"
	"$@"
}

src_configure()
{ :; }

src_compile()
{
	mkdir obj
	for f in $(ls src/lib_json/*.cpp); do
		cxx_wrapper -Iinclude -fPIC -c ${f} -o obj/$(basename ${f} .cpp).o || die "Failed to compile ${f}"
	done

	# create SO
	cxx_wrapper -Iinclude obj/*.o -shared -fPIC -Wl,-soname,libjson_libmt-${MY_PVR}.so -o libjson_libmt-${MY_PVR}.so || die
	ar cr libjson_libmt-${MY_PVR}.a obj/*.o || die
}

src_install()
{
	versionize_src_install

	# Follow Debian, Ubuntu, Arch convention for headers location, bug #452234 .
	insinto $(dirv include)
	doins -r include/json/*

	insinto $(dirv lib)
	doins libjson_libmt-${MY_PVR}.so
	doins libjson_libmt-${MY_PVR}.a
}
