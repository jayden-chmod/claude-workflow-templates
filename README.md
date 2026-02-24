# Claude Workflow Templates

Reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) workflow templates for disciplined feature development and spec review. These templates encode a methodology-driven approach to building software with AI assistance — ensuring every feature goes through decomposition, design, implementation, validation, and documentation.

## What's Included

### 4-Phase Feature Development Pipeline (Agent Teams)

A DDD-based pipeline using collaborative agent teams for decomposition, design, implementation, and validation:

```
Phase A: Decomposition
  TeamCreate("design-team") → feature-planner + architecture-designer
  → N chunks finalized → TeamDelete("design-team") → User approve

For each chunk (repeat N times):
  Phase B: Design
    TeamCreate("design-team") → architecture-designer + feature-planner + spec-test-writer
    → architecture + plan + tests → TeamDelete("design-team") → User approve

  Phase C: Implement
    TeamCreate("dev-review") → developer + senior-architect + post-dev-validator
    → implement + validate → TeamDelete("dev-review") → User approve

Phase D: Update Docs
  spec-updater
```

#### Phase A: Feature Decomposition

**Team**: `TeamCreate("design-team")` — spawn `feature-planner` + `architecture-designer`

1. `feature-planner` reads all spec documents
2. `feature-planner` proposes N domain-based chunks → sends to `architecture-designer` via `SendMessage`
3. `architecture-designer` reviews chunk boundaries against DDD principles → sends feedback
4. Iterate until consensus (max 3 rounds)
5. **If spec gaps are found** → present to user, wait for clarification before proceeding
6. `feature-planner` saves: `docs/plans/[feature-name]-decomposition.md`
7. `TeamDelete("design-team")`
8. Spawn `pipeline-recorder` → records decomposition decisions and constraints

**User Gate**: User reviews chunk breakdown → Approve to proceed, or reject to revise

#### Phase B: Design (per chunk)

**Team**: `TeamCreate("design-team")` — spawn `architecture-designer` + `feature-planner` + `spec-test-writer`

```
architecture-designer           feature-planner              spec-test-writer
      |                               |                             |
      |-- Design DDD architecture     |                             |
      |   docs/plans/*-architecture   |                             |
      |-- Notify teammates ---------> |                             |
      |                               |-- Read architecture         |
      |                               |-- Write detailed plan       |
      |                               |   docs/plans/*-plan.md      |
      |                               |-- Mark task complete        |
      |                               |                             |-- Read architecture
      |                               |                             |-- Read plan
      |                               |                             |-- Plan Gap Analysis
      |                               |                             |   (gaps → ask user)
      |                               |                             |-- Write tests
      |                               |                             |-- Mark task complete
```

**TaskCreate per chunk:**
- **"Design architecture: [chunk]"** → architecture-designer
- **"Write plan: [chunk]"** → feature-planner, `blockedBy` architecture task
- **"Write tests: [chunk]"** → spec-test-writer, `blockedBy` both above

**End of Phase B**: `TeamDelete("design-team")` → Spawn `pipeline-recorder` → records design decisions

**User Gate**: User reviews architecture + plan + tests together → Approve or reject to revise

#### Phase C: Implement (per chunk)

**Team**: `TeamCreate("dev-review")` — spawn `developer` + `senior-architect` + `post-dev-validator`

```
developer                  senior-architect        post-dev-validator
  |                               |                       |
  |-- Claim task                  |                       |
  |-- [PLAN MODE]                 |                       |
  |-- Propose file tree           |                       |
  |-- codebase-explorer scan      |                       |
  |-- SendMessage(senior-arch) -> |                       |
  |                               |-- Confirm file tree   |
  |                               |-- SendMessage(dev) -> |
  |-- Write impl plan             |                       |
  |-- → User approves plan        |                       |
  |-- Implement code              |                       |
  |-- Run tests                   |                       |
  |-- Mark task complete          |                       |
  |                               |-- Review vs arch file |-- Read changes
  |                               |-- SendMessage(dev)    |-- Run tests
  |                               |                       |-- Check spec
  |                               |                       |-- SendMessage(dev)
  |-- Receive feedback            |                       |
  |-- Fix & re-run tests          |                       |
  |-- Claim next task...          |                       |
```

After all steps complete:
- `post-dev-validator` runs full test suite → produces validation report
- If systemic issues → recommend spawning `mistake-learner`

**End of Phase C**: `TeamDelete("dev-review")` → Spawn `pipeline-recorder` → records implementation deviations and lessons

**User Gate**: User reviews validation report → Approve or spawn `mistake-learner` if needed

#### Phase D: Update Docs (single agent)

- Spawn `spec-updater` with the full implementation summary (all chunks)
- Agent updates spec documents to reflect what was actually built
- **User reviews doc changes**

**Pipeline Rules:**
- **Never skip phases** — even small features follow all 4 phases
- **User gates** — user must approve output at each phase before proceeding
- **Team cleanup** — always `TeamDelete` after each team stage completes
- **Pipeline recording** — `pipeline-recorder` captures decisions after each phase
- **Learning from mistakes** — when systemic validation issues found → invoke `mistake-learner`

### Model Configuration

Each agent has a `model` field in its YAML frontmatter (`.claude/agents/*.md`). Defaults:
- **sonnet**: `feature-planner`, `architecture-designer`, `developer`, `senior-architect`, `post-dev-validator`, `spec-test-writer`, `mistake-learner`
- **haiku**: `spec-updater`, `pipeline-recorder`, `session-context-saver`, `codebase-explorer`

To upgrade specific agents to opus (e.g., for safety-critical domains), edit the `model:` field directly in the agent file.

### Session Context Saver

A lightweight agent that captures the current session's working state so the next session can resume exactly where you left off. Invoke it before `/clear` to preserve context across sessions.

- Collects task state, active teams, plan files, and conversation context
- Saves a structured context file to `.claude/memory/sessions/`
- Auto-cleans session files older than 30 days
- Runs on Haiku for speed — completes in under 30 seconds

### 6-Agent Spec Review System

A multi-agent review pipeline for validating specification documents:

```
Phase 1: Researcher (sequential)
Phase 2: Formal Verifier + Coherence Auditor + Systems Engineer + Adversarial Tester (parallel)
Phase 3: Moderator (sequential synthesis)
```

## Quick Start

### Use as a Template

The easiest way to use these templates is to **clone this repository** directly as your project starter or copy the files into your existing project.

#### Option 1: Start a New Project

```bash
git clone https://github.com/jayden-chmod/claude-workflow-templates.git my-new-project
cd my-new-project
rm -rf .git  # Remove template's git history
git init     # Start fresh
```

#### Option 2: Add to Existing Project

Simply copy the `.claude` and `docs` folders into your project root:

```bash
# Assuming you cloned claude-workflow-templates elsewhere
cp -r /path/to/claude-workflow-templates/.claude .
cp -r /path/to/claude-workflow-templates/docs .  # Optional: for spec review agents
```

### Configuration

**Step 1**: Edit `.claude/project-context.md` — fill in spec document paths, test commands, and document update rules (all agents read this automatically).

**Step 2**: Open `.claude/CLAUDE.md` and replace `{{PLACEHOLDER}}` values with your project details:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{PROJECT_NAME}}` | Your project name | `MyApp` |
| `{{PROJECT_DESCRIPTION}}` | One-line description | `A real-time analytics platform` |
| `{{BACKEND_LANGUAGE}}` | Primary language | `Python 3.11+` |
| `{{BACKEND_FRAMEWORK}}` | API/web framework | `FastAPI` |
| `{{DATABASE}}` | Database(s) used | `PostgreSQL + Redis` |
| `{{FRONTEND_FRAMEWORK}}` | Frontend framework | `Next.js` |

**Step 3**: Edit `.claude/project-context.md` placeholders:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{SPEC_DOCUMENTS}}` | Spec document paths | `docs/ARCHITECTURE.md` |
| `{{TEST_FRAMEWORK}}` | Test framework | `pytest` |
| `{{TEST_DIRECTORY}}` | Test file location | `tests/` |
| `{{TEST_COMMAND}}` | Test run command | `pytest tests/ -v` |
| `{{DOCUMENT_UPDATE_RULES}}` | Doc update triggers | See examples in file |

## File Structure

```
your-project/
├── .claude/
│   ├── CLAUDE.md                      # Project instructions + 4-phase pipeline rules
│   ├── project-context.md             # Spec paths, test config, doc update rules
│   ├── agents/
│   │   # Phase A: Decomposition
│   │   ├── feature-planner.md         # Reads specs, proposes domain-based chunks
│   │   ├── architecture-designer.md   # DDD-based architecture design + chunk review
│   │   # Phase B: Design (per chunk)
│   │   ├── spec-test-writer.md        # Gap analysis, feedback loop, writes tests
│   │   # Phase C: Implement (per chunk)
│   │   ├── developer.md               # Step-by-step implementation (plan_mode_required)
│   │   ├── senior-architect.md        # Real-time architecture review
│   │   ├── post-dev-validator.md      # Spec compliance + validation report
│   │   # Phase D + Support
│   │   ├── spec-updater.md            # Updates docs to match implementation
│   │   ├── mistake-learner.md         # Records systemic mistake patterns
│   │   ├── pipeline-recorder.md       # Records pipeline decisions per phase
│   │   ├── codebase-explorer.md       # Fast file/code exploration (haiku)
│   │   └── session-context-saver.md   # Saves session state for resumption
│   ├── memory/
│   │   ├── sessions/                  # Session context snapshots (auto-cleaned)
│   │   ├── mistakes/                  # Mistake learning knowledge base
│   │   │   ├── security.md
│   │   │   ├── spec-deviation.md
│   │   │   ├── test-quality.md
│   │   │   ├── architecture.md
│   │   │   ├── error-handling.md
│   │   │   ├── code-style.md
│   │   │   └── common-patterns.md
│   │   └── pipeline/                  # Pipeline decision records per feature
│   └── skills/
│       └── spec-review/
│           └── SKILL.md               # Spec review orchestrator
└── docs/
    └── internal/
        └── spec-review/
            └── prompts/
                ├── 01_researcher.md
                ├── 02_formal_verifier.md
                ├── 03_coherence_auditor.md
                ├── 04_systems_engineer.md
                ├── 05_adversarial_tester.md
                └── 06_moderator.md
```

## Example: CogEC

The `examples/cogec/` directory contains a reference showing how these templates were customized for the CogEC project (a neuro-symbolic cognitive memory engine). Use it as inspiration for your own customization.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A project with specification/design documents

## License

MIT
