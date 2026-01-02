# Modular Development Environment Flakes

A composable, language-organized NixOS flake system for development environments. Converted from Ansible playbook to provide declarative, reproducible system configuration.

## Overview

This repository provides modular NixOS flakes organized by language and task groups. Mix and match only what you need for your development workflow.

### Key Features

- **Modular Architecture**: Independent flakes for each language/tool
- **Composable**: Mix and match components as needed
- **Reproducible**: Declarative configuration with locked dependencies
- **Version Controlled**: All configuration in Git
- **Rollback Support**: NixOS atomic upgrades and rollbacks

## Structure

```
.
├── flake.nix                    # Main orchestrator
├── base/                        # Base system config (locale, env)
├── languages/                   # Language-specific flakes
│   ├── javascript/             # Node.js 22, npm, pnpm, yarn, Bun, TypeScript
│   ├── python/                 # Python 3, pip, uv, dev packages
│   ├── rust/                   # Rust, cargo, clippy, rustfmt
│   ├── go/                     # Go compiler and tools
│   ├── ruby/                   # Ruby and dev tools
│   ├── java/                   # JDK, Maven, Gradle
│   └── cpp/                    # gcc, clang, cmake, ninja
├── tools/                      # Tool-specific flakes
│   ├── version-control/        # Git, Git LFS, GitHub CLI
│   ├── databases/              # PostgreSQL, Redis, SQLite clients
│   ├── utilities/              # jq, vim, tmux, ripgrep, fd, etc.
│   ├── build-essentials/       # Build tools, dev libraries
│   ├── mise/                   # mise - polyglot runtime manager
│   └── ai-dev/                 # AI tool configuration (uses mise)
└── services/                   # System services
    └── networking/             # Tailscale VPN
```

## Quick Start

### Prerequisites

- NixOS system (for full system configuration)
- Or: `nix` package manager installed (for devShells)
- Flakes enabled in your Nix configuration

### Enable Flakes

Add to `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Then rebuild: `sudo nixos-rebuild switch`

## Usage

### 1. Pre-built Stacks

Use predefined configurations for common use cases:

```bash
# Full environment (all languages and tools)
sudo nixos-rebuild switch --flake .#full

# JavaScript/TypeScript stack
sudo nixos-rebuild switch --flake .#javascript-stack

# Python data science stack
sudo nixos-rebuild switch --flake .#python-stack

# Systems programming (Rust + C/C++)
sudo nixos-rebuild switch --flake .#systems-stack

# Backend/infrastructure stack (Python, Go, Rust, databases)
sudo nixos-rebuild switch --flake .#backend-stack

# Minimal stack (essential tools only)
sudo nixos-rebuild switch --flake .#minimal-stack
```

### 2. Custom Composition

Create your own `configuration.nix` and import only what you need:

```nix
{
  description = "My Custom Dev Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dev-env.url = "github:yourname/agents-dev-env";  # Or local path
  };

  outputs = { self, nixpkgs, dev-env, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Pick only what you need
        dev-env.nixosModules.base
        dev-env.nixosModules.javascript
        dev-env.nixosModules.python
        dev-env.nixosModules.version-control
        dev-env.nixosModules.utilities

        # Your custom config
        ./configuration.nix
      ];
    };
  };
}
```

### 3. Development Shells

Use individual flakes as development environments without system installation:

```bash
# Enter JavaScript dev shell
nix develop ./languages/javascript

# Enter Python dev shell
nix develop ./languages/python

# Enter Rust dev shell
nix develop ./languages/rust

# Enter utilities shell
nix develop ./tools/utilities
```

### 4. Individual Module Usage

Import individual modules in your existing NixOS configuration:

```nix
# In your configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    /path/to/agents-dev-env/languages/javascript/flake.nix
    /path/to/agents-dev-env/tools/version-control/flake.nix
  ];
}
```

## Available Modules

### Languages

| Module | Description | Key Packages |
|--------|-------------|--------------|
| `javascript` | JavaScript/TypeScript | Node.js 22, npm, pnpm, yarn, Bun, TypeScript, ESLint |
| `python` | Python development | Python 3, pip, uv, PyYAML, Jinja2, requests |
| `rust` | Rust development | rustup, cargo, clippy, rustfmt |
| `go` | Go development | Go compiler, gopls, delve |
| `ruby` | Ruby development | Ruby 3.3, bundler, rake |
| `java` | Java development | JDK, Maven, Gradle |
| `cpp` | C/C++ development | gcc, clang, cmake, ninja, gdb |

### Tools

| Module | Description | Key Packages |
|--------|-------------|--------------|
| `version-control` | Version control | Git, Git LFS, GitHub CLI |
| `databases` | Database clients | PostgreSQL, Redis, SQLite, pgcli |
| `utilities` | System utilities | jq, vim, tmux, ripgrep, fd, bat |
| `build-essentials` | Build libraries | OpenSSL, zlib, dev headers, pkg-config |
| `mise` | Runtime manager | mise - polyglot tool version manager |
| `ai-dev` | AI coding tools | Configures mise for AI agents (claude, aider, etc.) |

### Services

| Module | Description | Configuration |
|--------|-------------|---------------|
| `networking` | Tailscale VPN | `services.tailscale.enable = true` |

## Configuration Examples

### Secrets Management

For sensitive data (Tailscale auth key, GitHub tokens, SSH keys), use:

**Option 1: sops-nix**
```nix
{
  imports = [ <sops-nix/modules/sops> ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.tailscale-key = {};

  # Use in Tailscale config
  systemd.services.tailscale-auth = {
    after = [ "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.tailscale}/bin/tailscale up --authkey=$(cat ${config.sops.secrets.tailscale-key.path})
    '';
  };
}
```

**Option 2: Environment Variables**
```bash
# Pass at deployment time
nixos-rebuild switch --flake .#my-config --build-host root@server \
  --option extra-substituters "ssh://root@server" \
  --option extra-trusted-public-keys "server-key"
```

### Git Configuration

Override Git settings in your configuration:

```nix
{
  imports = [ dev-env.nixosModules.version-control ];

  programs.git = {
    config = {
      user.name = "Your Name";
      user.email = "your.email@example.com";
    };
  };
}
```

### Using mise and AI Development Tools

The `mise` module installs the mise runtime manager, while `ai-dev` configures it for AI coding tools:

```nix
{
  # Option 1: Just mise (manual configuration)
  imports = [ dev-env.nixosModules.mise ];

  # Option 2: mise + AI tools pre-configured
  imports = [ dev-env.nixosModules.ai-dev ];  # Automatically includes mise
}
```

**Configure AI tools** in `/etc/mise/config.toml`:

```toml
[tools]
# Uncomment to install AI coding agents
# aider = "latest"
# claude = "latest"

# Or override system tools with specific versions
# python = "3.12"
# node = "22"

[settings]
experimental = true
```

**Install configured tools**:

```bash
# Install all tools from config
sudo mise install

# Or install specific tool
sudo mise install aider@latest
```

**Note**: AI tools installed via mise are NOT managed by Nix and won't be in your flake.lock. This is intentional - AI tools update frequently and you want the latest versions.

### Custom Package Versions

Override package versions:

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      nodejs = prev.nodejs_20;  # Use Node 20 instead of 22
    })
  ];
}
```

## Deployment

### Local NixOS System

```bash
# Clone repository
git clone https://github.com/yourname/agents-dev-env.git
cd agents-dev-env

# Test configuration
sudo nixos-rebuild test --flake .#full

# Apply permanently
sudo nixos-rebuild switch --flake .#full
```

### Remote Deployment

```bash
# Deploy to remote server
nixos-rebuild switch --flake .#full \
  --target-host root@server.example.com \
  --build-host root@server.example.com
```

### CI/CD Integration

```yaml
# Example GitHub Actions workflow
name: Deploy NixOS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      - name: Deploy
        run: |
          nixos-rebuild switch --flake .#full \
            --target-host root@${{ secrets.SERVER_HOST }}
```

## Verification

After deployment, verify your environment:

```bash
# Run the check-versions script
check-versions

# Output shows installed versions:
# ===========================================
#             Dev Environment
# ===========================================
#
# System:
#   OS:      NixOS
#   Kernel:  6.x.x
#   Arch:    x86_64
#
# Languages:
#   Python:  3.12.x
#   Node.js: v22.x.x
#   Go:      go1.22.x
#   ...
```

## Updating

### Update All Flakes

```bash
# Update all inputs
nix flake update

# Apply updates
sudo nixos-rebuild switch --flake .#full
```

### Update Specific Input

```bash
# Update only nixpkgs
nix flake lock --update-input nixpkgs

# Rebuild
sudo nixos-rebuild switch --flake .#full
```

## Rollback

If something breaks, rollback to previous generation:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous
sudo nixos-rebuild switch --rollback

# Or rollback to specific generation
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Comparison with Ansible

### Ansible (Previous)
- Imperative approach
- State drift over time
- Difficult rollbacks
- Manual dependency management

### NixOS Flakes (Current)
- Declarative configuration
- Reproducible builds
- Atomic upgrades with rollback
- Automatic dependency management
- Versioned configuration

## Migration from Ansible

See `playbook.yml` for the original Ansible configuration. Key mappings:

| Ansible | NixOS |
|---------|-------|
| `apt install` | `environment.systemPackages` |
| `service: enabled` | `services.<name>.enable = true` |
| `copy: dest=/path` | `environment.etc."path".text = "..."` |
| `shell: cmd` | `system.activationScripts` |
| `lineinfile` | `environment.variables` or `programs.<name>.config` |

## Troubleshooting

### Flake Not Found

Ensure you've committed the flake files to git:

```bash
git add .
git commit -m "Add flakes"
```

Nix flakes require files to be tracked in git.

### Missing Packages

Some packages from the Ansible playbook may have different names in nixpkgs:

```bash
# Search for packages
nix search nixpkgs <package-name>
```

### Build Failures

Check the build log:

```bash
sudo nixos-rebuild switch --flake .#full --show-trace
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `nix flake check`
5. Submit a pull request

## License

See `LICENSE` file.

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Moving from Ansible to NixOS](https://discourse.nixos.org/t/moving-from-ansible-to-nixos-side-by-side-snippets/36205)
