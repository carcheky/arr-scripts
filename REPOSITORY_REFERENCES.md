# Repository Reference Checker

This script helps identify and fix references to the original `RandomNinjaAtk/arr-scripts` repository and update them to point to this repository (`carcheky/arr-scripts`).

## Usage

```bash
# Check for references (no changes made)
./check_repo_references.bash

# Automatically fix references with confirmation
./check_repo_references.bash --fix

# Show help
./check_repo_references.bash --help
```

## What it does

1. **Scans** all relevant files (.md, .txt, .sh, .bash, .py, .json, .yml, .yaml, .conf) for references to `RandomNinjaAtk/arr-scripts`
2. **Reports** where these references are found with line numbers
3. **Can automatically fix** most references while being smart about:
   - Skipping image URLs that point to other repositories (like `unraid-templates`, `docker-lidarr-extended`, `docker-amtd`)
   - Creating backups before making changes
   - Providing a summary of changes made

## When to use

Run this script:
- After forking the repository to identify references that need updating
- Periodically to ensure no new references to the original repository have been introduced
- Before major releases to ensure all documentation points to the correct repository

## What gets updated

- GitHub links in documentation
- Download URLs in setup scripts  
- Repository references in configuration files
- Links in README files

## What doesn't get updated

- Image URLs pointing to other repositories (these often still work and don't need changing)
- References in comments that are meant to credit the original work
- External links that are not repository-specific

## Safety features

- Creates timestamped backups in `.repo_reference_backup_*` directories
- Shows exactly what will be changed before making changes
- Asks for confirmation before proceeding with fixes
- Provides detailed summary of changes made