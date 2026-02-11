# Spec Review Skill

## Description

Run a comprehensive multi-agent review of specification documents. This skill orchestrates 6 specialized agents in a 3-phase pipeline to validate external foundations, verify formal logic, audit cross-document coherence, assess engineering feasibility, and test edge cases.

## When to Use

Trigger this skill when the user says:
- "Run spec review"
- "Start spec review"
- "Review the specs"
- "Start the spec review team"
- "Review my specification documents"

## Project Context

<!-- CUSTOMIZE: List your specification documents -->
This skill reviews the following specification documents:

```
{{SPEC_DOCUMENTS}}
```

<!-- CUSTOMIZE: Update agent prompt paths if you moved them -->
Agent prompts are located at: `agents/prompts/`

## Execution Flow

### Phase 1: Research (Sequential)

**Agent 01: Researcher** (Sonnet, foundational research)

Launch the researcher agent first. All other agents depend on its output.

```
Task(
  subagent_type="general-purpose",
  model="sonnet",
  name="researcher",
  description="Research external knowledge",
  prompt=<read agents/prompts/01_researcher.md>
)
```

**Wait** until `agents/reports/research_report.md` is complete before proceeding.

---

### Phase 2: Parallel Review (Concurrent)

Launch all 4 review agents **simultaneously in parallel**. Each agent reads the research report from Phase 1.

**IMPORTANT**: Make all 4 Task calls in a single response using `run_in_background=true`.

```
# Agent 02: Formal Verifier (Opus)
Task(
  subagent_type="general-purpose",
  model="opus",
  name="formal-verifier",
  description="Verify formal logic and model correctness",
  prompt=<read agents/prompts/02_formal_verifier.md>,
  run_in_background=true
)

# Agent 03: Coherence Auditor (Sonnet)
Task(
  subagent_type="general-purpose",
  model="sonnet",
  name="coherence-auditor",
  description="Audit cross-document consistency",
  prompt=<read agents/prompts/03_coherence_auditor.md>,
  run_in_background=true
)

# Agent 04: Systems Engineer (Sonnet)
Task(
  subagent_type="general-purpose",
  model="sonnet",
  name="systems-engineer",
  description="Assess engineering feasibility",
  prompt=<read agents/prompts/04_systems_engineer.md>,
  run_in_background=true
)

# Agent 05: Adversarial Tester (Opus)
Task(
  subagent_type="general-purpose",
  model="opus",
  name="adversarial-tester",
  description="Test edge cases and failures",
  prompt=<read agents/prompts/05_adversarial_tester.md>,
  run_in_background=true
)
```

**Wait** until all 4 reports are complete:
- `agents/reports/formal_verification_report.md`
- `agents/reports/coherence_audit_report.md`
- `agents/reports/systems_engineering_report.md`
- `agents/reports/adversarial_test_report.md`

**Monitor progress**: Use the TaskOutput tool or Read tool to check on background agents.

---

### Phase 3: Synthesis (Sequential)

**Agent 06: Moderator** (Opus, final synthesis)

After all 5 reports are ready, launch the moderator to synthesize findings.

```
Task(
  subagent_type="general-purpose",
  model="opus",
  name="moderator",
  description="Synthesize all review reports",
  prompt=<read agents/prompts/06_moderator.md>
)
```

**Output**: `agents/reports/final_improvement_plan.md` (final deliverable)

---

## Output Structure

After completion, `agents/reports/` will contain:

```
agents/reports/
  research_report.md               <- Phase 1 (foundational)
  formal_verification_report.md    <- Phase 2 (parallel)
  coherence_audit_report.md        <- Phase 2 (parallel)
  systems_engineering_report.md    <- Phase 2 (parallel)
  adversarial_test_report.md       <- Phase 2 (parallel)
  final_improvement_plan.md        <- Phase 3 (FINAL DELIVERABLE)
```

## Execution Summary

Present the user with:
1. **Phase 1 Status**: Researcher completion
2. **Phase 2 Progress**: Track all 4 parallel agents
3. **Phase 3 Status**: Moderator synthesis
4. **Final Deliverable**: Link to `agents/reports/final_improvement_plan.md`

## Notes

- **Model Selection**: Opus for logic-heavy tasks (formal verification, adversarial testing, synthesis), Sonnet for research and engineering assessment
- **Parallelization**: Phase 2 agents run concurrently to save time
- **Dependencies**: Phase 2 depends on Phase 1; Phase 3 depends on Phase 2
- **Reports Location**: All outputs go to `agents/reports/`
