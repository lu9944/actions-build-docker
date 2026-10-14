# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitHub Actions workflow template** for pulling Docker images and saving them as downloadable TAR artifacts. It's not a traditional software project - it provides reusable workflow files that users copy to their own repositories.

## Architecture

The project consists of GitHub Actions workflow files in `.github/workflows/`:

### `pull-docker-image.yml` — Pull Docker Image and Save as TAR
- Pulls any Docker image (public or private)
- Saves as compressed TAR file; optional GitHub Release / FTP upload
- Optionally authenticates with `DOCKERHUB_TOKEN` for private images / higher rate limits

### `build-dockerfile.yml` — Build Dockerfile and Save as TAR
- Builds an image from a Dockerfile in this repo (inputs: `dockerfile_path`, `image_name`, `build_context`)
- Moves the Docker data-root to `/mnt` to work around runner disk limits
- Pushes to Docker Hub (optional visibility management), optionally exports TAR to Release / FTP

### `build-opencode-image.yml` — Build OpenCode Ubuntu Image
- Downloads the latest (or a pinned) release asset from the external repo `lu9944/offline-opencode-installer`,
  verifies SHA256, extracts it, and builds `examples/opencode/Dockerfile`
- The Dockerfile is multi-stage: stage 1 runs the offline package's `install.sh --system`
  (installs the official standalone OpenCode binary to `/usr/local/bin`, no Node.js needed);
  stage 2 installs Node.js 24 + the latest `@openchamber/web` (OpenChamber web workspace, port 3000),
  common network tools and vim, then copies only the OpenCode binaries
- `examples/opencode/docker-entrypoint.sh` is staged into the build context and installed as the
  image entrypoint: defaults to `0.0.0.0`, generates/persists the OpenChamber UI password, creates an
  SSH key on first start, and execs the given command (`opencode` for TUI, `bash`, `openchamber`, ...)
- CI smoke tests on the runner: tool versions, presence of network tools/vim, and a real
  OpenChamber server boot/HTTP check; then pushes to Docker Hub / optionally exports TAR

### `apt-packages-to-ftp.yml` — Extract APT Packages and Upload to FTP
- Builds a throwaway container from a base image, downloads apt/pip packages with all dependencies
- Packages them as `tar.gz` with an install script, uploads to FTP and Actions Artifacts


## Code Style

YAML formatting (from `.editorconfig`):
- 2-space indentation
- UTF-8 encoding with LF line endings
- Clean trailing whitespace
- Clean final newlines

Commit message convention (from `CONTRIBUTING.md`):
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Example: `feat(workflow): add support for ARM64 architecture`

## Development Workflow

This is a template repository, so there are no build/test/lint commands. Development consists of:

1. **Editing workflow files** - Modify `.github/workflows/*.yml`
2. **Testing changes** - Create a test repository and copy the workflow file there
3. **Documentation updates** - Keep README.md in sync with workflow changes

## Common Modifications

When modifying workflows, keep in mind:

1. **Artifact naming**: The filename transformation logic (replacing `/` and `:` with `_`) is repeated in both workflows. If changed, update both files consistently.

2. **Platform support**: To add new architectures to the multi-arch workflow, add to the `platform` input choices and ensure the platform is supported by Docker Buildx.

3. **Compression level**: Currently set to 9 (maximum). Lower values reduce CPU usage but increase artifact size.

4. **Retention days**: Free GitHub accounts are limited to 90 days maximum.

## Security Considerations

- For private registry support, users must add their own `docker/login-action` step
- Credentials should always use GitHub Secrets, never hardcoded
- The workflows themselves don't handle secrets - users must extend them

## GitHub Artifact Limits

- Single artifact: 2GB max
- Total storage: 500GB max
- Retention: 90 days max for free accounts

## Local Testing

After downloading artifacts, users load images with:
```bash
docker load -i docker-image-name.tar
docker run -it image:tag
```
