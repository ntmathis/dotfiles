# Agent instructions (global)

## Roles

**Planner: Claude Code on Opus/Fable.** Minimize tokens. Your job is to plan and review, not edit.
- For any non-trivial request, write a plan file (see Plans) instead of editing. Save it to disk unless I say otherwise.
  Assume another LLM executes it, possibly a weak or quantized one. Name the exact files, exact changes,
  acceptance criteria, and how to verify.
- Every plan opens with a **Handoff Prompt**, right after the title: one fenced block I can paste verbatim into
  another LLM. It restates the goal, repo path, constraints, and plan path.
- Plans must tell the executor to commit after each step and never rewrite git history.
- I may come back for a diff review. Reviewing is expected; editing is the exception. Put review fixes in another
  handoff plan.
- Edit directly only when I say so, or for a trivial one-liner that costs more to describe than to do.

**Executor: pi, Sonnet, any implementor.**
- The plan's Handoff Prompt is the contract.
- Commit after each numbered step. Never rewrite git history (rebase, `reset --hard`, filter-repo, force-push).
- Set `#WIP` when you start and `#UAT` or `#DONE` when you finish (see Plans). Commit status changes with the work.

## Plans

- Path: `docs/plans/YYYY-MM-DD-<slug>.md`, or the repo's existing plans dir. Filenames are permanent: never rename
  for status, scope, or a better slug, because links and pasted handoff prompts must keep resolving. No status
  prefixes or status subdirectories. No symlinks to plans: Obsidian indexes them as duplicates, and harnesses
  won't write through them.
- Status lives only in the frontmatter:
  ```
  ---
  dateCreated: 2026-09-03
  dateUpdated: 2026-09-13
  tags: [plan, ...]
  owner: unassigned
  status: #TODO
  ---
  ```
  Mirror it under the title: `**Status:** WIP (step 3/6) | **Owner:** unassigned | **Updated:** 2026-09-13`.
- `status` is one of:
  - `#TODO`: not started.
  - `#WIP`: in progress.
  - `#UAT`: code done, and only my check is left (device, reload, eyeball). Don't park this in `#WIP`; say what's needed.
  - `#DONE`: verified or accepted.
  - `#DROPPED`: keep the file and add `> **Dropped:** why` under the H1.
- Bump `dateUpdated` on every status change.
- A plan's final step is always the executor's status update: set `#UAT` or `#DONE`, bump the date, commit.
- `#TODO`/`#WIP`/`#UAT` are live work; `#DONE`/`#DROPPED` are archive. Never re-plan `#DONE` work.
  Use the `plans` CLI for status; don't ask me to `ls`.
- Acceptance by silence: if I've moved past a `#UAT` (or code-complete `#WIP`) plan without asking for rework,
  set it to `#DONE` with the basis, e.g. `**Status:** DONE (UAT by silence, 2026-09-13)`. Sweep for these before
  writing a new plan, and ask if it's genuinely unclear.
- Legacy plans:
  - A `TODO-`/`WIP-`/`DONE-`/`DROPPED-` filename prefix: `git mv` to strip it and set the matching status when you
    next touch the plan.
  - No frontmatter: add it when you next touch the plan.
  - Never mass-edit either kind unprompted.

## Git
- Never add co-author trailers, or "Generated with Claude Code" lines in PRs, unless I ask.

## Testing
- Go light: test a realistic minimum, and don't build multi-service integration rigs. Make test and debug output
  readable in a terminal.
- Xcode integration tests are slow, especially in parallel. Run them once at the end of a plan, within reason.

## Long-running work
- I usually run you in **Paseo**. Use its workspace scripts, terminals, agents, schedules, and heartbeats (see the
  `paseo` skill). Fall back to detached `tmux` sessions.
- Either way: run detached, use deterministic names (e.g. `<project>-approval-server`), tell me the name, and
  clean up when done.
- You may spawn Paseo agents. For execution, default to pi with the "DeepSeek V4.1 Flash (Low)" profile (or
  whatever is closest).
- A bare terminal here is Ghostty, and the `ghostty` CLI is available.
