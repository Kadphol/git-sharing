# Git Workshop Runbook

This runbook is the presenter guide for the Git knowledge-sharing session. It
matches the one-page presentation and expands only the sections that benefit
from live commands, presenter preparation, or audience interaction.

Primary presentation:

```text
git-knowledge-sharing-presentation.html
```

Demo repository:

```text
taskly/
```

The `taskly/` directory is generated local session state and is ignored by Git.

## Presenter Guidelines

- Keep the presentation visible as the primary artifact. Use the terminal only
  when the current section needs proof or practice.
- Use a large terminal font and clear the screen between sections when useful.
- Before running a command, say what question the command answers.
- After running a command, point at the one or two lines that matter.
- Let attendees predict the output before merge, conflict, and undo demos.
- If a command fails, stop and explain the current Git state with `git status`
  before trying to fix it.
- Keep branching strategies as discussion, not command demos. The diagrams are
  the teaching artifact for that section.

## Session Map

| Presentation section | Runbook treatment |
|---|---|
| Overview | Opening framing |
| [Git Internal](git-knowledge-sharing-presentation.html#internal) | Live demo |
| [Three States](git-knowledge-sharing-presentation.html#states) | Live demo |
| [Basic Workflow](git-knowledge-sharing-presentation.html#workflow) | Live demo |
| [Branching Strategies](git-knowledge-sharing-presentation.html#branching-intro) | Discussion guide |
| [Git Hooks](git-knowledge-sharing-presentation.html#hooks) | Guided example |
| [Conflict Resolution](git-knowledge-sharing-presentation.html#conflicts) | Live demo |
| [Undo Decision Tree](git-knowledge-sharing-presentation.html#undo) | Live demo |
| [Command-Line Guide](git-knowledge-sharing-presentation.html#guide) | Live demo |

## Preparation Checklist

- Open `git-knowledge-sharing-presentation.html` in a browser.
- Keep `git-workshop-visual.md` open only if you want extra diagrams.
- Open a terminal at the repository root.
- Prepare `taskly/` using the setup block below.
- Confirm the terminal starts clean:

```bash
cd taskly
git status --short
git branch --list
git log --oneline --graph --decorate --all
```

Expected branches:

```text
feature/dark-mode
feature/greeting
feature/login
main
```

## Demo Repo Setup

Run this once before the session. It recreates `taskly/` from scratch.

```bash
set -e

cd /Users/kadphol/Documents/git-sharing
rm -rf taskly
mkdir -p taskly/src taskly/test
cd taskly

git init -b main
git config user.name "Workshop Bot"
git config user.email "workshop@demo.local"
git config commit.gpgsign false

export GIT_AUTHOR_DATE="2026-05-25T09:00:00+0700"
export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"

cat > README.md <<'EOF'
# taskly
A minimal task manager CLI.

## Usage
node src/app.js
EOF

cat > package.json <<'EOF'
{ "name": "taskly", "version": "1.0.0", "main": "src/app.js" }
EOF

cat > src/app.js <<'EOF'
const { listTasks } = require('./tasks');
const { greet } = require('./greet');

greet('World');
listTasks();
EOF

cat > src/tasks.js <<'EOF'
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

cat > src/greet.js <<'EOF'
function greet(name) {
  console.log('Hello, ' + name + '!');
}
module.exports = { greet };
EOF

cat > src/utils.js <<'EOF'
function formatDate(date) {
  return date.toISOString().split('T')[0];
}
module.exports = { formatDate };
EOF

cat > test/tasks.test.js <<'EOF'
const { addTask, listTasks } = require('../src/tasks');
// TODO: add proper test assertions
console.log('Tests pass!');
EOF

git add .
git commit -m "feat: initial taskly project structure"

cat >> src/tasks.js <<'EOF'

function deleteTask(id) {
  const idx = tasks.findIndex(t => t.id === id);
  if (idx !== -1) tasks.splice(idx, 1);
}
module.exports = { addTask, listTasks, completeTask, deleteTask };
EOF
git add src/tasks.js
git commit -m "feat(tasks): add deleteTask function"

echo "node_modules/" > .gitignore
git add .gitignore
git commit -m "chore: add .gitignore"
git tag workshop-start

git switch -c feature/dark-mode
cat > src/theme.js <<'EOF'
const themes = { light: '#ffffff', dark: '#1e293b' };
function getTheme(name) { return themes[name] || themes.light; }
module.exports = { getTheme };
EOF
git add src/theme.js
git commit -m "feat(ui): add theme support"

cat >> src/theme.js <<'EOF'

function applyTheme(name) {
  const color = getTheme(name);
  console.log('Applying theme:', color);
}
module.exports = { getTheme, applyTheme };
EOF
git add src/theme.js
git commit -m "feat(ui): implement applyTheme helper"
git tag workshop-feature-dark-mode

git switch main
cat >> src/utils.js <<'EOF'

function truncate(str, len) {
  return str.length > len ? str.slice(0, len) + '...' : str;
}
module.exports = { formatDate, truncate };
EOF
git add src/utils.js
git commit -m "feat(utils): add truncate helper"

cat >> README.md <<'EOF'

## Commands
- `node src/app.js list`    list all tasks
- `node src/app.js add <t>` add a task
EOF
git add README.md
git commit -m "docs: add usage commands to README"

git switch -c feature/login
cat > src/auth.js <<'EOF'
function login(username, password) {
  if (!username || !password) throw new Error('Missing credentials');
  return { token: 'tok_' + username, expiresIn: 3600 };
}
module.exports = { login };
EOF
git add src/auth.js
git commit -m "feat(auth): add login function"

cat >> src/auth.js <<'EOF'

function logout(token) {
  console.log('Invalidating token:', token);
}
module.exports = { login, logout };
EOF
git add src/auth.js
git commit -m "feat(auth): add logout function"
git tag workshop-feature-login

git switch main
git switch -c feature/greeting
cat > src/greet.js <<'EOF'
function greet(name) {
  console.log('Hey there, ' + name + '! Welcome back.');
}
module.exports = { greet };
EOF
git add src/greet.js
git commit -m "feat(greet): make greeting more casual"
git tag workshop-feature-greeting

git switch main
cat > src/greet.js <<'EOF'
function greet(name) {
  console.log('Good morning, ' + name + '. Have a productive day!');
}
module.exports = { greet };
EOF
git add src/greet.js
git commit -m "feat(greet): make greeting more formal"
git tag workshop-main

git log --oneline --graph --decorate --all
```

## Reset During The Session

Use this when a demo gets messy. It returns the main prepared branches to their
tagged starting points and deletes demo-only branches.

```bash
cd /Users/kadphol/Documents/git-sharing/taskly

git merge --abort 2>/dev/null || true
git rebase --abort 2>/dev/null || true
git switch main
git reset --hard workshop-main

for branch in \
  demo/basic-workflow \
  demo/conflict-main \
  demo/conflict-abort-main \
  demo/hooks-example \
  demo/recovered-work \
  demo/three-states \
  demo/undo-local \
  important-work
do
  git branch -D "$branch" 2>/dev/null || true
done

git branch -f feature/dark-mode workshop-feature-dark-mode
git branch -f feature/greeting workshop-feature-greeting
git branch -f feature/login workshop-feature-login

git status --short
git log --oneline --graph --decorate --all
```

## Opening

Presentation section: top of `git-knowledge-sharing-presentation.html`

Purpose: set expectations and explain why Git matters beyond memorizing
commands.

Presenter notes:

- Ask who has used `git add`, who has seen a conflict, and who can explain
  `HEAD`.
- Frame the session as a map of Git concepts: objects, states, workflow,
  branching choices, quality gates, conflicts, and undo decisions.
- Tell attendees the terminal is for evidence. The presentation remains the
  guide.

Transition line:

```text
Before we talk about commands, let's look at what Git stores.
```

## Demo 1: Git Internal

Presentation anchor: [Git Internal](git-knowledge-sharing-presentation.html#internal)

Purpose: show that commits point to trees, trees point to blobs, and refs point
to commits.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git status --short
```

Presenter commands:

```bash
git log --oneline -5
git cat-file -p HEAD
git cat-file -p HEAD^{tree}
git cat-file -p HEAD:src/tasks.js
find .git/objects -maxdepth 1 -type d | sort | head
cat .git/refs/heads/main
cat .git/HEAD
```

Expected observation:

- `HEAD` is a commit object with metadata, a parent, and a tree pointer.
- `HEAD^{tree}` lists file names mapped to blob or tree object IDs.
- `HEAD:src/tasks.js` prints the raw file content stored in Git.
- `.git/refs/heads/main` contains the commit SHA for the branch.

Reset note:

```bash
git switch main
git status --short
```

Transition line:

```text
Now that we know Git stores snapshots, let's see how a change becomes one.
```

## Demo 2: Three States

Presentation anchor: [Three States](git-knowledge-sharing-presentation.html#states)

Purpose: demonstrate working directory, staging area, and local repository.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git reset --hard workshop-main
git branch -D demo/three-states 2>/dev/null || true
git switch -c demo/three-states
```

Presenter commands:

```bash
git status

printf '\n# NEW SECTION\n' >> README.md
git status
git diff

git add README.md
git status
git diff --staged

git commit -m "docs: add new section header"
git log --oneline -3
```

Expected observation:

- `git status` names the state of the file.
- `git diff` shows working directory changes that are not staged.
- `git diff --staged` shows exactly what will be committed.
- The commit records only staged content.

Reset note:

```bash
git switch main
git branch -D demo/three-states
git reset --hard workshop-main
```

Transition line:

```text
Once we can make a clean commit, we can put that commit into the team workflow.
```

## Demo 3: Basic Workflow

Presentation anchor: [Basic Workflow](git-knowledge-sharing-presentation.html#workflow)

Purpose: walk through branch, change, add, commit, and push conceptually without
requiring a remote repository.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git reset --hard workshop-main
git branch -D demo/basic-workflow 2>/dev/null || true
```

Presenter commands:

```bash
git switch -c demo/basic-workflow
git branch --show-current

cat > src/labels.js <<'EOF'
function taskLabel(task) {
  return task.done ? '[done]' : '[todo]';
}
module.exports = { taskLabel };
EOF

git status
git add src/labels.js
git commit -m "feat(tasks): add task label helper"
git log --oneline --graph --decorate -4

git remote -v
git push -u origin demo/basic-workflow
```

Expected observation:

- The first commands create and commit a short-lived feature branch.
- `git remote -v` is empty in this local demo repo.
- The final push command should fail unless a remote is configured. Use that as
  the teaching point: push publishes local commits to a shared server.

Reset note:

```bash
git switch main
git branch -D demo/basic-workflow
git reset --hard workshop-main
```

Transition line:

```text
Branching is not only a command. It is a release and collaboration agreement.
```

## Branching Strategy Discussion

Presentation anchors:

- [Branching Strategies](git-knowledge-sharing-presentation.html#branching-intro)
- [Trunk-Based Development](git-knowledge-sharing-presentation.html#trunk)
- [Git Flow](git-knowledge-sharing-presentation.html#git-flow)
- [GitHub Flow](git-knowledge-sharing-presentation.html#github-flow)
- [GitLab Flow](git-knowledge-sharing-presentation.html#gitlab-flow)
- [Release Branches](git-knowledge-sharing-presentation.html#release)
- [Branching Conclusion](git-knowledge-sharing-presentation.html#branching-conclusion)

Purpose: choose vocabulary and tradeoffs, not run commands.

Discussion prompts:

- Which strategy does our team use today?
- How long do branches normally live?
- Where do we need release control: main branch, staging branch, release branch,
  or deployment tooling?
- What is our biggest bottleneck: review time, CI reliability, QA/UAT, or
  production approval?

Presenter guideline:

- Use the diagrams in the presentation as the source of truth.
- End with the recommendation slide: default to GitHub/GitLab Flow, move toward
  trunk-based when CI and feature flags are strong, and add release branches
  only when release governance needs them.

Transition line:

```text
Whatever branching model we choose, quality checks should happen before bad code reaches main.
```

## Demo 4: Git Hooks

Presentation anchor: [Git Hooks](git-knowledge-sharing-presentation.html#hooks)

Purpose: explain where hooks fit and why local hooks should be fast and clear.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git reset --hard workshop-main
git branch -D demo/hooks-example 2>/dev/null || true
git switch -c demo/hooks-example
```

Presenter commands:

```bash
mkdir -p .git/hooks

cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env sh
echo "pre-commit: checking for TODO markers"
if grep -R "TODO" src >/dev/null 2>&1; then
  echo "pre-commit: TODO marker found"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit

printf '\n// TODO: validate input\n' >> src/tasks.js
git add src/tasks.js
git commit -m "demo: trigger hook"

git status --short
git restore --staged src/tasks.js
git restore src/tasks.js
git status --short
```

Expected observation:

- The commit is blocked because the hook exits with a non-zero status.
- Hooks live inside `.git/hooks` for this local repo.
- This example is intentionally simple; real teams often use tools such as
  Husky, Lefthook, pre-commit, lint-staged, or CI.

Reset note:

```bash
rm -f .git/hooks/pre-commit
git restore --staged src/tasks.js 2>/dev/null || true
git restore src/tasks.js
git switch main
git branch -D demo/hooks-example
```

Transition line:

```text
Hooks catch predictable issues. Conflicts are different: Git needs a human decision.
```

## Demo 5: Conflict Resolution

Presentation anchor: [Conflict Resolution](git-knowledge-sharing-presentation.html#conflicts)

Purpose: trigger a real conflict, inspect the markers, abort once, then resolve
the conflict.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git reset --hard workshop-main
git branch -D demo/conflict-abort-main demo/conflict-main 2>/dev/null || true
```

Presenter commands - inspect both sides:

```bash
git show workshop-main:src/greet.js
git show workshop-feature-greeting:src/greet.js
```

Presenter commands - abort path:

```bash
git switch -c demo/conflict-abort-main workshop-main
git merge feature/greeting
git status
cat src/greet.js
git merge --abort
git status --short
```

Presenter commands - resolve path:

```bash
git switch -c demo/conflict-main workshop-main
git merge feature/greeting
git status
cat src/greet.js

cat > src/greet.js <<'EOF'
function greet(name) {
  console.log('Good morning, ' + name + '! Welcome back.');
}
module.exports = { greet };
EOF

git add src/greet.js
git commit --no-edit
git log --oneline --graph --decorate -6
node src/app.js
```

Expected observation:

- `<<<<<<< HEAD` is the current branch.
- `=======` separates the two versions.
- `>>>>>>> feature/greeting` is the incoming branch.
- A resolved conflict is just the final file content plus `git add`.

Reset note:

```bash
git merge --abort 2>/dev/null || true
git switch main
git branch -D demo/conflict-abort-main demo/conflict-main 2>/dev/null || true
git reset --hard workshop-main
```

Transition line:

```text
Conflict resolution is one kind of repair. Now let's choose the right undo command.
```

## Demo 6: Undo Decision Tree

Presentation anchor: [Undo Decision Tree](git-knowledge-sharing-presentation.html#undo)

Purpose: connect undo commands to sharing risk: local cleanup can rewrite
history, shared cleanup should preserve history.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
git reset --hard workshop-main
git branch -D demo/undo-local important-work demo/recovered-work 2>/dev/null || true
git switch -c demo/undo-local
```

Presenter commands - amend:

```bash
echo "forgotten note" > note.txt
git add note.txt
git commit -m "docs: add note"

echo "extra line" >> note.txt
git add note.txt
git commit --amend --no-edit
git log --oneline -3
```

Presenter commands - restore and reset:

```bash
echo "temporary work" > scratch.txt
git add scratch.txt
git status --short

git restore --staged scratch.txt
git status --short

git add scratch.txt
git commit -m "demo: commit scratch"
git reset --soft HEAD~1
git status --short

git restore --staged scratch.txt
rm scratch.txt
```

Presenter commands - revert:

```bash
echo "shared bad change" > revert-target.txt
git add revert-target.txt
git commit -m "demo: shared bad change"

git revert --no-edit HEAD
git log --oneline -5
```

Presenter commands - reflog recovery:

```bash
git switch main
git switch -c important-work
echo "important work" > important.txt
git add important.txt
git commit -m "feat: important local work"

git switch main
git branch -D important-work
git reflog -8
git switch -c demo/recovered-work HEAD@{1}
ls important.txt
```

Expected observation:

- `commit --amend` rewrites the last local commit.
- `restore --staged` moves a staged change back to the working directory.
- `reset --soft` removes a commit but keeps its changes staged.
- `revert` creates a new commit instead of deleting shared history.
- `reflog` can recover commits that are no longer reachable from a branch.

Reset note:

```bash
git switch main
git branch -D demo/undo-local important-work demo/recovered-work 2>/dev/null || true
git reset --hard workshop-main
```

Transition line:

```text
The goal is not to memorize every command. The goal is to know where Git keeps the manual.
```

## Demo 7: Command-Line Guide

Presentation anchor: [Command-Line Guide](git-knowledge-sharing-presentation.html#guide)

Purpose: show attendees how to find Git help from the terminal.

Setup state:

```bash
cd /Users/kadphol/Documents/git-sharing/taskly
git switch main
```

Presenter commands:

```bash
git help -a
git commit -h
git help rebase
man git
```

Expected observation:

- `git help -a` lists available Git commands.
- `git commit -h` gives quick flag help.
- `git help rebase` and `man git` open longer documentation.
- In man pages: `Space` moves forward, `/word` searches, `n` jumps to the next
  match, and `q` quits.

Reset note:

```bash
git status --short
```

Closing line:

```text
Git is safer when we understand the model: snapshots, refs, staging, branches, and sharing risk.
```
