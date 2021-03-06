# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Ebuild generated by g-pypi 0.4

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1


DESCRIPTION="Redis built into a python package"
HOMEPAGE="https://github.com/yahoo/redislite"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}"

src_prepare()
{
	distutils-r1_src_prepare

	# There's a bug in the Makefile for hiredis wherein it's appending $(ARCH) to the CFLAGS and LDFLAGS and that is
	# normally not set. But Gentoo does set that so it ends up failing due to an invalid compie line like:
	# gcc -std=c99 -pedantic -c -O3 -fPIC -march=corei7 -O2 -pipe -Wall -W -Wstrict-prototypes -Wwrite-strings -g -ggdb amd64 net.c
	# gcc: error: amd64: No such file or directory
	# So we just remove the unnecessary $(ARCH) parameter.
	sed -i -e 's|REAL_CFLAGS=$(OPTIMIZATION) -fPIC $(CFLAGS) $(WARNINGS) $(DEBUG) $(ARCH)|REAL_CFLAGS=$(OPTIMIZATION) -fPIC $(CFLAGS) $(WARNINGS) $(DEBUG)|' \
	       -e 's|REAL_LDFLAGS=$(LDFLAGS) $(ARCH)|REAL_LDFLAGS=$(LDFLAGS)|' \
		"${S}/redis.submodule/deps/hiredis/Makefile" || die
}
