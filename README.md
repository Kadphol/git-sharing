# Git Knowledge Sharing

Technical knowledge-sharing materials for explaining Git to software developers.

The main artifact is a one-page scrolling visual guide that covers Git internals, the three Git states, daily collaboration workflow, branching strategies, hooks, conflict resolution, undo commands, and command-line guide.

A preserved slide-based HTML version from the `main` branch is also included for comparison or fallback.

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

## Previous Slide Version

The previous slide-based version from `main` is available as:

```text
git-knowledge-sharing-presentation-slides.html
```

When using the local preview server, open:

```text
http://localhost:8765/git-knowledge-sharing-presentation-slides.html
```

## Repository Contents

- `git-knowledge-sharing-presentation.html` - scrolling visual guide for the session.
- `git-knowledge-sharing-presentation-slides.html` - preserved slide-based HTML version from `main`.
- `git-knowledge-sharing-script.md` - speaker script and source material.
- `git-workshop-guide.md` - facilitator guide for a longer workshop format.
- `git-workshop-visual.md` - visual aid markdown with Git diagrams.
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
