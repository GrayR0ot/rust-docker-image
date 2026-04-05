#!/bin/bash
set -e

INSTALL_DIR="/data/server"

# --- Graceful shutdown ---
trap 'echo "[RUST] Shutting down..."; kill -TERM "$PID" 2>/dev/null; wait "$PID"; exit 0' SIGTERM SIGINT

# --- Update server ---
if [ "$SERVER_UPDATE_ON_START" = "1" ]; then
    echo "[RUST] Updating server (AppID $RUST_APP_ID, branch: $SERVER_BRANCH)..."
    steamcmd +force_install_dir "$INSTALL_DIR" +login anonymous +app_update "$RUST_APP_ID" -beta "$SERVER_BRANCH" validate +quit
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
    +server.seed "$SERVER_SEED" \
    +server.worldsize "$SERVER_WORLDSIZE" \
    +server.maxplayers "$SERVER_MAXPLAYERS" \
    +server.identity "$SERVER_IDENTITY" \
    +server.saveinterval 300 \
    +rcon.ip 0.0.0.0 \
    +rcon.port "$RCON_PORT" \
    +rcon.password "$RCON_PASSWORD" \
    +rcon.web "$RCON_WEB" \
    +app.listenip 0.0.0.0 \
    +app.port "$APP_PORT" \
    "$@" &

PID=$!
wait "$PID"
