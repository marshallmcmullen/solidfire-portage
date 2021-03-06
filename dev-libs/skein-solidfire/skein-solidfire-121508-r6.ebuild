# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit solidfire

DESCRIPTION="Skein hash function family"
HOMEPAGE="http://www.skein-hash.info"
SRC_URI="http://www.skein-hash.info/sites/default/files/skein_NIST_CD_${PV}.zip"

LICENSE="public-domain"
KEYWORDS="~amd64 amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/NIST/CD/Optimized_64bit"

# Define a src_unpack() function to skip the solidfire_src_unpack()
# function, which does the wrong thing with our distfile's zip archive.
src_unpack()
{
	default_src_unpack
}

src_prepare()
{
	cp ${FILESDIR}/Makefile . || die
}

src_install()
{
	emake LIBDIR="${DP}/lib" INCDIR="${DP}/include" install || die
}
