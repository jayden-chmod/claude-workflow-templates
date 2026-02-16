# Claude Workflow Templates

Reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) workflow templates for disciplined feature development and spec review. These templates encode a methodology-driven approach to building software with AI assistance — ensuring every feature goes through planning, testing, implementation, validation, and documentation.

## What's Included

### 3-Stage Feature Development Pipeline (Agent Teams)

A TDD-based pipeline using collaborative agent teams for planning, implementation, and validation:

```
① plan-and-test-team  →  ② dev-review-team  →  ③ spec-updater
   (agent team)            (agent team)           (agent)
   - feature-planner       - developer (plan_mode_required)
   - spec-test-writer      - senior-architect
                            - post-dev-validator
                                ↓ (if systemic issues)
                              mistake-learner (agent)
```

#### Stage ① Plan + Test (agent team)
A two-agent team that produces development plan and tests with bidirectional feedback:
- **feature-planner** reads specs, analyzes codebase, creates plan with Business Logic Decision Tree
- **spec-test-writer** performs Plan Gap Analysis, provides feedback to planner (≤3 rounds), writes tests

**How to activate:**
```
1. TeamCreate("plan-and-test") — create the team
2. TaskCreate two tasks:
   - "Write development plan" (assigned to feature-planner)
   - "Write spec tests" (assigned to spec-test-writer, blocked by plan task)
3. Spawn teammates using Task tool with team_name parameter
```

#### Stage ② Dev + Review (agent team)
A three-agent team for implementation with real-time architecture review and spec validation:
- **developer** (with plan_mode_required) implements code step-by-step, must get user approval for each step's plan
- **senior-architect** reviews code structure, patterns, and conventions after each step
- **post-dev-validator** checks spec compliance and test quality after each step, produces final validation report

**How to activate:**
```
1. TeamCreate("dev-review") — create the team
2. TaskCreate one task per plan implementation step with sequential dependencies
3. Spawn teammates using Task tool with team_name parameter
4. Developer claims tasks sequentially, enters plan mode for each step
```

#### Stage ③ Update Docs (single agent)
- **spec-updater** agent updates spec documents to reflect what was actually built

**Pipeline Rules:**
- Never skip stages — even small features follow all 3 stages
- User must approve output at each stage before proceeding to the next
- Always `TeamDelete` after each team stage completes
- If systemic validation issues found → invoke `mistake-learner` to record patterns

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

Open the agent files in `.claude/agents/` and replace the `{{PLACEHOLDER}}` values with your project details:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{PROJECT_NAME}}` | Your project name | `MyApp` |
| `{{PROJECT_DESCRIPTION}}` | One-line description | `A real-time analytics platform` |
| `{{BACKEND_LANGUAGE}}` | Primary language | `Python 3.11+` |
| `{{BACKEND_FRAMEWORK}}` | API/web framework | `FastAPI` |
| `{{DATABASE}}` | Database(s) used | `PostgreSQL + Redis` |
| `{{TEST_FRAMEWORK}}` | Test framework | `pytest` |
| `{{TEST_COMMAND}}` | Test run command | `pytest tests/ -v` |
| `{{TEST_DIRECTORY}}` | Test file location | `tests/` |
| `{{FRONTEND_FRAMEWORK}}` | Frontend framework | `Next.js` |
| `{{SPEC_DOCUMENTS}}` | Spec document paths | `docs/ARCHITECTURE.md` |

## File Structure

```
your-project/
├── .claude/
│   ├── CLAUDE.md                      # Project instructions + 3-stage pipeline rules
│   ├── agents/
│   │   # Stage ① Plan + Test Team
│   │   ├── feature-planner.md         # Reads specs, creates plan with Decision Tree
│   │   ├── spec-test-writer.md        # Gap analysis, feedback loop, writes tests
│   │   # Stage ② Dev + Review Team
│   │   ├── developer.md               # Step-by-step implementation (plan_mode_required)
│   │   ├── senior-architect.md        # Real-time architecture review
│   │   ├── post-dev-validator.md      # Spec compliance + validation report
│   │   # Stage ③ + Learning
│   │   ├── spec-updater.md            # Updates docs to match implementation
│   │   ├── mistake-learner.md         # Records systemic mistake patterns
│   │   └── session-context-saver.md   # Saves session state for resumption
│   ├── memory/
│   │   ├── sessions/                  # Session context snapshots (auto-cleaned)
│   │   └── mistakes/                  # Mistake learning knowledge base
│   │       ├── security.md            # Security-related mistakes
│   │       ├── spec-deviation.md      # Spec compliance issues
│   │       ├── test-quality.md        # Test rigor problems
│   │       ├── architecture.md        # Architecture violations
│   │       ├── error-handling.md      # Error handling gaps
│   │       ├── code-style.md          # Style convention issues
│   │       └── common-patterns.md     # Frequently repeated mistakes
│   └── skills/
│       └── spec-review/
│           └── SKILL.md               # Spec review orchestrator
└── docs/
    └── internal/
        └── spec-review/
            └── prompts/
                ├── 01_researcher.md           # External research agent
                ├── 02_formal_verifier.md      # Formal logic verification
                ├── 03_coherence_auditor.md    # Cross-doc consistency
                ├── 04_systems_engineer.md     # Engineering feasibility
                ├── 05_adversarial_tester.md   # Edge case discovery
                └── 06_moderator.md            # Final synthesis
```

## Example: CogEC

The `examples/cogec/` directory contains a reference showing how these templates were customized for the CogEC project (a neuro-symbolic cognitive memory engine). Use it as inspiration for your own customization.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A project with specification/design documents

## License

MIT
