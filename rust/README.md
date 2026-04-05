# Forge

Forge is a local coding-agent CLI implemented in safe Rust. It is **Claude Code inspired** and developed as a **clean-room implementation**: it aims for a strong local agent experience, but it is **not** a direct port or copy of Claude Code.

The Rust workspace is the current main product surface. The `forge` binary provides interactive sessions, one-shot prompts, workspace-aware tools, local agent workflows, and plugin-capable operation from a single workspace.

## Current status

- **Version:** `0.1.0`
- **Release stage:** initial public release, source-build distribution
- **Primary implementation:** Rust workspace in this repository
- **Platform focus:** macOS and Linux developer workstations

## Install, build, and run

### Quick start (pre-built binaries)

Download latest binaries for your platform from [GitHub Releases](https://github.com/natkal-coder/claw-code/releases):

**Linux (x86_64):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/latest/forge-linux-x86_64
chmod +x forge-linux-x86_64
./forge-linux-x86_64 --help
```

**macOS (Apple Silicon M1/M2/M3):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/latest/forge-macos-arm64
chmod +x forge-macos-arm64
./forge-macos-arm64 --help
```

**macOS (Intel):**
```bash
wget https://github.com/natkal-coder/claw-code/releases/download/latest/forge-macos-x86_64
chmod +x forge-macos-x86_64
./forge-macos-x86_64 --help
```

**Windows (x86_64):**
Download `forge-windows-x86_64.exe` from [Releases](https://github.com/natkal-coder/claw-code/releases)

Then optionally install system-wide:
```bash
# Linux/macOS
sudo cp forge-* /usr/local/bin/forge
chmod +x /usr/local/bin/forge

# Windows: Add exe to PATH or use directly
```

### Prerequisites

- Provider credentials for the model you want to use
  - For Anthropic: `ANTHROPIC_API_KEY`
  - For Grok: `XAI_API_KEY`
  - For local models: [Ollama](https://ollama.com) (no credentials needed)

### Authentication

Anthropic-compatible models:

```bash
export ANTHROPIC_API_KEY="..."
# Optional when using a compatible endpoint
export ANTHROPIC_BASE_URL="https://api.anthropic.com"
```

Grok models:

```bash
export XAI_API_KEY="..."
# Optional when using a compatible endpoint
export XAI_BASE_URL="https://api.x.ai"
```

Locally hosted models via Ollama (including Gemma 4):

```bash
# Install Ollama: https://ollama.com
# Pull a model
ollama pull gemma4

# Set the Ollama endpoint
export OLLAMA_BASE_URL="http://localhost:11434/v1"

# Run Forge with Gemma 4
./target/release/forge --model gemma4
```

Supported Ollama models:
- `gemma4` — [Google Gemma 4](https://huggingface.co/collections/google/gemma-4)
- `gemma2` — Google Gemma 2
- Any other Ollama model (use the exact model name)

### Network deployment (server/client)

Run Gemma 4 on a desktop server, access from mobile/laptop clients over network or VPN.

**Desktop (compute server):**

1. Install [ZeroTier](https://www.zerotier.com) and join your VPN network:
```bash
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join <YOUR_NETWORK_ID>
```

2. Get ZeroTier IP:
```bash
sudo zerotier-cli info
# Look for the address like "192.168.193.xxx"
```

3. Make Ollama listen on all interfaces:
```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

4. Make Gemma 4 default in `~/.bashrc`:
```bash
export OLLAMA_BASE_URL=http://localhost:11434/v1
export FORGE_MODEL=gemma4
```

5. Reload and test:
```bash
source ~/.bashrc
forge  # Will auto-use gemma4
```

**VPN Peers (mobile/laptop/remote):**

1. Install ZeroTier and join the same network
2. Get desktop ZeroTier IP:
```bash
# From desktop
sudo zerotier-cli info
# e.g., 192.168.193.42
```

3. Connect Forge to desktop:
```bash
export OLLAMA_BASE_URL=http://192.168.193.42:11434/v1
forge --model gemma4
```

**Optional: Web UI for VPN peers:**

Run [Open WebUI](https://docs.openwebui.com) on desktop for browser access:
```bash
docker run -d -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://localhost:11434 \
  ghcr.io/open-webui/open-webui:latest
```

Then VPN peers access via: `http://192.168.193.42:3000`

All compute happens on the desktop; VPN clients only run the Forge CLI or browser.

OAuth login is also available:

```bash
cargo run --bin claw -- login
```

### Build from source (if you prefer)

**Prerequisites for building:**
- Rust stable toolchain
- Cargo

**Build locally:**
```bash
git clone git@github.com:natkal-coder/claw-code.git
cd claw-code/rust
cargo build --release -p claw-cli
# Binary at: target/release/forge
```

**Install from source:**
```bash
cargo install --path crates/claw-cli --locked
# Installs to: ~/.cargo/bin/forge
```

### Run

From the workspace:

```bash
cargo run --bin forge -- --help
cargo run --bin forge --
cargo run --bin forge -- prompt "summarize this workspace"
cargo run --bin forge -- --model sonnet "review the latest changes"
```

From the release build:

```bash
./target/release/forge
./target/release/forge prompt "explain crates/runtime"
```

## Supported capabilities

- Interactive REPL and one-shot prompt execution
- Saved-session inspection and resume flows
- Built-in workspace tools for shell, file read/write/edit, search, web fetch/search, todos, and notebook updates
- Slash commands for status, compaction, config inspection, diff, export, session management, and version reporting
- Local agent and skill discovery with `claw agents` and `claw skills`
- Plugin discovery and management through the CLI and slash-command surfaces
- OAuth login/logout plus model/provider selection from the command line
- Workspace-aware instruction/config loading (`CLAW.md`, config files, permissions, plugin settings)

## Current limitations

- Public distribution is **source-build only** today; this workspace is not set up for crates.io publishing
- GitHub CI verifies `cargo check`, `cargo test`, and release builds, but automated release packaging is not yet present
- Current CI targets Ubuntu and macOS; Windows release readiness is still to be established
- Some live-provider integration coverage is opt-in because it requires external credentials and network access
- The command surface may continue to evolve during the `0.x` series

## Implementation

The Rust workspace is the active product implementation. It currently includes these crates:

- `claw-cli` — user-facing binary
- `api` — provider clients and streaming
- `runtime` — sessions, config, permissions, prompts, and runtime loop
- `tools` — built-in tool implementations
- `commands` — slash-command registry and handlers
- `plugins` — plugin discovery, registry, and lifecycle support
- `lsp` — language-server protocol support types and process helpers
- `server` and `compat-harness` — supporting services and compatibility tooling

## Roadmap

- Publish packaged release artifacts for public installs
- Add a repeatable release workflow and longer-lived changelog discipline
- Expand platform verification beyond the current CI matrix
- Add more task-focused examples and operator documentation
- Continue tightening feature coverage and UX polish across the Rust implementation

## Release notes

- Draft 0.1.0 release notes: [`docs/releases/0.1.0.md`](docs/releases/0.1.0.md)

## License

See the repository root for licensing details.
