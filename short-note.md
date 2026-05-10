## Table of contents

1. [What's Git?](#1-whats-git)
2. [Git internals](#2-git-internals)
3. [Three states of Git](#3-three-states-of-git)
4. [Basic git commands](#4-basic-git-commands)
5. [Branch strategies](#5-branch-strategies)
6. [Resolve conflicts](#6-resolve-conflicts)
7. [Change history](#7-change-history)
8. [Remark](#8-remark)

## 1. What's Git?

- Git is a distributed version control system that allows multiple developers to work on the same codebase simultaneously. It tracks changes to files and allows for collaboration, branching, and merging of code.
- Git was created by Linus Torvalds in 2005 to manage the development of the Linux kernel. It has since become one of the most popular version control systems in the world,
- Git is not the only version control system available, but it is widely used due to its speed, flexibility, and powerful features. Other popular version control systems include Subversion (SVN) and Mercurial.

## 2. Git internals

- start with `git init` create `.git` directory, which contains all the metadata and objects for the repository.
- Git uses a content-addressable file system to store objects, which means that each object is identified by a unique hash value based on its content. This allows Git to efficiently store and manage changes to files over time.
- Git uses a directed acyclic graph (DAG) to represent the history of commits in a repository. Each commit is represented as a node in the graph, and the edges between nodes represent the parent-child relationships between commits. This allows Git to efficiently manage branching and merging of code, as well as to track the history of changes to files over time.

## 3. Three states of Git

- Git has three main states: the working directory, the staging area, and the repository. The working directory is where you make changes to files, the staging area is where you prepare changes to be committed, and the repository is where Git stores all the commits and their associated metadata.
- When you make changes to files in the working directory, Git tracks those changes and allows you to stage them for commit. Staging allows you to prepare changes for commit and to organize your commits in a logical way. Once you have staged your changes, you can commit them to the repository, which creates a new commit object that contains the changes you made, along with metadata such as the author and the commit message.

## 4. Basic git commands

- `git init`: Initializes a new Git repository in the current directory.
- `git add <file>`: Stages changes to a file for commit.
- `git commit -m "message"`: Commits staged changes to the repository with a commit message.
- `git status`: Shows the current status of the working directory and staging area.
- `git log`: Shows the commit history of the repository.
- `git branch`: Lists all branches in the repository.
- `git checkout <branch>`: Switches to a different branch.
- `git switch <branch>`: Switches to a different branch (alternative to `git checkout`).
- `git restore <file>`: Restores a file to its state in the last commit.
- `git pull`: Fetches changes from a remote repository and merges them into the current branch.
- `git push`: Pushes changes from the local repository to a remote repository.

## 5. Branch strategies

- Git allows for branching, which is a powerful feature that allows developers to work on different features or bug fixes in isolation from each other. There are several common branch strategies that teams use to manage their codebase, including:
  - Git Flow: A branching model that defines specific branches for development, testing, and production.
  - GitHub Flow: A simpler branching model that focuses on feature branches and pull requests.
  - GitLab Flow: A branching model that combines elements of Git Flow and GitHub Flow, with a focus on continuous integration and deployment.
  - Trunk-based development: A branching model that emphasizes keeping the main branch (trunk) stable and using short-lived feature branches for development.
- Main ideas:
  - naming conventions
  - PR/MRs
  - Keep branchs short-lived
  - CI/CD
- What's best for what and why with how.

## 6. Resolve conflicts

- There are several ways to resolve conflict:
  - manually edit the conflicting files to resolve the conflicts, and then stage and commit the changes.
  - merge the conflicting branches using `git merge`, which will automatically attempt to resolve conflicts. If there are conflicts that cannot be automatically resolved, Git will mark the conflicting files and allow you to manually resolve them.
  - rebase the conflicting branch using `git rebase`, which will apply the changes from the conflicting branch on top of the current branch. If there are conflicts during the rebase process, Git will pause and allow you to manually resolve them before continuing.
    - tip for rebase: `git config --global rerere.enabled true` to enable the "reuse recorded resolution" feature, which allows Git to remember how you resolved conflicts and automatically apply the same resolution if the same conflict occurs again in the future.
    - https://git-scm.com/docs/git-rerere

## 7. Change history

- Git allows you to view the history of changes to files in a repository using the `git log` command. This command shows a list of commits, along with their associated metadata such as the author, date, and commit message.
- Undo your mistake in many step:
  - local unstaged: `git restore <filename>` restore file changees to latest commit.
  - local staged: `git restore --staged <filename>` same with staged changed.
  - local commited: `git reset` with modes: soft undo only commit but saved changes, hard undo commit and changes. If you want to change only message you could you `git commit --amend` instead. If you want squash commit `git rebase -i <commit>`
  - remote commited: `git reset` need to `git push --force` or `--force-with-lease` to change history. git revert can undo you mistake but also create new history.
  - `--force-with-lease` is safer with check latest git fetch status before force push if remote have another commited, it would failed to prevent remove another's work.

## 8. Remark
