#!/usr/bin/env bash

duet() {
  if [[ $# -eq 0 ]]
  then
    duet_whoami
  elif [[ $# -eq 1 ]]
  then
    duet_set "$1" "$1"
    duet_save_state "$1" "$1"
  else
    duet_set "$@"
    duet_randomize_authors
    duet_save_state "$@"
  fi
}

duet_set() {
  local author_initials committer_initials
  author_initials="${1:?"Expected author initials argument in duet_set"}"
  committer_initials="${2:?"Expected committer initials argument in duet_set"}"
  export GIT_AUTHOR_NAME
  GIT_AUTHOR_NAME="$(duet_get_name "$author_initials")"
  export GIT_COMMITTER_NAME
  GIT_COMMITTER_NAME="$(duet_get_name "$committer_initials")"
  export GIT_AUTHOR_EMAIL
  GIT_AUTHOR_EMAIL="$(duet_get_email "$author_initials")"
  export GIT_COMMITTER_EMAIL
  GIT_COMMITTER_EMAIL="$(duet_get_email "$committer_initials")"
}

duet_whoami() {
  echo "You're the following author and committer:"
  echo "$GIT_AUTHOR_NAME"
  echo "$GIT_AUTHOR_EMAIL"
  echo "$GIT_COMMITTER_NAME"
  echo "$GIT_COMMITTER_EMAIL"
}

duet_rotate_authors() {
  local name email
  name="${GIT_AUTHOR_NAME}"
  email="${GIT_AUTHOR_EMAIL}"
  export GIT_AUTHOR_NAME="${GIT_COMMITTER_NAME}"
  export GIT_AUTHOR_EMAIL="${GIT_COMMITTER_EMAIL}"
  export GIT_COMMITTER_NAME="${name}"
  export GIT_COMMITTER_EMAIL="${email}"
}

duet_randomize_authors() {
  for _ in $(seq $(( RANDOM % 2 )) )
  do
    duet_rotate_authors
  done
}

# usage: duet_get_name initials
# Given initials, it gets the corresponding name from ~/.git-authors
duet_get_name() {
  local initials
  initials="${1:?"Expected initials argument in duet_get_name"}"
  duet_git_authors | grep "^$initials" | \
    cut -d ";" -f 2 | \
    xargs # trims whitespace from beginning and end of the line
}

# usage: duet_get_email initials
# Given initials, it gets the corresponding email from ~/.git-authors
duet_get_email() {
  local initials
  initials="${1:?"Expected initials argument in duet_get_email"}"
  duet_git_authors | grep "^$initials" | \
    cut -d ";" -f 3 | \
    xargs # trims whitespace from beginning and end of the line
}

# usage: duet_save_state firstinits secondinits
# Given two sets of initials, saves that duet configuration in the filesystem
duet_save_state() {
  local author_initials committer_initials
  author_initials="${1:?"Expected author initials argument in duet_set"}"
  committer_initials="${2:?"Expected committer initials argument in duet_set"}"
  echo "duet_set \"$author_initials\" \"$committer_initials\"
duet_randomize_authors" | duet_state_writer
}

# override this to unit test this file
duet_git_authors() {
  cat "$HOME/.git-authors"
}

# override this to unit test this file
duet_state_writer() {
  cat > "$HOME/.git-duet-bash-state"
}
