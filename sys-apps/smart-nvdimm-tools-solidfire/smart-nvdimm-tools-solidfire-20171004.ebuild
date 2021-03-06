# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5
inherit solidfire

DESCRIPTION="SMART NVDIMM Diagnostic Tools"
HOMEPAGE="http://www.smartm.com"
SRC_URI="http://bitbucket.org/solidfire/${UPSTREAM_PN}/get/release/${PV}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="SMART-NDA"
KEYWORDS="~amd64 amd64"

src_compile()
{
    emake -j1
}

src_install()
{
    dobin "smart-nvdimm"
	dobinlinks "${DP}"/bin/*
}
