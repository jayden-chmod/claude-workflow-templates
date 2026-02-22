# {{PROJECT_NAME}} Instructions

> **⚠️ FIRST-TIME SETUP REQUIRED**
>
> This is a template file. Before using the Feature Development Pipeline, you must:
> 1. Edit **`.claude/project-context.md`** — fill in spec document paths, test command, and update rules (agents read this automatically)
> 2. Fill in `{{PLACEHOLDERS}}` in this file — project name, description, tech stack
> 3. Customize sections marked with `<!-- CUSTOMIZE: ... -->` comments
> 4. Configure MCP servers in `.mcp.json` if needed
> 5. Adjust `model:` in agent frontmatter (`.claude/agents/*.md`) if needed — defaults are sonnet/haiku
> 6. **Delete this entire setup block** once configuration is complete
>
> **Ask Claude to help**: You can say "Help me configure this project" to get started.

<!-- CUSTOMIZE: Replace this section with your project overview -->
## Project Overview
{{PROJECT_DESCRIPTION}}

<!-- CUSTOMIZE: Replace with your tech stack -->
## Tech Stack

### Backend
- **Language**: {{BACKEND_LANGUAGE}}
- **Framework**: {{BACKEND_FRAMEWORK}}
- **Database**: {{DATABASE}}

### Frontend
- **Framework**: {{FRONTEND_FRAMEWORK}}

<!-- CUSTOMIZE: Add your domain-specific concepts -->
## Key Domain Concepts
<!-- List core abstractions, data models, and terminology unique to your project -->

<!-- CUSTOMIZE: Describe your architecture layers -->
## Architecture Layers
<!-- List the layers of your system (e.g., API, Service, Data, etc.) -->

## Documentation

<!-- Spec document paths are configured in .claude/project-context.md — edit that file, not here. -->
<!-- Add high-level notes about documentation conventions here if needed. -->

## Code Style
<!-- CUSTOMIZE: Replace with your project's conventions -->
- Follow language-standard style guide
- Type hints / type annotations on all function signatures
- Docstrings on public functions
- Async/await for all I/O operations (if applicable)

<!-- CUSTOMIZE: List your MCP servers if any -->
## MCP Servers (configured in .mcp.json)
<!-- Example:
- **github**: GitHub PR/issue management
- **playwright**: Browser automation for frontend testing
-->

## Feature Development Pipeline

When developing a new feature, follow this 3-stage pipeline in order:

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

---

### Phase A: Feature Decomposition

**Team**: `TeamCreate("design-team")` — spawn `feature-planner` + `architecture-designer`

1. `feature-planner` reads all spec documents
2. `feature-planner` proposes N domain-based chunks → sends to `architecture-designer` via `SendMessage`
3. `architecture-designer` reviews chunk boundaries against DDD principles → sends feedback
4. Iterate until consensus (max 3 rounds)
5. **If spec gaps are found** → present to user, wait for clarification before proceeding
6. `feature-planner` saves: `docs/plans/[feature-name]-decomposition.md`
7. `TeamDelete("design-team")`
8. Spawn `pipeline-recorder` → records decomposition decisions and constraints to `.claude/memory/pipeline/[feature-name]/decomposition.md`

**User Gate**:
- User reviews chunk breakdown → Approve to proceed, or reject to revise (re-open team)

---

### Phase B + C: Per-Chunk Loop

Repeat for **each chunk** in execution order. Each chunk creates and dissolves its own teams.

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

**End of Phase B**:
1. `TeamDelete("design-team")`
2. Spawn `pipeline-recorder` → records design decisions, trade-offs, and constraints to `.claude/memory/pipeline/[feature-name]/[chunk-name]-design.md`

**User Gate (Phase B)**:
- User reviews architecture + plan + tests together
- Approve → proceed to Phase C
- Reject → `TeamCreate("design-team")` again to revise

#### Phase C: Implement (per chunk)

**Team**: `TeamCreate("dev-review")` — spawn `developer` + `senior-architect` + `post-dev-validator`

`TaskCreate` one task per implementation step in the chunk's plan (sequential):

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

**End of Phase C**:
1. `TeamDelete("dev-review")`
2. Spawn `pipeline-recorder` → records implementation deviations, lessons, and constraints to `.claude/memory/pipeline/[feature-name]/[chunk-name]-implementation.md`

**User Gate (Phase C)**:
- User reviews validation report
- If systemic issues → spawn `mistake-learner` with the report
- Approve → proceed to **next chunk (Phase B)**
- Reject → `TeamCreate("dev-review")` again to fix

---

### Phase D: Update Docs (agent: spec-updater)
- Spawn `spec-updater` with the full implementation summary (all chunks)
- Agent updates spec documents to reflect what was actually built
- **User reviews doc changes**

### Model Configuration

Each agent has a `model` field in its YAML frontmatter (`.claude/agents/*.md`). Defaults:
- **sonnet**: `feature-planner`, `architecture-designer`, `developer`, `senior-architect`, `post-dev-validator`, `spec-test-writer`, `mistake-learner`
- **haiku**: `spec-updater`, `pipeline-recorder`, `session-context-saver`, `codebase-explorer`

To upgrade specific agents to opus (e.g., for safety-critical domains), edit the `model:` field directly in the agent file.

### Pipeline Rules
- **Never skip stages**: Even for small features, follow all 3 stages
- **User gates**: The user must approve output at each stage before proceeding to the next
- **Agent locations**: `.claude/agents/` — `feature-planner.md`, `architecture-designer.md`, `spec-test-writer.md`, `developer.md`, `senior-architect.md`, `post-dev-validator.md`, `spec-updater.md`, `mistake-learner.md`, `pipeline-recorder.md`
- **Learning from mistakes**: When systemic validation issues are found, invoke `mistake-learner` to record patterns
- **Team cleanup**: Always `TeamDelete` after each team stage completes

## Documentation Language
- All documentation, decision records, and tracking entries must be written in **English**
