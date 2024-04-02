[![Build status](https://badge.buildkite.com/2f8a9e7c6ef1a04d686b9a94847d9d56b0a46ea49e2d598268.svg)](https://buildkite.com/datum/helm-buildkite-plugin)

Credit to [equinixmetal](https://github.com/equinixmetal-buildkite/helm-tar-update-buildkite-plugin) for the inspiration. 

# helm-buildkite-plugin

This re-usable workflow ensures that when a helm dependency update happens, a tarball is downloaded.

## Example

Provide an example of using this plugin, like so:

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - datumforge/helm#v1.0.0:
          message: "roll up them tarballs"
          user:
            name: bender-rodriguez
            email: brodriguez@datum.net
```

This buildkite plugin relies on the existence of a `charts` directory.

## Authentication on commits

By default, this plugin will attempt to push a commit back to the repository over `https`. When using `https` the `user.name` and `GITHUB_TOKEN` environment **must** be set. 

If you prefer to push commits over `ssh`, set `ssh: true` and ensure the buildkite runner is setup with a valid ssh config to authorize commits.

## Developing

Requires [taskfile](https://taskfile.dev/installation/) - `task lint` and `task test` to validate updates to the plugin
