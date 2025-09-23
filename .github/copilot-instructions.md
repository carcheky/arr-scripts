# Arr-Scripts Repository Instructions

**Always follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## About this Repository

This repository contains bash scripts designed to extend Arr applications (Lidarr, Radarr, Sonarr, Readarr, SABnzbd) within Linuxserver.io containers. It is a fork of RandomNinjaAtk/arr-scripts with all references updated to carcheky/arr-scripts..

## Working Effectively

### Repository Structure
- **Application folders**: `/lidarr/`, `/radarr/`, `/sonarr/`, `/readarr/`, `/sabnzbd/`, `/ra-rom-downloader/`
- **Universal components**: `/universal/` contains shared functions and services
- **Setup mechanism**: Each app has a `setup.bash` script and `scripts_init.bash` bootstrap script
- **Services**: Background services that run at intervals (QueueCleaner, AutoConfig, etc.)
- **Configuration**: `extended.conf` files contain user-configurable settings

### No Traditional Build System
**CRITICAL**: This repository does NOT have a traditional build system like make, npm, or maven. Scripts are deployed directly to Docker containers via curl downloads from GitHub raw URLs.

### Validation Commands
Always run these commands to validate changes:
- `bash -n <script>.bash` - Validate bash syntax for any script you modify
- `./check_repo_references.bash` - Check for repository reference consistency
- Test script downloads: `curl -sfL https://raw.githubusercontent.com/carcheky/arr-scripts/main/<path>/<script> -o /tmp/test.bash`

### Key Script Testing
Test critical scripts by validating their syntax and download capability:
```bash
# Validate setup scripts
bash -n lidarr/setup.bash
bash -n radarr/setup.bash
bash -n sonarr/setup.bash
bash -n readarr/setup.bash
bash -n sabnzbd/setup.bash

# Test service script syntax
find . -name "*.service*" -exec bash -n {} \;

# Test repository reference checker
./check_repo_references.bash --help
./check_repo_references.bash

# Test script downloads (2-5 seconds each)
curl -sfL https://raw.githubusercontent.com/carcheky/arr-scripts/main/universal/functions.bash -o /tmp/test-functions.bash
curl -sfL https://raw.githubusercontent.com/carcheky/arr-scripts/main/universal/services/QueueCleaner -o /tmp/test-service.bash
```

## Timing Expectations

**NEVER CANCEL any operation below - Set appropriate timeouts:**

### Package Installation Operations
- **apk add** commands: 30-120 seconds each. NEVER CANCEL. Set timeout to 180+ seconds.
- **pip install** commands: 30-300 seconds depending on packages. NEVER CANCEL. Set timeout to 600+ seconds.
- **npm install -g** commands: 60-180 seconds. NEVER CANCEL. Set timeout to 300+ seconds.
- **git clone** operations: 5-30 seconds. Set timeout to 60+ seconds.

### Full Setup Script Execution
The setup scripts install many packages and would take considerable time in a real container environment:
- **Each setup.bash**: Would take 5-15 minutes in real Alpine container. NEVER CANCEL.
- **Total package count**: 23+ package installation commands across all scripts.

### Script Downloads and Validation
- **Individual script downloads**: 0.1-0.5 seconds each
- **Syntax validation**: Nearly instantaneous (<0.01s)
- **Repository reference check**: 1-3 seconds for full repository scan

## Manual Validation Requirements

### After Making Script Changes
Always test these scenarios after modifying scripts:

1. **Syntax Validation**: Run `bash -n` on every modified script file
2. **Download Test**: Test that modified scripts can be downloaded via curl from GitHub raw URLs
3. **Reference Consistency**: Run `./check_repo_references.bash` to ensure no broken references
4. **Service Dependencies**: If modifying service scripts, verify they can source `/config/extended.conf` and `/config/extended/functions`

### Functional Testing Scenarios
Since these scripts run inside Docker containers with specific dependencies, full functional testing requires:
- Alpine Linux container environment with `with-contenv` support
- Arr application installation and configuration
- Required system packages (jq, curl, wget, git, python3, etc.)

**Cannot perform full functional testing in this environment**, but always validate:
- Script syntax is correct
- Download URLs are accessible  
- Repository references are consistent
- Configuration file formats are valid

## Repository Reference Management

Use the provided repository reference checker:
```bash
# Check for inconsistent references
./check_repo_references.bash

# Fix references automatically (with confirmation)
./check_repo_references.bash --fix
```

This script ensures all references point to `carcheky/arr-scripts` instead of the original `RandomNinjaAtk/arr-scripts`.

## Common File Locations

### Scripts
- Bootstrap scripts: `*/scripts_init.bash`
- Setup scripts: `*/setup.bash` 
- Service scripts: `*/AutoConfig.service*`, `*/Video.service*`, etc.
- Universal services: `universal/services/QueueCleaner`
- Shared functions: `universal/functions.bash`

### Configuration
- User configs: `*/extended.conf`
- App-specific configs: `*/AutoConfig.json`, `*/recyclarr.yaml`, etc.
- Documentation: `*/readme.md`

### Key Script Components
Always check these when working on scripts:
- **Shebang**: Must be `#!/usr/bin/with-contenv bash` for service scripts
- **Error handling**: Most scripts use `set -euo pipefail`
- **Logging**: Scripts use shared logging functions from `universal/functions.bash`
- **Configuration**: Scripts source `/config/extended.conf` for settings

## Script Deployment Method

Scripts are deployed to containers via:
1. User downloads `scripts_init.bash` to `/custom-cont-init.d`
2. Container startup runs `scripts_init.bash` which downloads `setup.bash`
3. `setup.bash` installs packages and downloads service scripts to `/custom-services.d`
4. Service scripts run at configured intervals within the container

## Critical Validation Commands

Before committing changes, always run:
```bash
# Validate all bash scripts
find . -name "*.bash" -exec bash -n {} \;
find . -name "*.service*" -exec bash -n {} \;

# Check repository references
./check_repo_references.bash

# Test key download URLs
curl -s -I https://raw.githubusercontent.com/carcheky/arr-scripts/main/lidarr/setup.bash
curl -s -I https://raw.githubusercontent.com/carcheky/arr-scripts/main/universal/functions.bash
```

All validation commands should complete successfully before changes are committed.