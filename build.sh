#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -euo pipefail

cd /usr/local
wget -q -c -t 9 -T 9 'https://github.com/icebluey/ziprust/releases/download/v1.94.0/rust-v1.94.0-stable-x86_64-ub2204.tar.xz'
tar -xof rust-v1.94.0-stable-x86_64-ub2204.tar.xz
sleep 1
rm -f rust*.tar*
. /usr/local/rust/env
cargo --version && rustc --version

_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"

wget -q -c -t 9 -T 9 https://github.com/openai/codex/archive/refs/tags/rust-v0.114.0.tar.gz
tar -xof rust-*.tar*
sleep 1
rm -f rust-*.tar*
cd codex*
sed 's/pub const DEFAULT_ORIGINATOR: \&str = "codex_cli_rs"/pub const DEFAULT_ORIGINATOR: \&str = "Codex Desktop"/g' -i codex-rs/core/src/default_client.rs
cat codex-rs/core/src/default_client.rs | grep -i 'pub const DEFAULT_ORIGINATOR: &str ='
cd codex-rs
cargo check
cargo build --release -p codex-cli --bin codex
ls -la
echo ' done'
exit


cd /tmp
rm -fr "${_tmp_dir}"
