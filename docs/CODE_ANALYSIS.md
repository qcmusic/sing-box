# sing-box.sh 项目解析

这份仓库的核心是一个 Bash 编排器：它不自己实现代理协议，而是下载 sing-box、cloudflared、jq、qrencode 等二进制工具，再生成服务端和客户端配置。

## 一键命令如何工作

```bash
bash <(wget -qO- https://raw.githubusercontent.com/qcmusic/sing-box/main/sing-box.sh) -l
```

- `wget -qO- URL`：静默下载远程脚本，并输出到标准输出。
- `<(...)`：Bash 进程替换，把下载结果变成一个临时文件路径。
- `bash <(...) -l`：用 Bash 执行该临时脚本，并把 `-l` 传给脚本。
- `-l`：中文极速安装模式，脚本会自动补齐协议、端口、订阅、Argo 等默认值。

## 主入口流程

脚本底部是实际入口：

1. 解析 `-c/-e/-l/-k/-f` 和 `--KEY VALUE` 参数。
2. `check_root` 要求 root 运行。
3. `select_language` 选择语言。
4. `check_system_info` 检查系统、包管理器、架构。
5. `check_dependencies` 安装基础依赖。
6. `check_system_ip` 探测公网 IPv4/IPv6。
7. `check_install` 判断 sing-box、Argo、Nginx 是否已安装和运行。
8. 根据参数进入无交互安装、极速安装或菜单模式。

## 关键函数分工

| 函数 | 作用 |
| --- | --- |
| `check_cdn` | 判断 GitHub 是否需要反代代理。 |
| `get_sing_box_version` | 获取 sing-box 版本，优先读取本仓库 `force_version`。 |
| `sing-box_variables` | 收集协议、端口、UUID、节点名、Argo/CDN 等安装变量。 |
| `check_dependencies` | 按系统安装 `wget`、`tar`、`iproute2`、`openssl` 等依赖。 |
| `sing-box_json` | 生成 `/etc/sing-box/conf/*.json` 服务端配置。 |
| `ssl_certificate` | 生成自签 TLS 证书。 |
| `export_nginx_conf_file` | 生成订阅和 WebSocket 回源用的 Nginx 配置。 |
| `sing-box_systemd` | 生成 sing-box 的 systemd/OpenRC 服务。 |
| `argo_systemd` | 生成 cloudflared/Argo Tunnel 服务。 |
| `sync_firewall_rules` | 管理普通端口放行规则。 |
| `add_port_hopping_nat` | 为 Hysteria2 端口跳跃添加 NAT 转发规则。 |
| `install_sing-box` | 安装主流程。 |
| `export_list` | 输出节点链接、订阅地址和客户端配置。 |
| `change_config` | 安装后修改 CDN、端口、UUID、节点名、Reality SNI 等。 |
| `change_protocols` | 安装后增加或删除协议。 |
| `uninstall` | 停服务、删配置、清理防火墙规则和快捷命令。 |

## 支持的协议

协议列表定义在 `PROTOCOL_LIST` 和 `NODE_TAG`：

| 选择项 | 协议 |
| --- | --- |
| `b` | XTLS + reality |
| `c` | hysteria2 |
| `d` | tuic |
| `e` | ShadowTLS |
| `f` | shadowsocks |
| `g` | trojan |
| `h` | vmess + ws |
| `i` | vless + ws + tls |
| `j` | H2 + reality |
| `k` | gRPC + reality |
| `l` | AnyTLS |
| `m` | naive |
| `a` | 全部协议 |

端口按选择顺序从 `START_PORT` 连续分配，默认从 `8881` 开始。

## 安装后的目录

默认目录是 `/etc/sing-box`：

```text
/etc/sing-box/
|-- sing-box              # sing-box 主程序
|-- cloudflared           # Cloudflare Tunnel 主程序
|-- conf/                 # 服务端 JSON 配置
|-- cert/                 # 自签证书
|-- subscribe/            # 客户端订阅文件
|-- nginx.conf            # 订阅服务和 ws 回源配置
|-- list                  # 节点信息
|-- jq                    # JSON 处理工具
|-- qrencode              # 二维码工具
`-- sb.sh                 # /usr/bin/sb 指向的快捷脚本
```

## 适合 fork 后优先改的地方

本分支已经新增了这些变量：

```bash
PROJECT_REPO="${PROJECT_REPO:-qcmusic/sing-box}"
PROJECT_BRANCH="${PROJECT_BRANCH:-main}"
PROJECT_RAW_URL="${PROJECT_RAW_URL:-https://raw.githubusercontent.com/${PROJECT_REPO}/refs/heads/${PROJECT_BRANCH}}"
SELF_SCRIPT_URL="${SELF_SCRIPT_URL:-${PROJECT_RAW_URL}/sing-box.sh}"
FORCE_VERSION_URL="${FORCE_VERSION_URL:-${PROJECT_RAW_URL}/force_version}"
```

这份 fork 已经把 `PROJECT_REPO` 指向：

```bash
PROJECT_REPO="${PROJECT_REPO:-qcmusic/sing-box}"
```

这样：

- `sb` 快捷命令会继续下载你的 fork 里的 `sing-box.sh`。
- `force_version` 会从你的 fork 读取，方便你临时锁定 sing-box 内核版本。
- 后续维护不用到处搜索替换原作者仓库地址。

## 修改建议

低风险维护路线：

1. 先只改 `PROJECT_REPO`、README 安装命令和项目说明。
2. 再按你的目标删减协议，例如只保留 Reality、Hysteria2、TUIC。
3. 最后再改菜单文案、默认端口、默认 CDN、Docker 镜像名。

高风险区域：

- `sing-box_json`：配置生成逻辑很长，改错会导致服务启动失败。
- `export_list`：客户端订阅格式多，容易出现某个客户端不可用。
- `sync_firewall_rules` 和端口跳跃：会改系统防火墙，必须在测试 VPS 上验证。
- `change_protocols`：涉及保留旧配置、删除文件、重算端口，回归测试要更仔细。
