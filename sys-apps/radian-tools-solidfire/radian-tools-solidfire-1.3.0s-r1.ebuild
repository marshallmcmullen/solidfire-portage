# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5
inherit solidfire

DESCRIPTION="Radian NVRAM userspace tools"
HOMEPAGE="http://www.radianmemory.com"
SRC_URI="http://bitbucket.org/solidfire/${MY_PN}/get/release/${PV}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="Radian Memory Systems Restricted Use License (1/10/2014)"
KEYWORDS="~amd64 amd64"

DEPEND="dev-libs/libnl
	virtual/pkgconfig"

src_install()
{
	emake DESTDIR="${D}" install
	dobinlinks ${DP}/bin/*
}
