# 🌐🔒 I2P over Yggdrasil Network

## 📝 Description

A Docker container that runs [I2PD](https://i2pd.website/) over the [Yggdrasil](https://yggdrasil-network.github.io/) encrypted mesh network, providing enhanced anonymity and network resilience.

No clearnet for I2P (Invisible Internet Project), only Yggdrasil!

## 🎯 Overview

This project creates a privacy-focused networking stack that combines:

- **I2P (Invisible Internet Project)**: An anonymous overlay network that focuses on secure and anonymous communication
- **Yggdrasil Network**: An early-stage implementation of an encrypted IPv6 routing network for mesh and point-to-point connectivity

### ✨ Key Features

- **Double Encryption** 🔒🔒: Traffic is encrypted through both Yggdrasil and I2P layers
- **Mesh Networking** 🕸️: Operates over Yggdrasil's peer-to-peer mesh network
- **Enhanced Anonymity** 🎭: I2P's anonymity features combined with Yggdrasil's encryption
- **Automatic Peer Discovery** 🔍: Automatically finds and connects to optimal Yggdrasil peers
- **Strong Cryptography** 🛡️: Generates cryptographically strong Yggdrasil addresses

## 🏗️ Architecture

At startup, the script searches YGGDRASIL public peers and chooses several best of them. 
Then it generates YGGDRASIL *PublicKey* and *PrivateKey* unless the keys not set in environment variables.

+-------------------------+
| I2P Applications        |
+-------------------------+
| I2P Routing Layer       |
+-------------------------+
| Yggdrasil Network Layer |
+-------------------------+
| Physical Network        |
+-------------------------+

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux host (for TUN device access)
- IPv6 support enabled

## 🚀 Quick Start

1. **Clone and build** 📥:
```bash
chmod +x make_docker_image.sh
./make_docker_image.sh
```

2. **Run with Docker Compose** 🏃‍♂️:
```bash
docker-compose up -d
```

3. **Access (I2P web console)[http://localhost:7070] to check I2P router state** 🌐:
```bash
# View I2P status
curl http://localhost:7070
```

## Security Considerations 🔒

 - The container runs with NET_ADMIN capabilities for TUN device access
 - Yggdrasil keys are generated automatically on first run
 - I2P is configured in floodfill mode by default (can be disabled)
 - Both networks use strong encryption by default