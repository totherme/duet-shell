#!/usr/bin/env bash

# basht macro, shellcheck fix
export T_fail

. "./duet.bash"

# Override the accessor of the local ~/git-authors with test data
duet_git_authors() {
  echo "
abc; Alice Beatrice Cromwell ; alice@awesome.com
def; Derick Edward Farroe ; derick@awesome.com
ghi; Greta Hillary Innes ; greta@awesome.com
"
}

T_duet_with_no_args_calls_duet_whoami() {
  (
    whoami_called="whoami not called yet"
    duet_whoami() {
      whoami_called="called"
    }

    duet

    expect_to_equal "$whoami_called" "called"
  )
}

T_duet_with_two_args_calls_duet_set_then_randomize() {
  (
    set_arg1="set not called yet"
    set_arg2="set not called yet"
    duet_set() {
      set_arg1=$1
      set_arg2=$2
    }

    randomize_called="randomize hasn't been called yet"
    duet_randomize_authors() {
      randomize_called="called"
    }

    duet firstarg secondarg

    expect_to_equal "$set_arg1" "firstarg" &&
      expect_to_equal "$set_arg2" "secondarg" &&
      expect_to_equal "$randomize_called" "called"
  )
}

T_duet_with_one_arg_calls_duet_set_with_that_arg_twice() {
  (
    arg1="set not called yet"
    arg2="set not called yet"
    duet_set() {
      arg1=$1
      arg2=$2
    }

    duet firstarg

    expect_to_equal "$arg1" "firstarg" &&
      expect_to_equal "$arg2" "firstarg"
  )
}

T_duet_whoami_prints_current_duet() {
  local expected actual

  expected="You're the following author and committer:
Author Person
author@place
Committer Person
committer@place"

  actual="$(
    GIT_AUTHOR_NAME="Author Person" \
    GIT_COMMITTER_NAME="Committer Person" \
    GIT_AUTHOR_EMAIL="author@place" \
    GIT_COMMITTER_EMAIL="committer@place" \
    duet_whoami
  )"

  expect_to_equal "$actual" "$expected"
}

T_duet_set_sets_all_vars() {
  (
    duet_set "abc" "def"
    expect_to_equal "$GIT_AUTHOR_NAME" "Alice Beatrice Cromwell" &&
      expect_to_equal "$GIT_COMMITTER_NAME" "Derick Edward Farroe" &&
      expect_to_equal "$GIT_AUTHOR_EMAIL" "alice@awesome.com" &&
      expect_to_equal "$GIT_COMMITTER_EMAIL" "derick@awesome.com"
  )
}

T_rotate_authors_rotates_committer_and_author() {
  (
    GIT_AUTHOR_NAME="Author Person" \
    GIT_COMMITTER_NAME="Committer Person" \
    GIT_AUTHOR_EMAIL="author@place" \
    GIT_COMMITTER_EMAIL="committer@place" \
    duet_rotate_authors

    expect_to_equal "$GIT_AUTHOR_NAME" "Committer Person" &&
      expect_to_equal "$GIT_COMMITTER_NAME" "Author Person" &&
      expect_to_equal "$GIT_AUTHOR_EMAIL" "committer@place" &&
      expect_to_equal "$GIT_COMMITTER_EMAIL" "author@place"
  )
}

T_randomize_authors_rotates_authors_some_random_amount() {
  (
    rotations=0
    duet_rotate_authors() {
      rotations=$(( rotations + 1 ))
    }

    duet_randomize_authors

    if [[ $rotations -eq 0 ]]
    then
      echo "Expected more than 0 rotations"
      return 1
    fi

    if [[ $rotations -gt 2 ]]
    then
      echo "Expected fewer than 3 rotations"
      return 1
    fi
  )
}

T_get_name_gets_a_given_name() {
  expect_to_equal "$(duet_get_name "abc")" \
      "Alice Beatrice Cromwell" &&
    expect_to_equal "$(duet_get_name "def")" \
      "Derick Edward Farroe" &&
    expect_to_equal "$(duet_get_name "ghi")" \
      "Greta Hillary Innes"
}

T_get_email_gets_a_given_email() {
  expect_to_equal "$(duet_get_email "abc")" \
      "alice@awesome.com" &&
    expect_to_equal "$(duet_get_email "def")" \
      "derick@awesome.com" &&
    expect_to_equal "$(duet_get_email "ghi")" \
      "greta@awesome.com"
}


expect_to_equal() {
  local actual expected diff_output diff_exit
  actual="$1"
  expected="$2"

  diff_output="$(diff <(echo "$actual") <(echo "$expected"))"
  diff_exit=$?

  if [[ $diff_exit != 0 ]]
  then
    echo -e "$diff_output"
    return $diff_exit
  fi
}
