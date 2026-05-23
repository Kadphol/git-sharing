# Git Knowledge Sharing Session

## Session Goal

By the end of this session, developers should understand:

1. What Git is and how Git thinks about changes.
2. How to use basic Git commands confidently.
3. How teams collaborate through branches, pull/merge requests, and reviews.
4. Which branching strategy fits different project situations.
5. How Git hooks help improve quality.
6. How to resolve conflicts with merge and rebase.
7. How to safely undo mistakes.

---

# 1. Short Summary of Git

## Speaker Script

Git is a **distributed version control system**.

That means every developer has a full copy of the repository history on their machine, not just the latest files. This allows us to work offline, create branches cheaply, inspect history, compare changes, and collaborate safely.

The main idea of Git is simple:

> Git tracks snapshots of your project over time.

Every commit is like a checkpoint. When we commit, Git records the current state of our files, who made the change, when it happened, and a message describing why the change was made.

Git helps answer important engineering questions:

- What changed?
- Who changed it?
- Why was it changed?
- When was it changed?
- Can we go back safely?
- Can multiple people work in parallel?

## Visual Guide Prompt

Use this prompt to create a visual:

> Create a clean technical diagram explaining Git as a distributed version control system. Show three developers, each with a local repository containing full history, connected to a shared remote repository such as GitHub or GitLab. Include arrows for clone, pull, push, and merge request. Use a simple modern software engineering style.

---

# 2. Three States of Git

Git usually works with three main states:

```text
Working Directory → Staging Area → Repository
```

## Speaker Script

When we edit files, Git does not immediately save everything into history.

Git separates our work into three main areas.

The first is the **working directory**. This is where we edit files. Any new changes start here.

The second is the **staging area**, also called the index. This is where we choose which changes should be included in the next commit.

The third is the **repository**, where committed snapshots are stored permanently in Git history.

This separation is powerful because we can edit many files, but only commit related changes together.

For example, maybe I changed a login bug and also reformatted another file. I can stage only the login bug and commit that separately.

## Example Commands

```bash
git status
```

Shows where your changes are.

```bash
git add file.ts
```

Moves a change from working directory to staging area.

```bash
git commit -m "Fix login validation"
```

Moves staged changes into repository history.

## Visual Guide Prompt

> Create a simple three-column diagram showing Git states: Working Directory, Staging Area, and Local Repository. Show file changes moving from left to right using git add and git commit. Include git status as an inspection command across all three states.

---

# 3. Basic Commands and Collaboration

## Speaker Script

The basic Git workflow is usually:

```text
Clone → Branch → Change → Stage → Commit → Push → Pull Request → Review → Merge
```

This is the daily collaboration flow for most development teams.

We do not usually commit directly to the main branch. Instead, we create a branch for each feature, bug fix, or experiment. Then we push that branch to the remote repository and create a merge request or pull request.

Code review happens there. After review and CI checks pass, we merge the branch.

## Basic Commands

### Start working

```bash
git clone <repo-url>
cd <repo-name>
```

### Check current state

```bash
git status
git branch
git log --oneline
```

### Create a branch

```bash
git checkout -b feature/login-page
```

or newer style:

```bash
git switch -c feature/login-page
```

### Stage and commit

```bash
git add .
git commit -m "Add login page"
```

### Push branch

```bash
git push origin feature/login-page
```

### Get latest changes

```bash
git fetch origin
git pull origin main
```

### Merge main into your branch

```bash
git checkout feature/login-page
git merge main
```

### Rebase your branch on main

```bash
git checkout feature/login-page
git rebase main
```

## Collaboration Key Points

Good collaboration is not only about commands. It is also about habits.

A good team should agree on:

- Branch naming convention.
- Commit message style.
- Pull request size.
- Code review expectation.
- Merge strategy.
- CI/CD checks.
- Release process.
- Conflict resolution approach.

## Practical Rule

A good pull request should be:

```text
Small enough to review.
Clear enough to understand.
Safe enough to merge.
```

---

# 4. Branching Strategies

## 4.1 Trunk-Based Development

```text
main
 ├─ short-lived feature branch
 ├─ short-lived bugfix branch
 └─ short-lived experiment branch
```

## Speaker Script

Trunk-based development means the team integrates changes into the main branch frequently.

Branches should be short-lived, often less than one or two days. The goal is to reduce long-running branches and avoid painful merge conflicts.

This strategy works very well when the team has strong CI, automated tests, feature flags, and frequent deployment.

## Pros

- Fast integration.
- Fewer long-term conflicts.
- Works well with CI/CD.
- Encourages small pull requests.
- Good for teams that deploy frequently.

## Cons

- Requires discipline.
- Requires strong test coverage.
- Feature flags may be necessary.
- Risky if developers merge incomplete work carelessly.

## Use When

Use trunk-based development when:

- Your team deploys often.
- You have automated tests.
- You use feature flags.
- Your team can create small pull requests.
- You want fast delivery.

## Good For

Modern web apps, SaaS products, internal tools, agile product teams.

---

## 4.2 Git Flow

```text
main
 └─ develop
     ├─ feature/*
     ├─ release/*
     └─ hotfix/*
```

## Speaker Script

Git Flow is a more structured branching model.

There is a `main` branch for production-ready code and a `develop` branch for ongoing development. Features are created from `develop`. When preparing a release, the team creates a release branch. Hotfixes are created from `main`.

This gives strong separation between development, release, and production.

## Pros

- Clear release structure.
- Good for scheduled releases.
- Useful when production releases need strict control.
- Hotfix flow is explicit.

## Cons

- More complex.
- More branches to manage.
- Slower integration.
- Can create long-lived branches.
- Often too heavy for fast-moving web teams.

## Use When

Use Git Flow when:

- You have scheduled releases.
- You maintain multiple release versions.
- You need strong release governance.
- Production deployment is not continuous.

## Good For

Enterprise systems, mobile apps, on-premise software, regulated projects.

---

## 4.3 GitHub Flow / GitLab Flow

```text
main
 ├─ feature/*
 ├─ bugfix/*
 └─ hotfix/*
```

## Speaker Script

GitHub Flow is simpler than Git Flow.

The main branch is always deployable. Developers create branches from main, open pull requests, review changes, and merge back into main.

GitLab Flow extends this idea by adding environment branches, such as staging or production, when needed.

## Pros

- Simple.
- Easy to teach.
- Works well with pull requests.
- Good fit for web application teams.
- Less overhead than Git Flow.

## Cons

- Needs a stable main branch.
- Requires CI discipline.
- Release control may need extra process.
- Can be risky if main is not protected.

## Use When

Use GitHub/GitLab Flow when:

- You build web applications.
- You use pull requests or merge requests.
- You want simple collaboration.
- You deploy from main or environment branches.

## Good For

Most frontend/backend product teams, software houses, internal business apps.

---

## 4.4 Release Branch Strategy

```text
main
 ├─ feature/*
 └─ release/2026.05
```

## Speaker Script

A release branch strategy is used when the team wants to stabilize a specific release while development continues on main.

For example, we may create `release/2026.05` before production deployment. Only bug fixes go into that branch. Meanwhile, new features continue on main.

## Pros

- Allows release stabilization.
- Development can continue.
- Easier rollback and patching.
- Useful for QA/UAT cycles.

## Cons

- Fixes may need to be cherry-picked back.
- Release branches can become stale.
- Requires discipline around what goes into release branches.

## Use When

Use release branches when:

- QA needs time before production.
- You have UAT cycles.
- Multiple features are bundled into releases.
- Production deployment is controlled.

---

## Branching Strategy Recommendation

For most modern web teams:

```text
Default: GitHub Flow / GitLab Flow
Advanced: Trunk-Based Development + Feature Flags
Heavy Release Process: Git Flow or Release Branches
```

## Key Points for Good Collaboration

```text
1. Keep branches short-lived.
2. Keep pull requests small.
3. Pull or rebase frequently from main.
4. Write meaningful commit messages.
5. Use CI before merge.
6. Protect main branch.
7. Avoid force push on shared branches.
8. Use feature flags for incomplete features.
9. Resolve conflicts early.
10. Prefer clarity over clever Git history.
```

---

# 5. Git Hooks

## Speaker Script

Git hooks are scripts that run automatically when certain Git events happen.

For example, before committing, we can run linting, formatting, tests, or commit message validation.

Hooks help teams catch problems earlier before code reaches the remote repository.

Common hook points include:

```text
pre-commit
commit-msg
pre-push
post-merge
```

## Example Use Cases

### pre-commit

Run before a commit is created.

Useful for:

```text
formatting
linting
type checking
unit tests
secret scanning
```

### commit-msg

Run after writing a commit message but before the commit is saved.

Useful for enforcing commit style:

```text
feat: add login page
fix: correct token refresh bug
refactor: simplify user service
```

### pre-push

Run before pushing code to remote.

Useful for:

```text
test suite
build check
security scan
```

## Example with Husky

```bash
npm install husky --save-dev
npx husky init
```

Add pre-commit script:

```bash
echo "npm run lint" > .husky/pre-commit
```

Example package script:

```json
{
  "scripts": {
    "lint": "eslint .",
    "test": "vitest",
    "typecheck": "tsc --noEmit"
  }
}
```

## Speaker Note

Hooks should help developers, not block them unnecessarily.

A good hook is:

```text
Fast
Reliable
Clear
Useful
```

Do not put very slow checks in pre-commit. Put heavier checks in CI or pre-push.

## Visual Guide Prompt

> Create a visual workflow showing Git hooks in a developer workflow. Show developer writes code, runs git commit, pre-commit hook runs lint and format, commit-msg hook checks message style, git push triggers pre-push tests, then remote CI runs full validation. Use clear icons and arrows.

---

# 6. Resolve Conflicts with Merge and Rebase

## Speaker Script

A conflict happens when Git cannot automatically combine changes.

This usually occurs when two branches modify the same line or nearby lines in the same file.

Conflict resolution is not about “Git being broken.” It is Git asking a human to make a decision.

---

## Conflict Example

File:

```ts
const title = "Login";
```

Branch A changes it to:

```ts
const title = "Sign In";
```

Branch B changes it to:

```ts
const title = "Member Login";
```

When merging, Git may show:

```ts
<<<<<<< HEAD
const title = "Sign In";
=======
const title = "Member Login";
>>>>>>> feature/member-login
```

You must choose the correct final version:

```ts
const title = "Member Login";
```

Then stage and continue:

```bash
git add src/Login.tsx
git commit
```

---

## Resolving Conflict During Merge

```bash
git checkout feature/login-page
git merge main
```

If conflict happens:

```bash
git status
```

Open conflicted files, fix them, then:

```bash
git add .
git commit
```

To cancel merge:

```bash
git merge --abort
```

## Speaker Note

Merge creates a merge commit if histories have diverged. It preserves the fact that two branches were combined.

Use merge when you want to preserve branch history clearly.

---

## Resolving Conflict During Rebase

```bash
git checkout feature/login-page
git rebase main
```

If conflict happens:

```bash
git status
```

Fix files, then:

```bash
git add .
git rebase --continue
```

To skip current commit:

```bash
git rebase --skip
```

To cancel rebase:

```bash
git rebase --abort
```

## Speaker Note

Rebase rewrites your branch history by replaying your commits on top of another branch.

Use rebase to keep history linear and clean.

But be careful:

> Do not rebase public shared branches unless your team agrees.

---

## Merge vs Rebase

| Topic | Merge | Rebase |
|---|---|---|
| History | Preserves branch structure | Creates linear history |
| Commit SHA | Existing commits remain | Commit SHA changes |
| Conflict timing | Usually once during merge | May happen commit by commit |
| Best for | Shared branches, preserving context | Local branches, clean history |
| Risk | More merge commits | History rewriting risk |

## Practical Recommendation

Use this rule:

```text
Before sharing branch: rebase is fine.
After sharing branch: prefer merge, unless team agrees.
```

For daily work:

```bash
git fetch origin
git rebase origin/main
```

Then push:

```bash
git push origin feature/my-branch
```

If already pushed and rebased:

```bash
git push --force-with-lease
```

Avoid:

```bash
git push --force
```

Prefer:

```bash
git push --force-with-lease
```

Because it is safer and prevents overwriting someone else’s remote changes accidentally.

---

# 7. Undo Your Mistakes

## Speaker Script

Git gives us multiple ways to undo mistakes, but each command has a different purpose.

The most important question is:

> Has this change already been pushed/shared?

If it has not been shared, we can rewrite history more freely.

If it has already been shared, we should avoid rewriting history and use safer commands like `revert`.

---

## 7.1 Amend

Use amend when you want to fix the latest commit.

### Fix commit message

```bash
git commit --amend -m "Fix login validation"
```

### Add forgotten file to last commit

```bash
git add missing-file.ts
git commit --amend --no-edit
```

## Use When

Use amend when:

```text
You forgot a file.
You wrote a bad commit message.
The commit has not been shared yet.
```

## Be Careful

If you already pushed the commit, amend rewrites commit history.

You may need:

```bash
git push --force-with-lease
```

---

## 7.2 Restore

Use restore to discard or unstage changes.

### Discard working directory change

```bash
git restore file.ts
```

### Unstage a file

```bash
git restore --staged file.ts
```

## Use When

Use restore when:

```text
You changed a file but want to discard it.
You accidentally staged a file.
```

---

## 7.3 Reset

Reset moves your branch pointer to another commit.

There are three common modes.

### Soft reset

```bash
git reset --soft HEAD~1
```

Keeps changes staged.

Use when:

```text
You want to undo the last commit but keep files ready to recommit.
```

### Mixed reset

```bash
git reset HEAD~1
```

Keeps changes in working directory but unstaged.

Use when:

```text
You want to undo commit and restage manually.
```

### Hard reset

```bash
git reset --hard HEAD~1
```

Deletes commit and local changes.

Use carefully.

Use when:

```text
You want to completely discard local work.
```

## Warning

```bash
git reset --hard
```

can destroy uncommitted work.

Before using it, check:

```bash
git status
git log --oneline
```

---

## 7.4 Revert

Revert creates a new commit that undoes a previous commit.

```bash
git revert <commit-hash>
```

## Use When

Use revert when:

```text
The commit was already pushed.
Other people may already have pulled it.
You want a safe undo operation.
```

## Speaker Note

`revert` is safer for shared history because it does not delete or rewrite previous commits.

It says:

> “This change happened, and now we are intentionally undoing it.”

---

## Undo Decision Guide

```text
Need to fix last commit message?
→ git commit --amend

Need to add forgotten file to last commit?
→ git add file && git commit --amend --no-edit

Need to unstage file?
→ git restore --staged file

Need to discard local file changes?
→ git restore file

Need to undo local commit but keep changes?
→ git reset --soft HEAD~1

Need to completely discard local commit and changes?
→ git reset --hard HEAD~1

Need to undo a pushed/shared commit?
→ git revert <commit-hash>
```

## Visual Guide Prompt

> Create a Git undo decision tree. Start with the question: “Has the change been pushed/shared?” If no, show amend, restore, and reset options. If yes, show revert as the safest option. Include warnings for reset --hard and force push. Use a clean developer-friendly style.

---

# 8. Fun Facts About Git

## Fun Fact 1: Git Was Created by Linus Torvalds

Git was created by Linus Torvalds, the creator of Linux, in 2005.

Speaker angle:

> Git was designed for speed, distributed collaboration, and managing a very large codebase like the Linux kernel.

---

## Fun Fact 2: Git Does Not Store Diffs First

Many people think Git stores only file differences.

Actually, Git thinks more like snapshots. Each commit points to a snapshot of the project. Git is also smart about compression and object reuse internally.

---

## Fun Fact 3: Branches Are Cheap

In Git, a branch is basically just a pointer to a commit.

That is why creating a branch is fast:

```bash
git branch experiment
```

It does not copy the whole project.

---

## Fun Fact 4: Commit Hashes Are Content-Based

A commit hash is generated from commit content and metadata.

If you amend or rebase a commit, the hash changes because the commit is technically a new object.

---

## Fun Fact 5: Git Has a Built-In Manual

You do not need to memorize everything.

You can ask Git itself.

```bash
git help commit
git help rebase
git help reset
```

or:

```bash
man git
man git-commit
man git-rebase
```

---

# 9. Command Line Guide: Using `man` and Help

## Speaker Script

A strong developer does not memorize every command.

A strong developer knows how to find the right information quickly.

The command line has built-in documentation. The `man` command means “manual.”

## Examples

```bash
man git
```

Shows the Git manual.

```bash
man git-commit
```

Shows documentation for `git commit`.

```bash
git help log
```

Shows Git help for `log`.

```bash
git log --help
```

Also opens help for `git log`.

## Useful Navigation in `man`

Inside a man page:

```text
j / Down arrow    move down
k / Up arrow      move up
Space             next page
b                 previous page
/search-word      search
n                 next search result
q                 quit
```

Example:

```bash
man git-rebase
```

Then search:

```text
/continue
```

This helps you find `git rebase --continue`.

## Practical Tip

When you forget a command, try:

```bash
git <command> -h
```

Example:

```bash
git reset -h
git restore -h
git commit -h
```

This usually gives a shorter quick reference than the full manual.

---

# 10. Suggested Live Demo Flow

## Demo 1: Git Three States

```bash
mkdir git-demo
cd git-demo
git init

echo "Hello Git" > README.md
git status

git add README.md
git status

git commit -m "Initial commit"
git status
```

Explain:

```text
Working directory → Staging area → Repository
```

---

## Demo 2: Branch and Merge

```bash
git switch -c feature/add-intro

echo "This is a Git demo." >> README.md
git add README.md
git commit -m "Add intro"

git switch main
git merge feature/add-intro
```

Explain:

```text
Feature branch keeps work isolated.
Merge brings changes back.
```

---

## Demo 3: Create a Conflict

```bash
git switch -c feature/title-a
echo "Title: Git Basics" > README.md
git add README.md
git commit -m "Change title to Git Basics"

git switch main
git switch -c feature/title-b
echo "Title: Git Collaboration" > README.md
git add README.md
git commit -m "Change title to Git Collaboration"

git switch feature/title-a
git merge feature/title-b
```

Resolve conflict manually, then:

```bash
git add README.md
git commit
```

---

## Demo 4: Undo Mistake

Create a bad commit:

```bash
echo "wrong config" > config.txt
git add config.txt
git commit -m "Add wrong config"
```

Undo with reset:

```bash
git reset --soft HEAD~1
```

Show that changes are still staged:

```bash
git status
```

Then recommit correctly or discard.

---

## Demo 5: Revert a Shared Commit

```bash
git log --oneline
git revert <commit-hash>
```

Explain:

```text
Revert is safer than reset for shared commits.
```

---

# 11. Full Visual Guide Prompt

You can paste this into Figma AI, Canva, Gamma, or any visual-generation tool:

> Create a technical knowledge-sharing visual guide about Git for software developers. The guide should be modern, clean, and easy to understand. Include these sections:
>
> 1. What Git is: distributed version control system with local repositories and remote repository.
> 2. Three states of Git: Working Directory, Staging Area, Local Repository.
> 3. Basic workflow: clone, branch, change, add, commit, push, pull request, review, merge.
> 4. Branching strategies: Trunk-Based Development, Git Flow, GitHub/GitLab Flow, Release Branches. Include pros, cons, and when to use each.
> 5. Git hooks workflow: pre-commit, commit-msg, pre-push, CI.
> 6. Conflict resolution: merge conflict markers, resolve file, add, continue merge or rebase.
> 7. Undo decision tree: amend, restore, reset, revert.
> 8. Command-line help: man git, git help, git command -h.
>
> Use diagrams, arrows, decision trees, and small terminal command snippets. Style should be suitable for an internal engineering knowledge-sharing presentation.

---

# 12. Suggested Session Agenda

```text
00:00–05:00  Why Git matters
05:00–12:00  Git basics and three states
12:00–20:00  Basic commands and collaboration flow
20:00–35:00  Branching strategies
35:00–42:00  Git hooks
42:00–52:00  Conflict resolution: merge and rebase
52:00–58:00  Undo mistakes
58:00–60:00  Fun facts and Q&A
```

---

# 13. Closing Message for Speaker

You can close with this:

> Git is not just a command-line tool. It is a collaboration system.  
> Good Git usage helps the team move faster, review better, recover safely, and reduce deployment risk.  
> The goal is not to memorize every command. The goal is to understand how Git thinks, then use the right command for the right situation.
