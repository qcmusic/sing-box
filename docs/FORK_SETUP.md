# Fork 后维护指南

## 1. 仓库归属

当前这份 fork 已经把两个脚本里的 `PROJECT_REPO` 默认值改为 `qcmusic/sing-box`：

- `sing-box.sh`
- `docker_init.sh`

当前值是：

```bash
PROJECT_REPO="${PROJECT_REPO:-qcmusic/sing-box}"
```

以后如果迁移到另一个账号或仓库，再把它改成新的 `owner/repo`，例如：

```bash
PROJECT_REPO="${PROJECT_REPO:-new-owner/sing-box}"
```

这样安装后的 `sb` 快捷命令、`force_version` 版本锁定和 Docker 初始化逻辑都会从你的 fork 读取。

## 2. README 安装命令

当前 README 的一键安装命令已经指向这个 fork：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/qcmusic/sing-box/main/sing-box.sh)
```

如果以后迁移仓库，把命令里的 `qcmusic/sing-box` 替换成新的 `owner/repo`。

快速安装是：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/qcmusic/sing-box/main/sing-box.sh) -l
```
英文快速安装是：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/qcmusic/sing-box/main/sing-box.sh) -k
```

## 3. 本地检查

每次改脚本后先跑：

```bash
bash -n sing-box.sh
bash -n docker_init.sh
```

这只能检查 Bash 语法，不能保证 VPS 安装一定成功。涉及防火墙、systemd、Nginx、Argo、Reality、Hysteria2 的改动都要在测试 VPS 上实测。

## 4. 测试 VPS 建议

建议先用干净的 Debian 或 Ubuntu VPS 测：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/qcmusic/sing-box/main/sing-box.sh) --LANGUAGE c --CHOOSE_PROTOCOLS bcdf --START_PORT 8881 --SUBSCRIBE false --ARGO false
```

确认能启动后再测试：

```bash
sb -n
sb -d
sb -r
sb -u
```

## 5. 低风险改造顺序

1. 先改项目归属和 README。
2. 再改默认端口、默认 CDN、默认协议集合。
3. 再删减你不想维护的协议。
4. 最后再动订阅输出和 Docker 镜像。

不要一开始就重构 `sing-box_json` 或 `export_list`。这两个函数牵连的客户端格式最多，最好先通过小改建立测试闭环。
