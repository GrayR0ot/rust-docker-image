#!/bin/bash
set -e

INSTALL_DIR="/server"

# --- Graceful shutdown ---
trap 'echo "[RUST] Shutting down..."; kill -TERM "$PID" 2>/dev/null; wait "$PID"; exit 0' SIGTERM SIGINT

# --- Update server ---
if [ "$SERVER_UPDATE_ON_START" = "1" ]; then
    echo "[RUST] Updating server (AppID $RUST_APP_ID, branch: $SERVER_BRANCH)..."
    steamcmd +force_install_dir "$INSTALL_DIR" +login anonymous +app_update "$RUST_APP_ID" -beta "$SERVER_BRANCH" validate +quit
fi

# --- Install/Update Oxide (uMod) ---
if [ "$OXIDE_ENABLED" = "1" ]; then
    echo "[RUST] Installing/updating Oxide..."
    OXIDE_URL="https://umod.org/games/rust/download/develop"
    OXIDE_TMP=$(mktemp -d)
    curl -fsSL -o "$OXIDE_TMP/oxide.zip" "$OXIDE_URL"
    unzip -o "$OXIDE_TMP/oxide.zip" -d "$OXIDE_TMP"
    rm -f "$OXIDE_TMP/oxide.zip"
    cp -rf "$OXIDE_TMP/"* "$INSTALL_DIR/"
    rm -rf "$OXIDE_TMP"
    echo "[RUST] Oxide installed."
fi

# --- Start server ---
cd "$INSTALL_DIR"
chmod +x ./RustDedicated

export LD_LIBRARY_PATH="./RustDedicated_Data/Plugins/x86_64:.:${LD_LIBRARY_PATH:-}"

echo "[RUST] Starting: $SERVER_NAME | seed=$SERVER_SEED | size=$SERVER_WORLDSIZE | max=$SERVER_MAXPLAYERS"

./RustDedicated \
    -batchmode -nographics \
    +server.ip 0.0.0.0 \
    +server.port "$SERVER_PORT" \
    +server.queryport "$SERVER_PORT" \
    +server.hostname "$SERVER_NAME" \
    +server.description "$SERVER_DESCRIPTION" \
    +server.url "$SERVER_URL" \
    +server.headerimage "$SERVER_BANNER_URL" \
    +server.seed "$SERVER_SEED" \
    +server.worldsize "$SERVER_WORLDSIZE" \
    +server.maxplayers "$SERVER_MAXPLAYERS" \
    +server.identity "$SERVER_IDENTITY" \
    +server.saveinterval 300 \
    +rcon.ip 0.0.0.0 \
    +rcon.web "$RCON_WEB" \
    +rcon.port "$RCON_PORT" \
    +rcon.password "$RCON_PASSWORD" \
    +app.listenip 0.0.0.0 \
    +app.port "$APP_PORT" \
    "$@" &

PID=$!
wait "$PID"
