# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5
inherit solidfire

DESCRIPTION="Broadcom NIC Firmware"
HOMEPAGE="https://www.netapp.com"
SRC_URI="http://bdr-jenkins.eng.solidfire.net/libs/distfiles/${P}.tar.gz -> ${P}.tar.gz"

LICENSE="Dell-EMC-Software-License-and-Support-Services-Agreement"
KEYWORDS="~amd64 amd64"

S="${WORKDIR}"
src_install()
{
	# Add chassis specific payloads into /sf/package/../lib/firmware/
	dofirmware -r ${S}/${MY_P}/*
	chmod +x ${DP}/lib/firmware/lnxfwnx2
}
