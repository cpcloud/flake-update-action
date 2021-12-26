# Update flake dependencies

This action will create PRs that update flake dependencies.

## Usage in a GitHub workflow

```yaml
jobs:
  update-deps:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        dependency:
          - nixpkgs
          - poetry2nix
    steps:
      - name: Update ${{ matrix.dependency }}
        uses: cpcloud/flake-update-action@*
        with:
          dependency: ${{ matrix.dependency }}
          pull-request-token: ${{ secrets.ANOTHER_TOKEN }}
          pull-request-author: "Me <me@me.com>"
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

```yaml
inputs:
  dependency:
    required: true
    description: "The flake dependency to update"
  pull-request-token:
    required: true
    description: "Access token used to create pull requests"
  pull-request-author:
    required: true
    description: "The author of the pull request"
  pull-request-merge-method:
    required: false
    description: "The merge method for automerging pull requests"
    default: "rebase"
  delete-branch:
    required: false
    default: "false"
    description: "Delete branch upon merge"
  github-token:
    required: false
    description: "Access token to increase the rate limit for GitHub API requests"
  pull-request-branch-prefix:
    required: false
    default: "create-pull-request/update-"
    description: "Prefix of the branch for the pull request"
  pull-request-labels:
    required: false
    description: "Labels to attach to the pull request"
    default: ""
  include-merge-commits:
    required: false
    description: "Whether to show merge commits in the log"
    default: "false"
  automerge:
    required: false
    description: "Whether to set the pull request to automatically merge on success. Requires that the automerge feature is enabled on GitHub."
    default: "false"
```
