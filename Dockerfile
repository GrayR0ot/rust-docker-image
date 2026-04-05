FROM ubuntu:noble

# --- Create unprivileged 'steam' user (as per Valve docs) ---
RUN useradd -m steam

ENV HOME=/home/steam

# --- Install SteamCMD (official Valve method for Ubuntu) ---
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        software-properties-common \
    && add-apt-repository multiverse \
    && apt-get update \
    && echo "steam steam/question select I AGREE" | debconf-set-selections \
    && echo "steam steam/license note ''" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        steamcmd \
        ca-certificates \
        curl \
        unzip \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# --- Link steamcmd into user PATH & prepare .steam dirs ---
RUN ln -sf /usr/games/steamcmd /usr/bin/steamcmd \
    && mkdir -p /home/steam/.steam/sdk32 /home/steam/.steam/sdk64 \
    && chown -R steam:steam /home/steam

# --- Environment variables (overridable at runtime) ---
ENV SERVER_NAME="Rust Server" \
    SERVER_DESCRIPTION="A Rust Dedicated Server" \
    SERVER_URL="" \
    SERVER_BANNER_URL="" \
    SERVER_SEED="12345" \
    SERVER_WORLDSIZE="3000" \
    SERVER_MAXPLAYERS="50" \
    SERVER_PORT="28015" \
    RCON_PORT="28016" \
    RCON_PASSWORD="changeme" \
    RCON_WEB="1" \
    APP_PORT="28082" \
    SERVER_IDENTITY="rustserver" \
    SERVER_BRANCH="public" \
    SERVER_UPDATE_ON_START="1" \
    OXIDE_ENABLED="0" \
    RUST_APP_ID="258550"

# --- Server directory ---
RUN mkdir -p /server && chown steam:steam /server

WORKDIR /server

# --- Copy startup script (outside /server to avoid volume conflicts) ---
RUN mkdir -p /opt/rust && chown steam:steam /opt/rust
COPY --chown=steam:steam start.sh /opt/rust/start.sh
RUN chmod +x /opt/rust/start.sh

# --- Declare persistent volume ---
VOLUME ["/server"]


# --- Graceful shutdown ---
STOPSIGNAL SIGTERM

# --- Run as unprivileged 'steam' user ---
USER steam

ENTRYPOINT ["/opt/rust/start.sh"]
