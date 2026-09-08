# Aeronote deployment

The `v5` branch is the source of truth. A push to this branch triggers
`.github/workflows/deploy-aeronote.yaml`.

## Build and release flow

1. GitHub Actions installs Node.js 24 and runs `npm ci`.
2. Quartz plugins are restored from `quartz.lock.json` with
   `npx quartz plugin install`.
3. `npx quartz build` creates the static site in `public/`.
4. The workflow packages `public/` as a checksum-protected tar archive and
   retains it as a GitHub Actions artifact for 30 days.
5. The archive is uploaded with a dedicated, unprivileged SSH key.
6. `ops/activate-release.sh` verifies the checksum, extracts a new immutable
   release, validates `index.html`, and atomically switches the `current`
   symlink.
7. `ops/verify-origin.sh` verifies the live Nginx health endpoint and homepage
   over HTTPS from the VPS itself.

The deployment workflow never runs `npx quartz create`. The wizard-generated
`quartz.config.yaml` and `quartz.lock.json` are committed inputs to the build.

The origin check pins `aeronote.net` to `127.0.0.1`, so it validates Nginx, TLS,
and the activated release without passing through Cloudflare. Public requests
from GitHub-hosted runners are not used as a deployment gate because
Cloudflare may reject those runner addresses even while the origin and public
site are healthy.

## GitHub environment and secrets

The workflow uses the `production` environment and these repository secrets:

| Secret               | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `DEPLOY_HOST`        | SSH hostname (`hk.aerodock.net`)                 |
| `DEPLOY_USER`        | Unprivileged deployment user (`aeronote-deploy`) |
| `DEPLOY_SSH_KEY`     | Dedicated Ed25519 private key                    |
| `DEPLOY_KNOWN_HOSTS` | Pinned SSH host key for `hk.aerodock.net`        |

Never commit private keys, Cloudflare API tokens, or `authorized_keys`.

Administrative SSH uses `ubuntu@hk.aerodock.net`; Actions uses the separate
`aeronote-deploy` account with no sudo privileges. Pin the host key against
the host identity verified by the administrative SSH connection before
updating `DEPLOY_KNOWN_HOSTS`. Update all four deployment secrets together
after provisioning the new host, then dispatch the workflow on `v5`.

The initial Hong Kong provisioning script is `ops/bootstrap-hk.sh`. Stage it
beside `ops/nginx/aeronote.net.conf` (named `aeronote.net.conf`) and a new
deployment public key named `deploy.pub`, then run it with sudo. It backs up
Nginx under `/var/backups/aeronote-<UTC timestamp>/`, creates the deployment
account and directories, installs the existing certificate, validates Nginx,
and reloads it. The website content is published separately by Actions.

Hong Kong runs Nginx 1.24, so the virtual host uses `listen ... ssl http2`
rather than the `http2 on` directive introduced in Nginx 1.25.1.

## VPS layout

```text
/srv/aeronote/
├── current -> releases/<commit>-<attempt>
├── releases/
├── shared/
└── .ssh/authorized_keys
```

Nginx serves `/srv/aeronote/current`. Its version-controlled configuration is
`ops/nginx/aeronote.net.conf`; the live path is
`/etc/nginx/conf.d/aeronote.net.conf`.

## Migration and rollback

Each successful workflow run produces a portable `.tar.gz` file and a
`.sha256` checksum. To migrate, install the Nginx configuration on another
host, create the directory layout above, verify the checksum, and extract the
archive into a release directory.

To roll back on the current VPS, select an existing directory under
`/srv/aeronote/releases`, create `current.next` as a relative symlink to that
release, then atomically rename `current.next` to `current`. Validate
`https://aeronote.net/healthz` and the site after switching.

TLS certificates are installed at
`/etc/nginx/ssl/aeronote.net/{fullchain,privkey}.pem` and renewed by acme.sh
using Cloudflare DNS-01. Certificate credentials are intentionally not stored
in this repository.

acme.sh runs as `ubuntu`, from `/home/ubuntu/.acme.sh`. Its `--install-cert`
configuration copies renewed certificates to the Nginx paths above and runs
`sudo -n /usr/sbin/nginx -t && sudo -n /usr/bin/systemctl reload nginx`.
`/etc/sudoers.d/aeronote-renewal` permits only these two exact commands without
a password. The certificate directory is owned by `ubuntu` with mode 700;
the private key has mode 600. Do not point Nginx directly at acme.sh's internal
certificate storage.

To undo the initial virtual host activation, restore the prior
`aeronote.net.conf` from the timestamped Nginx backup, or remove only this
virtual host if it did not previously exist. Run `nginx -t` before reloading.
The backup is a local configuration backup, not a provider snapshot or an
off-host backup. Confirm a separate backup before subsequent major changes.
