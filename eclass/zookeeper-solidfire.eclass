

# $Id$

if [[ -z ${_ZOOKEEPER_ECLASS} ]]; then
_ZOOKEEPER_ECLASS=1

inherit toolchain-funcs java-pkg-2 solidfire
EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install src_test pkg_preinst

zookeeper-solidfire_src_prepare()
{
	# Prepare JAVA
	java-utils-2_src_prepare

	# Set ivy path to not be /root/.ivy or else we get a sandbox violation
	sed -i -e 's|<property name="ivy.home" value="${user.home}/.ant"|<property name="ivy.home" value="'${WORKDIR}'/ant"|g' \
		build.xml

	# Prepare Jute
	ant compile_jute || die

	# Prepare C code
	if tc-is-gcc && [[ ( $(gcc-major-version) -gt 7 ) || $(gcc-major-version) -eq 7 && $(gcc-minor-version) -ge 3 ]]; then
		# GCC 7.3.0 fails with the following:
		# src/zookeeper.c:2253:5: error: null argument where non-null required (argument 1) [-Werror=nonnull]
		append-cppflags "-Wno-error=nonnull"
		append-cflags "-Wno-error=nonnull"
	fi

	# Compile failure with glibc 2.26 due to movement of INT32_MAX symbol into a new header file. This change is safe
	# on older glibc versions as well and will not alter the validity of what we build.
	sed -i -e 's|#include <stdlib.h>|&\n#include <stdint.h>|' src/c/src/mt_adaptor.c || die

	pushd src/c
	eautoreconf
	popd

	# Update log4j properties file
	props="${S}/conf/log4j.properties"
	sed -i -e "s|zookeeper.root.logger=INFO, CONSOLE|zookeeper.root.logger=INFO, CONSOLE, SYSLOGD|" ${props} || die

	# Add log4j SYSLOGD output
	{
		echo ""
		echo "#"
		echo "# Log INFO level and above messages to SYSLOG"
		echo "#"
		echo "log4j.appender.SYSLOGD=org.apache.log4j.net.SyslogAppender"
		echo "log4j.appender.SYSLOGD.Threshold=INFO"
		echo "log4j.appender.SYSLOGD.SyslogHost=localhost"
		echo "log4j.appender.SYSLOGD.Facility=LOCAL0"
		echo "log4j.appender.SYSLOGD.layout=org.apache.log4j.PatternLayout"
		echo "log4j.appender.SYSLOGD.layout.ConversionPattern=%X{hostname}zookeeper - %-5p [%t:%C{1}@%L] - %m%n"

	} >> ${props}
	
	# SolidFire versioning
	solidfire_src_prepare
}

#----------------------------------------------------------------------------------------------------------------------
# CONFIGURE
#----------------------------------------------------------------------------------------------------------------------

zookeeper-solidfire_src_configure()
{
	einfo "Configure C: make"
	pushd src/c
	econf
	popd
}

#----------------------------------------------------------------------------------------------------------------------
# COMPILE
#----------------------------------------------------------------------------------------------------------------------

zookeeper-solidfire_src_compile()
{
	# Java
	{
		einfo "Compiling Java: compile"
		ant compile || die
		
		einfo "Compiling Java: jar"
		ant jar || die
	}
	
	# C
	{
		einfo "Compiling C: make"
		pushd src/c
		emake
		
		#einfo "Compiling C: make zktest-st zktest-mt"
		#emake zktest-st zktest-mt
		popd
	}
}

#----------------------------------------------------------------------------------------------------------------------
# INSTALL
#----------------------------------------------------------------------------------------------------------------------

zookeeper-solidfire_src_install()
{
	# Java
	{
		einfo "Installing Java"
		doins -r ${S}/conf ${S}/build/{lib,*.jar}
		mv ${DP}/zookeeper-${UPSTREAM_PV}.jar ${DP}/${PF}.jar || die
		
		local bin
		for bin in $(find ${S}/bin/*.sh); do
			newbin ${bin} $(basename ${bin} .sh).sh
		done
	}

	# C
	{
		einfo "Installing C"
		pushd src/c
		emake DESTDIR="${D}" install
		popd

		mv ${DP}/bin/cli_st ${DP}/bin/zkcli_st || die
		mv ${DP}/bin/cli_mt ${DP}/bin/zkcli_mt || die
	}

	# Expose paths
	dobinlinks "${DP}/bin/zkCli.sh"
}

zookeeper-solidfire_pkg_preinst()
{
	solidfire_pkg_preinst
}

#----------------------------------------------------------------------------------------------------------------------
# TEST
#----------------------------------------------------------------------------------------------------------------------

zookeeper-solidfire_src_test()
{
	# Java
	ant test || die

	# C
	{
		pushd src/c
	
		einfo "Testing C: zktest-st"
		./zktest-st || die
		
		einfo "Testing C: zktest-mt"
		./zktest-mt || die
		
		popd
	}
}


fi
