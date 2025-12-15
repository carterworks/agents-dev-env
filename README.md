# Development Environment Replication

This repository contains configuration files to replicate a comprehensive development environment supporting multiple programming languages and tools.

## Overview

Three approaches are provided for environment replication:

1. **Nix Flake** (Recommended) - Declarative, reproducible environment
2. **Docker** - Nix-built container image for isolated development
3. **mise** - Runtime version management and tooling

You can use them independently or combine them (e.g., Nix + mise for best of both worlds).

### Architecture Philosophy

This repository uses **Nix** as the foundation for reproducibility:
- **Nix Flake**: Declarative package management with exact version pinning
- **Development Shell**: Interactive development with `nix develop`
- **Docker Image**: Nix-built container using `dockerTools.buildLayeredImage`
- **mise Integration**: Optional runtime version management for frequently updated tools

All approaches are built on the same Nix package definitions, ensuring consistency across local development, CI/CD, and containerized environments.

## Quick Start

### Option 1: Using Nix Flake (Recommended)

**Prerequisites**: [Install Nix](https://nixos.org/download.html) with flakes enabled.

```bash
# Enable flakes (if not already enabled)
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Enter the development environment
nix develop

# Or use direnv for automatic activation
echo "use flake" > .envrc
direnv allow
```

The Nix environment includes:
- All major programming languages (Python, Node.js, Go, Rust, Java, PHP, Ruby, Perl)
- Python tooling: uv (fast package installer and resolver)
- Build tools (GCC, Clang, CMake, Make, Ninja)
- Development utilities (Git, curl, wget, jq, vim, tmux)
- Database clients (PostgreSQL, Redis)
- System libraries with dev headers

### Option 2: Using Docker (Nix-Built Image)

**Prerequisites**:
- [Install Nix](https://nixos.org/download.html) with flakes enabled
- [Install Docker](https://docs.docker.com/get-docker/)

The Docker image is built entirely with Nix for maximum reproducibility:

```bash
# Build the Docker image with Nix
nix build .#dockerImage

# Load the image into Docker
docker load < result

# Run interactively with current directory mounted
docker run -it -v $(pwd):/workspace dev-env:latest

# Or run in background for long-running tasks
docker run -d --name dev-env-container -v $(pwd):/workspace dev-env:latest
docker exec -it dev-env-container /bin/bash
```

**Advantages of this approach:**
- **Fully Reproducible**: Entire image built with Nix, byte-for-byte reproducible
- **Efficient Layering**: Nix's buildLayeredImage creates optimal Docker layers
- **Smaller Images**: Better deduplication and compression
- **Consistent with Dev Shell**: Uses same package definitions as `nix develop`
- **mise Integration**: mise included for additional runtime version management
- **No Ubuntu Base**: Pure Nix environment, smaller attack surface

**Alternative: Quick build without Nix**

If you don't have Nix but want a Docker image, a traditional Dockerfile is available as `Dockerfile.reference`.

### Option 3: Using mise

**Prerequisites**: [Install mise](https://mise.jdx.dev/getting-started.html)

```bash
# Install mise (if not already installed)
curl https://mise.jdx.dev/install.sh | sh

# Activate mise in your shell (add to ~/.bashrc or ~/.zshrc)
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Install all tools defined in .mise.toml
# This includes: Claude Code, GitHub CLI, and opencode
mise install

# Show information about mise-managed tools
mise run info
```

**Tools managed by mise:**
- **Claude Code** - Anthropic's official CLI for Claude AI
- **GitHub CLI** - GitHub's official command-line tool (includes Copilot extensions)
- **opencode** - SST's code generation tool

*Note: Language runtimes (Python, Node.js, Go, Rust, Java, Ruby, etc.) are provided by Nix, not mise.*

## Hybrid Approach: Nix + mise (Recommended)

For maximum flexibility and reproducibility:

```bash
# 1. Use Nix for all system packages, compilers, and language runtimes
nix develop

# 2. Use mise for frequently updated development tools
mise install

# 3. Your environment is now fully configured!
```

This approach gives you:
- **Nix**: Reproducible base system, libraries, and language runtimes
- **mise**: Easy updates for frequently changing tools (Claude Code, GitHub CLI, opencode)

## Environment Details

See [ENVIRONMENT.md](./ENVIRONMENT.md) for complete specifications including:
- Exact package versions
- Installed libraries
- Programming language versions
- Build tools and compilers

### Core Components

- **OS**: Ubuntu 24.04.3 LTS
- **Languages**: Python 3.11, Node.js 22, Go 1.24, Rust 1.91, Java 21, PHP 8.4, Ruby 3.3, Perl 5.38
- **Build Tools**: GCC 13, Clang 18, CMake 3.28, Make 4.3
- **Databases**: PostgreSQL 16, Redis 7, SQLite 3.45
- **Development Tools** (via mise): Claude Code, GitHub CLI, opencode

## File Descriptions

| File | Purpose |
|------|---------|
| `flake.nix` | Nix flake for reproducible environment setup and Docker image build |
| `Dockerfile.reference` | Traditional Dockerfile (reference only, Nix build recommended) |
| `.mise.toml` | Runtime version management and task automation |
| `ENVIRONMENT.md` | Complete environment specification and package list |
| `README.md` | This file - usage instructions |
| `.gitignore` | Standard ignore patterns for development artifacts |

## Common Tasks

### Installing Additional Tools

**With Nix:**
```bash
# Edit flake.nix and add package to buildInputs
# Then rebuild the environment
nix develop
```

**With mise:**
```bash
# Edit .mise.toml and add tool
# Then install
mise install
```

**With Docker:**
```bash
# Option 1: Edit flake.nix (for system packages) or .mise.toml (for runtime tools)
# Then rebuild the image with Nix
nix build .#dockerImage
docker load < result

# Option 2: Install tools directly in running container with mise
docker exec -it dev-env-container mise use tool@version
```

### Managing Language Versions

Language versions are managed through **Nix**:
```bash
# Edit flake.nix and change package versions
# Example: nodejs_22 -> nodejs_20
# Then rebuild the environment
nix develop

# Or rebuild the Docker image
nix build .#dockerImage
docker load < result
```

**mise** is only used for frequently updated dev tools (Claude Code, GitHub CLI, opencode).

### Running Project Tasks

mise provides task automation:
```bash
# List available tasks
mise tasks

# Run a specific task
mise run install-python-packages
mise run install-global-npm
mise run setup
mise run info
```

## Troubleshooting

### Nix Flake Issues

```bash
# Update flake lock file
nix flake update

# Rebuild with verbose output
nix develop --verbose
```

### Docker Issues

```bash
# Rebuild Docker image with Nix
nix build .#dockerImage --rebuild

# Check if image loaded correctly
docker images | grep dev-env

# Check container logs
docker logs dev-env-container

# If using the reference Dockerfile
docker build -f Dockerfile.reference -t dev-env .
```

### mise Issues

```bash
# Check mise status
mise doctor

# Reinstall all tools
mise install --force

# Show debug information
mise --verbose install
```

## Contributing

To update the environment specification:

1. Modify the appropriate configuration file(s)
2. Test the changes
3. Update ENVIRONMENT.md with new package versions
4. Commit and push

## Additional Resources

- [Nix Package Search](https://search.nixos.org/packages)
- [mise Documentation](https://mise.jdx.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Ubuntu Packages](https://packages.ubuntu.com/)

## License

These configuration files are provided as-is for environment replication purposes.
