# Duet

This is a partial re-implementation of [git
duet](https://github.com/git-duet/git-duet).

Git duet is handy when pair-programming. Both engineers in the pair get their
names on all the commits. ~~Unfortunately, the current implementation of
git-duet does not play nicely with git rebase. When doing trunk-based
development as part of an XP workflow, this is often not an issue. However,
when contributing to open source projects with a PR-based workflow, large
rebases happen frequently.~~ If you want to do rebases with [git
duet](https://github.com/git-duet/git-duet), you should probably `export
GIT_DUET_SET_GIT_USER_CONFIG=1`. Alternatively, you can use this bash
re-implementation.

By re-implementing git duet in bash, we can interface with git using
environment variables, rather than requiring a new commit binary. This means
that commands which run commit "under the hood" (such as rebase) still work as
we expect.

## Usage

Check out this repo:

```sh
git co git@github.com:totherme/duet-shell $HOME/workspace/duet-shell
```

Put the following into your `~/.bash_profile` to load the library:

```sh
# shellcheck disable=SC1090
. "$HOME/workspace/duet-shell/duet.bash"
# shellcheck disable=SC1090
. "$HOME/.git-duet-bash-state"
```

Create yourself a `~/.git-authors` file. Each line should contain a set of
initials, a name, and an email address, like so:

```
abc; Alice Beatrice Cromwell ; alice@awesome.com
```

Start a new shell. Now you can use commands similar to what you're used to from previous
git-duet implementations:

```sh
duet # prints out who you're currently duetted as
duet abc # Sets both author and committer to user "abc"
duet abc def # Duets as abc and def. Randomly pick who gets to be author.
```

### Migrating from [git-duet](https://github.com/git-duet/git-duet)

If you have an existing `~/.git-authors` file, I'm afraid you'll need to change
it. This implementation only supports very simple `.git-authors` files, in
which every line has the form:

```
abc; Alice Beatrice Cromwell ; alice@awesome.com
```

Once you've sourced the script and put a compatible `.git-authors` file in
place, 
If you're migrating from [git-duet](https://github.com/git-duet/git-duet),
you'll probably want to change the `git ci` alias in `~/.gitconfig` back from
`duet-commit` to `commit --verbose`.

## Testing

The tests use [basht](http://github.com/progrium/basht). You can get basht and
run the tests by doing:

```
go get github.com/progrium/basht
basht tests.bash
```

