#!/usr/bin/env bash
# Run as root from the staged directory containing the config and deploy.pub.
set -euo pipefail
umask 077
[[ $EUID == 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }
stage=$(cd -- "$(dirname -- "$0")" && pwd)
test -s "$stage/aeronote.net.conf"
test -s "$stage/deploy.pub"
ssh-keygen -lf "$stage/deploy.pub" >/dev/null
nginx -t

backup="/var/backups/aeronote-$(date -u +%Y%m%dT%H%M%SZ)"
install -d -m 700 "$backup"
cp -a /etc/nginx "$backup/nginx"
printf 'Nginx backup: %s/nginx\n' "$backup"

if ! id aeronote-deploy >/dev/null 2>&1; then
    useradd --system --user-group --home-dir /srv/aeronote --shell /bin/bash aeronote-deploy
fi
test "$(getent passwd aeronote-deploy | cut -d: -f6)" = /srv/aeronote
install -d -o aeronote-deploy -g aeronote-deploy -m 755 /srv/aeronote /srv/aeronote/releases /srv/aeronote/shared
install -d -o aeronote-deploy -g aeronote-deploy -m 700 /srv/aeronote/.ssh
# Refuse to replace any pre-existing deployment authorization.
test ! -e /srv/aeronote/.ssh/authorized_keys
{ printf 'restrict '; cat "$stage/deploy.pub"; } > /srv/aeronote/.ssh/authorized_keys
chown aeronote-deploy:aeronote-deploy /srv/aeronote/.ssh/authorized_keys
chmod 600 /srv/aeronote/.ssh/authorized_keys

# acme.sh runs as ubuntu; only its dedicated certificate directory is writable.
install -d -o ubuntu -g ubuntu -m 700 /etc/nginx/ssl/aeronote.net
test ! -e /etc/sudoers.d/aeronote-renewal
printf '%s\n' 'ubuntu ALL=(root) NOPASSWD: /usr/sbin/nginx -t, /usr/bin/systemctl reload nginx' > "$backup/aeronote-renewal"
visudo -cf "$backup/aeronote-renewal"
install -o root -g root -m 440 "$backup/aeronote-renewal" /etc/sudoers.d/aeronote-renewal
runuser -u ubuntu -- /home/ubuntu/.acme.sh/acme.sh --install-cert -d aeronote.net --ecc \
    --key-file /etc/nginx/ssl/aeronote.net/privkey.pem \
    --fullchain-file /etc/nginx/ssl/aeronote.net/fullchain.pem \
    --reloadcmd 'sudo -n /usr/sbin/nginx -t && sudo -n /usr/bin/systemctl reload nginx'
chmod 600 /etc/nginx/ssl/aeronote.net/privkey.pem

conf=/etc/nginx/conf.d/aeronote.net.conf
install -o root -g root -m 644 "$stage/aeronote.net.conf" "$conf"
if ! nginx -t; then
    if test -f "$backup/nginx/conf.d/aeronote.net.conf"; then
        cp -a "$backup/nginx/conf.d/aeronote.net.conf" "$conf"
    else
        rm -- "$conf"
    fi
    echo "Nginx config validation failed; previous config restored. Backup: $backup" >&2
    exit 1
fi
systemctl reload nginx
# Reload is asynchronous: allow old workers to finish handing over listeners.
curl --fail --silent --show-error --retry 5 --retry-all-errors --retry-delay 1 \
    --connect-timeout 5 --max-time 10 \
    --resolve aeronote.net:443:127.0.0.1 https://aeronote.net/healthz
printf '\nProvisioning complete. Website content will be deployed by GitHub Actions.\nBackup: %s\n' "$backup"
