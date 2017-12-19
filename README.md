# Duet

This is a partial re-implementation of [git duet](https://github.com/git-duet/git-duet).

Git duet is handy when pair-programming. Both engineers in the pair get their
names on all the commits. Unfortunately, the current implementation of
git-duet does not play nicely with git rebase. When doing trunk-based
development as part of an XP workflow, this is often not an issue. However,
when contributing to open source projects with a PR-based workflow, large
rebases happen frequently.

By re-implementing git duet in bash, we can interface with git using
environment variables, rather than requiring a new commit binary. This means
that commands which run commit "under the hood" (such as rebase) still work
as we expect.

## Usage

Add `. duet.bash` to your `.bash_profile`, then start a new shell.

If you have an existing `~/.git-authors` file, I'm afraid you'll need to change
it. This implementation only supports very simple `.git-authors` files, in
which every line has the form:

```
abc; Alice Beatrice Cromwell ; alice@awesome.com
```

Once you've sourced the script and put a compatible `.git-authors` file in
place, you can use commands similar to what you're used to from previous
git-duet implementations:

```sh
duet # prints out who you're currently duetted as
duet abc # Sets both author and committer to user "abc"
duet abc def # Duets as abc and def. Randomly pick who gets to be author.
```

If you're migrating from [git-duet](https://github.com/git-duet/git-duet),
you'll probably want to change the `git ci` alias in `~/.gitconfig` back from
`duet-commit` to `commit --verbose`.

## Limitations

Currently, this duet implementation keeps all its state in environment
variables. This means you have to duet afresh for each terminal window you
open.

On a one-pair team, you can just add `duet me mypair` to your `.bash_profile`
and you'll be fine. On a team with actual rotations this might get a bit
annoying. Expect to see a duet-statefile show up in future commits.

## Testing

The tests use [basht](http://github.com/progrium/basht). You can get basht and
run the tests by doing:

```
go get github.com/progrium/basht
basht tests.bash
```

