# First Implementation Cycle

The reboot starts with an implementation surface that is safe to inspect,
review, and publish: a Pi-style documentation system inside the `XjMVVM`
repository.

This first slice proves three things before we change Xojo source:

1. The repository can host the new documentation framework.
2. The documentation can be built into self-contained HTML.
3. The reboot direction is captured as source-backed implementation notes, not
   only as chat history.

<div class="note"><span class="note-t">Cycle rule</span>
For Xojo source work, the human owns visual layout and Codex owns non-UI source,
diagnostics, generated docs, and handoff continuity. This docs slice stays out
of `.xojo_project` files and does not rearrange the existing app.
</div>

## Current Locked Direction

The current reboot direction is stored in the developer documentation plan:

[[snippet:developer docs/REBOOT_PLAN_ONE_REPO_POCKETBASE.md:11-23|Locked direction from the reboot plan]]

## First Features In This Cycle

Feature 1 is the documentation scaffold itself: `docs/book`, `docs/tools`,
`docs/assets`, `docs/reader`, and generated `docs/site`.

Feature 2 is the review loop inherited from Pi Analysis Docs: run the reader,
highlight text, leave comments, process `reader/comments.json`, rebuild, and
repeat.

Feature 3 is the implementation map. The next source slice should create the
shared MVVM contracts and a Customer vertical slice before any platform-specific
UI or backend specialization grows large.

