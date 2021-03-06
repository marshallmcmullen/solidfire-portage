# Copyright 2017-2018 NetApp, Inc. All rights reserved.

EAPI=5
inherit solidfire

DESCRIPTION="Convert XML to JSON."
HOMEPAGE="http://solidfire.com"
SRC_URI=

LICENSE="public-domain"
KEYWORDS="amd64 ~amd64"
RDEPEND="dev-perl/JSON-Any
	dev-perl/XML-Simple"

src_unpack()
{
	mkdir -p ${S}
}

src_install()
{
	dobin ${FILESDIR}/xml2json
	dobinlinks "${DP}/bin/xml2json"
}
