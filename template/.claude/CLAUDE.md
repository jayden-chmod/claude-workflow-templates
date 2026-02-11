# {{PROJECT_NAME}} Instructions

<!-- CUSTOMIZE: Replace this section with your project overview -->
## Project Overview
{{PROJECT_DESCRIPTION}}

<!-- CUSTOMIZE: Replace with your tech stack -->
## Tech Stack

### Backend
- **Language**: {{BACKEND_LANGUAGE}}
- **Framework**: {{BACKEND_FRAMEWORK}}
- **Database**: {{DATABASE}}
- **Test Framework**: {{TEST_FRAMEWORK}}

### Frontend
- **Framework**: {{FRONTEND_FRAMEWORK}}

<!-- CUSTOMIZE: Add your domain-specific concepts -->
## Key Domain Concepts
<!-- List core abstractions, data models, and terminology unique to your project -->

<!-- CUSTOMIZE: Describe your architecture layers -->
## Architecture Layers
<!-- List the layers of your system (e.g., API, Service, Data, etc.) -->

<!-- CUSTOMIZE: List your spec/design documents -->
## Documentation
<!-- Example:
- `docs/ARCHITECTURE.md` — System architecture overview
- `docs/specs/DATA_MODEL.md` — Data model specification
- `docs/specs/API.md` — API specification
-->

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

When developing a new feature, follow this 5-stage pipeline in order:

```
① feature-planner  →  ② spec-test-writer  →  ③ Development  →  ④ post-dev-validator  →  ⑤ spec-updater
     (agent)               (agent)            (main conversation)      (agent)               (agent)
```

### Stage ① Plan (agent: feature-planner)
- Spawn `feature-planner` agent with the feature description
- Agent reads spec documents, analyzes codebase, and generates a development plan
- Output: `docs/plans/[feature-name].md`
- **User reviews and approves the plan before proceeding**

### Stage ② Test First (agent: spec-test-writer)
- Spawn `spec-test-writer` agent with the approved plan
- Agent writes test code derived from spec requirements (TDD red phase)
- Output: test files in the project's test directory
- **User reviews test code before proceeding**
- **Critical**: Tests must be rigorous and spec-accurate. Do NOT weaken requirements to make tests easy to pass

### Stage ③ Development (main conversation — NOT a sub-agent)
- Implementation happens in the main conversation so the user can review each step
- Follow the development plan step by step
- Rules:
  - **One step at a time**: Implement one plan step, then STOP and wait for user confirmation
  - **Explain before coding**: Before writing code, explain what will be created and why
  - **Small code units**: Each step should produce a reviewable amount of code (roughly one function or one small module). If a plan step is large, break it into sub-steps
  - **Comments**: All code must include clear comments explaining intent, not just what the code does
  - **No auto-pilot**: Do not batch multiple plan steps together. Never proceed to the next step without user approval
  - **User understanding**: The user wants to fully understand every piece of code. Explain non-obvious patterns or library usage
  - **Run tests incrementally**: After each step, run relevant tests to show progress (red → green)
  - **Context reset workflow**: After each step completion, user will `/clear` and resume. On step completion: (1) verify tests pass, (2) update MEMORY.md `Current Step`, (3) announce completion
  - **Resume protocol**: On resume, read MEMORY.md → check Current Step → read plan → read tests → implement next step

### Stage ④ Validate (agent: post-dev-validator)
- Spawn `post-dev-validator` agent after all development steps are complete
- Agent runs the full test suite and reviews code against spec and plan
- Output: Validation report with PASS / FAIL / PASS WITH WARNINGS
- **If FAIL**: fix issues in main conversation, then re-run validator
- **If PASS**: proceed to Stage ⑤

### Stage ⑤ Update Docs (agent: spec-updater)
- Spawn `spec-updater` agent with the implementation summary
- Agent updates spec documents to reflect what was actually built
- **User reviews doc changes**

### Pipeline Rules
- **Never skip stages**: Even for small features, follow all 5 stages
- **User gates**: The user must approve output at each stage before proceeding to the next
- **Agent locations**: `.claude/agents/feature-planner.md`, `spec-test-writer.md`, `post-dev-validator.md`, `spec-updater.md`

## Documentation Language
- All documentation, decision records, and tracking entries must be written in **English**
