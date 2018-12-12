# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Ebuild generated by g-pypi 0.4

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1


DESCRIPTION="A fork of the HotQueue Python library that allows you to use Redis/Redislite as a message queue."
HOMEPAGE="http://github.com/dwighthubbard/hotqueue"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}"




