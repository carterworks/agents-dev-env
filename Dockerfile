# Development Environment Dockerfile
# Layered approach: Ubuntu 24.04 → Nix → mise
# This provides a modern, reproducible development environment

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install minimal dependencies for Nix and development
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    xz-utils \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Nix package manager with flakes support
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes || \
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes

# Configure Nix to enable flakes and the nix command
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Set up Nix environment for root user
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
ENV NIX_PROFILES="/nix/var/nix/profiles/default /root/.nix-profile"
ENV NIX_PATH="/root/.nix-defexpr/channels"

# Source Nix profile in future shell sessions
RUN echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc

# Copy flake configuration
COPY flake.nix /workspace/flake.nix

# Set working directory
WORKDIR /workspace

# Build and activate the Nix development environment
# This installs all languages, build tools, and dependencies defined in flake.nix
RUN . /root/.nix-profile/etc/profile.d/nix.sh && \
    nix develop --command echo "Nix environment built successfully"

# Install mise for runtime version management and additional tools
RUN curl https://mise.jdx.dev/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Copy mise configuration
COPY .mise.toml /workspace/.mise.toml

# Activate mise and install tools
RUN echo 'eval "$(mise activate bash)"' >> /root/.bashrc

# Install mise-managed tools (this happens when mise.toml is present)
# Users can run `mise install` or `mise run setup` to install additional tools

# Create a startup script that enters the Nix development shell
RUN echo '#!/bin/bash\n\
# Source Nix profile\n\
if [ -f /root/.nix-profile/etc/profile.d/nix.sh ]; then\n\
    . /root/.nix-profile/etc/profile.d/nix.sh\n\
fi\n\
\n\
# Activate mise\n\
if command -v mise &> /dev/null; then\n\
    eval "$(mise activate bash)"\n\
fi\n\
\n\
echo "Development Environment Ready!"\n\
echo "================================"\n\
echo ""\n\
echo "This environment uses:"\n\
echo "  • Ubuntu 24.04 (base OS)"\n\
echo "  • Nix (reproducible package management)"\n\
echo "  • mise (runtime version management)"\n\
echo ""\n\
echo "To see available tools:"\n\
echo "  nix develop --command bash  # Enter Nix shell"\n\
echo "  mise list                   # Show mise-managed tools"\n\
echo "  mise run info               # Display environment info"\n\
echo ""\n\
echo "To install additional tools:"\n\
echo "  Edit .mise.toml and run: mise install"\n\
echo ""\n\
\n\
# Enter Nix development shell if available\n\
if [ -f /workspace/flake.nix ]; then\n\
    exec nix develop --command "$@"\n\
else\n\
    exec "$@"\n\
fi\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
