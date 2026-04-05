#!/bin/bash
set -e

# Forge Release Build Script
# Builds all platform binaries and commits to git

VERSION="${1:-0.1.1}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$REPO_ROOT/rust"
RELEASE_DIR="$REPO_ROOT/releases/$VERSION"

echo "🔨 Forge Release Builder v$VERSION"
echo "=================================="

# Check if git repo is clean
if ! git -C "$REPO_ROOT" diff-index --quiet HEAD --; then
    echo "❌ Git repository has uncommitted changes. Commit first."
    exit 1
fi

# Create release directory
mkdir -p "$RELEASE_DIR"

# Function to build for a target
build_target() {
    local target=$1
    local bin_name=$2
    echo ""
    echo "📦 Building $target..."

    cd "$RUST_DIR"

    if [ "$target" = "host" ]; then
        cargo build --release -p claw-cli
        cp "target/release/$bin_name" "$RELEASE_DIR/forge-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
    else
        cargo build --release -p claw-cli --target "$target"
        cp "target/$target/release/$bin_name" "$RELEASE_DIR/forge-$target"
    fi

    echo "✓ Built $target"
}

# Detect current platform and build
UNAME_S=$(uname -s)
if [ "$UNAME_S" = "Linux" ]; then
    build_target "host" "forge"
elif [ "$UNAME_S" = "Darwin" ]; then
    # macOS - detect arch
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        build_target "aarch64-apple-darwin" "forge"
    else
        build_target "x86_64-apple-darwin" "forge"
    fi
else
    echo "⚠️  Unsupported platform: $UNAME_S"
    echo "Use GitHub Actions for cross-platform builds: push a git tag v*"
    exit 1
fi

# Make binaries executable
chmod +x "$RELEASE_DIR"/*

echo ""
echo "📝 Creating release commit..."
cd "$REPO_ROOT"

# Add release binaries
git add releases/
git commit -m "release: build $VERSION binaries

Includes:
- $(ls -1 "$RELEASE_DIR" | sed 's/^/  - /')"

# Create git tag
git tag -a "v$VERSION" -m "Release $VERSION"

echo ""
echo "✅ Build complete!"
echo ""
echo "Next steps:"
echo "1. Push to GitHub:"
echo "   git push origin main"
echo "   git push origin v$VERSION"
echo ""
echo "2. GitHub Actions will cross-compile for all platforms"
echo "3. Download binaries from:"
echo "   https://github.com/natkal-coder/claw-code/releases/tag/v$VERSION"
echo ""
echo "📦 Local binary available at:"
echo "   $RELEASE_DIR/"
