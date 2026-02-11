#!/usr/bin/env bash
set -euo pipefail

# Claude Workflow Templates — Interactive Setup Script
# Copies template files into your project and fills in project-specific context.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Claude Workflow Templates — Setup                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- Step 1: Target directory ---
echo -e "${BOLD}Step 1: Target Project${NC}"
read -rp "Path to your project root (default: current directory): " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo -e "  Target: ${GREEN}${TARGET_DIR}${NC}"
echo ""

# --- Step 2: Project name ---
echo -e "${BOLD}Step 2: Project Info${NC}"
DEFAULT_NAME="$(basename "$TARGET_DIR")"
read -rp "Project name (default: ${DEFAULT_NAME}): " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"

read -rp "Short project description: " PROJECT_DESCRIPTION
echo ""

# --- Step 3: Tech stack ---
echo -e "${BOLD}Step 3: Tech Stack${NC}"
read -rp "Backend language (e.g., Python 3.11+, TypeScript, Go): " BACKEND_LANGUAGE
read -rp "Backend framework (e.g., FastAPI, Express, Gin): " BACKEND_FRAMEWORK
read -rp "Database(s) (e.g., PostgreSQL, Neo4j, MongoDB): " DATABASE
read -rp "Test framework (e.g., pytest, vitest, jest, go test): " TEST_FRAMEWORK
read -rp "Test command (e.g., 'pytest tests/ -v', 'npm test'): " TEST_COMMAND
read -rp "Test directory (e.g., tests/, __tests__, src/**/*.test.ts): " TEST_DIRECTORY
read -rp "Frontend framework (e.g., Next.js, React, Vue, N/A): " FRONTEND_FRAMEWORK
echo ""

# --- Step 4: Spec documents ---
echo -e "${BOLD}Step 4: Specification Documents${NC}"
echo -e "List your spec/design documents (one per line, relative to project root)."
echo -e "Press ${YELLOW}Enter on an empty line${NC} to finish."

if [[ -d "${TARGET_DIR}/docs" ]]; then
    echo ""
    echo -e "${CYAN}Detected docs/ directory. Found markdown files:${NC}"
    find "${TARGET_DIR}/docs" -name "*.md" -type f | sed "s|${TARGET_DIR}/||" | sort | head -20
    echo ""
fi

SPEC_DOCUMENTS=""
SPEC_DOCUMENTS_FORMATTED=""
while true; do
    read -rp "  Doc path: " doc_path
    if [[ -z "$doc_path" ]]; then
        break
    fi
    # Build formatted list (for template injection)
    if [[ -n "$SPEC_DOCUMENTS" ]]; then
        SPEC_DOCUMENTS="${SPEC_DOCUMENTS}\n${doc_path}"
        SPEC_DOCUMENTS_FORMATTED="${SPEC_DOCUMENTS_FORMATTED}\n${doc_path}"
    else
        SPEC_DOCUMENTS="${doc_path}"
        SPEC_DOCUMENTS_FORMATTED="${doc_path}"
    fi
done

if [[ -z "$SPEC_DOCUMENTS" ]]; then
    echo -e "${YELLOW}Warning: No spec documents specified. You can add them later by editing the template files.${NC}"
    SPEC_DOCUMENTS="# Add your spec document paths here"
    SPEC_DOCUMENTS_FORMATTED="# Add your spec document paths here"
fi

echo ""

# --- Step 5: Confirmation ---
echo -e "${BOLD}Configuration Summary${NC}"
echo "  Project Name:      ${PROJECT_NAME}"
echo "  Description:       ${PROJECT_DESCRIPTION}"
echo "  Backend:           ${BACKEND_LANGUAGE} / ${BACKEND_FRAMEWORK}"
echo "  Database:          ${DATABASE}"
echo "  Test Framework:    ${TEST_FRAMEWORK}"
echo "  Test Command:      ${TEST_COMMAND}"
echo "  Test Directory:    ${TEST_DIRECTORY}"
echo "  Frontend:          ${FRONTEND_FRAMEWORK}"
echo "  Spec Documents:"
echo -e "    ${SPEC_DOCUMENTS}" | sed 's/^/    /'
echo ""

read -rp "Proceed with installation? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BOLD}Installing templates...${NC}"

# --- Step 6: Copy template files ---

# Create directories
mkdir -p "${TARGET_DIR}/.claude/agents"
mkdir -p "${TARGET_DIR}/.claude/skills/spec-review"
mkdir -p "${TARGET_DIR}/agents/prompts"
mkdir -p "${TARGET_DIR}/agents/reports"

# Function to copy and fill template
fill_template() {
    local src="$1"
    local dst="$2"

    if [[ -f "$dst" ]]; then
        echo -e "  ${YELLOW}SKIP${NC} $(basename "$dst") (already exists)"
        return
    fi

    cp "$src" "$dst"

    # Replace placeholders using sed
    # Use | as delimiter to avoid conflicts with / in paths
    sed -i '' \
        -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|${PROJECT_DESCRIPTION}|g" \
        -e "s|{{BACKEND_LANGUAGE}}|${BACKEND_LANGUAGE}|g" \
        -e "s|{{BACKEND_FRAMEWORK}}|${BACKEND_FRAMEWORK}|g" \
        -e "s|{{DATABASE}}|${DATABASE}|g" \
        -e "s|{{TEST_FRAMEWORK}}|${TEST_FRAMEWORK}|g" \
        -e "s|{{TEST_COMMAND}}|${TEST_COMMAND}|g" \
        -e "s|{{TEST_DIRECTORY}}|${TEST_DIRECTORY}|g" \
        -e "s|{{FRONTEND_FRAMEWORK}}|${FRONTEND_FRAMEWORK}|g" \
        "$dst" 2>/dev/null || true

    # Replace spec documents placeholder (multiline — use Python for reliability)
    python3 -c "
import sys
with open(sys.argv[1], 'r') as f:
    content = f.read()
content = content.replace('{{SPEC_DOCUMENTS}}', sys.argv[2])
with open(sys.argv[1], 'w') as f:
    f.write(content)
" "$dst" "$(echo -e "$SPEC_DOCUMENTS_FORMATTED")"

    echo -e "  ${GREEN}OK${NC}   $(echo "$dst" | sed "s|${TARGET_DIR}/||")"
}

# Pipeline agents
fill_template "${TEMPLATE_DIR}/.claude/CLAUDE.md"                          "${TARGET_DIR}/.claude/CLAUDE.md"
fill_template "${TEMPLATE_DIR}/.claude/agents/feature-planner.md"          "${TARGET_DIR}/.claude/agents/feature-planner.md"
fill_template "${TEMPLATE_DIR}/.claude/agents/spec-test-writer.md"         "${TARGET_DIR}/.claude/agents/spec-test-writer.md"
fill_template "${TEMPLATE_DIR}/.claude/agents/post-dev-validator.md"       "${TARGET_DIR}/.claude/agents/post-dev-validator.md"
fill_template "${TEMPLATE_DIR}/.claude/agents/spec-updater.md"             "${TARGET_DIR}/.claude/agents/spec-updater.md"

# Spec review skill
fill_template "${TEMPLATE_DIR}/.claude/skills/spec-review/SKILL.md"        "${TARGET_DIR}/.claude/skills/spec-review/SKILL.md"

# Spec review agent prompts
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/01_researcher.md"            "${TARGET_DIR}/agents/prompts/01_researcher.md"
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/02_formal_verifier.md"       "${TARGET_DIR}/agents/prompts/02_formal_verifier.md"
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/03_coherence_auditor.md"     "${TARGET_DIR}/agents/prompts/03_coherence_auditor.md"
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/04_systems_engineer.md"      "${TARGET_DIR}/agents/prompts/04_systems_engineer.md"
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/05_adversarial_tester.md"    "${TARGET_DIR}/agents/prompts/05_adversarial_tester.md"
fill_template "${TEMPLATE_DIR}/docs/internal/spect-review/agents/prompts/06_moderator.md"             "${TARGET_DIR}/agents/prompts/06_moderator.md"

echo ""
echo -e "${GREEN}${BOLD}Done!${NC} Templates installed to ${TARGET_DIR}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Review .claude/CLAUDE.md and customize any remaining sections"
echo "  2. Review agent prompts in .claude/agents/ and agents/prompts/"
echo "  3. Add project-specific research topics to agents/prompts/01_researcher.md"
echo "  4. Add project-specific formal concerns to agents/prompts/02_formal_verifier.md"
echo "  5. Start developing with: 'Implement feature X using the pipeline'"
echo ""
