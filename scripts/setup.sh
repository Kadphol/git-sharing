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
