# CogEC — Project Context Reference

This document shows how the Claude Workflow Templates were customized for the CogEC project. Use it as a reference when customizing templates for your own project.

## Project Info

- **Name**: CogEC (Cognitive-EC Graph)
- **Description**: A neuro-symbolic cognitive memory engine that uses Event Calculus, graph-based memory, and ontology-driven reasoning to track belief evolution, detect contradictions, and proactively ask questions.

## Tech Stack

| Placeholder | CogEC Value |
|-------------|-------------|
| `BACKEND_LANGUAGE` | Python 3.11+ |
| `BACKEND_FRAMEWORK` | FastAPI |
| `DATABASE` | Neo4j (Cypher queries, APOC), MongoDB (raw logs), Redis (session cache) |
| `TEST_FRAMEWORK` | pytest + pytest-asyncio |
| `TEST_COMMAND` | `cd backend && python -m pytest tests/ -v --tb=long` |
| `TEST_DIRECTORY` | `backend/tests/` |
| `FRONTEND_FRAMEWORK` | Next.js (App Router) + Jotai + TailwindCSS |

## Spec Documents

```
docs/ARCHITECTURE.md                    — System architecture overview
docs/internal/SPEC_CORE.md              — Core ontology & data model (EC predicates, graph schema)
docs/internal/SPEC_COGNITIVE_FLOW.md    — Cognitive pipeline (6-stage loop)
docs/internal/SPEC_MEMORY_RETRIEVAL.md  — Memory retrieval engine (4-stage pipeline)
docs/internal/SPEC_REASONING.md         — Reasoning engine & methodologies
docs/internal/IMPLEMENTATION_PLAN.md    — Current implementation phases & progress
docs/internal/SPEC_FRONTEND.md          — Frontend specification
docs/internal/RESEARCH_NOTES.md         — Academic foundations & evaluation
```

## Researcher Topics (01_researcher.md)

CogEC's researcher agent was customized with these 4 topics:

### Topic 1: Event Calculus Formalism
- Standard EC (Kowalski & Sergot 1986) axioms
- CogEC's extensions: sign, magnitude, reliability on AFFECTS edges; Weakens predicate
- Decay functions in temporal reasoning
- Known EC limitations (frame problem, ramification, concurrent events)
- Belief strength aggregation formula validation

### Topic 2: Neo4j / Graph DB Patterns
- APOC path expansion capabilities
- Neosemantics (n10s) integration
- Neo4j performance for multi-hop traversal with property filters
- Materialization patterns for derived relationships
- Concurrent write handling

### Topic 3: Comparable Systems
- Microsoft GraphRAG
- MemGPT (Letta)
- LangGraph
- Zep, Mem0, and other memory-augmented LLM systems
- Differentiator validation: temporal truth management, belief evolution, proactive questioning

### Topic 4: Cognitive Science Accuracy
- Zeigarnik Effect (1927 experiment, 2.0x boost faithfulness)
- ACT-R spreading activation (ACTIVATION_WEIGHTS mapping)
- Tulving's memory model (episodic vs. semantic dual-layer)
- Ranganathan PMEST (5-facet + Purpose extension)
- Encoding Specificity Principle (Spatial/Temporal roles)

## Formal Verifier Checklist (02_formal_verifier.md)

CogEC's formal verifier focused on:

1. **EC Axiom Completeness**: Frame problem, Weakens predicate semantics, concurrent events, null time semantics
2. **Belief Strength Formula**: Range analysis (can produce values outside [0,1]), N definition, decay function (undefined), edge case with zero AFFECTS, formula inconsistency between spec text and Cypher
3. **Ontology Logical Consistency**: RuleNode semantics, crystallization reversibility, class definitions, hand-authored vs. crystallized rule precedence
4. **State Machine Completeness**: Fluent states (NEW → ACTIVE → WEAKENED → DORMANT → CRYSTALLIZED), all transition triggers
5. **Zeigarnik Formalization**: Gap definition, boost composition, decay interaction, gap lifecycle
6. **Inference Rule Soundness**: Transitive inference with dormant edges, derived relationship validity, circular reasoning in Sandwich Architecture

## Adversarial Tester Scenarios (05_adversarial_tester.md)

CogEC-specific attack vectors included:

1. **Adversarial Input**: Contradictory rapid-fire assertions, gaslighting (retraction vs. correction), ambiguous entity references, multi-language (Korean/English), sarcasm/irony, hypotheticals/quotes
2. **Long-Term Evolution**: Fluent accumulation (hundreds of AFFECTS edges), crystallization lock-in (seasonal patterns), zombie DORMANT fluents, identity collision over time, belief ossification
3. **Multi-User**: Shared real-world entities, user mentions another user, identity spoofing
4. **Ontology**: Circular definitions, ontology-data mismatch, incomplete inference chains, rule conflicts
5. **Zeigarnik Gaps**: Question fatigue (5 gaps in one message), unresolvable gaps, gap oscillation, false gap detection from decayed edges
6. **Dispatcher**: Misrouted cognitive input, misrouted social input, boundary inputs (social + cognitive)

## Key Domain Concepts Added to CLAUDE.md

```markdown
## Key Domain Concepts
- **Event Calculus (EC)**: 4-Predicate system — Initiates/Strengthens/Weakens/Terminates + HoldsAt
- **Fluent**: Truth value tracked by belief_strength. States: ACTIVE (>0.5), WEAKENED (0.1–0.5), DORMANT (≤0.1)
- **AFFECTS edge**: [:AFFECTS {sign, magnitude, reliability}] — sign ∈ {+1, -1}, edges NEVER deleted
- **Belief Evolution**: EMA (α=0.3). Coexist/Erosion/Rupture classification
- **Knowledge Crystallization**: Fluents → RuleNodes. Lifecycle: Episodic → Semantic → Ontology
- **Zeigarnik-inspired Gap**: Information gaps as "unfinished tasks" for proactive questioning
- **Dual-Layer Memory**: Episodic (7 Universal Roles / 5W1H) + Semantic (PMEST+P / 6 Facets)
```

## MCP Servers Added to CLAUDE.md

```markdown
## MCP Servers (configured in .mcp.json)
- **neo4j-mcp**: Direct Cypher query execution against Neo4j (read-only)
- **mongodb**: MongoDB collection browsing and queries (read-only)
- **redis-mcp-server**: Redis key/value inspection (read-only)
- **playwright**: Browser automation for Next.js frontend testing
- **github**: GitHub PR/issue management
- **Context7**: Library documentation lookup
```

## Architecture Layers Added to CLAUDE.md

```markdown
## Architecture Layers
1. Conversation Interface → FastAPI endpoints
2. Orchestrator → 6-stage cognitive loop (Receive → Dispatch → Extract → Store → Reason → Respond)
3. Memory Engine → Neo4j graph + MongoDB raw + Redis cache
4. Reasoning Engine → Structural (graph traversal) + Judgmental (ontology + EC)
5. Retrieval Engine → 4-stage pipeline (Anchor → Expand → Rank → Assemble)
```
