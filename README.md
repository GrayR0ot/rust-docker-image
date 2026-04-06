# 🦀 Rust Dedicated Server — Docker Image

Docker image to host a [Rust](https://rust.facepunch.com/) dedicated server, based on **Ubuntu Noble (24.04)** with **SteamCMD** installed following the [official Valve documentation](https://developer.valvesoftware.com/wiki/SteamCMD#Ubuntu).

## 🚀 Quick Start

```bash
docker build -t rust-server .

docker run -d \
  --name rust \
  -p 28015:28015/udp \
  -p 28016:28016/tcp \
  -p 28082:28082/tcp \
  -v rust-data:/server \
  -e SERVER_NAME="My Rust Server" \
  -e RCON_PASSWORD="a_real_password" \
  rust-server
```

## ⚙️ Environment Variables

All variables can be configured at runtime via `-e` (Docker) or `env` (Kubernetes).

### Server

| Variable | Default | Description |
|---|---|---|
| `SERVER_NAME` | `Rust Server` | Server name displayed in the server browser |
| `SERVER_DESCRIPTION` | `A Rust Dedicated Server` | Server description |
| `SERVER_URL` | *(empty)* | Server website URL (shown in server browser) |
| `SERVER_BANNER_URL` | *(empty)* | Server banner/header image URL (shown in server browser) |
| `SERVER_SEED` | `12345` | Map generation seed |
| `SERVER_WORLDSIZE` | `3000` | Map size (1000 to 6000) |
| `SERVER_MAXPLAYERS` | `50` | Maximum number of players |
| `SERVER_IDENTITY` | `rustserver` | Server identity name (save folder) |

### Network

| Variable | Default | Description |
|---|---|---|
| `SERVER_PORT` | `28015` | Game port (UDP) |
| `RCON_PORT` | `28016` | RCON port (TCP) |
| `RCON_PASSWORD` | `changeme` | ⚠️ RCON password — **must be changed** |
| `RCON_WEB` | `1` | Enable web RCON (`1` = enabled, `0` = disabled) |
| `APP_PORT` | `28082` | Rust+ Companion app port (TCP) |

### Updates & Mods

| Variable | Default | Description |
|---|---|---|
| `SERVER_UPDATE_ON_START` | `1` | Update the server via SteamCMD on startup (`1` = yes, `0` = no) |
| `SERVER_BRANCH` | `public` | Steam branch to use (`public`, `staging`, etc.) |
| `OXIDE_ENABLED` | `0` | Install/update [Oxide (uMod)](https://umod.org/) on startup (`1` = yes, `0` = no) |

### Advanced

| Variable | Default | Description |
|---|---|---|
| `RUST_APP_ID` | `258550` | Steam application ID (do not change unless specific use case) |

## 📁 Volumes

| Path | Description |
|---|---|
| `/server` | Server installation directory (world, saves, config, Oxide plugins) |

Mount a persistent volume on `/server` to preserve data between restarts:

```bash
-v rust-data:/server
```

## 🔌 Ports

| Port    | Protocol | Description |
|---------|---|---|
| `28015` | UDP | Game port |
| `28016` | TCP | RCON |
| `28017` | UDP | Query |
| `28082` | TCP | Rust+ Companion App |

## 🧩 Oxide / uMod

To enable Oxide (plugin framework):

```bash
-e OXIDE_ENABLED=1
```

Oxide is downloaded and installed on every container startup (when enabled). Plugins go in:

```
/server/oxide/plugins/
```

This directory is persisted via the `/server` volume.

## 🛑 Graceful Shutdown

The image handles the `SIGTERM` signal for a clean server shutdown. Docker and Kubernetes send this signal by default on `stop` or `delete`.

## ☸️ Kubernetes

The image is ready for Kubernetes deployment. Example probes to add to your manifest:

```yaml
livenessProbe:
  exec:
    command: ["pgrep", "-f", "RustDedicated"]
  initialDelaySeconds: 120
  periodSeconds: 30
readinessProbe:
  exec:
    command: ["pgrep", "-f", "RustDedicated"]
  initialDelaySeconds: 120
  periodSeconds: 15
```

## 📝 Extra Arguments

All arguments passed after the image name are forwarded directly to `RustDedicated`:

```bash
docker run ... rust-server +server.pve true +server.radiation false
```
