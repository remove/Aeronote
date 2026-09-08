# Aeronote 项目指南

## 项目用途

这个仓库同时承担两类工作：

1. 维护并发布 Aeronote 的 Quartz 5 静态博客。
2. 作为香港 `hk.aerodock.net` VPS 的日常运维工作区，让 Codex 通过 SSH 代用户执行服务器任务。

除非用户另有要求，使用中文沟通。新任务开始时只读取与任务有关的文件，不要无目的遍历整台服务器。

## VPS 连接

- SSH 主机：`hk.aerodock.net`
- SSH 用户：`ubuntu`（管理员操作使用 sudo）
- 登录命令：`ssh -o BatchMode=yes ubuntu@hk.aerodock.net`
- SSH key 已在本机配置好；不要寻找、复制、输出或提交私钥。
- 2026-09-08 核实系统为 Ubuntu 24.04，服务器时区为 `Etc/UTC`；向用户报告时间时注明时区。不要依赖本文中的临时运行状态或版本号，每次操作前应重新检查。

默认先做只读检查，确认目标、依赖、当前状态和回滚路径。用户要求的运维变更可以在任务范围内执行，但要尽量避免停机并验证结果。涉及删除、重装、重启整机、批量升级、SSH/UFW 规则或可能中断代理流量的操作，必须先清楚说明影响和回滚方式。

## 服务器架构

### Nginx

- 主配置：`/etc/nginx/nginx.conf`
- Aeronote 线上配置：`/etc/nginx/conf.d/aeronote.net.conf`
- Aeronote 仓库配置：`ops/nginx/aeronote.net.conf`
- `agri.aerodock.net` 反代配置：`/etc/nginx/conf.d/agri.aerodock.net.conf`
- `aeronote.net` 由 Nginx 直接提供静态文件。
- `agri.aerodock.net` 当前仅将特定路径反代到外部源站，其余路径返回 404；修改前读取线上配置确认当前 upstream 和 location。

修改 Nginx 时：

1. 先保存带时间戳的配置备份，并保留属主和权限。
2. 如果 Aeronote 配置发生变化，同时更新仓库中的版本控制副本。
3. 运行 `nginx -t`，成功后才 reload，不要无必要 restart。
4. 验证相关域名、路径、TLS 和上游响应。

### 3x-ui / Xray

- systemd 服务：`x-ui.service`
- 安装目录：`/usr/local/x-ui/`
- 数据库：`/etc/x-ui/x-ui.db`
- Xray 运行配置：`/usr/local/x-ui/bin/config.json`
- 面板端口当前为 `55555`；Xray 公网入口包含 `61234` 和 `62345`。端口用途可能随面板配置变化，调整 UFW 前必须结合进程监听和 3x-ui 配置重新确认。
- 面板使用 HTTPS 和非根路径。不要把面板路径、用户名、密码、节点链接或客户端信息写入仓库或回复。
- Fail2ban 包含 `sshd` 和 `3x-ipl` jail。

修改 3x-ui 时，先备份数据库并记录服务状态、版本和监听端口；变更后验证面板、Xray 进程、入站端口和日志。除非用户明确要求，不要直接编辑 SQLite 数据库或生成的 Xray 配置。

### Quartz 5 博客

- `v5` 分支是生产源码。
- GitHub Actions 工作流：`.github/workflows/deploy-aeronote.yaml`
- 部署说明：`ops/DEPLOYMENT.md`
- 静态站根目录：`/srv/aeronote/current`
- 发布目录：`/srv/aeronote/releases/`
- 共享上传目录：`/srv/aeronote/shared/`
- 部署用户：`aeronote-deploy`
- `current` 是指向不可变 release 的相对符号链接；正常部署和回滚应保持原子切换。
- 正常发布走 GitHub Actions，不要在 VPS 上临时修改生成后的静态文件。

本地验证命令：

```sh
npm run check
npm test
npx quartz build
```

VPS 源站验证：

```sh
curl --resolve aeronote.net:443:127.0.0.1 https://aeronote.net/healthz
curl --resolve aeronote.net:443:127.0.0.1 -I https://aeronote.net/
```

## TLS 与机密

- Aeronote 证书：`/etc/nginx/ssl/aeronote.net/`
- `agri.aerodock.net` 当前引用 `/home/ubuntu/.acme.sh/aerodock.net_ecc/` 下的证书。
- acme.sh 位于 `/home/ubuntu/.acme.sh/`，由 ubuntu 的 cron 续期。
- Aeronote 证书覆盖 `aeronote.net` 和 `www.aeronote.net`，已通过 `ops/bootstrap-hk.sh` 安装到上述 Nginx 证书目录，续期后自动检查并 reload。`/etc/sudoers.d/aeronote-renewal` 仅允许 ubuntu 免密运行 `/usr/sbin/nginx -t` 和 `/usr/bin/systemctl reload nginx`。
- 可以检查证书主题、签发者和有效期；绝不读取或输出私钥内容。
- 下列内容始终按机密处理：SSH 私钥、`authorized_keys` 内容、证书私钥、3x-ui 数据库内容、Xray 客户端配置、面板凭据和路径、GitHub Secrets、Cloudflare 凭据。

## 运维检查与交付

常规只读检查优先使用：

```sh
systemctl --failed
systemctl status nginx x-ui fail2ban ufw
ss -lntup
ufw status verbose
df -hT
free -h
nginx -t
fail2ban-client status
```

不要把 release 目录当作完整备份。处理升级或重要配置前，应确认是否存在 VPS 提供商快照或异机备份。完成服务器变更后，报告：

- 改了哪些线上文件或服务；
- 备份放在哪里；
- 执行了哪些验证；
- 是否仍需重启、续期、升级或人工确认。
