# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitHub Actions workflow template** for pulling Docker images and saving them as downloadable TAR artifacts. It's not a traditional software project - it provides reusable workflow files that users copy to their own repositories.

## Architecture

The project consists of two GitHub Actions workflow files in `.github/workflows/`:

### Basic Workflow: `pull-docker-image.yml`
- Pulls any Docker image (public or private)
- Saves as compressed TAR file
- Single job with sequential steps
- No additional Docker setup required

### Multi-Architecture Workflow: `pull-docker-image-multiarch.yml`
- All basic features plus platform selection
- Requires `docker/setup-buildx-action@v3` for cross-platform support
- Supports 5 architectures: linux/amd64, linux/arm64, linux/arm/v7, linux/ppc64le, linux/s390x
- Platform-aware artifact naming

Both workflows:
- Use `workflow_dispatch` trigger (manual execution only)
- Use `actions/upload-artifact@v4` with compression-level 9
- Store output filename in `GITHUB_ENV` for passing between steps
- Display detailed progress information at each step

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
