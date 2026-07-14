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
| `DEPLOY_HOST`        | SSH hostname (`los.aerodock.net`)                |
| `DEPLOY_USER`        | Unprivileged deployment user (`aeronote-deploy`) |
| `DEPLOY_SSH_KEY`     | Dedicated Ed25519 private key                    |
| `DEPLOY_KNOWN_HOSTS` | Pinned SSH host key for `los.aerodock.net`       |

Never commit private keys, Cloudflare API tokens, or `authorized_keys`.

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
