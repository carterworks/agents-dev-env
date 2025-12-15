# Development Environment Specification

This document describes the complete development environment configuration for this project.

## Base System

- **OS**: Ubuntu 24.04.3 LTS (Noble Numbat)
- **Architecture**: x86_64 (64-bit)
- **Deployment**: Docker container
- **Shell**: GNU Bash 5.2.21

## Programming Languages

### Python
- **Version**: 3.11.14
- **Package Managers**:
  - pip 24.0, pip3
  - uv (fast Python package installer and resolver)
- **Installation**: Via apt-get and official uv installer

### Node.js & JavaScript
- **Node.js**: v22.21.1 (via NodeSource repository)
- **Package Managers**:
  - npm 10.9.4 (bundled with Node.js)
  - pnpm 10.25.0 (global npm package)
  - yarn 1.22.22 (global npm package)
  - bun 1.3.4 (via official installer)

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
- **Installation**: Official tarball from go.dev
- **GOPATH**: `/root/go`

### Rust
- **Version**: 1.91.1
- **Installation**: Via rustup official installer
- **Package Manager**: cargo

### Java
- **Version**: OpenJDK 21.0.9
- **Installation**: Via apt-get (openjdk-21-jdk)
- **JAVA_HOME**: `/usr/lib/jvm/java-21-openjdk-amd64`

### PHP
- **Version**: 8.3 (cli)
- **Installation**: Via apt-get
- **Extensions**: curl, mbstring, xml

### Ruby
- **Version**: 3.3.6
- **Installation**: Via apt-get (ruby-full)

### Perl
- **Version**: 5.38.2
- **Installation**: Included in Ubuntu base image

## Build Tools & Compilers

### C/C++ Toolchain
- **GCC**: 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04) - set as default
- **Clang**: 18.1.3
- **Make**: GNU Make 4.3
- **CMake**: 3.28.3
- **Ninja**: Available via apt-get

### System Libraries (Development Headers)
- libssl-dev 3.0.13-0ubuntu3.6
- zlib1g-dev 1:1.3.dfsg-3.1ubuntu2.1
- libffi-dev 3.4.6-1build1
- libsqlite3-dev 3.45.1-1ubuntu2.5
- libcurl4-openssl-dev

## Databases

### PostgreSQL
- **Client Version**: 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
- **Installation**: Via apt-get (postgresql-client-16)

### Redis
- **Client Version**: 7.0.15
- **Installation**: Via apt-get (redis-tools)

### SQLite
- **Version**: 3.45.1 (library only)

## Version Control & Utilities

- **Git**: 2.43.0
- **curl**: Installed
- **wget**: Installed
- **jq**: Installed (JSON processor)
- **vim**: Installed
- **tmux**: Installed
- **Standard Ubuntu tools**: All available

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

## Installation Paths

- **Node.js**: Managed by NodeSource repository
- **Rust/Cargo**: `/root/.cargo/bin/`
- **Bun**: `/root/.bun/bin/` (symlinked to `/usr/local/bin/bun`)
- **Go**: `/usr/local/go/bin/`
- **mise**: `/root/.local/bin/`
- **uv**: `/root/.cargo/bin/`

## Environment Setup

### Docker Build

Build the Docker image:
```bash
docker build -t dev-env .
```

### Running the Environment

```bash
# Interactive mode
docker run -it -v $(pwd):/workspace dev-env

# Background mode
docker run -d --name dev-env-container -v $(pwd):/workspace dev-env
docker exec -it dev-env-container /bin/bash
```

### Installing mise Tools

Once inside the container:
```bash
mise install          # Install Claude Code, GitHub CLI, opencode
mise run info         # Show tool information
```

## Architecture Decisions

### Why Ubuntu 24.04 LTS?

- **Familiar**: Most developers know Ubuntu
- **Stable**: LTS release with 5 years of support
- **Compatible**: Standard Linux paths and tools
- **Portable**: Works the same everywhere with Docker
- **Flexible**: Easy to add packages via apt

### Why mise for Dev Tools?

- **Focused Use**: Only for frequently updated tools
- **Easy Updates**: `mise upgrade` keeps tools current
- **Separation of Concerns**: Languages in Docker, dev tools in mise
- **Optional**: Core environment works without mise

### Why Not Nix?

While Nix provides excellent reproducibility, it was removed because:
- Not familiar to most developers
- Non-standard filesystem paths
- Steeper learning curve
- Ubuntu + Docker provides sufficient portability
- mise handles the "frequently updated" use case well

## Notes

- This is a comprehensive development environment with support for multiple languages and frameworks
- The environment is optimized for web development, systems programming, and general-purpose software development
- All packages are installed via official sources (apt, official installers, npm global)
- Package versions are current as of December 2025
- The Docker image provides a consistent, portable environment
