FROM scratch
ADD ubuntu-xenial-core-cloudimg-amd64-root.tar.gz /

# a few minor docker-specific tweaks
# see https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap
RUN set -xe \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L40-L48
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L54-L56
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L71-L78
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L85-L105
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L109-L115
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L118-L130
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L134-L151
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
# this forces "apt-get update" in dependent images, which is also good
# (see also https://bugs.launchpad.net/cloud-images/+bug/1699913)

# make systemd-detect-virt return "docker"
# See: https://github.com/systemd/systemd/blob/aa0c34279ee40bce2f9681b496922dedbadfca19/src/basic/virt.c#L434
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

RUN apt-get update
RUN apt-get -y install xbase-clients
RUN apt-get -y install wget libxpm4 libxext6 libxt6 libxmu6 libx11-dev x11proto-print-dev libxext-dev libxau-dev \
    python python-numpy python-scipy python-gtk2 python-matplotlib python-tornado python-dateutil python-pyparsing \
    python-nose python-flask python-yaml python-h5py
RUN wget http://ftp.dk.debian.org/debian/pool/main/libx/libxp/libxp6_1.0.2-2_amd64.deb
RUN dpkg -i libxp6_1.0.2-2_amd64.deb
RUN wget http://ftp.dk.debian.org/debian/pool/main/libx/libxp/libxp-dev_1.0.2-2_amd64.deb
RUN dpkg -i libxp-dev_1.0.2-2_amd64.deb
RUN wget http://packages.mccode.org/debian/dists/stable/main/binary-amd64/ifit-2.0.2-amd64.deb
RUN wget http://packages.mccode.org/debian/dists/stable/main/binary-amd64/mcrinstaller-7.13-2010a-amd64.deb
RUN wget http://packages.mccode.org/debian/dists/oldstable/python-ase_3.14.0_all.deb
RUN wget http://packages.mccode.org/debian/dists/stable/main/binary-amd64/python-phonopy_1.11.10_all.deb
RUN dpkg -i mcrinstaller-7.13-2010a-amd64.deb
RUN dpkg -i ifit-2.0.2-amd64.deb
RUN dpkg -i python-ase_3.14.0_all.deb
RUN dpkg -i python-phonopy_1.11.10_all.deb
RUN rm *.deb

RUN groupadd --gid 1000 docker \
    && useradd --uid 1000 --gid docker --shell /bin/bash --create-home docker

CMD ["/bin/bash"]

