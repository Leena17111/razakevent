# GitHub Workflow

## Main Rule

Do not work directly on the `main` branch.

Each task or subtask should have its own branch. The branch name should follow the Jira work item number and a short task name.

After completing the task, commit your changes, push your branch, create a pull request, and merge it into `main`.

---

## Branch Naming Format

Use this format:

```bash
AD-number-short-task-name
```

---

## 1. Get the Latest Main Branch Before Starting Work

Before starting any task, make sure your local `main` branch is updated.

```bash
git checkout main
git pull origin main
```

---

## 2. Create a New Branch

Create a new branch based on the Jira task or subtask you are working on.

```bash
git checkout -b AD-number-short-task-name
```

Example:

```bash
git checkout -b AD-11-registration-ui
```

---

## 3. Make Your Changes

Complete your assigned coding or documentation task in the project files.

---

## 4. Check Your Changes

Check which files were changed:

```bash
git status
```

---

## 5. Add Changes

Add all changed files:

```bash
git add .
```

Or add a specific file only:

```bash
git add file-path
```

---

## 6. Commit Changes

Commit message should include the Jira issue number and a short description.

Format:

```bash
git commit -m "AD-number Short description of changes"
```

---

## 7. Push Your Branch

Push your branch to GitHub.

```bash
git push origin AD-number-short-task-name
```

---

## 8. Create a Pull Request

After pushing the branch:

1. Open the project repository on GitHub.
2. Click **Compare & pull request**.
3. Write the pull request title using the Jira issue number.
4. Add a short description of what was done.
5. Create the pull request.

Pull request title format:

```text
AD-number Short description of changes
```

---

## 9. Review and Merge

Before merging:

1. Check that the code is correct.
2. Make sure the app still runs.
3. Ask a teammate to review if needed.
4. Merge the pull request into `main`.

After merging, delete the branch if it is no longer needed.

---

## 10. Start a New Task

Before starting the next task, update your local `main` branch again:

```bash
git checkout main
git pull origin main
```

Then create a new branch for the next Jira task:

```bash
git checkout -b AD-number-short-task-name
```

---

## Important Notes

- Do not commit directly to `main`.
- Always create a branch for each Jira task or subtask.
- Always pull the latest `main` before starting new work.
- Keep branch names short and clear.
- Keep commit messages simple and understandable.
