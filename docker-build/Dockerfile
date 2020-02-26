FROM	debian:buster

RUN set -eux; \
	apt-get -q update; \
	DEBIAN_FRONTEND=noninteractive apt-get -fyqq install sysvinit-core wget ca-certificates psmisc procps build-essential; \
	DEBIAN_FRONTEND=noninteractive apt-get -fy remove --purge --auto-remove systemd; \
	DEBIAN_FRONTEND=noninteractive apt-get -fyqq -u dist-upgrade; \
	rm /etc/cron.daily/apt-compat;

RUN set -eux; \
	DEBIAN_FRONTEND=noninteractive apt-get -fyqq install \
		htop \
		lsof \
		strace \
		tcpdump \
		net-tools; \
	{ \
		echo "id:2:initdefault:\\nsi::sysinit:/etc/init.d/rcS\\n~:S:wait:/sbin/sulogin"; \
		echo "l0:0:wait:/etc/init.d/rc 0\\nl1:1:wait:/etc/init.d/rc 1\\nl2:2:wait:/etc/init.d/rc 2"; \
		echo "l3:3:wait:/etc/init.d/rc 3\\nl4:4:wait:/etc/init.d/rc 4\\nl5:5:wait:/etc/init.d/rc 5"; \
		echo "l6:6:wait:/etc/init.d/rc 6\\nz6:6:respawn:/sbin/sulogin"; \
	} >/etc/inittab;

CMD	["/sbin/init", "2"]
