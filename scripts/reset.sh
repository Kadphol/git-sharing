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
