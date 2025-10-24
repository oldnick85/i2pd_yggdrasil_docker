#!/bin/bash
set -e  # Exit on any error

echo "Starting I2P over Yggdrasil setup..."

# Function to handle graceful shutdown
cleanup() {
    echo "Received shutdown signal, stopping services..."
    kill -TERM $i2pd_pid $yggdrasil_pid 2>/dev/null
    wait
    echo "Services stopped gracefully."
    exit 0
}

trap cleanup SIGTERM SIGINT

# Generate strong Yggdrasil address (https://yggdrasil-network.github.io/configuration.html#generating-stronger-addresses-and-prefixes)
echo "Generating Yggdrasil keys..."
python3 /UTILS/yggdrasil_get_keys/yggdrasil_get_keys.py \
    --genkeys="/YGGDRASIL/genkeys" \
    --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
    --timeout=60 \
    --environment

# Find and configure public Yggdrasil peers
echo "Discovering Yggdrasil public peers..."
python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json" \
    --parallel=4 \
    --pings=10 \
    --best=6 \
    --max-from-country=2 \
    --ping-interval=0.5

# Enable IPv6 (required for Yggdrasil)
echo "Enabling IPv6..."
sysctl net.ipv6.conf.all.disable_ipv6=0 || true

# Start Yggdrasil in background
echo "Starting Yggdrasil..."
/YGGDRASIL/yggdrasil -useconffile /YGGDRASIL/yggdrasil.conf &
yggdrasil_pid=$!

# Wait for Yggdrasil to establish connections
echo "Waiting for Yggdrasil network connectivity (60 seconds)..."
sleep 60

# Start I2P in background
echo "Starting I2P..."
/I2PD/i2pd --datadir /I2PD --conf /I2PD/i2pd.conf &
i2pd_pid=$!

echo "Both services started successfully!"
echo "I2P Web Console: http://localhost:7070"
echo "Yggdrasil status: check container logs"

# Wait for any process to exit and handle restart if needed
wait -n

# If we reach here, one process died
echo "One of the services stopped unexpectedly, shutting down..."
kill -TERM $i2pd_pid $yggdrasil_pid 2>/dev/null
wait
exit 1