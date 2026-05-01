# GitHub Workflow

This file explains how our team should push code and documentation to GitHub for RazakEvent development.

## Main Rule

Do not work directly on the `main` branch.

Each task should have its own branch. After completing the task, create a pull request and merge it into `main`.

## 1. Get the latest main branch before starting any work

\```bash
git checkout main
git pull origin main
\```

## 2. Create a New Branch

\```bash
git checkout -b <branch-name>
\```

## 3. Make Your Changes

Complete your assigned coding or documentation task in the project files.


## 4. Check Changes

\```bash
git status
\```

## 5. Add Changes

\```bash
git add .
\```

## 6. Commit Changes

\```bash
git commit -m "<commit-message>"
\```

## 7. Push the Branch

\```bash
git push origin <branch-name>
\```

## 8. Create a Pull Request

On GitHub, create a pull request with:

\```text
base: main
compare: <branch-name>
\```

Then add a title and description.

## 9. Merge the Pull Request

After reviewing the changes, merge the pull request into `main`.

## 10. Update Local Main After Merge

\```bash
git checkout main
git pull origin main
\```


## Quick Summary

\```bash
git checkout main
git pull origin main

git checkout -b <branch-name>

git status
git add .
git commit -m "<commit-message>"
git push origin <branch-name>
\```

Then create a pull request:

\```text
<branch-name> → main
\```
