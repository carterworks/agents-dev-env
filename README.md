# Development Environment Replication

This repository contains configuration files to replicate a comprehensive development environment supporting multiple programming languages and tools.

## Overview

Three approaches are provided for environment replication:

1. **Nix Flake** (Recommended) - Declarative, reproducible environment
2. **Docker** - Layered container (Ubuntu → Nix → mise) for isolated development
3. **mise** - Runtime version management and tooling

You can use them independently or combine them (e.g., Nix + mise for best of both worlds).

### Architecture Philosophy

This repository follows a **layered architecture**:
- **Base Layer (Ubuntu 24.04)**: Modern, stable Linux distribution
- **Package Management (Nix)**: Reproducible, declarative package installation
- **Runtime Management (mise)**: Flexible version management for project-specific needs

The Docker image uses all three layers, while you can use Nix or mise independently on your local machine.

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
- Build tools (GCC, Clang, CMake, Make, Ninja)
- Development utilities (Git, curl, wget, jq, vim, tmux)
- Database clients (PostgreSQL, Redis)
- System libraries with dev headers

### Option 2: Using Docker (Layered Architecture)

**Prerequisites**: [Install Docker](https://docs.docker.com/get-docker/)

The Dockerfile uses a **layered approach**:
1. **Ubuntu 24.04** as the base OS
2. **Nix** for reproducible package management
3. **mise** for flexible runtime version management

```bash
# Build the image (this will take a few minutes on first build)
docker build -t dev-env .

# Run interactively with current directory mounted
docker run -it -v $(pwd):/workspace dev-env

# Or run in background for long-running tasks
docker run -d --name dev-env-container -v $(pwd):/workspace dev-env
docker exec -it dev-env-container /bin/bash
```

**Advantages of this approach:**
- **Reproducible**: Nix ensures consistent package versions
- **Flexible**: mise allows easy runtime version switching
- **Maintainable**: Changes to flake.nix or .mise.toml automatically update the Docker image
- **Isolated**: Full environment in a container, won't affect your host system

### Option 3: Using mise

**Prerequisites**: [Install mise](https://mise.jdx.dev/getting-started.html)

```bash
# Install mise (if not already installed)
curl https://mise.jdx.dev/install.sh | sh

# Activate mise in your shell (add to ~/.bashrc or ~/.zshrc)
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Install all tools defined in .mise.toml
# This includes: language runtimes, Claude Code, GitHub CLI, and opencode
mise install

# Run setup tasks (install Python packages, npm globals, etc.)
mise run setup

# Show environment info
mise run info
```

**Tools managed by mise:**
- All language runtimes (Python, Node.js, Go, Rust, Java, Ruby)
- **Claude Code** - Anthropic's official CLI for Claude AI
- **GitHub CLI** - GitHub's official command-line tool
- **opencode** - SST's code generation tool

## Hybrid Approach: Nix + mise (Best of Both Worlds)

For maximum flexibility and reproducibility:

```bash
# 1. Use Nix for core system packages and compilers
nix develop

# 2. Use mise for language runtime versions and additional tools
mise install
mise run setup

# 3. Your environment is now fully configured!
```

This approach gives you:
- Nix: Reproducible base system and libraries
- mise: Easy version management and project-specific tools

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
| `flake.nix` | Nix flake for reproducible environment setup |
| `Dockerfile` | Layered container image (Ubuntu → Nix → mise) |
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
# Option 1: Edit flake.nix (for system packages)
# or .mise.toml (for runtime tools)
# Then rebuild the image
docker build -t dev-env .

# Option 2: Install tools directly in running container
docker exec -it dev-env-container nix-env -iA nixpkgs.package-name
# or
docker exec -it dev-env-container mise use tool@version
```

### Managing Language Versions

**mise** is the best tool for this:
```bash
# Change version in .mise.toml
# Example: node = "20.11.0"
mise install
```

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
# Clean build (no cache)
docker build --no-cache -t dev-env .

# Check container logs
docker logs dev-env-container
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
