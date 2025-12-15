# Development Environment

A comprehensive, portable development environment based on Ubuntu 24.04 LTS with support for multiple programming languages and modern development tools.

## Overview

This repository provides a Docker-based development environment that includes:

- **Ubuntu 24.04 LTS** - Familiar, stable Linux base
- **Multiple Languages** - Python, Node.js, Go, Rust, Java, PHP, Ruby, Perl
- **mise** - For frequently updated development tools (Claude Code, GitHub CLI, opencode)
- **Build Tools** - GCC, Clang, CMake, Make, Ninja
- **Databases** - PostgreSQL and Redis clients

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)

### Build and Run

```bash
# Build the Docker image
docker build -t dev-env .

# Run interactively with current directory mounted
docker run -it -v $(pwd):/workspace dev-env

# Or run in background
docker run -d --name dev-env-container -v $(pwd):/workspace dev-env
docker exec -it dev-env-container /bin/bash
```

### Install Development Tools

Once inside the container:

```bash
# Install mise-managed tools (Claude Code, GitHub CLI, opencode)
mise install

# Show information about installed tools
mise run info
```

## What's Included

### Programming Languages

- **Python 3.11** with pip and uv (fast package installer)
- **Node.js 22** with npm, pnpm, yarn, and bun
- **Go 1.24**
- **Rust 1.91**
- **Java 21** (OpenJDK)
- **PHP 8.3**
- **Ruby 3.3**
- **Perl 5.38**

### Build Tools & Compilers

- GCC 13
- Clang 18
- CMake 3.28
- Make 4.3
- Ninja

### Development Tools (via mise)

- **Claude Code** - Anthropic's official CLI for Claude AI
- **GitHub CLI (gh)** - GitHub's official command-line tool with Copilot extensions
- **opencode** - SST's code generation tool

### Database Clients

- PostgreSQL 16 client
- Redis 7 client

### Utilities

- Git, curl, wget, jq
- vim, tmux
- Standard Ubuntu tools

## File Descriptions

| File | Purpose |
|------|---------|
| `Dockerfile` | Ubuntu 24.04-based container with all development tools |
| `.mise.toml` | Configuration for frequently updated development tools |
| `ENVIRONMENT.md` | Complete environment specification and package list |
| `README.md` | This file - usage instructions |
| `.gitignore` | Standard ignore patterns for development artifacts |

## Common Tasks

### Installing Additional Tools with mise

```bash
# Edit .mise.toml and add tool
# Then install
mise install
```

### Managing Language Versions

Language versions are baked into the Docker image. To change versions:

```bash
# Edit Dockerfile and change version numbers
# Example: nodejs_22 -> nodejs_20
# Then rebuild
docker build -t dev-env .
```

### Running Project Tasks

mise provides task automation:

```bash
# Show information about mise-managed tools
mise run info
```

### Adding apt Packages

```bash
# Inside the container
apt-get update
apt-get install <package-name>

# Or add to Dockerfile for permanent installation
```

## Troubleshooting

### Docker Issues

```bash
# Clean build (no cache)
docker build --no-cache -t dev-env .

# Check container logs
docker logs dev-env-container

# Remove all containers and rebuild
docker rm -f dev-env-container
docker build -t dev-env .
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

## Environment Details

See [ENVIRONMENT.md](./ENVIRONMENT.md) for complete specifications including:
- Exact package versions
- Installed libraries
- Programming language versions
- Build tools and compilers

### Core Components

- **OS**: Ubuntu 24.04 LTS
- **Languages**: Python 3.11, Node.js 22, Go 1.24, Rust 1.91, Java 21, PHP 8.3, Ruby 3.3, Perl 5.38
- **Build Tools**: GCC 13, Clang 18, CMake 3.28, Make 4.3
- **Databases**: PostgreSQL 16 client, Redis 7 client
- **Development Tools** (via mise): Claude Code, GitHub CLI, opencode

## Architecture Philosophy

This environment prioritizes:

1. **Portability** - Standard Ubuntu base that everyone understands
2. **Familiarity** - Traditional Linux filesystem and tools
3. **Flexibility** - Easy to add packages via apt or language package managers
4. **Separation of Concerns** - mise only for frequently updated dev tools

The Docker image provides a complete, consistent development environment that can be easily shared across teams and works identically on any system with Docker installed.

## Additional Resources

- [mise Documentation](https://mise.jdx.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Ubuntu Packages](https://packages.ubuntu.com/)

## License

These configuration files are provided as-is for environment replication purposes.
