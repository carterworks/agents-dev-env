# Development Environment Specification

This document describes the complete development environment configuration for this project.

## Base System

- **OS**: Ubuntu 24.04.3 LTS (Noble Numbat)
- **Architecture**: x86_64 (64-bit)
- **Kernel**: Linux 4.4.0
- **Shell**: GNU Bash 5.2.21

## Programming Languages

### Python
- **Version**: 3.11.14
- **Package Managers**:
  - pip 24.0, pip3
  - uv (fast Python package installer and resolver, via Nix)
- **Key Packages**:
  - conan 2.23.0
  - PyYAML 6.0.1
  - Jinja2 3.1.6
  - requests 2.32.5
  - cryptography 41.0.7

### Node.js & JavaScript
- **Node.js**: v22.21.1
- **npm**: 10.9.4
- **pnpm**: 10.25.0
- **yarn**: 1.22.22
- **bun**: 1.3.4

**Global npm packages**:
- TypeScript 5.9.3
- ESLint 9.39.1
- Prettier 3.7.4
- ts-node 10.9.2
- nodemon 3.1.11
- playwright 1.56.1
- http-server 14.1.1
- serve 14.2.5

### Go
- **Version**: 1.24.7 linux/amd64

### Rust
- **Version**: 1.91.1
- **Package Manager**: cargo (in /root/.cargo/bin/)

### Java
- **Version**: OpenJDK 21.0.9
- **Runtime**: OpenJDK Runtime Environment (build 21.0.9+10-Ubuntu-124.04)
- **JVM**: OpenJDK 64-Bit Server VM (mixed mode, sharing)

### PHP
- **Version**: 8.4.15 (cli) NTS
- **Extensions**: curl module available

### Ruby
- **Version**: 3.3.6 (2024-11-05)
- **Platform**: x86_64-linux

### Perl
- **Version**: 5.38.2
- **Platform**: x86_64-linux-gnu-thread-multi

## Build Tools & Compilers

### C/C++ Toolchain
- **GCC**: 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
- **Clang**: 18.1.3 (1ubuntu1)
- **Make**: GNU Make 4.3
- **CMake**: 3.28.3
- **Ninja**: Available

### System Libraries (Development Headers)
- libssl-dev 3.0.13-0ubuntu3.6
- libssl3t64 3.0.13-0ubuntu3.6
- zlib1g-dev 1:1.3.dfsg-3.1ubuntu2.1
- libffi-dev 3.4.6-1build1
- libsqlite3-dev 3.45.1-1ubuntu2.5

## Databases

### PostgreSQL
- **Client Version**: 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

### Redis
- **Client Version**: 7.0.15

### SQLite
- **Version**: 3.45.1

## Version Control & Tools

- **Git**: 2.43.0
- **build-essential**: Installed
- **curl**: Installed
- **wget**: Installed
- **jq**: Installed (JSON processor)
- **vim**: Installed
- **tmux**: Installed

## Frequently Updated Development Tools (via mise)

These tools are managed via mise for easy updates and version management:

- **Claude Code** (`@anthropic-ai/claude-code`): Anthropic's official CLI for Claude AI
- **GitHub CLI** (`gh`): GitHub's official command-line tool (includes Copilot CLI extensions)
- **opencode** (`github.com/sst/opencode`): SST's code generation tool

To install these tools, run:
```bash
mise install
```

To update to the latest versions:
```bash
mise upgrade
```

## Notable Absences

The following common tools are **NOT** installed in the base environment (but can be added via mise):
- Docker
- kubectl
- terraform
- ansible
- ffmpeg
- ImageMagick
- sqlite3 CLI (library only)
- mysql/mongosh clients

## Package Installation Paths

- Node.js: `/opt/node22/`
- Rust cargo: `/root/.cargo/bin/`
- Bun: `/root/.bun/bin/`

## Recommendations for Replication

### Using Nix Flake (Primary)
Use the provided `flake.nix` to set up the core development environment with reproducible package versions.

### Using mise (Incidentals & Frequently Updated Tools)
Use the provided `.mise.toml` for:
- Language version management
- Project-specific tool versions
- Frequently updated development tools (Claude Code, GitHub CLI, opencode)
- Additional utilities not critical to core functionality

### Using Docker
Build a Docker image using Nix for maximum reproducibility:
```bash
nix build .#dockerImage
docker load < result
```

The Docker image is built with `dockerTools.buildLayeredImage`, providing:
- Byte-for-byte reproducible builds
- Optimal layer caching
- Same package definitions as the dev shell
- Smaller image sizes compared to traditional Dockerfile builds

A traditional `Dockerfile.reference` is available for reference, but the Nix build is recommended.

## Notes

- This is a comprehensive development environment with support for multiple languages and frameworks
- The environment appears to be optimized for web development, systems programming, and general-purpose software development
- Package versions are current as of December 2025
