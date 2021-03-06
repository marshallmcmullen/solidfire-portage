# Copyright 2017-2018 NetApp, Inc. All rights reserved.

EAPI=5

inherit solidfire

DESCRIPTION="NetApp SolidFire Storage I/O Control"
HOMEPAGE="https://www.solidfire.com"
MY_PV="${PV%.*}"
BUILD="${PV##*.}"
SRC_URI="https://bitbucket.org/solidfire/vcenter-plugin/get/v${PV}.tar.bz2 -> solidfire-vcenter-plugin-${PV}.tar.bz2"

LICENSE="NetApp"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=">=virtual/jdk-1.7
    dev-java/java-config
    dev-java/maven-bin:*"
RDEPEND=">=virtual/jre-1.7
    www-servers/jetty-bin"

src_prepare()
{
    set -e

    # Paths in Ember are different than in Ubuntu
    einfo "Fixing sioc path in vcp-reg.bash"
    sed -i 's|/opt/solidfire|/sf/packages/sioc|g' SolidFire-Debian/src/main/resources/vcp-reg.bash 
}

src_compile()
{
    set -e
    mvn clean install
}

src_install()
{
    set -e
    mkdir -p ${DP} ${DP}/systemd

    einfo "Installing SIOC files"
    cp --verbose keystore.jks ${DP}
    cp --verbose SolidFire-SIOC/target/solidfire-sioc-${PV}-boot.jar ${DP}/solidfire-sioc-boot.jar
    cp --verbose ${FILESDIR}/sioc.service ${DP}/systemd

    einfo "Install new VCP Registration files"
    mkdir -p ${DP}/jetty/{etc,root,webapps}
    cp --verbose SolidFire-Debian/src/main/resources/vcp-reg.bash ${DP}
    cp --verbose SolidFire-Debian/src/main/resources/{index.html,index.css,NetApp_logo*.png,favicon.ico} ${DP}/jetty/root
    cp --verbose SolidFire-Plugin/target/solidfire-plugin-${MY_PV}-bin.zip ${DP}/jetty/root
    chmod -R 644 ${DP}/jetty/root/*
    chmod 755 ${DP}/jetty/{root,webapps}
    
    cp SolidFire-MNode-War/target/solidfire-mnode-${MY_PV}.war ${DP}/jetty/webapps/solidfire-mnode.war
    chmod 444 ${DP}/jetty/webapps/solidfire-mnode.war
    
    cp SolidFire-Registration/target/solidfire-registration-${MY_PV}-jar-with-dependencies.jar ${DP}/solidfire-registration-jar-with-dependencies.jar
    chmod 555 ${DP}/solidfire-registration-jar-with-dependencies.jar

    # Copy customized Jetty files
    cp --verbose SolidFire-Debian/src/main/resources/{jetty-ssl.xml,keystore,start.ini} ${DP}/jetty/etc
    chown -R jetty:jetty ${DP}/jetty
    
    # Setup eselect path links
    dopathlinks /opt/jetty/etc          ${DP}/jetty/etc/*
    dopathlinks /opt/jetty/webapps      ${DP}/jetty/webapps/*
    dopathlinks /opt/jetty/webapps/root ${DP}/jetty/root/*
}

pkg_preinst()
{
    set -e
    
    local backup="/opt/jetty/sfbackup"
    if [[ ! -d "${backup}" ]]; then
        mkdir -p "${backup}"
    
        einfo "Backing up original non-sf jetty files"
        cp --verbose /opt/jetty/etc/jetty-ssl.xml /opt/jetty/start.ini "${backup}"
        
        if [[ -e "/opt/jetty/etc/keystore" ]]; then
            cp --verbose /opt/jetty/etc/keystore "${backup}"
        fi

        einfo "Removing non-sf jetty files"
        rm --force /opt/jetty/etc/{jetty-ssl.xml,keystore,start.ini}
    fi
}
