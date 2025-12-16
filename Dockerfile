# Development Environment Dockerfile
# Ubuntu 24.04 LTS with mise for development tools
# Provides a familiar, portable development environment

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies and build tools
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc-13 \
    g++-13 \
    make \
    cmake \
    ninja-build \
    pkg-config \
    clang-18 \
    # Version control
    git \
    # Network tools
    curl \
    wget \
    # Utilities
    jq \
    vim \
    tmux \
    gnupg \
    ca-certificates \
    software-properties-common \
    unzip \
    # System libraries (dev headers)
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    # Database clients
    postgresql-client-16 \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Set GCC 13 and Clang 18 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100

# Install Python 3.11 and uv
RUN add-apt-repository ppa:deadsnakes/ppa -y && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm, yarn, and bun
RUN npm install -g pnpm@10.25.0 yarn@1.22.22
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Install Go 1.24
RUN wget https://go.dev/dl/go1.24.7.linux-arm64.tar.gz \
    && tar -C /usr/local -xzf go1.24.7.linux-arm64.tar.gz \
    && rm go1.24.7.linux-arm64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.91.1
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Java (OpenJDK 21)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Install PHP 8.3 (8.4 requires PPA)
RUN apt-get update && apt-get install -y \
    php8.3-cli \
    php8.3-curl \
    php8.3-mbstring \
    php8.3-xml \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby 3.3
RUN apt-get update && apt-get install -y \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# Perl is already included in Ubuntu base image

# Install TypeScript and development tools globally
RUN npm install -g \
    typescript@5.9.3 \
    eslint@9.39.1 \
    prettier@3.7.4 \
    ts-node@10.9.2 \
    nodemon@3.1.11 \
    playwright@1.56.1 \
    http-server@14.1.1 \
    serve@14.2.5

# Install mise for frequently updated development tools
RUN curl https://mise.jdx.dev/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy mise configuration
COPY .mise.toml /workspace/.mise.toml

# Trust the mise config
RUN mise trust /workspace/.mise.toml

# Activate mise in bashrc
RUN echo 'eval "$(mise activate bash)"' >> /root/.bashrc

# Create a startup script
RUN echo '#!/bin/bash\n\
# Activate mise\n\
if command -v mise &> /dev/null; then\n\
    eval "$(mise activate bash)"\n\
fi\n\
\n\
echo "Development Environment Ready!"\n\
echo "================================"\n\
echo ""\n\
echo "Ubuntu 24.04 LTS Development Environment"\n\
echo ""\n\
echo "Languages:"\n\
echo "  Python: $(python3 --version)"\n\
echo "  uv: $(uv --version 2>&1 || echo not found)"\n\
echo "  Node.js: $(node --version)"\n\
echo "  Go: $(go version)"\n\
echo "  Rust: $(rustc --version)"\n\
echo "  Java: $(java -version 2>&1 | head -1)"\n\
echo "  PHP: $(php --version | head -1)"\n\
echo "  Ruby: $(ruby --version)"\n\
echo ""\n\
echo "Build Tools:"\n\
echo "  GCC: $(gcc --version | head -1)"\n\
echo "  Clang: $(clang --version | head -1)"\n\
echo "  CMake: $(cmake --version | head -1)"\n\
echo ""\n\
echo "Package Managers:"\n\
echo "  npm: $(npm --version)"\n\
echo "  pnpm: $(pnpm --version)"\n\
echo "  yarn: $(yarn --version)"\n\
echo "  bun: $(bun --version)"\n\
echo "  pip: $(pip3 --version)"\n\
echo "  cargo: $(cargo --version)"\n\
echo ""\n\
echo "Development Tools (via mise):"\n\
echo "  Run: mise install    # Install Claude Code, GitHub CLI, opencode"\n\
echo "  Run: mise run info   # Show mise tool info"\n\
echo ""\n\
exec "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
