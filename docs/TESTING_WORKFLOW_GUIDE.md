# Testing Agent Setup & Daily Workflow Guide

## Quick Setup (One-Time)

### 1. Add files to your repositories

Copy these files into each repository:

```
your-repo/
├── TESTING_AGENT_CLAUDE.md          ← Testing agent instructions
├── scripts/
│   ├── check_coverage.sh            ← Coverage threshold enforcement
│   └── coverage_diff.sh             ← Coverage comparison vs branch
├── bitbucket-pipelines.yml          ← Update with test/coverage steps
└── docs/
    ├── TEST_CASE_DOCUMENTATION.md   ← (already exists from prior work)
    ├── BUGS_FOUND_DURING_TESTING.md ← Create empty, will be populated
    └── BUGS_REQUIRING_REVIEW.md     ← Create empty, will be populated
```

### 2. Make scripts executable

```bash
chmod +x scripts/check_coverage.sh
chmod +x scripts/coverage_diff.sh
```

### 3. Install lcov locally (if not already)

```bash
# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov
```

### 4. Update Bitbucket Pipeline

Merge the test/coverage steps from the template into your existing
bitbucket-pipelines.yml. Enable "Require passing builds" in Bitbucket
branch permissions for your main/develop branches.

### 5. Create empty bug tracking docs

```bash
mkdir -p docs
echo "# Bugs Found During Testing" > docs/BUGS_FOUND_DURING_TESTING.md
echo "" >> docs/BUGS_FOUND_DURING_TESTING.md
echo "No bugs found yet." >> docs/BUGS_FOUND_DURING_TESTING.md

echo "# Bugs Requiring Review" > docs/BUGS_REQUIRING_REVIEW.md
echo "" >> docs/BUGS_REQUIRING_REVIEW.md
echo "No bugs pending review." >> docs/BUGS_REQUIRING_REVIEW.md
```

---

## Daily Workflow

### Morning Startup

Open three terminals:

```
Terminal 1 (Dev Agent):
  $ cd ~/projects/optmsg-app    # or whichever repo
  $ claude                       # Start Claude Code for development

Terminal 2 (Testing Agent):
  $ cd ~/projects/optmsg-app    # Same repo
  $ claude                       # Start Claude Code
  > "You are the testing agent. Read TESTING_AGENT_CLAUDE.md and begin
     your operating loop. Start with /test-scan to assess current state."

Terminal 3 (Optional — second repo or infrastructure):
  $ cd ~/projects/optmsg-api
  $ claude
```

### During Development

**You (in Terminal 1 — Dev Agent):** Work normally. Fix bugs, add features,
refactor. Commit frequently.

**Testing Agent (Terminal 2):** Runs its operating loop. After you commit or
save changes, tell it:

```
> "I just finished adding the password reset flow. Scan for changes
   and write tests for the new code."

> "I refactored the auth service — check if any existing tests broke."

> "I'm done with this feature. Run /test-coverage and tell me where
   we stand."
```

### Quick Commands for the Testing Agent

| Command | What it does |
|---------|-------------|
| `/test-scan` | Detect changed files, report what needs testing |
| `/test-regressions` | Run all tests, report failures |
| `/test-coverage` | Run coverage, show per-module breakdown |
| `/test-file lib/services/auth.dart` | Write tests for a specific file |
| `/test-feature auth` | Write all tests for the auth module |
| `/test-bugs` | List all bugs found during testing |
| `/test-report` | Full cycle report |
| `/test-release` | Pre-release validation |

### Before Committing / Creating a PR

Ask the testing agent:
```
> "Run /test-coverage and make sure we're above thresholds before I push."
```

Or run locally:
```bash
flutter test --coverage
./scripts/check_coverage.sh --report
```

### Before a Release

Ask the testing agent:
```
> "Run /test-release for a full pre-release validation."
```

This will:
1. Run every test
2. Check all coverage targets
3. Verify no skipped tests without documentation
4. Check for open bugs
5. Produce a release readiness report

---

## How the Pieces Work Together

```
┌─────────────────────────────────────────────────────────────────┐
│                        YOUR WORKFLOW                            │
│                                                                 │
│  Terminal 1 (Dev)          Terminal 2 (Test)                     │
│  ┌───────────────┐        ┌───────────────┐                     │
│  │ Write feature  │───────▶│ Detect changes │                    │
│  │ code in lib/   │        │ Run tests      │                    │
│  │               │◀───────│ Report results │                    │
│  │ Fix bugs from │        │ Write new tests│                    │
│  │ test agent    │        │ Update docs    │                    │
│  └───────┬───────┘        └───────┬───────┘                     │
│          │                        │                              │
│          ▼                        ▼                              │
│  ┌─────────────────────────────────────┐                        │
│  │           git push                   │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
└────────────────────┼─────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   BITBUCKET PIPELINES                           │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐     │
│  │ Run all      │  │ Check       │  │ Block merge if      │     │
│  │ tests        │─▶│ coverage    │─▶│ tests fail OR       │     │
│  │              │  │ thresholds  │  │ coverage drops      │     │
│  └─────────────┘  └─────────────┘  └─────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Safety Net Layers

1. **Testing Agent (real-time):** Catches issues as you code.
   Fastest feedback loop. Can fix tests and find bugs immediately.

2. **Local coverage check (pre-push):** Quick validation before
   pushing. Catches anything the testing agent missed.

3. **Bitbucket Pipeline (PR gate):** Final automated gate.
   Blocks merges that would reduce coverage or break tests.
   Cannot be bypassed.

---

## Handling Common Scenarios

### "The testing agent found a bug"

The testing agent will log it in `docs/BUGS_FOUND_DURING_TESTING.md`.

- If it fixed the bug: Review the fix in the git diff, verify it's correct.
- If it flagged for review: Check `docs/BUGS_REQUIRING_REVIEW.md`,
  decide whether to fix now or defer.

### "Tests are failing after my changes"

Tell the testing agent:
```
> "Tests are failing after my recent changes. Determine if these are
   regressions (bugs I introduced) or stale tests that need updating."
```

### "I need to ship fast — can I skip tests?"

The pipeline will block you. But you can:
1. Ask the testing agent to prioritize just the changed code
2. Add minimum viable tests for the new code
3. Create a follow-up task for comprehensive coverage

### "Coverage dropped below threshold"

```bash
# See exactly which files are below target
./scripts/check_coverage.sh --report

# See what changed vs main
./scripts/check_coverage.sh --diff main
```

Then tell the testing agent:
```
> "Coverage dropped. Focus on the files listed in the coverage report
   and bring them back above threshold."
```

### "I'm working across multiple repos"

Run a testing agent terminal for each repo. They operate independently.
The TESTING_AGENT_CLAUDE.md detects which repo it's in automatically.

---

## Maintaining This Over Time

### Weekly

- Review `docs/BUGS_REQUIRING_REVIEW.md` — resolve or accept pending bugs
- Check overall coverage trend — is it going up or plateauing?

### Per Release

- Run `/test-release` for full validation
- Archive the TEST_IMPLEMENTATION_REPORT.md with the release version
- Reset BUGS_FOUND_DURING_TESTING.md for the next cycle (move resolved to archive)

### When Adding New Features

- Tell the testing agent about the feature BEFORE you start coding:
  ```
  > "I'm about to add a contact import feature. Create test case
     documentation stubs in TEST_CASE_DOCUMENTATION.md so tests
     can be written alongside the feature code."
  ```

- This way the testing agent has a head start and can write tests
  as soon as you commit code.
