# actions-status Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `bin/actions-status` - a dashboard script showing the latest GitHub Actions run per workflow across configured repos.

**Architecture:** Mirrors `bin/actions-fails` structure. Uses `gh run list` to fetch all recent runs, groups by workflow taking the most recent, computes duration, and outputs JSON grouped by repo with summary counts.

**Tech Stack:** Bash, gh CLI, jq, yq

---

## CRITICAL: TDD + Parallel Agent Execution

**This plan uses Test-Driven Development (TDD).** Tests are written BEFORE implementation.

**Parallel Agent Pattern:** For each task that has independent test and implementation work, launch TWO agents IN PARALLEL using a single message with multiple Task tool calls:

1. **@bash-tdd-architect** - Writes the behavior-driven tests FIRST
2. **@bash-script-architect** - Writes the implementation to make tests pass

These agents run concurrently. The TDD agent designs tests from specification (not implementation), while the script architect implements the production code. After both complete, run tests to verify.

---

## Task 0: Cleanup Pre-existing Files (SEQUENTIAL)

**Files to remove:**
- `bin/tests/test-actions-status.bats` (if exists)
- `bin/actions-status` (if exists)

### Step 1: Remove pre-existing files

```bash
rm -f bin/actions-status bin/tests/test-actions-status.bats
```

### Step 2: Verify clean state

```bash
ls bin/actions-status bin/tests/test-actions-status.bats 2>&1 || echo "Clean - no pre-existing files"
```

**No commit needed** - just ensuring clean slate before TDD begins.

---

## Task 1: Create Test File Skeleton + Script Skeleton (PARALLEL)

**Files:**
- Create: `bin/tests/test-actions-status.bats`
- Create: `bin/actions-status`

### Agent Dispatch (PARALLEL)

Launch both agents in a single message:

**Agent 1: @bash-tdd-architect**
```
Create bin/tests/test-actions-status.bats with:
- setup() and teardown() functions (mirror test-actions-fails.bats)
- SCRIPT path pointing to ../actions-status
- DEFAULT_CONFIG path pointing to ../repos.yaml
- TEST_TEMP_DIR creation/cleanup
- Section comment: "# Behavior: Script Existence and Executability"
- Two tests: "actions-status script exists" and "actions-status script is executable"
```

**Agent 2: @bash-script-architect**
```
Create bin/actions-status with:
- Shebang: #!/usr/bin/env bash
- Strict mode: set -euo pipefail and IFS=$'\n\t'
- Header comment block (mirror actions-fails format)
- Empty main() function
- VERBOSE=0 global
- Script execution guard: if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi
```

### Step 1: Run tests to verify skeleton

```bash
bats bin/tests/test-actions-status.bats
```

Expected: 2 tests pass (script exists, is executable)

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add actions-status script skeleton with initial tests"
```

---

## Task 2: Add Help and Argument Parsing Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Help and Arguments"

Tests:
1. "shows help with -h flag" - run with -h, status 0, output contains "Usage"
2. "shows help with --help flag" - run with --help, status 0, output contains "Usage"
3. "exits with error on unknown option" - run with --invalid, status non-zero
4. "accepts -v flag without error" - run with -v and empty config, status 0
5. "accepts --verbose flag without error" - run with --verbose and empty config, status 0
```

**Agent 2: @bash-script-architect**
```
Add to bin/actions-status:

1. Copy helper functions from actions-fails: die(), warn(), info(), command_exists()
2. Copy show_help() - update to reference actions-status and ACTIONS_STATUS_CONFIG
3. Copy parse_args() - same logic for -h/--help/-v/--verbose
4. Update header comment to document actions-status usage
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add help and argument parsing to actions-status"
```

---

## Task 3: Add Config Handling Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Configuration File Handling"

Tests:
1. "repos.yaml config file exists at default location" - check $DEFAULT_CONFIG exists
2. "exits non-zero when config file is missing" - set ACTIONS_STATUS_CONFIG to nonexistent, status non-zero
3. "outputs error message when config file is missing" - output contains "config" or "not found"
4. "uses ACTIONS_STATUS_CONFIG env var when set" - set to valid empty config, status 0
```

**Agent 2: @bash-script-architect**
```
Add to bin/actions-status:

1. Copy check_dependencies() from actions-fails
2. Copy get_config_file() - update env var name to ACTIONS_STATUS_CONFIG
3. Copy read_repos() from actions-fails
4. Update main() to call check_dependencies and get_config_file
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add config file handling to actions-status"
```

---

## Task 4: Add Output Structure Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Output Format - Valid JSON"

Tests (use empty repos config to avoid network):
1. "output is valid JSON" - pipe to jq, succeeds
2. "output JSON has 'timestamp' key" - jq 'has("timestamp")' == true
3. "output JSON has 'repos' key" - jq 'has("repos")' == true
4. "output JSON has 'summary' key" - jq 'has("summary")' == true
5. "repos is an array" - jq '.repos | type == "array"' == true
6. "timestamp is in ISO-8601 format" - matches pattern ^[0-9]{4}-[0-9]{2}-[0-9]{2}T
```

**Agent 2: @bash-script-architect**
```
Add to bin/actions-status:

1. Add fetch_repo_status() function - uses gh run list with JSON fields:
   workflowName, databaseId, headBranch, conclusion, url, createdAt, updatedAt, headSha, actor
   Limit: 50 runs per repo

2. Add process_repo_workflows() function - groups by workflowName, takes first per workflow,
   computes duration_seconds (updatedAt - createdAt for completed, null for in_progress),
   maps conclusion to status (null -> in_progress)

3. Update main() to:
   - Loop through repos
   - Build repos array with nested workflows
   - Generate timestamp
   - Output JSON with timestamp, repos, summary structure
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add JSON output structure to actions-status"
```

---

## Task 5: Add Summary Structure Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Summary Structure"

Tests:
1. "summary has 'total_repos' key" - jq '.summary | has("total_repos")' == true
2. "summary has 'total_workflows' key" - jq '.summary | has("total_workflows")' == true
3. "summary has 'success' key" - jq '.summary | has("success")' == true
4. "summary has 'failure' key" - jq '.summary | has("failure")' == true
5. "summary has 'in_progress' key" - jq '.summary | has("in_progress")' == true
6. "summary values are numbers" - check types for all summary fields
```

**Agent 2: @bash-script-architect**
```
Update bin/actions-status main() to:

1. Track counts: total_repos, total_workflows, success, failure, in_progress
2. Aggregate across all repos/workflows
3. Include in final JSON output under summary key
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add summary structure to actions-status"
```

---

## Task 6: Add Repo/Workflow Structure Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Repo and Workflow Structure"

Note: These tests need a mock or use integration approach. Add section comment for clarity.

Tests (integration, skip if SKIP_INTEGRATION set):
1. "each repo object has 'repo' key" - check first repo has .repo
2. "each repo object has 'workflows' array" - check first repo has .workflows array
3. "workflow has required fields" - check name, run_id, status, branch, head_sha, actor, created_at, url
4. "workflow status is valid value" - status in [success, failure, in_progress, cancelled, skipped]
5. "duration_seconds is number or null" - type check
```

**Agent 2: @bash-script-architect**
```
Ensure bin/actions-status workflow objects include all fields:
- name (from workflowName)
- run_id (from databaseId)
- status (mapped from conclusion)
- branch (from headBranch)
- head_sha (from headSha)
- actor (from actor)
- created_at (from createdAt)
- duration_seconds (computed or null)
- url (from url)
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass (integration tests may skip if not authenticated)

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: add repo and workflow structure to actions-status"
```

---

## Task 7: Add Empty Repos Tests + Implementation (PARALLEL)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`
- Modify: `bin/actions-status`

### Agent Dispatch (PARALLEL)

**Agent 1: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Behavior: Empty Repos Array"

Tests:
1. "empty repos array produces zero counts in summary" - all summary values are 0
2. "empty repos array produces empty repos array" - .repos | length == 0
```

**Agent 2: @bash-script-architect**
```
Verify bin/actions-status handles empty repos gracefully:
- Empty repos config produces valid JSON with empty arrays and zero counts
- No errors on empty input
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Commit

```bash
git add bin/actions-status bin/tests/test-actions-status.bats
git commit -m "feat: handle empty repos in actions-status"
```

---

## Task 8: Add Integration Tests (SEQUENTIAL - TDD agent only)

**Files:**
- Modify: `bin/tests/test-actions-status.bats`

### Agent Dispatch (SINGLE)

**Agent: @bash-tdd-architect**
```
Add to bin/tests/test-actions-status.bats:

Section: "# Integration Tests (require network + gh auth)"

Add setup_integration() helper:
- Skip if SKIP_INTEGRATION env var set
- Skip if gh auth status fails

Tests using JamesPrial/dotfiles repo:
1. "real repo fetch produces valid structure" - full output validation
2. "workflow objects have expected fields" - check all required fields present
3. "status values are valid" - verify status is one of expected values
4. "duration is numeric for completed runs" - type check
5. "summary counts match actual data" - verify totals are consistent
```

### Step 1: Run tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: Integration tests pass (or skip if not authenticated)

### Step 2: Commit

```bash
git add bin/tests/test-actions-status.bats
git commit -m "test: add integration tests for actions-status"
```

---

## Task 9: Update Permissions Script (SEQUENTIAL)

**Files:**
- Modify: `bin/dotfiles-fix-perms`

### Step 1: Add new script to permissions

Add `chmod 700` line for `bin/actions-status` in `bin/dotfiles-fix-perms`

### Step 2: Run permissions fix

```bash
./bin/dotfiles-fix-perms
```

### Step 3: Commit

```bash
git add bin/dotfiles-fix-perms
git commit -m "chore: add actions-status to permissions script"
```

---

## Task 10: Final Verification (SEQUENTIAL)

### Step 1: Run all tests

```bash
bats bin/tests/test-actions-status.bats
```

Expected: All tests pass

### Step 2: Manual verification

```bash
./bin/actions-status | jq .
./bin/actions-status -v | jq .
./bin/actions-status --help
```

### Step 3: Verify with real repos

```bash
./bin/actions-status | jq '.summary'
```

### Step 4: Final commit if needed

```bash
git status
# If any uncommitted changes, commit them
```

---

## Execution Summary

| Task | Agents | Parallelizable |
|------|--------|----------------|
| 0. Cleanup | Manual (rm) | NO |
| 1. Skeleton | @bash-tdd-architect + @bash-script-architect | YES |
| 2. Help/Args | @bash-tdd-architect + @bash-script-architect | YES |
| 3. Config | @bash-tdd-architect + @bash-script-architect | YES |
| 4. Output Structure | @bash-tdd-architect + @bash-script-architect | YES |
| 5. Summary | @bash-tdd-architect + @bash-script-architect | YES |
| 6. Repo/Workflow | @bash-tdd-architect + @bash-script-architect | YES |
| 7. Empty Repos | @bash-tdd-architect + @bash-script-architect | YES |
| 8. Integration Tests | @bash-tdd-architect only | NO |
| 9. Permissions | Manual | NO |
| 10. Verification | Manual | NO |

**Total: 11 tasks, 7 parallelizable with dual agents**
