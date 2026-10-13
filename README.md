# readme-scribe

A GitHub Action that generates and updates markdown content, such as the README of a profile, from a [markscribe](https://github.com/muesli/markscribe) template.

This is a fork of [muesli/readme-scribe](https://github.com/muesli/readme-scribe), whose only release is from 2020 and runs an unpinned image from 2021. The fork builds markscribe from source with a current Go toolchain and publishes the image the action runs as `ghcr.io/freifunkmuc/readme-scribe`, one version per release. markscribe comes from [freifunkMUC/markscribe](https://github.com/freifunkMUC/markscribe), a fork with current dependencies and fixes from upstream's backlog (GraphQL resource limits, pagination, releases, archived repositories, RSS fields, `truncate`).

## Usage

1. Write a markscribe template and put it into the repository to update, for example as `templates/README.md.tpl`. Upstream has an [example for a profile](https://github.com/muesli/markscribe/blob/master/templates/github-profile.tpl).

2. Most template functions call the GitHub API and need a personal access token, stored as the secret `PERSONAL_GITHUB_TOKEN`. The full set of functions needs the scopes `read:user`, `repo:status`, `public_repo` and `read:org`; the [markscribe documentation](https://github.com/muesli/markscribe) lists the scopes per function.

3. Add a workflow, for example `.github/workflows/readme-scribe.yml`:

```yml
name: Update README

on:
  schedule:
    - cron: "0 */6 * * *"
  workflow_dispatch:

permissions:
  contents: write

jobs:
  markscribe:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v7

      - uses: freifunkMUC/readme-scribe@v1.2.0
        env:
          GITHUB_TOKEN: ${{ secrets.PERSONAL_GITHUB_TOKEN }}
        with:
          template: "templates/README.md.tpl"
          writeTo: "README.md"

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "docs: update generated README [skip ci]"
          file_pattern: README.md
```

The last step commits the README only when it changed.

## Inputs

| Name | Default | |
|---|---|---|
| `template` | `README.md.tpl` | The template to render. |
| `writeTo` | `README.md` | The file to write. |

## Releasing

Raise the image version in `action.yml`, merge, then push a tag `v<version>` on that commit. The workflow `Image` checks that the tag and `action.yml` agree and publishes `ghcr.io/freifunkmuc/readme-scribe:<version>` for amd64 and arm64.
