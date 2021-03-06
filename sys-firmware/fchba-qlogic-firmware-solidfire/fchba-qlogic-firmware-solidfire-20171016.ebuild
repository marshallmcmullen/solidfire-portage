# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5

DESCRIPTION="QLogic FC HBA Firmware"
HOMEPAGE="https://www.netapp.com"

inherit solidfire

# Individual versions of all payloads in this package
QLOGIC_FIRMWARES="bk011018 hld33424"

SRC_URI="http://bdr-jenkins.eng.solidfire.net/libs/distfiles/${P}.tar.gz"

LICENSE="QLogic-SLA"
KEYWORDS="~amd64 amd64"

src_install()
{
	# Add chassis specific payloads into /sf/package/../lib/firmware/
	dofirmware -r ${S}/*
	dopathlinks "/sf/rtfi/firmware/fchba/qlogic" "${DP}/lib/firmware/."
}

