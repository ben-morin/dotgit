# dotgit

Personal configuration files for this machine.

## Strategy

This is a **split repository**: the git metadata lives in `~/.dotgit` while the
work tree is `$HOME` itself. A `dotgit` shell function (defined in
`.zshrc-func`) wraps git so commands target both automatically:

```sh
dotgit status
dotgit add <path>
dotgit commit -m "..."
```

It uses an **allow-list** `.gitignore`: everything under `$HOME` is ignored by
default, and config files are opted in explicitly. See `.gitignore` for the
tracked set and rationale.

## Tracking a new file

The easiest way is the `~/bin/dotgit-add` helper (see below):

```sh
dotgit-add .config/nvim          # track a whole directory
dotgit-add .config/bat/config    # track a single file
```

Or do it by hand: add a matching `!/path/to/newfile` line to `.gitignore`
(un-ignoring parent directories first for nested paths), then
`dotgit add -f path/to/newfile`.

## The `dotgit-add` helper

`~/bin/dotgit-add` automates the allow-list bookkeeping. For each path it
appends the required rules to `.gitignore` — un-ignore each parent directory
(`!/a/`), re-ignore its contents (`/a/*`), and finally un-ignore the target —
then stages it. Only missing rules are added, so it is safe to re-run, and it
leaves the commit to you. Its git calls are wrapped to target
`--git-dir=~/.dotgit --work-tree=~`, matching the `dotgit` shell function.

```sh
dotgit-add [options] <path>...

  -c, --check     Report whether each path is tracked, ignored, or neither
  -n, --dry-run   Print the .gitignore lines that would be added; change nothing
  -h, --help      Show help
```

## What is deliberately NOT tracked

Secrets and machine state: SSH/GPG private keys, `known_hosts`,
`~/.config/gh/hosts.yml`, `~/.config/mysql/mylogin.cnf`, `~/.config/op/`,
`~/.zshrc-secrets`, shell history, caches, and `.DS_Store`.
