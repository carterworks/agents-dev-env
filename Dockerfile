# syntax=docker/dockerfile:1
# =============================================================================
# AI Agent Development Environment
# Matches Claude Code on the Web specification
# Uses mise for reproducible language version management
# =============================================================================

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# =============================================================================
# System Dependencies
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    gnupg \
    software-properties-common \
    # Development headers (required for compiling native extensions)
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    libffi-dev \
    liblzma-dev \
    libxml2-dev \
    libxmlsec1-dev \
    tk-dev \
    xz-utils \
    # C/C++ toolchain
    gcc \
    g++ \
    clang \
    cmake \
    ninja-build \
    pkg-config \

    # Database clients
    postgresql-client \
    redis-tools \
    sqlite3 \
    # Utilities
    jq \
    vim \
    tmux \
    unzip \
    sudo \
    locales \
    less \
    openssh-client \
    git-lfs \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    # fd is installed as fdfind on Ubuntu, symlink to fd
    && ln -s $(which fdfind) /usr/local/bin/fd

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Git configuration - mark /workspace as safe to avoid "dubious ownership" errors
RUN git config --system --add safe.directory /workspace \
    && git lfs install

# =============================================================================
# mise Configuration
# =============================================================================
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# mise environment variables
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"

# Install mise
RUN curl https://mise.run | sh

# =============================================================================
# Tool Versions Configuration
# =============================================================================
COPY <<'EOF' /mise/config.toml
[tools]
# Languages - matching Claude Code on the Web spec
python = "3.11"
node = "22"
go = "1.24"
rust = "latest"
java = "openjdk-21"
ruby = "3.3"
# php omitted - requires complex build dependencies

# AI Coding Agents
claude = "latest"
codex = "latest"
opencode = "latest"

# Python tools
uv = "latest"

# CLI tools
github-cli = "latest"

[settings]
experimental = true
EOF

# Install all tools via mise
RUN mise install --yes

# Trust the config
RUN mise trust /mise/config.toml

# =============================================================================
# Package Managers & Global Packages
# =============================================================================

# Node.js package managers and global packages
RUN mise exec -- npm install -g \
    pnpm \
    yarn \
    typescript \
    eslint \
    prettier \
    ts-node \
    nodemon \
    playwright \
    http-server \
    serve

# Bun (installed via mise or standalone)
RUN mise use -g bun@latest

# Python packages
RUN mise exec -- pip install --no-cache-dir \
    pyyaml \
    jinja2 \
    requests \
    cryptography \
    conan

# Rust components
RUN mise exec -- rustup component add clippy rustfmt

# =============================================================================
# Workspace Setup
# =============================================================================
WORKDIR /workspace

# Version check script
COPY <<'SCRIPT' /usr/local/bin/check-versions
#!/bin/bash
set -e
echo "==========================================="
echo "   AI Agent Development Environment"
echo "==========================================="
echo ""
echo "System:"
echo "  OS:      $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  Kernel:  $(uname -r)"
echo "  Arch:    $(uname -m)"
echo ""
echo "AI Coding Agents:"
echo "  claude:   $(claude --version 2>&1 | head -1 || echo 'not found')"
echo "  codex:    $(codex --version 2>&1 | head -1 || echo 'not found')"
echo "  opencode: $(opencode --version 2>&1 | head -1 || echo 'not found')"
echo ""
echo "Languages:"
echo "  Python:  $(python --version 2>&1 | awk '{print $2}')"
echo "  Node.js: $(node --version)"
echo "  Go:      $(go version | awk '{print $3}')"
echo "  Rust:    $(rustc --version | awk '{print $2}')"
echo "  Java:    $(java --version 2>&1 | head -1)"
echo "  Ruby:    $(ruby --version | awk '{print $2}')"
echo ""
echo "Package Managers:"
echo "  npm:     $(npm --version)"
echo "  pnpm:    $(pnpm --version)"
echo "  yarn:    $(yarn --version)"
echo "  bun:     $(bun --version)"
echo "  pip:     $(pip --version | awk '{print $2}')"
echo "  uv:      $(uv --version | awk '{print $2}')"
echo "  cargo:   $(cargo --version | awk '{print $2}')"
echo ""
echo "Build Tools:"
echo "  gcc:     $(gcc --version | head -1)"
echo "  clang:   $(clang --version | head -1)"
echo "  cmake:   $(cmake --version | head -1 | awk '{print $3}')"
echo "  make:    $(make --version | head -1)"
echo ""
echo "==========================================="
SCRIPT
RUN chmod +x /usr/local/bin/check-versions

# Default command
CMD ["/bin/bash"]
