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

When developing a new feature, follow this 3-stage pipeline in order:

```
① plan-and-test-team  →  ② dev-review-team  →  ③ spec-updater
   (agent team)            (agent team)           (agent)
   - feature-planner       - developer (plan_mode_required)
   - spec-test-writer      - senior-architect
                            - post-dev-validator
                                ↓ (if systemic issues)
                              mistake-learner (agent)
```

### Stage ① Plan + Test (agent team: plan-and-test)

A two-agent team that produces a plan and tests with bidirectional feedback.

#### Setup
1. `TeamCreate("plan-and-test")` — create the team
2. `TaskCreate` — create two tasks:
   - **Task: "Write development plan"** — assigned to feature-planner
   - **Task: "Write spec tests"** — assigned to spec-test-writer, `blockedBy` the plan task
3. Spawn teammates:
   - `feature-planner` — reads specs, analyzes codebase, generates plan with Business Logic Decision Tree
   - `spec-test-writer` — blocked until plan is ready, then performs Plan Gap Analysis

#### Feedback Loop (≤3 rounds)
1. **Planner** writes initial plan → marks task complete
2. **Test-writer** unblocks → reads plan → runs Plan Gap Analysis (5 gap categories)
3. If gaps found → test-writer sends structured feedback to planner
4. Planner evaluates feedback → updates plan → sends change summary
5. Test-writer re-analyzes changed sections → repeat if needed (max 3 rounds)
6. After gaps resolved (or Round 3 reached with `# ASSUMPTION:` markers) → test-writer writes tests → marks task complete

#### Output
- Development plan: `docs/plans/[feature-name].md`
- Test files in the project's test directory

#### User Gate
- **User reviews both plan and tests together** before proceeding
- Approve → `TeamDelete("plan-and-test")` → proceed to Stage ②
- Reject → provide feedback, team iterates

### Stage ② Dev + Review (agent team: dev-review)

A three-agent team for implementation with real-time architecture review and spec validation.

#### Setup
1. `TeamCreate("dev-review")` — create the team
2. `TaskCreate` — create one task per plan implementation step:
   - **Task: "Step 1: [title]"** — description includes plan step details
   - **Task: "Step 2: [title]"** — `blockedBy` Step 1
   - ... (sequential dependencies between steps)
3. Spawn teammates:
   - `developer` with `plan_mode_required` — implements code, must get user approval for each step's implementation plan
   - `senior-architect` — reviews code structure, patterns, and conventions after each step
   - `post-dev-validator` — checks spec compliance and test quality after each step

#### Per-Step Flow
```
developer                  architect              validator
  |                           |                       |
  |-- Claim task              |                       |
  |-- [PLAN MODE]             |                       |
  |-- Write impl plan         |                       |
  |-- → User approves plan    |                       |
  |-- Implement code          |                       |
  |-- Run tests               |                       |
  |-- Mark task complete       |                       |
  |                           |-- Read changes        |-- Read changes
  |                           |-- Review structure    |-- Run tests
  |                           |-- SendMessage(dev,    |-- Check spec
  |                           |   arch feedback)      |-- SendMessage(dev,
  |                           |                       |   spec feedback)
  |-- Receive feedback        |                       |
  |-- Fix issues              |                       |
  |-- Re-run tests            |                       |
  |-- Claim next task...      |                       |
```

#### Final Validation
After all tasks complete:
1. **Validator** runs the full test suite and produces a comprehensive validation report
2. **Validator** sends the report to the team leader (user)
3. If **systemic issues** (repeated failure patterns across tasks) are detected → validator recommends spawning `mistake-learner` agent

#### User Gate
- **User reviews the final validation report**
- If systemic issues → spawn `mistake-learner` agent with the report
- Approve → shutdown all teammates → `TeamDelete("dev-review")` → proceed to Stage ③

### Stage ③ Update Docs (agent: spec-updater)
- Spawn `spec-updater` agent with the implementation summary
- Agent updates spec documents to reflect what was actually built
- **User reviews doc changes**

### Pipeline Rules
- **Never skip stages**: Even for small features, follow all 3 stages
- **User gates**: The user must approve output at each stage before proceeding to the next
- **Agent locations**: `.claude/agents/feature-planner.md`, `spec-test-writer.md`, `developer.md`, `senior-architect.md`, `post-dev-validator.md`, `spec-updater.md`, `mistake-learner.md`
- **Learning from mistakes**: When systemic validation issues are found, invoke `mistake-learner` to record patterns
- **Team cleanup**: Always `TeamDelete` after each team stage completes

## Documentation Language
- All documentation, decision records, and tracking entries must be written in **English**
