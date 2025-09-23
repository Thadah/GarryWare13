# Forgejo Workflows Configuration

This directory contains CI/CD workflows for Forgejo Actions.

## mirror-to-github.yml

Automatically mirrors this repository to GitHub on every push to master branch and tag creation.

### Required Configuration

To use this workflow in your own project, you need to modify:

1. **GITHUB_MIRROR_URL** (line 14):
   ```yaml
   GITHUB_MIRROR_URL: https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   ```
   Replace with your GitHub repository's HTTPS URL.

2. **Repository Secret** (Repository Settings > Actions > Secrets):
   - Create a secret named `_GITHUB_MIRROR_TOKEN` (yes, the '_' is required)
   - Value should be a [GitHub Personal Access Token](https://github.com/settings/tokens/new) with `repo` permissions

### How it works

- Triggers on pushes to master branch and any tag creation/deletion
- Uses `git push --mirror` to keep GitHub repository identical to Forgejo
- Authenticates using GitHub token stored in repository secrets
- Maintains full history, branches, and tags synchronization

## docker-forgejo.yml

Builds and pushes Docker images to Forgejo's container registry on every push and pull request.

### Required Configuration

To use this workflow in your own project, you need to modify:

1. **Environment Variables** (lines 11-14):
   ```yaml
   REGISTRY: your-forgejo-domain.com          # Your Forgejo instance domain
   NAMESPACE: your-username                   # Your Forgejo username or organization
   IMAGE_NAME: your-project-name              # Your repository/image name
   TAG: latest                                # Docker tag (usually keep as 'latest')
   ```

2. **Repository Secrets** (Repository Settings > Actions > Secrets):
   - `FORGEJO_TOKEN`: Personal access token created in **User Settings > Applications > Access tokens** with package write permissions
   - `FORGEJO_USER`: Your Forgejo username (same as your login username)

### How it works

- Triggers on pushes to master branch and pull requests
- Builds Docker image using project's Dockerfile
- Tags image for Forgejo registry
- Pushes to registry only on branch pushes (skips PRs for security)
- Requires Docker runner with label `docker`