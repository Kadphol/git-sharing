# Git Knowledge Sharing

Technical knowledge-sharing materials for explaining Git to software developers.

The main artifact is a one-page scrolling visual guide that covers Git internals, the three Git states, daily collaboration workflow, branching strategies, hooks, conflict resolution, undo commands, and command-line guide.

A preserved slide-based HTML version from the `main` branch is also included for comparison or fallback.

## GitHub Pages

When deployed to GitHub Pages, open the repository site root:

```text
https://<user-or-org>.github.io/<repo>/
```

The landing page links to the audience presentation, mobile speaker notes, and
the preserved slide version. For presenting, use this setup:

- Laptop or projector: `git-knowledge-sharing-presentation.html`
- Phone: `speaker-notes.html`
- Terminal: local `taskly/` demo repository

All links are relative so the pages work under a GitHub Pages project path.

## Main Guide

Open the current scrolling guide directly in a browser:

```bash
open git-knowledge-sharing-presentation.html
```

Or run a local preview server:

```bash
python3 -m http.server 8765
```

Then open:

```text
http://localhost:8765/git-knowledge-sharing-presentation.html
```

The GitHub Pages entrypoint is also available locally:

```text
http://localhost:8765/index.html
```

Presenter controls:

- Click `Full screen` or press `F` to enter or exit fullscreen mode.
- Use `ArrowDown`, `PageDown`, or `Space` to move to the next section.
- Use `ArrowUp` or `PageUp` to move to the previous section.
- Use `Home` and `End` to jump to the first or last section.

## Previous Slide Version

The previous slide-based version from `main` is available as:

```text
git-knowledge-sharing-presentation-slides.html
```

When using the local preview server, open:

```text
http://localhost:8765/git-knowledge-sharing-presentation-slides.html
```

## Workshop Runbook

For a hands-on session, follow the presenter runbook:

```text
WORKSHOP_RUNBOOK.md
```

The runbook matches the presentation sections and provides copy-paste commands,
facilitator notes, expected observations, reset steps, and discussion prompts.

For live presenting on mobile, use the condensed phone-first speaker notes:

```text
speaker-notes.html
```

## Repository Contents

- `git-knowledge-sharing-presentation.html` - scrolling visual guide for the session.
- `speaker-notes.html` - mobile-friendly condensed presenter notes.
- `index.html` - GitHub Pages landing page.
- `git-knowledge-sharing-presentation-slides.html` - preserved slide-based HTML version from `main`.
- `git-knowledge-sharing-script.md` - speaker script and source material.
- `git-workshop-guide.md` - facilitator guide for a longer workshop format.
- `git-workshop-visual.md` - visual aid markdown with Git diagrams.
- `WORKSHOP_RUNBOOK.md` - presentation-aligned hands-on runbook and guidelines.
- `short-note.md` - shorter notes for quick reference.
- `assets/` - images used by the HTML guide.

## Guide Sections

The HTML guide is organized as:

1. Overview
2. Git Internal
3. Three States
4. Basic Workflow
5. Branching Strategy Intro
6. Trunk-Based Development
7. Git Flow
8. GitHub Flow
9. GitLab Flow
10. Release Branches
11. Branching Strategy Conclusion
12. Git Hooks
13. Conflict Resolution
14. Undo Decision Tree
15. Command-Line Guide

## Editing Notes

- Keep `git-knowledge-sharing-presentation.html` as the active one-page scrolling guide.
- Keep `git-knowledge-sharing-presentation-slides.html` as the preserved slide-based reference unless intentionally updating the fallback version.
- Use each image asset only once in the scrolling guide.
- Keep branching strategies as separate sections in the scrolling guide.
- Prefer visual emphasis through layout, cards, diagrams, and terminal snippets instead of long paragraphs.
