# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5

DESCRIPTION="Radian NVRAM Firmware"
HOMEPAGE="https://www.netapp.com"

inherit solidfire

# Individual versions of all payloads in this package
RADIAN_FIRMWARE="ae34b8cc"

SRC_URI="http://bdr-jenkins.eng.solidfire.net/libs/distfiles/${P}.tar.gz"

LICENSE="NetApp"
KEYWORDS="~amd64 amd64"

src_install()
{
    # Add chassis specific payloads into /sf/package/../lib/firmware/
    dofirmware -r ${S}/*
	dopathlinks "/sf/rtfi/firmware/nvram/radian" "${DP}/lib/firmware/."
}

