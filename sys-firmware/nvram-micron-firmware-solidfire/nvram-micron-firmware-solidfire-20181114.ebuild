# Copyright 2018 NetApp, Inc.  All rights reserved.

EAPI=5

DESCRIPTION="MICRON NVRAM FIRMWARE"
HOMEPAGE="https://www.netapp.com"

inherit solidfire

# Individual versions of all payloads in this package
SMART_FIRMWARE="0x26_0x2C"

SRC_URI="http://bdr-jenkins.eng.solidfire.net/distfiles/${P}.tar.gz"

LICENSE="NetApp"
KEYWORDS="~amd64 amd64"

src_install()
{
	# Add chassis specific payloads into /sf/package/../lib/firmware/
	dofirmware -r ${S}/*
	dopathlinks "/sf/rtfi/firmware/nvram/micron" "${DP}/lib/firmware/."
}

