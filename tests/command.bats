#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

command_hook="$PWD/hooks/command"

@test "Commits all changes" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  stub git \
    "fetch origin main:main : echo fetch" \
    "checkout main : echo checkout" \
    "add -A . : echo add" \
    "diff-index --quiet HEAD : false" \
    "commit -m \"Build #1\" : echo commit" \
    "push origin main : echo push"

  run "$command_hook"

  assert_success
  assert_output --partial "--- Committing changes"
  assert_output --partial "--- Pushing to origin"
  unstub git
}

@test "Configures git user.name" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  export BUILDKITE_PLUGIN_GIT_COMMIT_USER_NAME=Robot

  stub git \
    "config user.name \"Robot\" : echo config.name" \
    "fetch origin main:main : echo fetch" \
    "checkout main : echo checkout" \
    "add -A . : echo add" \
    "diff-index --quiet HEAD : false" \
    "commit -m \"Build #1\" : echo commit" \
    "push origin main : echo push"

  run "$command_hook"

  assert_success
  assert_output --partial "--- Committing changes"
  assert_output --partial "--- Pushing to origin"
  unstub git
}

@test "Configures git user.email" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  export BUILDKITE_PLUGIN_GIT_COMMIT_USER_EMAIL="bot@example.com"

  stub git \
    "config user.email \"bot@example.com\" : echo config.email" \
    "fetch origin main:main : echo fetch" \
    "checkout main : echo checkout" \
    "add -A . : echo add" \
    "diff-index --quiet HEAD : false" \
    "commit -m \"Build #1\" : echo commit" \
    "push origin main : echo push"

  run "$command_hook"

  assert_success
  assert_output --partial "--- Committing changes"
  assert_output --partial "--- Pushing to origin"
  unstub git
}

@test "Allows a custom message" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  export BUILDKITE_PLUGIN_GIT_COMMIT_MESSAGE="Good Morning!"

  stub git \
    "fetch origin main:main : echo fetch" \
    "checkout main : echo checkout" \
    "add -A . : echo add" \
    "diff-index --quiet HEAD : false" \
    "commit -m \"Good Morning!\" : echo commit" \
    "push origin main : echo push"

  run "$post_command_hook"

  assert_success
  assert_output --partial "--- Committing changes"
  assert_output --partial "--- Pushing to origin"
  unstub git
}

@test "Skip commit when there are no changes" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  stub git \
    "fetch origin main:main : echo fetch" \
    "checkout main : echo checkout" \
    "add -A . : echo add" \
    "diff-index --quiet HEAD : true"

  run "$post_command_hook"

  assert_success
  assert_output --partial "--- No changes to commit"
  unstub git
}

@test "Bails out when the command fails" {
  export BUILDKITE_BUILD_NUMBER=1
  export BUILDKITE_BRANCH=main

  export BUILDKITE_COMMAND_EXIT_STATUS=127

  run "$post_command_hook"

  assert_success
  assert_output --partial "--- Skipping git-commit"
}