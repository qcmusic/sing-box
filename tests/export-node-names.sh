#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
eval "$(sed -n '/^set_export_node_names() {/,/^}/p; /^move_hysteria_first() {/,/^}/p' "$SCRIPT_DIR/sing-box.sh")"

NODE_TAG=(xtls-reality hysteria2 tuic ShadowTLS shadowsocks trojan vmess-ws vless-ws-tls h2-reality grpc-reality anytls naive)
for index in {11..22}; do NODE_NAME[index]=sg新加坡超高速; done
PORT_XTLS_REALITY=8881
PORT_HYSTERIA2=8882
PORT_TUIC=8883
PORT_SHADOWTLS=8884
PORT_SHADOWSOCKS=8885
PORT_TROJAN=8886
PORT_VMESS_WS=8887
PORT_VLESS_WS=8888
PORT_H2_REALITY=8889
PORT_GRPC_REALITY=8890
PORT_ANYTLS=8891
PORT_NAIVE=8892

assert_name() {
  local index=$1 expected=$2
  [[ "${EXPORT_NAME[index]}" == "$expected" ]] || {
    printf 'node %s: expected %s, got %s\n' "$index" "$expected" "${EXPORT_NAME[index]}" >&2
    exit 1
  }
}

set_export_node_names v2rayn
assert_name 12 'sg新加坡超高速1|BGP|流媒体'
assert_name 11 'sg新加坡超高速2|BGP|流媒体'
assert_name 15 'sg新加坡超高速4|BGP|流媒体'
assert_name 20 'sg新加坡超高速8|BGP|流媒体'
assert_name 21 'sg新加坡超高速9|BGP|流媒体'
assert_name 22 'sg新加坡超高速10|BGP|流媒体'
assert_name 23 'sg新加坡超高速11|BGP|流媒体'
[[ -z ${EXPORT_NAME[14]:-} && -z ${EXPORT_NAME[19]:-} ]]

PORT_TUIC=''
PORT_SHADOWTLS=''
PORT_H2_REALITY=''
PORT_NAIVE=''
set_export_node_names clash
assert_name 12 'sg新加坡超高速1|BGP|流媒体'
assert_name 15 'sg新加坡超高速3|BGP|流媒体'
assert_name 21 'sg新加坡超高速8|BGP|流媒体'

NODE_NAME[11]='Custom server'
set_export_node_names v2rayn
assert_name 11 'Custom server xtls-reality'
assert_name 15 'sg新加坡超高速3|BGP|流媒体'

ordered=$(move_hysteria_first $'vless://first\nhysteria2://second\ntuic://third')
[[ "$ordered" == $'hysteria2://second\nvless://first\ntuic://third' ]]
printf 'export node name tests passed\n'
