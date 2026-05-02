# Git Mastery Workshop — Facilitator Guide

**Duration:** 60 min core · 30 min extended (optional advanced topics)  
**Audience:** Mixed engineers and non-engineers  
**Companion:** `git-workshop-visual.md` — open alongside this guide for all diagrams  
**Demo Repo:** `taskly` — set up in the section below before the session

---

## At-a-Glance Session Plan

| Part | Topic | Visual Aid § | Time | Type |
|---|---|---|---|---|
| 0 | Welcome & Setup | — | 5 min | Talk |
| 1 | What is Git + Internals | §1–2 | 15 min | Talk + Live Demo |
| 2 | Three Areas + Local↔Remote | §3 | 10 min | Talk + Demo |
| 3 | Branches & HEAD | §5 | 10 min | Talk + Demo |
| 4 | Branching Strategies | §6 | 10 min | Talk |
| 5 | Merge + Rebase | §7–8 | 20 min | Demo + Exercise |
| 6 | Conflict Resolution | §10 | 15 min | Demo + Exercise |
| 7 *(ext.)* | Recovery: reflog/reset/revert | §11 | 15 min | Demo + Exercise |
| — | Golden Rules + Q&A | §12 | 5 min | Talk |

> **Facilitator tip:** Keep `git-workshop-visual.md` open in a markdown viewer (GitHub, VS Code, Obsidian) on a second display — the Mermaid diagrams are your visual aid for each section.

---

## Pre-Session Checklist

Before attendees arrive:

- [ ] Terminal open, font size ≥ 16pt, dark theme
- [ ] `taskly` repo created (see setup below)
- [ ] Markdown viewer showing `git-workshop-visual.md`
- [ ] `git log --oneline --graph --all` gives a clean output in `taskly/`
- [ ] `git diff` and `git status` both return clean state

---

## Example Repository — `taskly`

Every live demo and exercise in this guide runs against a purpose-built demo project called **taskly** — a minimal task management CLI tool with a realistic commit history and pre-staged branches.

### What's in `taskly`

```
taskly/
  README.md          # project description
  package.json       # minimal Node config
  src/
    app.js           # entry point
    tasks.js         # task CRUD operations  ← conflict target
    utils.js         # shared helpers
    greet.js         # greeting module       ← conflict target
  test/
    tasks.test.js    # basic tests
```

### One-Time Setup — Run This Before the Session

Copy-paste this entire block into your terminal. It creates the `taskly` repo with all the branches and commit history you need for every scenario.

```bash
#!/usr/bin/env bash
# ==========================================================
# taskly — Git Workshop Demo Repository Setup Script
# Run once before your session. Safe to re-run (removes
# existing taskly/ directory first).
# ==========================================================

set -e
rm -rf taskly
mkdir taskly && cd taskly
git init
git config user.name "Workshop Bot"
git config user.email "workshop@demo.local"

# ── COMMIT A: Initial project ─────────────────────────────
mkdir -p src test
cat > README.md << 'EOF'
# taskly
A minimal task manager CLI.

## Usage
node src/app.js
EOF

cat > package.json << 'EOF'
{ "name": "taskly", "version": "1.0.0", "main": "src/app.js" }
EOF

cat > src/app.js << 'EOF'
const { listTasks } = require('./tasks');
const { greet } = require('./greet');

greet('World');
listTasks();
EOF

cat > src/tasks.js << 'EOF'
const tasks = [];

function addTask(title) {
  tasks.push({ id: tasks.length + 1, title, done: false });
}

function listTasks() {
  tasks.forEach(t => console.log(`[${t.done ? 'x' : ' '}] ${t.title}`));
}

function completeTask(id) {
  const task = tasks.find(t => t.id === id);
  if (task) task.done = true;
}

module.exports = { addTask, listTasks, completeTask };
EOF

cat > src/greet.js << 'EOF'
function greet(name) {
  console.log('Hello, ' + name + '!');
}
module.exports = { greet };
EOF

cat > src/utils.js << 'EOF'
function formatDate(date) {
  return date.toISOString().split('T')[0];
}
module.exports = { formatDate };
EOF

cat > test/tasks.test.js << 'EOF'
const { addTask, listTasks } = require('../src/tasks');
// TODO: add proper test assertions
console.log('Tests pass!');
EOF

git add .
git commit -m "feat: initial taskly project structure"

# ── COMMIT B ──────────────────────────────────────────────
cat >> src/tasks.js << 'EOF'

function deleteTask(id) {
  const idx = tasks.findIndex(t => t.id === id);
  if (idx !== -1) tasks.splice(idx, 1);
}
module.exports = { addTask, listTasks, completeTask, deleteTask };
EOF
git add src/tasks.js
git commit -m "feat(tasks): add deleteTask function"

# ── COMMIT C ──────────────────────────────────────────────
echo "node_modules/" > .gitignore
git add .gitignore
git commit -m "chore: add .gitignore"

# ── tag the clean initial state ───────────────────────────
git tag workshop-start

# ── BRANCH: feature/dark-mode (for FF merge demo) ─────────
git switch -c feature/dark-mode
cat > src/theme.js << 'EOF'
const themes = { light: '#ffffff', dark: '#1e293b' };
function getTheme(name) { return themes[name] || themes.light; }
module.exports = { getTheme };
EOF
git add src/theme.js
git commit -m "feat(ui): add theme support"

cat >> src/theme.js << 'EOF'

function applyTheme(name) {
  const color = getTheme(name);
  console.log('Applying theme:', color);
}
module.exports = { getTheme, applyTheme };
EOF
git add src/theme.js
git commit -m "feat(ui): implement applyTheme helper"

# ── Back to main — add commits so branches diverge ────────
git switch main
cat >> src/utils.js << 'EOF'

function truncate(str, len) {
  return str.length > len ? str.slice(0, len) + '...' : str;
}
module.exports = { formatDate, truncate };
EOF
git add src/utils.js
git commit -m "feat(utils): add truncate helper"

cat >> README.md << 'EOF'

## Commands
- `node src/app.js list`    list all tasks
- `node src/app.js add <t>` add a task
EOF
git add README.md
git commit -m "docs: add usage commands to README"

# ── BRANCH: feature/login (for 3-way merge + rebase demo) ─
git switch -c feature/login
cat > src/auth.js << 'EOF'
function login(username, password) {
  if (!username || !password) throw new Error('Missing credentials');
  return { token: 'tok_' + username, expiresIn: 3600 };
}
module.exports = { login };
EOF
git add src/auth.js
git commit -m "feat(auth): add login function"

cat >> src/auth.js << 'EOF'

function logout(token) {
  console.log('Invalidating token:', token);
}
module.exports = { login, logout };
EOF
git add src/auth.js
git commit -m "feat(auth): add logout function"

# ── BRANCH: feature/greeting (for conflict demo) ──────────
# Branch from main (NOT from feature/login)
git switch main

git switch -c feature/greeting
# Change greet.js — this will conflict with main's change below
cat > src/greet.js << 'EOF'
function greet(name) {
  console.log('Hey there, ' + name + '! Welcome back.');
}
module.exports = { greet };
EOF
git add src/greet.js
git commit -m "feat(greet): make greeting more casual"

# ── Back to main — change the SAME line in greet.js ───────
git switch main
cat > src/greet.js << 'EOF'
function greet(name) {
  console.log('Good morning, ' + name + '. Have a productive day!');
}
module.exports = { greet };
EOF
git add src/greet.js
git commit -m "feat(greet): make greeting more formal"

echo ""
echo "✅  taskly repo ready. Branch summary:"
git log --oneline --graph --all
echo ""
echo "Branches created:"
git branch
```

### Verify Setup Looks Right

After running the script, you should see output like:

```
* feature/greeting      feat(greet): make greeting more casual
* feature/login         feat(auth): add logout function
* feature/dark-mode     feat(ui): implement applyTheme helper
* main                  feat(greet): make greeting more formal
```

And `git log --oneline --graph --all` should show diverging histories.

---

### Scenario Reset Commands

Use these during the session to quickly rewind to a clean state for each exercise. Run them from inside the `taskly/` directory.

```bash
# ── Reset to clean main (before any merges) ───────────────
git switch main
git checkout workshop-start  # detached HEAD at clean state
git switch -C main           # rebuild main from tag

# ── Reset feature/greeting to pre-conflict state ──────────
git switch feature/greeting
git reset --hard origin/feature/greeting  # if pushed to remote
# OR: re-run relevant section of setup script

# ── Nuclear reset: delete and re-run setup script ─────────
cd .. && rm -rf taskly && bash setup-taskly.sh
```

---

## Part 0 — Welcome (5 min)

**Goal:** Set expectations, gauge the room, build rapport.

**Opening (30 sec):** Introduce yourself. One sentence: how long you've used Git, one moment where it saved (or nearly destroyed) your work.

**Icebreaker — show of hands:**
1. "Who has used `git add` and `git commit` before?"
2. "Who has seen a merge conflict?"
3. "Who knows what `HEAD` actually is?"

> The third question usually gets silence from most of the room — that's your hook. "By the end of this session, you'll know exactly what HEAD is, down to the file it lives in."

**Frame for non-engineers:** "You don't need to write code to benefit from this. Understanding Git helps you understand timelines, why 'the app is broken on the branch', why engineers can't 'just undo' a deployment — and it makes you a better collaborator with your engineering team."

**Rules for the session:**
- Questions anytime — raise your hand or type in chat
- We have a live terminal — we'll do real commands on a real project
- Mistakes are the lesson — if something breaks, that's a teaching moment

---

## Part 1 — What is Git + Internals (15 min)

> **Visual Aid:** Open §1 (What is Git) and §2 (Git Internals) in `git-workshop-visual.md`

### 1.1 What is Git? (3 min)

**Core message:** Git is a *distributed* version control system. Every developer has the complete history. No single point of failure.

**Talking points:**
- Created by Linus Torvalds in 2005 to manage the Linux kernel source code — designed for thousands of contributors at scale.
- Git is *not* GitHub. Git is the tool; GitHub is a hosting service built on top of it. You can use Git with no internet connection.
- **The analogy:** "Imagine Google Docs' version history — but for your entire codebase, with the ability for 50 people to be editing simultaneously in separate isolated copies, then intelligently combining their work."

**Non-engineer framing:** "Git is the reason your engineering team can have 15 people working on the same product without constantly overwriting each other. Without it, teams emailed zip files or had one person allowed to edit at a time."

**Key vocabulary to establish now:**
- **commit** — a permanent, named snapshot of the entire project at a point in time
- **SHA** — the commit's unique fingerprint (40-character hex, e.g. `a3f9e1c`)
- **repo** — the project folder that Git tracks (contains a hidden `.git/` directory)

---

### 1.2 Git Internals — Objects (7 min)

> **Visual Aid:** §2 object graph diagram (commit → tree → blob)

This is the section most courses skip. We won't. Understanding Git's storage model explains *why* everything else works the way it does.

**Core message:** Git stores everything as three object types in `.git/objects/`. Every object is addressed by its SHA.

| Object | Analogous to | Contains |
|---|---|---|
| **blob** | file | raw file content |
| **tree** | directory | list of blobs + sub-trees with names |
| **commit** | snapshot | pointer to root tree + author + message + parent SHA |

**The BIG Takeaway — say this explicitly:**

> "Git does NOT store diffs. Git stores a complete snapshot of every file at the time of each commit. What makes it efficient is that if a file hasn't changed, the new commit simply reuses the existing blob's SHA — no duplication."

**Live Demo — navigate the object graph:**

> Scenario setup: in `taskly/`, run this live on the first commit.

```bash
cd taskly

# Step 1: get the commit SHA
git log --oneline -5

# Step 2: cat-file the commit — reveals tree SHA, author, message
git cat-file -p HEAD

# Step 3: cat-file the root tree — reveals blobs and sub-trees
git cat-file -p HEAD^{tree}

# Step 4: cat-file a blob — reveals raw file content
git cat-file -p HEAD^{tree}:src/tasks.js

# Step 5: show where it lives on disk
ls .git/objects/       # directories = first 2 chars of SHA
```

**Expected output (approximate):**
```
$ git cat-file -p HEAD
tree 4e507fdc6d9044ccd8a4a3061324c9f711c4667d
parent 7d2b4a8b3e...
author Workshop Bot <workshop@demo.local> ...
committer Workshop Bot <workshop@demo.local> ...

feat(utils): add truncate helper
```

**Pause for reaction.** Most engineers are surprised they've never seen this before.

**Common question:** *"Why does my SHA differ from yours?"*  
Answer: "SHA is computed from content + author + timestamp + parent SHA. Change any one → completely different hash. Two developers making identical commits get different SHAs because the timestamps differ."

**Exercise (2 min — engineers only, others observe):**
```bash
# Navigate from HEAD to a specific file's content using only cat-file
git cat-file -p HEAD                 # find the tree SHA
git cat-file -p <tree-sha>           # find src/ sub-tree
git cat-file -p <src-tree-sha>       # find tasks.js blob SHA
git cat-file -p <blob-sha>           # print tasks.js content
```

---

## Part 2 — The Three Working Areas + Local↔Remote (10 min)

> **Visual Aid:** §3 flowchart diagram

### 2.1 Three Working Areas (5 min)

**Core message:** Every file change passes through three distinct areas before it's permanently recorded.

Walk through the flowchart left to right:

1. **Working Directory** — the files you can see and edit in your editor. When you save a file, the change lives here. Git knows about it (`git status` shows it as "modified") but has not recorded it.

2. **Staging Area (Index)** — a deliberate checkpoint. `git add` places a *snapshot* of the current state of a file here. "Think of it as packing a box before shipping. You decide exactly what goes in before you seal it."

3. **Local Repository** — `git commit` seals the box: it takes everything staged and permanently records it as a new commit in `.git/objects/`, complete with your message, timestamp, and author.

**Live Demo — three areas in action:**

> Scenario setup: clean state on `main` in `taskly/`

```bash
git switch main
git status                      # should be clean

# Make a change
echo "# NEW SECTION" >> README.md

git status                      # "modified: README.md" — working dir only
git diff                        # shows the raw diff

git add README.md
git status                      # now "staged for commit"
git diff --staged               # shows what's in staging

git commit -m "docs: add new section header"
git log --oneline -3            # your commit is now permanent
```

**Key point to make:** `git diff` (no flags) shows working directory vs staging. `git diff --staged` shows staging vs last commit. If you can never remember which is which, just run `git status` — it tells you everything.

**Common question:** *"Why not skip staging and commit everything directly?"*  
Answer: `git add -p` lets you stage individual *hunks* (chunks of a file) not whole files. You can commit half a file's changes while leaving the rest as work-in-progress. This is extremely powerful when cleaning up before a PR.

---

### 2.2 Local ↔ Remote (5 min)

> **Visual Aid:** §3 flowchart (remote side)

**Core message:** Remote is just the same repo on another computer (typically GitHub/GitLab).

| Command | Direction | What it does |
|---|---|---|
| `git clone <url>` | Remote → Local | First-time full download |
| `git fetch` | Remote → Local | Downloads new commits, does NOT touch working files |
| `git pull` | Remote → Local | `fetch` + `merge` into current branch |
| `git push` | Local → Remote | Uploads your committed changes |

**Critical distinction — fetch vs pull:**
```bash
git fetch origin             # safe: just downloads, nothing changes locally
git log origin/main --oneline # inspect what came in
git merge origin/main        # merge only when you're ready
# vs.
git pull                     # does both in one step — less control
```

**Analogy:** "fetch is like checking your email without opening any attachments. pull is like opening everything immediately."

---

## Part 3 — Branches and HEAD (10 min)

> **Visual Aid:** §5 — branch pointer diagram + HEAD diagram

### 3.1 What a Branch Really Is (4 min)

**Core message:** A branch is a 41-byte text file containing a single commit SHA. That's it.

**Live Demo — reveal the file:**

> Scenario setup: `taskly/` with `feature/login` branch present

```bash
# List all branches as files
ls .git/refs/heads/

# Cat one out — it's just a SHA
cat .git/refs/heads/main
cat .git/refs/heads/feature/login

# Both of these are the same commit right now?
# Compare with git log:
git log --oneline -1 main
git log --oneline -1 feature/login
```

**Point to make:** "This is why branching in Git is free and instant. It's creating a 41-byte file. Compare that to older systems (SVN, Perforce) where branching meant physically copying files."

**Branches move automatically:** every time you commit on a branch, that file's SHA is updated to the new commit's SHA. You never have to manage this yourself.

---

### 3.2 HEAD (3 min)

> **Visual Aid:** §5 HEAD diagram

**Core message:** HEAD is the "you are here" marker. It's another file, always pointing to your current branch.

```bash
cat .git/HEAD
# → ref: refs/heads/main

git switch feature/login
cat .git/HEAD
# → ref: refs/heads/feature/login
```

**Detached HEAD:** if you check out a specific commit SHA (not a branch), HEAD points directly at that SHA — not a branch. New commits you make here are "orphaned" — they'll be garbage-collected eventually unless you create a branch to preserve them.

```bash
git checkout abc1234   # detached HEAD
cat .git/HEAD          # → abc1234... (a SHA, not a branch name)
git switch -c rescue   # create a branch to save your work
```

---

### 3.3 Branch Commands (3 min)

```bash
git branch                    # list local branches
git branch -a                 # list local + remote branches
git branch foo                # create 'foo' at current commit
git switch foo                # switch to foo (HEAD now refs/heads/foo)
git switch -c feature/new     # create + switch
git branch -d foo             # safe delete (fails if unmerged)
git branch -D foo             # force delete
git log --oneline --graph --decorate --all  # visualise full history
```

**Exercise — see branches live (2 min):**
```bash
cd taskly
git branch                          # see all branches
cat .git/refs/heads/main            # inspect the SHA
cat .git/refs/heads/feature/login   # different SHA
git log --oneline --graph --all     # see the divergence visually
```

---

## Part 4 — Branching Strategies (10 min)

> **Visual Aid:** §6 — all three gitGraph diagrams + quadrant chart

**Core message:** There is no universally "correct" branching strategy. The right choice depends on how often you release and how large your team is.

### The Three Strategies (5 min)

**Talk through the visual aid diagrams** for each strategy. Key points per strategy:

**Git Flow:**
- Five branch types: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`
- `main` is only touched at release time (tagged `v1.0`, `v2.0`, etc.)
- `hotfix/*` is the only branch that can go directly from main → fix → main + develop
- **Best for:** apps that have distinct versioned releases (mobile apps, SDKs, enterprise software)
- **Avoid if:** your team deploys to production daily — the release branch ceremony becomes a bottleneck

**GitHub Flow:**
- Two types: `main` (always production-ready) + short-lived `feature/*` branches
- Entire collaboration happens through Pull Requests
- **Best for:** web apps, SaaS products with continuous deployment
- **Rule:** if main isn't deployable at any moment, something went wrong

**Trunk-Based Development:**
- Everyone commits directly to `main` (or uses extremely short-lived branches, hours not days)
- Incomplete features hidden behind feature flags in code
- Requires high test coverage and mature CI/CD
- **Best for:** experienced teams, platforms like Google / Meta internal development

### Comparison (2 min)

```
Release cadence:  low ←──────────────────────────→ high
                 Git Flow    GitHub Flow    Trunk-Based
```

**For non-engineers:** "These are team agreements, like 'what naming convention do we use' or 'how do we handle code review.' They don't change what Git can do — they just say how the team uses it."

**Discussion question (3 min):** "Which strategy do you think our team currently uses — or *should* use? What's the main bottleneck in how we manage code changes today?"

---

## Part 5 — Merge and Rebase (20 min)

> **Visual Aid:** §7 (Merge) and §8 (Rebase)

### 5.1 Fast-Forward Merge (4 min)

**Core message:** When there's no divergence, Git just moves a pointer. No new commit is created.

**Scenario setup — state before demo:**
```bash
cd taskly
git switch main
# Ensure feature/dark-mode is ahead of main (it was created before
# main got more commits — but let's verify)
git log --oneline --graph --all
# You should see feature/dark-mode branching off BEFORE main's recent commits
# If main has moved past feature/dark-mode, do a fast-forward demo differently:
git switch -c demo/ff-test
echo "ff change" >> README.md
git add . && git commit -m "demo: ff commit"
git switch main
```

**Live Demo:**
```bash
# State: feature/dark-mode is ahead of where it branched from main
# (OR use demo/ff-test from above)
git switch main
git merge feature/dark-mode    # or demo/ff-test

# Output will say:
# Updating a665b08..b23e632
# Fast-forward
#  src/theme.js | 10 +++++
```

**After merge:**
```bash
git log --oneline --graph --all
# No merge commit — feature/dark-mode's commits are now directly on main
```

**Point to make:** "The feature/dark-mode pointer and the main pointer now point to the same commit. No new commit was created. This is the cleanest possible merge."

---

### 5.2 Three-Way Merge (5 min)

**Core message:** When both branches have moved on since their common ancestor, Git creates a new merge commit with two parents.

**Scenario setup — diverged state:**

Both `main` and `feature/login` have commits since they diverged. Verify:
```bash
git log --oneline --graph --all
# You should see:
# * <sha> (main) feat(greet): make greeting more formal
# * <sha> docs: add usage commands to README
# | * <sha> (feature/login) feat(auth): add logout function
# | * <sha> feat(auth): add login function
# |/
# * <sha> feat(utils): add truncate helper
```

**Live Demo:**
```bash
git switch main
git merge feature/login    # three-way merge
# Git opens an editor for the merge commit message — accept default with :wq or Ctrl+O Ctrl+X
```

**After merge:**
```bash
git log --oneline --graph --decorate

# *   <sha> (HEAD -> main) Merge branch 'feature/login'
# |\
# | * <sha> (feature/login) feat(auth): add logout function
# | * <sha> feat(auth): add login function
# * | <sha> feat(greet): make greeting more formal
# * | <sha> docs: add usage commands to README
# |/
# * <sha> feat(utils): add truncate helper
```

**Point to make:** "See the `|\` and `|/` lines? That's the branch existing in history. The merge commit at the top has two SHAs in its parent list — you can literally see both lines of development."

**Inspect the merge commit:**
```bash
git cat-file -p HEAD
# Shows: parent <sha1>
#         parent <sha2>   ← two parents!
```

---

### 5.3 Rebase — Replaying Commits (7 min)

> **Visual Aid:** §8 before/after gitGraph diagrams

**Core message:** Rebase picks up your commits and replays them one-by-one onto a new base. The result is a linear history. Each replayed commit gets a new SHA.

**Scenario setup — reset to diverged state:**

We need `feature/login` diverging from an older `main`. Let's use a fresh branch to demonstrate without destroying the previous merge:

```bash
# Reset for rebase demo
git switch main
git reset --hard workshop-start   # go back to the tag we set
git switch -c demo/rebase-test feature/login  # copy feature/login
git log --oneline --graph --all   # see divergence
```

**Live Demo:**
```bash
# We are on demo/rebase-test (which mirrors feature/login)
# main has commits B, C that demo/rebase-test doesn't
git switch demo/rebase-test

git log --oneline --graph --all   # shows diverged state

# Now rebase
git rebase main

git log --oneline --graph --all   # now linear!
```

**Output:**
```
* <new-sha> feat(auth): add logout function     ← B' (replayed, new SHA)
* <new-sha> feat(auth): add login function      ← A' (replayed, new SHA)
* <sha>     docs: add usage commands to README  ← main's commits
* <sha>     feat(utils): add truncate helper
* <sha>     feat: initial taskly project structure
```

**Point to make:** "Those feature commits look the same but they have brand new SHAs. Content identical, parent different → different hash. This is what 'rewriting history' means — and why you must never do this to commits others have already pulled."

**Now you can fast-forward merge:**
```bash
git switch main
git merge demo/rebase-test   # Fast-forward!
git log --oneline --graph    # perfectly linear history
```

---

### 5.4 Interactive Rebase — Cleaning Up (4 min)

**Core message:** Before opening a PR, interactive rebase lets you squash "fix typo" commits, reorder, reword, or drop commits entirely.

**Scenario — messy commit history:**
```bash
git switch -c demo/messy
echo "v1" > messy.txt && git add . && git commit -m "WIP: starting feature"
echo "v2" > messy.txt && git add . && git commit -m "fix typo"
echo "v3" > messy.txt && git add . && git commit -m "fix typo again"
echo "v4" > messy.txt && git add . && git commit -m "finally done"
git log --oneline   # 4 commits, embarrassing history
```

**Live Demo:**
```bash
git rebase -i HEAD~4   # edit the last 4 commits
```

The editor opens:
```
pick a1b2c3d WIP: starting feature
pick e4f5678 fix typo
pick b9c0d1e fix typo again
pick f2a3b4c finally done
```

Change to:
```
reword a1b2c3d WIP: starting feature
fixup  e4f5678 fix typo
fixup  b9c0d1e fix typo again
pick   f2a3b4c finally done
```

Save and exit. Git prompts for the new commit message for the first commit:
```
feat(demo): add messy feature cleanly
```

**After:**
```bash
git log --oneline   # 2 clean commits instead of 4
```

**Point to make:** "This is the professional habit. Build a messy history while coding, then clean it up before the PR. Your reviewers will thank you."

---

### Exercise: Simulate the Full Workflow (3 min)

> Run this as a facilitator-led walkthrough, or have participants follow along on their own machines.

```bash
# 1. Start from clean main
git switch main

# 2. Create a feature branch
git switch -c feature/exercise

# 3. Make 3 small commits (simulating real development)
echo "step 1" > exercise.txt && git add . && git commit -m "step 1"
echo "step 2" >> exercise.txt && git add . && git commit -m "step 2"
echo "step 3" >> exercise.txt && git add . && git commit -m "step 3"

# 4. Rebase to make sure you're up to date with main
git rebase main

# 5. Clean up your history
git rebase -i HEAD~3
# → squash all 3 into one: "feat(exercise): complete exercise feature"

# 6. Merge into main
git switch main
git merge feature/exercise   # fast-forward because you rebased
git log --oneline --graph

# 7. Clean up
git branch -d feature/exercise
```

---

## Part 6 — Conflict Resolution (15 min)

> **Visual Aid:** §10 — conflict markers + step-by-step flowchart

### 6.1 What Causes a Conflict (3 min)

**Core message:** Git only fails to merge when two branches modify the *same lines* in the *same file* from their common ancestor. Otherwise Git resolves automatically.

**Scenario — the `taskly` repo is already set up for this:**

```bash
# Verify the conflict setup
git log --oneline --graph --all
# You should see:
# * (main) feat(greet): make greeting more formal
# | * (feature/greeting) feat(greet): make greeting more casual
# |/
# * feat: initial taskly project structure
#
# Both branches changed src/greet.js line 2 — a conflict is guaranteed
```

**Show both versions before merging:**
```bash
git show main:src/greet.js         # "Good morning, World..."
git show feature/greeting:src/greet.js  # "Hey there, World..."
```

"These both changed the same line differently from the common ancestor. Git cannot auto-resolve which greeting is correct. That's a human decision."

---

### 6.2 Trigger and Resolve a Conflict (8 min)

**Live Demo:**

```bash
# Step 1 — trigger the conflict
git switch main
git merge feature/greeting
# Output:
# CONFLICT (content): Merge conflict in src/greet.js
# Automatic merge failed; fix conflicts and then commit the result.

# Step 2 — find what's conflicted
git status
# → both modified: src/greet.js

# Step 3 — look at the raw conflict markers
cat src/greet.js
```

**Show on screen:**
```javascript
function greet(name) {
<<<<<<< HEAD
  console.log('Good morning, ' + name + '. Have a productive day!');
=======
  console.log('Hey there, ' + name + '! Welcome back.');
>>>>>>> feature/greeting
}
module.exports = { greet };
```

**Explain each marker:**
- `<<<<<<< HEAD` — what your current branch (main) has
- `=======` — the divider
- `>>>>>>> feature/greeting` — what the incoming branch has

**Resolve — choose one or combine:**
```bash
# Open in your editor and decide — for demo, let's combine both:
cat > src/greet.js << 'EOF'
function greet(name) {
  console.log('Good morning, ' + name + '! Welcome back.');
}
module.exports = { greet };
EOF

# Step 4 — mark as resolved
git add src/greet.js

# Step 5 — complete the merge
git merge --continue
# (accepts the default merge commit message)

# Step 6 — verify
git log --oneline --graph
node src/app.js   # confirm it still runs
```

**Abort path (show this too):**
```bash
# If you get overwhelmed mid-conflict:
git merge --abort    # returns to pre-merge state as if nothing happened
```

---

### Exercise: Create Your Own Conflict (4 min)

Participants run this themselves to experience the full cycle:

```bash
# Setup (if starting fresh)
mkdir conflict-exercise && cd conflict-exercise
git init

# Common ancestor
echo "The colour is gray." > colours.txt
git add . && git commit -m "A: initial"

# Branch 1: British spelling
git switch -c feature/british
echo "The colour is grey." > colours.txt
git add . && git commit -m "B: use British spelling"

# Branch 2: main uses American
git switch main
echo "The color is gray." > colours.txt
git add . && git commit -m "C: use American spelling"

# Trigger conflict
git merge feature/british
# → CONFLICT

# Resolve: pick your preferred spelling
echo "The colour is grey." > colours.txt   # (or either variant)
git add colours.txt
git merge --continue

# Verify
git log --oneline --graph
```

---

## Part 7 (Extended) — Recovery: reflog, reset, revert (15 min)

> **Visual Aid:** §11 — reflog, reset table, revert diagram
> 
> *Skip this section if time is tight. It works best as a standalone follow-up session.*

### 7.1 reflog — Nothing is Ever Really Lost (5 min)

> **Core message:** `git reflog` records every position HEAD has been at — including commits from deleted branches.

**Scenario — simulate deleting "important" work:**

```bash
cd taskly
git switch main

# Create a branch with "irreplaceable" work
git switch -c important-work
cat > src/payment.js << 'EOF'
function processPayment(amount) {
  return { success: true, amount, ref: 'PAY_' + Date.now() };
}
module.exports = { processPayment };
EOF
git add . && git commit -m "feat(payment): critical payment integration"

# "Accidentally" delete it
git switch main
git branch -D important-work   # gone!
```

**Recovery:**
```bash
git reflog
# HEAD@{0}: checkout: moving from important-work to main
# HEAD@{1}: commit: feat(payment): critical payment integration  ← FOUND IT
# HEAD@{2}: checkout: moving from main to important-work
# ...

# Grab the SHA from HEAD@{1}
git switch -c recovered-work HEAD@{1}

# Verify the file is back
ls src/payment.js   # ✓ it's there
```

**Point to make:** "Almost nothing in Git is permanently lost. Reflog keeps every HEAD movement for ~30-90 days. This is your safety net. Before panicking, always run `git reflog`."

---

### 7.2 git reset — Undo Commits Locally (5 min)

> **Core message:** `git reset` moves HEAD (and the branch pointer) backward. Three modes control what happens to the uncommitted changes.

| Mode | Staged? | Working dir? | Use case |
|---|---|---|---|
| `--soft` | Changes kept staged | Changes kept | Want to recommit differently |
| `--mixed` (default) | Changes moved to working dir | Changes kept | Want to restage selectively |
| `--hard` | Changes discarded | Changes discarded | Truly throw away last commit |

**Live Demo — soft reset:**
```bash
cd taskly
git switch main

# Make a commit we want to undo
echo "bad idea" > bad.txt
git add . && git commit -m "bad commit"
git log --oneline -3   # see the bad commit

# Soft reset — undo commit but keep changes staged
git reset --soft HEAD~1
git status             # bad.txt still staged
git log --oneline -3   # commit gone

# Fix and recommit
git restore --staged bad.txt   # unstage it
rm bad.txt
```

**Warning about `--hard`:**
```bash
# This is the dangerous one:
git reset --hard HEAD~1   # commit gone AND working dir reverted
# recovery: git reflog → find the SHA → git switch -c rescue <sha>
```

---

### 7.3 git revert — Safe Undo for Shared Branches (3 min)

> **Core message:** `git revert` creates a *new* commit that undoes a previous one. History is not rewritten — safe to use even after pushing.

**Scenario:**
```bash
# Imagine this commit made it to main and was already pushed
git log --oneline -5
# Copy the SHA of a commit you want to undo

git revert <sha>   # creates a new "Revert ..." commit

git log --oneline --graph -5   # the bad commit is still there, but cancelled by the revert
```

**Analogy:** "reset is like deleting an email from your sent folder — it's gone from the record. revert is like sending a follow-up email saying 'please disregard my previous message' — both emails exist, but the effect is cancelled."

**Rule of thumb:**
- `reset` — local, private branch, before pushing
- `revert` — after pushing, or on any shared branch

---

### 7.4 cherry-pick — Take One Commit (2 min)

**Use case:** a critical fix was merged to `develop` but production needs it immediately, without the other in-progress features.

```bash
# Find the specific commit SHA on develop
git log --oneline develop | grep "fix:"

# Apply just that one commit to main
git switch main
git cherry-pick <sha>

git log --oneline main   # the fix is now on main too
```

**Warning:** cherry-pick duplicates the commit (new SHA, same content). If you later merge develop into main, Git will try to apply the same change again — usually results in a conflict. Use judiciously.

---

## Wrap-Up — Golden Rules + Q&A (5 min)

> **Visual Aid:** §12 — Golden Rules diagram

Go through each rule. After each, ask: "Has anyone experienced the consequences of breaking this one?"

| Rule | Talking hook |
|---|---|
| **01** Never force-push to main | "Has anyone seen history suddenly disappear from a branch?" |
| **02** Write meaningful commit messages | "Has anyone run `git log` looking for a bug and found 40 'fix' messages?" |
| **03** Commit small and often | "Has anyone had to review a 300-file PR? How did that go?" |
| **04** Branch before you change | "Raise your hand if you've worked directly on main and regretted it." |
| **05** Rebase locally, merge to integrate | "The pattern: rebase before PR, merge when done." |
| **06** NEVER rebase a public branch | "If you've pushed it, don't rebase it. Period." |
| **07** Run tests before pushing | "Broken CI on main blocks everyone. It's the fastest way to lose team trust." |
| **08** Use reflog before you panic | "Before you think you've lost work: `git reflog`. Almost nothing is gone forever." |

---

## Common Q&A

**Q: What's the difference between `git pull` and `git fetch`?**  
A: `fetch` downloads new commits from remote but does not touch your working files. `pull` = `fetch` + `merge`. Use `fetch` when you want to inspect before merging. Use `pull` for the quick everyday case.

**Q: What is HEAD, really?**  
A: A file at `.git/HEAD` containing the name of your current branch. When you commit, the branch pointer advances. HEAD just follows along. `cat .git/HEAD` during the session proves it.

**Q: When should I use `git stash`?**  
A: When you need to switch branches but have work-in-progress you're not ready to commit. `git stash` shelves it; `git stash pop` restores it. Tip: `git stash push -m "WIP: login form"` gives it a label so you remember what it is.

**Q: What is a Pull Request (PR)?**  
A: A GitHub/GitLab UI feature — not a Git command. It's a request to merge your branch, wrapped in a discussion thread and CI gate. `git merge` is what actually happens; the PR is the human review layer on top.

**Q: How do I undo a commit I already pushed?**  
A: Use `git revert <sha>` — creates a new commit that cancels the previous one without rewriting history. Never use `git reset` + force-push on a shared branch.

**Q: What is `git bisect`?**  
A: A binary search through your commit history to find which commit introduced a bug. Run `git bisect start`, mark the current (bad) commit with `git bisect bad`, mark a known-good older commit with `git bisect good <sha>`, and Git will check out the midpoint commit for you to test. Extremely useful for large codebases.

**Q: What's the difference between `git merge --squash` and interactive rebase squash?**  
A: `--squash` collapses all the feature's commits into *staged changes* on your current branch — you still have to commit it manually, and the branch pointer doesn't advance. Interactive rebase squash actually rewrites the commits in-place. Use `--squash` for a one-step clean merge; use interactive rebase when you want more control over the commit history.

---

## Appendix A — Full Command Reference

### Inspection
```bash
git status                           # three-area overview
git log --oneline --graph --all      # visual history of all branches
git log --oneline --graph --decorate # with branch/tag labels
git diff                             # working dir vs staging
git diff --staged                    # staging vs last commit
git show <sha>                       # inspect one commit
git blame <file>                     # who changed which line
git reflog                           # full HEAD movement history
git cat-file -p <sha>                # raw object content
git cat-file -t <sha>                # object type (commit/tree/blob)
```

### Daily Workflow
```bash
git add <file>                       # stage specific file
git add .                            # stage everything
git add -p                           # interactively stage hunks
git commit -m "type(scope): message" # commit
git commit --amend                   # fix the last commit message
git push origin <branch>             # push branch
git push -u origin <branch>          # push + set upstream
git pull                             # fetch + merge
git fetch --prune                    # download + remove stale refs
```

### Branching
```bash
git branch                           # list local
git branch -a                        # list local + remote
git switch -c <branch>               # create + switch
git switch <branch>                  # switch
git branch -d <branch>               # safe delete
git branch -D <branch>               # force delete
git branch -m <old> <new>            # rename
```

### Merging & Rebasing
```bash
git merge <branch>                   # merge (auto-detects FF or 3-way)
git merge --no-ff <branch>           # force merge commit
git merge --squash <branch>          # collapse to staged changes
git merge --abort                    # cancel mid-merge
git rebase <branch>                  # replay current branch onto <branch>
git rebase -i HEAD~N                 # interactive: edit last N commits
git rebase --onto <new> <old> <br>   # rebase onto a different base
git rebase --continue                # after resolving conflict
git rebase --abort                   # cancel entirely
git cherry-pick <sha>                # apply one commit
```

### Conflict Resolution
```bash
git status                           # shows "both modified" files
git diff                             # shows conflict markers inline
git mergetool                        # open visual merge tool
git show :1:<file>                   # common ancestor version
git show :2:<file>                   # our (current branch) version
git show :3:<file>                   # their (incoming) version
git add <file>                       # mark as resolved
git merge --continue
git rebase --continue
```

### Undoing
```bash
git restore <file>                   # discard working dir changes
git restore --staged <file>          # unstage
git reset HEAD~1                     # undo last commit (keep changes unstaged)
git reset --soft HEAD~1              # undo last commit (keep changes staged)
git reset --hard HEAD~1              # undo last commit (discard changes)
git revert <sha>                     # new commit that undoes <sha>
git stash                            # shelve uncommitted work
git stash push -m "label"            # shelve with label
git stash list                       # see all stashes
git stash pop                        # restore last stash
git stash apply stash@{2}            # restore specific stash
```

---

## Appendix B — Commit Message Convention

```
<type>(<optional scope>): <short imperative description>
[blank line]
[optional body — explains WHY, not WHAT]
[blank line]
[optional footer — Closes #123, BREAKING CHANGE: ...]

Types:
  feat      New feature
  fix       Bug fix
  docs      Documentation only
  style     Formatting, no logic change
  refactor  Code restructure, no feat/fix
  perf      Performance improvement
  test      Add/update tests
  chore     Build, tooling, CI

Examples:
  feat(auth): add JWT refresh token rotation
  fix(tasks): prevent duplicate task IDs on concurrent add
  refactor(utils): extract date formatting to shared helper
  docs(readme): add quickstart section
  chore(ci): add GitHub Actions workflow for tests
```

---

*Git Mastery Workshop Facilitator Guide · Updated May 2026*  
*Companion: `git-workshop-visual.md` · Demo repo: `taskly` (setup script above)*
