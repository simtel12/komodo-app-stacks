# Homelab Komodo Stacks

This repository contains application stacks deployed via Komodo using GitOps. All stacks depend on secrets being synchronized from 1Password by the `komodo-op` service.

## Stack Overview

| Stack | Description | Services |
|-------|-------------|----------|
| `caddy-home/sequoia/vps` | Reverse proxy | Caddy (3 instances) |
| `nebula-sync-home/sequoia` | Pi-hole sync | Nebula-sync (2 instances) |
| `servarr` | Media automation | Radarr, Sonarr, Jackett, Bazarr |
| `monitoring` | System monitoring | Prometheus, Grafana, Node Exporter |
| `homepage` | Dashboard | Homepage |
| `paperless` | Document management | Paperless-ngx |
| `immich` | Photo management | Immich |
| Others | Various services | actualbudget, authentik, stirlingpdf, tautulli, uptime-kuma, zigbee2mqtt |

## Prerequisites

1. **komodo-op deployed**: Must be running and syncing secrets from 1Password
2. **Komodo resource sync**: Must be configured to monitor this repository
3. **Required secrets**: All referenced secrets must exist in 1Password

## Directory Structure

```
komodo-app-stacks/
├── services/
│   ├── caddy/                    # Shared base + instance overrides
│   │   ├── docker-compose.yaml
│   │   ├── home/docker-compose.yaml
│   │   ├── sequoia/docker-compose.yaml
│   │   └── vps/docker-compose.yaml
│   ├── caddy-home/stack.toml     # References base + home files
│   ├── caddy-sequoia/stack.toml
│   ├── caddy-vps/stack.toml
│   ├── nebula-sync/              # Shared base + instance overrides
│   ├── servarr/
│   │   ├── docker-compose.yaml
│   │   └── stack.toml
│   ├── monitoring/
│   ├── homepage/
│   └── ...other services
├── renovate.json
└── README.md
```

## Deployment Flow

1. **Push changes** to this repository
2. **GitHub webhook** triggers Komodo resource sync
3. **Komodo syncs** new configurations
4. **Auto-deploy** occurs if enabled in stack.toml
5. **Services start** with secrets from Komodo global variables

## Multi-File Compose Pattern

For services with multiple instances (like Caddy), Komodo's multi compose file support is leveraged:

```toml
file_paths = [
    "services/caddy/docker-compose.yaml",        # Base configuration
    "services/caddy/home/docker-compose.yaml",   # Instance-specific overrides
]
```

**Benefits:**
- Single base configuration for common settings
- Instance-specific overrides for differences only
- Easy to maintain and add new instances

## Adding New Stacks

1. **Create directory** in `services/` for your stack
2. **Add docker-compose.yaml** with your services
3. **Create stack.toml** with deployment configuration
4. **Reference secrets** using `[[SECRET_NAME]]` syntax
5. **Commit and push** - auto-deployment will occur

### Example stack.toml
```toml
[[stack]]
name = "my-stack"
tags = ["category", "service-type"]

[stack.config]
server = "TARGET_SERVER"
auto_update = true
git_account = "simtel12"
repo = "simtel12/komodo-app-stacks"
branch = "main"
file_paths = ["services/my-stack/docker-compose.yaml"]

environment = """
SECRET_VALUE=[[MY_SECRET_FROM_1PASSWORD]]
CONFIG_DIR=[[MY_CONFIG_DIR]]
"""
```

## Host Notes

### Plex GPU transcoding (`blade_2016`)

The `plex` stack uses NVIDIA hardware transcoding. Docker passes the GPU through CDI (`/var/run/cdi/nvidia.yaml`), and the host uses the headless `-server` driver, so:

- Install `libnvidia-decode-<branch>-server` and `libnvidia-encode-<branch>-server` on the host (they are not part of the headless driver). The compose file must request the `video` capability (`capabilities: [gpu, compute, video, utility]`).
- The CDI spec is **not** refreshed automatically when those packages are installed or changed. If NVENC/NVDEC libraries are missing in the container (Plex logs `no hardware decode accelerator found`), run `sudo systemctl start nvidia-cdi-refresh.service`, check that `grep -cE 'nvcuvid|nvidia-encode' /var/run/cdi/nvidia.yaml` is non-zero, then recreate the container.

## Security

- **No secrets in repository**: All secrets come from 1Password via komodo-op
- **Environment variables**: Use Komodo global variables for all sensitive data
- **Access control**: Repository access controls who can deploy what

## Monitoring Deployments

- **Komodo UI**: View deployment status and logs
- **GitHub Actions**: See webhook delivery status
- **Container logs**: Check individual service logs in Komodo
