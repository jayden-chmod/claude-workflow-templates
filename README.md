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

| Agent | Role | Model |
|-------|------|-------|
| Researcher | External knowledge acquisition & validation | Sonnet |
| Formal Verifier | Logical completeness & correctness | Opus |
| Coherence Auditor | Cross-document consistency | Sonnet |
| Systems Engineer | Engineering feasibility assessment | Sonnet |
| Adversarial Tester | Edge case & failure scenario discovery | Opus |
| Moderator | Synthesis & prioritized improvement plan | Opus |

## Quick Start

### For Existing Projects: Migrate to Mistake Learner

If you're already using these templates and want to add the mistake-learner agent:

```bash
cd claude-workflow-templates
chmod +x migrate-mistake-learner.sh
./migrate-mistake-learner.sh
```

The migration script will:
1. Add `.claude/agents/mistake-learner.md`
2. Create `.claude/memory/mistakes/` with 7 category files
3. Update `CLAUDE.md` pipeline diagram and rules
4. Update `post-dev-validator.md` to recommend mistake-learner on FAIL
5. Update `feature-planner.md` to check past mistakes
6. Create `.backup` files of all modified files

**Recommendation**: Commit your changes before running the migration script.

### Option 1: Interactive Setup (Recommended for New Projects)

```bash
git clone https://github.com/your-org/claude-workflow-templates.git
cd claude-workflow-templates
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Ask for your project details (name, tech stack, spec documents)
2. Copy all template files into your project
3. Fill in project-specific placeholders automatically

### Option 2: Manual Setup

1. Copy the `template/` directory contents into your project root:

```bash
cp -r template/.claude /path/to/your-project/
cp -r template/agents /path/to/your-project/
```

2. Search for `{{PLACEHOLDER}}` markers in all copied files and replace them:

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
| `{{SPEC_DOCUMENTS}}` | Spec document paths | See below |

3. Customize the `<!-- CUSTOMIZE -->` sections in each file.

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

## Customization Guide

### Customizing the Pipeline Agents

Each agent template has a **Project Context** section at the top with `<!-- CUSTOMIZE -->` markers. This is where you add project-specific details:

**feature-planner.md** — Add your spec document list so the planner knows what to read.

**spec-test-writer.md** — Add your test framework, test directory, and spec documents.

**post-dev-validator.md** — Add your test command and spec documents.

**mistake-learner.md** — No customization needed. This agent automatically learns from validation failures.

**spec-updater.md** — Add your spec documents and document-specific update rules.

### Customizing the Spec Review Agents

The 6 spec review agents each have placeholder research topics and checklists:

**01_researcher.md** — Replace the 4 research topics with areas relevant to your project:
- Topic 1: Your core methodology or formalism
- Topic 2: Your technology stack specifics
- Topic 3: Comparable systems in your domain
- Topic 4: Domain-specific accuracy concerns

**02_formal_verifier.md** — Replace the analysis checklist with your project's formal concerns (data model, formulas, state machines, inference rules).

**03_coherence_auditor.md** — Add your key terms and domain concepts to check for consistency.

**04_systems_engineer.md** — The 7-category checklist is mostly generic, but add project-specific integration concerns.

**05_adversarial_tester.md** — Replace attack vectors with scenarios relevant to your domain and use cases.

**06_moderator.md** — This agent is already generic. Just ensure the report paths match your setup.

## Pipeline Workflow Explained

### Feature Development

When you tell Claude Code to implement a feature:

1. Claude spawns the **feature-planner** agent, which reads your specs (and past mistakes) and produces a plan in `docs/plans/`
2. You review and approve the plan
3. Claude spawns the **spec-test-writer** agent, which writes tests (TDD red phase)
4. You review the tests
5. Claude implements the feature step-by-step in the main conversation, running tests after each step
6. After all steps, Claude spawns the **post-dev-validator** to run the full test suite and review code quality
7. **If validation fails**:
   - Claude spawns the **mistake-learner** to analyze and record the failure patterns
   - Mistakes are categorized and stored in `.claude/memory/mistakes/`
   - Recurring patterns are flagged for systematic prevention
   - You fix the issues and re-run validation
8. If validation passes, Claude spawns the **spec-updater** to update documentation

### Spec Review

When you say "Run spec review":

1. The **Researcher** gathers external evidence (papers, documentation, comparable systems)
2. Four review agents run in parallel: Formal Verifier, Coherence Auditor, Systems Engineer, Adversarial Tester
3. The **Moderator** synthesizes all findings into a prioritized improvement plan
4. Output: `agents/reports/final_improvement_plan.md`

### Mistake Learning

The pipeline includes a **mistake-learner** agent that builds a knowledge base of common errors:

**When Triggered:**
- Automatically invoked when `post-dev-validator` reports FAIL status
- Can be manually invoked to analyze any failure or issue

**What It Does:**
1. Analyzes the validation report to identify root causes
2. Categorizes mistakes (security, spec-deviation, test-quality, architecture, etc.)
3. Checks for recurring patterns by comparing with historical records
4. Records detailed entries with context, root cause, correct approach, and prevention tips
5. Flags frequently repeated mistakes (2+ occurrences) in `common-patterns.md`
6. Generates prevention recommendations for future development

**Knowledge Base Structure:**
```
.claude/memory/mistakes/
  security.md           # SQL injection, hardcoded secrets, missing validation
  spec-deviation.md     # Misinterpreted requirements, missing features
  test-quality.md       # Weakened assertions, missing edge cases
  architecture.md       # Wrong layer, circular imports, pattern violations
  error-handling.md     # Silent failures, poor error messages
  code-style.md         # Missing type hints, poor naming
  common-patterns.md    # Mistakes that happened 2+ times (systematic prevention needed)
```

**Integration with Planning:**
- The **feature-planner** reads `.claude/memory/mistakes/` before creating plans
- Plans include a "Lessons from Past Mistakes" section with warnings
- Helps prevent repeating historical errors

**Benefits:**
- Continuous learning across development sessions
- Systematic prevention of recurring issues
- Project-specific knowledge accumulation
- No blame — focuses on patterns, not people

## Example: CogEC

The `examples/cogec/` directory contains a reference showing how these templates were customized for the CogEC project (a neuro-symbolic cognitive memory engine). Use it as inspiration for your own customization.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A project with specification/design documents

## License

MIT
