# Claude Workflow Templates

Reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) workflow templates for disciplined feature development and spec review. These templates encode a methodology-driven approach to building software with AI assistance — ensuring every feature goes through planning, testing, implementation, validation, and documentation.

## What's Included

### 5-Stage Feature Development Pipeline

A TDD-based pipeline that enforces quality at every step:

```
① feature-planner  →  ② spec-test-writer  →  ③ Development  →  ④ post-dev-validator  →  ⑤ spec-updater
     (agent)               (agent)            (main conversation)      (agent)               (agent)
                                                                           ↓ (if FAIL)
                                                                      mistake-learner
                                                                         (agent)
```

1. **Plan** — Agent reads specs and produces a structured development plan (checks past mistakes)
2. **Test First** — Agent writes tests from spec requirements (TDD red phase)
3. **Develop** — Step-by-step implementation in main conversation with user review
4. **Validate** — Agent runs tests and reviews code against spec and plan
5. **Learn** — If validation fails, agent analyzes and records mistake patterns (builds knowledge base)
6. **Update Docs** — Agent updates spec documents to reflect what was built

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
│   ├── CLAUDE.md                      # Project instructions + pipeline rules
│   ├── agents/
│   │   ├── feature-planner.md         # Stage ① Plan
│   │   ├── spec-test-writer.md        # Stage ② Test First
│   │   ├── post-dev-validator.md      # Stage ④ Validate
│   │   ├── mistake-learner.md         # Stage ⑤ Learn (on validation failure)
│   │   └── spec-updater.md            # Stage ⑥ Update Docs
│   ├── memory/
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
