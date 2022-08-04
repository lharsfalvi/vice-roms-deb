#FROM ubuntu:18.04
#FROM ubuntu:20.04
FROM debian:11

ENV LANG C.UTF-8

RUN	   set -ex \
	&& sed -i '/.*debian.*main/ s/$/ contrib/' /etc/apt/sources.list \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	   TZ=GMT \
	   apt-get install -y --no-install-recommends \
		build-essential \
		devscripts \
		lintian \
		cdbs \
		equivs \
		fakeroot \
		sudo \
		subversion \
	&& apt-get clean \
	&& rm -rf /tmp/* /var/tmp/* \
	&& mkdir -p /build

COPY dockerentry.sh /

ENTRYPOINT ["/dockerentry.sh"]
