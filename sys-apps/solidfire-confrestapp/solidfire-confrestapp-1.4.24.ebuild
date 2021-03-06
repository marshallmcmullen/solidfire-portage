# Copyright 2017 NetApp, Inc.  All rights reserved.

EAPI=5

inherit solidfire

DESCRIPTION="NetApp/SolidFire day zero configuration"
HOMEPAGE="solidfire.com"
MY_PF="${PF#solidfire-}"
SRC_URI="http://sf-artifactory.eng.solidfire.net/sfprime/nde/${MY_PF}.tar -> ${P}.tar"

LICENSE="SolidFire"
KEYWORDS="amd64"
RESTRICT="strip"
RDEPEND="dev-lang/python:3.5"

src_install()
{
	mkdir -p "${DP}"
	cp --preserve=mode --recursive "${S}/." "${DP}" || die
 	if [[ ! -x "${DP}/confrestapp" ]]; then
		die "${DP}/confrestapp must be executable"
 	fi
	
	# Prune directory that we do not want as it's upstart related
	rm -rf "${DP}/install/etc/init"

	# Create eselect symlinks file from template provided in-tree. This overrides the one that is already checked into the source
	# tree due to bugs in the versioning path in the generated eselect file.
	einfo "Generating eselect symlinks file from provided template"
	sed "s|%VERSION%|${PV}|g" "${DP}/install/eselect/symlinks-confrestapp" > "${DP}/eselect/symlinks"
	cat "${DP}/eselect/symlinks"

	einfo "Creating sf-nde service"
	mkdir "${DP}/systemd"
	cat <<- EOF > "${DP}/systemd/sf-nde.service"
	[Unit]
	Description=NetApp Deployment Engine configuration REST service
	Wants=network.target
	After=network.target

	[Service]
	Type=simple
	User=root
	WorkingDirectory=/sf
	ExecStart=/sf/hci/sfprime/confrestapp/confrestapp
	Restart=always

	[Install]
	WantedBy=multi-user.target
	EOF

	# Remove cruft
	rm -rf "${D}/.keepdir" "${D}/etc/init"
}
