# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit solidfire

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="http://jsoncpp.sourceforge.net"
SRC_URI="https://bitbucket.org/solidfire/${MY_PN}/get/solidfire/${PVR}.tar.bz2 -> ${PF}.tar.bz2"

LICENSE="public-domain"
KEYWORDS="~amd64 amd64"

DEPEND="dev-util/scons"
RDEPEND=""

src_compile()
{
	append-cxxflags -Iinclude -fPIC -DNDEBUG

	local_src_compile()
	{
		set -- $(tc-getCXX) ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} "${@}" || die "Failed to compile : ${@}"
		echo "${@}"
		"${@}"
	}

	mkdir obj
	for f in $(ls src/lib_json/*.cpp); do
		local_src_compile -c ${f} -o obj/$(basename ${f} .cpp).o
	done

	# create SO
	local_src_compile obj/*.o -shared -Wl,-soname,libjson_libmt${PS}.so -o libjson_libmt${PS}.so
	ar cr libjson_libmt${PS}.a obj/*.o || die
}

src_install()
{
	default_src_install

	# Follow Debian, Ubuntu, Arch convention for headers location, bug #452234 .
	doheader -r include/json/*

	dolib libjson_libmt${PS}.so
	dolib libjson_libmt${PS}.a
}
