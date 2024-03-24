#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

command_hook="$PWD/hooks/command"

# Uncomment the following line to debug stub failures
export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
export WHICH_STUB_DEBUG=/dev/tty

@test "Commits all changes" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 1" \
    "checkout -b meow : echo branch checked out" \
    "commit -m 'Update Helm Tarballs' : echo commit message added" \
    "push -u \"https://:gh_redacted@github.com/datumforge/meow-charts\" meow : echo branch pushed" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "dependencies updated"
  assert_output --partial "added files"
  assert_output --partial "branch checked out"
  assert_output --partial "commit message added" 
  assert_output --partial "branch pushed"
  unstub yq
  unstub helm
  unstub git
}


@test "Commits all changes over ssh" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export GITHUB_TOKEN=gh_redacted
  export BUILDKITE_PLUGIN_HELM_SSH_COMMIT=true

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 1" \
    "checkout -b meow : echo branch checked out" \
    "commit -m 'Update Helm Tarballs' : echo commit message added" \
    "config url.\"git@github.com:\".insteadOf \"https://github.com/\" : echo config set" \
    "push origin meow : echo branch pushed" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "dependencies updated"
  assert_output --partial "added files"
  assert_output --partial "branch checked out"
  assert_output --partial "commit message added" 
  assert_output --partial "config set"
  assert_output --partial "branch pushed"
  unstub yq
  unstub helm
  unstub git
}

@test "Commits no changes, no dependencies to update" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 0" \

  stub git \
    "diff --cached --exit-code : exit 0" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "no dependencies were found"
  unstub yq
  unstub git
}

@test "Configures git user.name" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export BUILDKITE_PLUGIN_HELM_USER_NAME="bender"
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 1" \
    "config user.name \"bender\" : echo configure user.name" \
    "checkout -b meow : echo branch checked out" \
    "commit -m 'Update Helm Tarballs' : echo commit message added" \
    "push -u \"https://bender:gh_redacted@github.com/datumforge/meow-charts\" meow : echo branch pushed" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "dependencies updated"
  assert_output --partial "configure user.name"
  assert_output --partial "branch checked out"
  assert_output --partial "added files"
  assert_output --partial "commit message added" 
  assert_output --partial "branch pushed"
  unstub yq
  unstub helm
  unstub git
}

@test "Configures git user.email" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export BUILDKITE_PLUGIN_HELM_USER_EMAIL="bot@example.com"
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 1" \
    "config user.email \"bot@example.com\" : echo configure user.email" \
    "checkout -b meow : echo branch checked out" \
    "commit -m 'Update Helm Tarballs' : echo commit message added" \
    "push -u \"https://:gh_redacted@github.com/datumforge/meow-charts\" meow : echo branch pushed" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "dependencies updated"
  assert_output --partial "configure user.email"
  assert_output --partial "branch checked out"
  assert_output --partial "added files"
  assert_output --partial "commit message added" 
  assert_output --partial "branch pushed"
  unstub yq
  unstub helm
  unstub git
}

@test "Allows a custom message" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export BUILDKITE_PLUGIN_HELM_MESSAGE="Good Morning!"
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 1" \
    "checkout -b meow : echo branch checked out" \
    "commit -m 'Good Morning!' : echo commit message added" \
    "push -u \"https://:gh_redacted@github.com/datumforge/meow-charts\" meow : echo branch pushed" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "dependencies updated"
  assert_output --partial "branch checked out"
  assert_output --partial "added files"
  assert_output --partial "commit message added" 
  assert_output --partial "branch pushed"
  unstub yq
  unstub helm
  unstub git
}

@test "Skip commit when there are no changes" {
  export BUILDKITE_REPO=https://github.com/datumforge/meow-charts
  export BUILDKITE_BRANCH=meow
  export GITHUB_TOKEN=gh_redacted

  stub yq \
    "'.dependencies | length' ./tests/_example/Chart.yaml : echo 1" \

  stub helm \
    "dependency update : echo dependencies updated" \

  stub git \
    "add ./tests/_example : echo added files" \
    "diff --cached --exit-code : exit 0" \
  
  run "$command_hook"

  assert_success
  assert_output --partial "--- No changes to commit"
  unstub yq
  unstub helm
  unstub git
}
