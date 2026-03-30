#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -euo pipefail

################################################
dnf makecache
dnf install -y dnf-plugins-core
dnf config-manager --set-enabled crb
dnf makecache
dnf install -y epel-release
dnf makecache
/usr/bin/crb enable
dnf upgrade -y epel-release
dnf makecache
dnf upgrade -y

yum install -y openssl-libs
yum install -y openssl
yum install -y openssl-devel
yum install -y lksctp-tools-devel lksctp-tools

yum install -y gcc cpp gcc-c++ libstdc++-devel make m4 libtool pkgconfig groff-base \
  glibc-devel glib2-devel systemd-devel libuuid-devel ncurses-devel ncurses \
  elfutils-libelf-devel elfutils-devel elfutils kmod libselinux-devel libcom_err-devel \
  libverto-devel keyutils-libs-devel krb5-devel libkadm5 libsepol-devel \
  redhat-rpm-config rpm-build rpmdevtools cpio wget ca-certificates \
  xz xz-devel bzip2 bzip2-devel gzip zlib-devel tar unzip zip \
  binutils util-linux findutils diffutils shadow-utils passwd \
  socat ethtool iptables ebtables ipvsadm ipset psmisc \
  bash-completion conntrack-tools iproute nfs-utils net-tools \
  authconfig libpwquality pam-devel pam audit which file sed gawk grep less \
  patch crontabs cronie info man-db lsof lshw dmidecode pciutils-libs pciutils \
  yum-utils createrepo_c

yum install -y ninja-build cmake clang llvm

yum install -y perl perl-devel perl-libs perl-Env perl-ExtUtils-Embed perl-IPC-Cmd \
  perl-ExtUtils-Install perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest \
  perl-ExtUtils-ParseXS perl-Git perl-JSON perl-libwww-perl perl-podlators

yum install -y glibc-devel glibc-headers libxml2-devel libxslt-devel gd-devel \
  perl-devel perl bc net-snmp-libs net-snmp-agent-libs net-snmp-devel libnl3-devel libnl3

# from spec
yum install -y asciidoc audit-libs-devel bash bc binutils binutils-devel bison bpftool bzip2 \
  diffutils dwarves elfutils-devel findutils flex gawk gcc gcc-c++ gcc-plugin-devel gettext git git-core \
  glibc-static gzip hmaccalc hostname java-devel kernel-rpm-macros kmod libbabeltrace-devel libbpf-devel \
  libcap-devel libcap-ng-devel libnl3-devel libtraceevent-devel m4 make ncurses-devel net-tools newt-devel \
  nss-tools numactl-devel openssl openssl-devel patch pciutils-devel perl-Carp perl-ExtUtils-Embed perl-devel \
  perl-generators perl-interpreter pesign python3-devel python3-docutils python3-sphinx python3-sphinx_rtd_theme \
  redhat-rpm-config rsync system-sb-certs tar which xmlto xz xz-devel zlib-devel

yum install -y libmnl-devel libmnl
yum install -y libnftnl-devel libnftnl
yum install -y libnfnetlink-devel libnfnetlink
yum install -y file-devel file
yum install -y nftables-devel nftables
yum install -y iptables-devel iptables
yum install -y ipset-devel ipset
yum install -y rsyslog logrotate
yum install -y chrpath
yum install -y patch
yum install -y patchelf
yum install -y glibc-all-langpacks

# For building kernel
yum install -y libpfm-devel libpfm
yum install -y libtraceevent-devel libtraceevent
yum install -y libbpf-devel libbabeltrace-devel

# to build nginx
yum install -y glibc-devel libxml2-devel libxslt-devel perl-devel perl gd-devel bc

# aws-lc
dnf install -y cmake ninja-build clang perl
yum install -y dracut ; yum update -y dracut
/sbin/ldconfig >/dev/null 2>&1
################################################

cd /usr/local
wget -q -c -t 9 -T 9 https://github.com/icebluey/ziprust/releases/download/v1.94.1/rust-v1.94.1-stable-x86_64-el9.tar.xz
tar -xof rust*.tar*
sleep 1
rm -f rust*.tar*
. /usr/local/rust/env
cargo --version && rustc --version

#_tmp_dir="$(mktemp -d)"
#cd "${_tmp_dir}"

rm -fr /src
mkdir /src
cd /src

#wget -q -c -t 9 -T 9 https://github.com/openai/codex/archive/refs/tags/rust-v0.114.0.tar.gz
#tar -xof rust-*.tar*
#sleep 1
#rm -f rust-*.tar*
#cd codex*

git clone https://github.com/openai/codex.git
cd codex
_codex_ver="$(git tag | grep -iEv 'alpha|beta|rc|v0\.0|v\.0\.0' | sort -V | tail -n 1)"
echo "codex version: ${_codex_ver}"
git checkout ${_codex_ver}

sed 's/pub const DEFAULT_ORIGINATOR: \&str = "codex_cli_rs"/pub const DEFAULT_ORIGINATOR: \&str = "Codex Desktop"/g' -i codex-rs/login/src/auth/default_client.rs
cat codex-rs/login/src/auth/default_client.rs | grep -i 'pub const DEFAULT_ORIGINATOR: &str ='
cd codex-rs
#cargo check
CARGO_PROFILE_RELEASE_DEBUG=0 \
CARGO_PROFILE_RELEASE_STRIP=symbols \
RUSTFLAGS="--remap-path-prefix=$(pwd)=/src --remap-path-prefix=src/=src/" \
cargo build --release -p codex-cli --bin codex
ls -la
ls -lah target/release
ls -lah target/release/build
rm -fr /tmp/codex
/bin/cp -vf target/release/codex /tmp/
sleep 1
chmod 0755 /tmp/codex
#file /tmp/codex | sed -n -E 's/^(.*):[[:space:]]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
file /tmp/codex
echo ' done'
cd /tmp
#rm -fr "${_tmp_dir}"
rm -fr /src
exit
