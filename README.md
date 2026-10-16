# dotfiles

My shell, tmux, git, and AI-agent setup for macOS. Symlink what you want.

## Files

- `.zshrc` — fish-like Up/Down history (substring search), a `git checkout` fallback between
  `main` and `master`, and `tmuxa` to attach the most recent tmux session.
- `.config/tmux/tmux.conf` — the status line shows git dirty/ahead/behind for the current pane
  plus a battery segment (`.config/tmux/battery-status.sh`, works on macOS via `pmset` and on Linux
  via `acpi`; prints nothing elsewhere); `C-g` opens a lazygit layout, `C-z` opens a claude-tmux
  popup, and the bar turns blue over SSH.
- `.gitconfig` — delta pager with `zdiff3` conflicts, `hist`/`ahead`/`behind` aliases, and
  typo aliases (`chekcout`, `pul`, `puhs`).
- `AGENTS.md`: my global agent instructions, shared by every coding agent I use. Claude Code
  on Opus/Fable plans and reviews; pi or Sonnet does the implementing. Plans are files with a
  status in their frontmatter and a copy-paste handoff prompt at the top. Locally it lives at
  `~/.config/agents/AGENTS.md`. `~/.claude/CLAUDE.md` imports it with
  `@~/.config/agents/AGENTS.md`, and `~/.pi/agent/AGENTS.md` is a symlink to it. Status is
  browsed with [plans-tui](https://github.com/ntmathis/plans-tui).

## Use

Symlink the files you want, e.g.:

    ln -s "$PWD/.config/tmux/tmux.conf" ~/.config/tmux/tmux.conf

Keep private bits in `~/.zshrc.local` and `~/.gitconfig.local`; both are gitignored and
never exported.

Exported one-way from a private repo by an allowlist script. MIT — see LICENSE.
