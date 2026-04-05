# Forge Setup Guide

Complete guide for setting up Forge as a distributed coding agent across ZeroTier VPN.

## Architecture

- **Desktop (Server):** Runs Ollama with Gemma 4 on ZeroTier, handles all compute
- **Clients (Thin):** Run Forge CLI pointing to desktop, send requests only

## Part 1: Desktop Setup (Compute Server)

### 1.1 Install Ollama

Download from [ollama.com](https://ollama.com) or:

**Linux:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**macOS:**
```bash
# Download from ollama.com or use homebrew
brew install ollama
```

**Windows:**
Download from [ollama.com/download](https://ollama.com/download)

### 1.2 Pull Gemma 4 Model

```bash
ollama pull gemma4
```

Verify it's installed:
```bash
ollama list
# Should show: gemma4:latest
```

### 1.3 Configure Ollama for Network Access

Make Ollama listen on all network interfaces:

**Linux/macOS:**
Edit `~/.bashrc` or `~/.zshrc`:
```bash
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_BASE_URL=http://localhost:11434/v1
```

Then reload:
```bash
source ~/.bashrc
```

**Or run directly:**
```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

### 1.4 Install ZeroTier

**Linux:**
```bash
curl -s https://install.zerotier.com/ | sudo bash
sudo systemctl start zerotier-one
```

**macOS:**
```bash
brew install zerotier-one
sudo launchctl start com.zerotier.one
```

**Windows:**
Download from [zerotier.com/download](https://zerotier.com/download)

### 1.5 Join ZeroTier Network

Get your Network ID from [zerotier.com/app](https://zerotier.com/app):

```bash
sudo zerotier-cli join <YOUR_NETWORK_ID>
```

Authorize the device in the web console (zerotier.com/app), then check your ZeroTier IP:

```bash
sudo zerotier-cli info
# Look for the address line, e.g.: fd28:73fd:f2:2eac:a699:9325:6c01:b6e4 or 172.30.250.235
```

**Save your ZeroTier IP** — this is what clients will use to connect.

### 1.6 Download and Install Forge

Get the latest release for your platform:

```bash
# Check releases
curl -s https://api.github.com/repos/natkal-coder/claw-code/releases/latest | grep browser_download_url

# Download (replace with actual URL from releases)
wget https://github.com/natkal-coder/claw-code/releases/download/v0.1.1/forge-linux-x86_64
chmod +x forge-linux-x86_64
sudo cp forge-linux-x86_64 /usr/local/bin/forge
```

### 1.7 Test Desktop Setup

```bash
# In a terminal, start Ollama
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# In another terminal, test Forge
export OLLAMA_BASE_URL=http://localhost:11434/v1
forge --model gemma4
```

You should see the Forge prompt. Type `/status` to verify Gemma 4 is connected.

## Part 2: Client Setup (Any Device)

### 2.1 Join ZeroTier Network

All clients must be on the same ZeroTier network:

**Linux/macOS:**
```bash
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join <YOUR_NETWORK_ID>
```

**Windows:**
Download from [zerotier.com/download](https://zerotier.com/download)

Authorize in [zerotier.com/app](https://zerotier.com/app)

### 2.2 Get Desktop IP

Ask the desktop admin for the ZeroTier IP, or check:

```bash
sudo zerotier-cli info
# Note the address that looks like: 172.30.250.235 or fd28:73fd:f2:...
```

### 2.3 Download Forge Binary

Get the correct binary for your platform:

**Linux (x86_64):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/v0.1.1/forge-linux-x86_64
chmod +x forge-linux-x86_64
sudo cp forge-linux-x86_64 /usr/local/bin/forge
```

**macOS (Apple Silicon M1/M2/M3):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/v0.1.1/forge-macos-arm64
chmod +x forge-macos-arm64
sudo cp forge-macos-arm64 /usr/local/bin/forge
```

**macOS (Intel):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/v0.1.1/forge-macos-x86_64
chmod +x forge-macos-x86_64
sudo cp forge-macos-x86_64 /usr/local/bin/forge
```

**Windows:**
Download `forge-windows-x86_64.exe` and add to PATH or run directly

### 2.4 Configure Forge to Point to Desktop

Set environment variables permanently:

**Linux/macOS:**
Edit `~/.bashrc` or `~/.zshrc`:
```bash
export OLLAMA_BASE_URL=http://DESKTOP_ZEROTIER_IP:11434/v1
export FORGE_MODEL=gemma4

# Example:
# export OLLAMA_BASE_URL=http://172.30.250.235:11434/v1
```

Then reload:
```bash
source ~/.bashrc
```

**Windows (PowerShell):**
```powershell
[Environment]::SetEnvironmentVariable("OLLAMA_BASE_URL", "http://172.30.250.235:11434/v1", "User")
[Environment]::SetEnvironmentVariable("FORGE_MODEL", "gemma4", "User")
```

### 2.5 Test Client Connection

```bash
forge --model gemma4
```

You should see the Forge prompt. Try:
```
> /status
```

If you see Gemma 4 with your workspace info, you're connected!

## Part 3: Build and Release (Developers)

### 3.1 Build Binaries Locally

From the repo root:

```bash
./scripts/build-release.sh 0.2.0
```

This:
- Builds Forge for your platform
- Commits changes
- Creates git tag v0.2.0

### 3.2 Push to GitHub

```bash
git push origin main
git push origin v0.2.0
```

GitHub Actions automatically:
- Cross-compiles for Linux, Windows, macOS (Intel + ARM)
- Creates release with all binaries
- Uploads to GitHub Releases

### 3.3 Users Download Binaries

Users go to [Releases](https://github.com/natkal-coder/claw-code/releases) and download for their platform.

## Troubleshooting

### Desktop: Ollama not accessible from network

Verify Ollama is listening on all interfaces:
```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# Test locally
curl http://localhost:11434/api/tags
```

### Client: Can't reach desktop

1. Check ZeroTier is running:
```bash
sudo zerotier-cli info
```

2. Verify both devices are on same network and authorized in zerotier.com/app

3. Test network connectivity:
```bash
ping DESKTOP_ZEROTIER_IP
```

4. Verify Ollama is running on desktop

### Forge: "missing Claw credentials"

This shouldn't happen with local Ollama. Verify:
```bash
echo $OLLAMA_BASE_URL
# Should output: http://DESKTOP_IP:11434/v1

forge --model gemma4
```

## Network Bandwidth

- Each request: ~1-10 KB
- Each response: ~5-50 KB
- Works well on 1 Mbps+ connections
- Desktop needs: 50+ Mbps for Gemma 4 inference (download once)

## Security

- ZeroTier encrypts all traffic end-to-end
- No credentials needed (local Ollama)
- Keep ZeroTier network ID private
- Only authorized devices can connect
