# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent. Only dispatch after spec compliance review passes.

```
Task tool (code-reviewer or general-purpose):
  description: "Review code quality for Task N: [task name]"
  prompt: |
    You are reviewing the code quality of an implementation that has already
    passed spec compliance review. The code does what it should — your job is
    to verify it's well-built.

    ## What Was Implemented

    [From implementer's report — what they built, files changed]

    ## Plan / Requirements Context

    Task N from [plan-file-path]:
    [Brief summary of what the task required]

    ## Project Conventions

    [Relevant excerpts from the project contract (CLAUDE.md / AGENTS.md per
    `references/project-contract.md`): conventions, file-size thresholds]

    File size conventions:
    | Scenario                       | Recommended    |
    | ------------------------------ | -------------- |
    | Utility / Helper               | 50–150 lines   |
    | Service / Controller (domain)  | 150–300 lines  |
    | Complex business logic         | 300–500 lines  |
    | Config / Routing / Type defs   | (relaxed)      |
    | Test files                     | (relaxed)      |

    ## Diff Context

    BASE_SHA: [commit before task]
    HEAD_SHA: [current commit]

    ## Your Job

    Review the implementation for code quality. Check:

    **Code cleanliness:**
    - Clear, accurate naming (names match what things do, not how they work)
    - Single responsibility per function / class / module
    - No unnecessary complexity or premature abstraction
    - No dead code, commented-out code, or leftover debugging

    **Testing quality:**
    - Tests verify behavior, not mock behavior
    - Tests are minimal and focused (one behavior per test)
    - Edge cases and error paths covered
    - TDD evidence present (FAIL then PASS runs captured)

    **File organization:**
    - Each file has one clear responsibility with a well-defined interface
    - Files stay within the project's file-size conventions (see table above)
    - New files follow the plan's file structure
    - Don't flag pre-existing file sizes — focus on what this change contributed

    **Ecosystem-standard tooling:**
    - Did the implementer use the project's real lint/test/format tools?
    - Any hand-rolled validation scripts substituting for standard tn      (e.g., grep instead of ESLint, custom Python script instead of Ruff,
      find+grep instead of cargo clippy)
    - Flag any custom script substitution as a **Critical** issue.

    **Patterns and consistency:**
    - Follows existing codebase patterns
    - Consistent with project conventions from the project contract
    - No unnecessary divergence from established approaches

    ## Issue Severity

    - **Critical:** Bugs, security issues, custom scripts replacing ecosystem
      tools, missing tests for core paths, file-size violations without split plan
    - **Important:** Naming issues, missing edge case tests, unnecessary
      complexity, pattern violations
    - **Minor:** Style nits, optional improvements, documentation gaps

    ## Report Format

    **Strengths:** What was done well (be specific)

    **Issues:** List each with severity, file:line reference, and what to fix
    - (Critical) file:line — description
    - (Important) file:line — description
    - (Minor) file:line — description

    **Assessment:** Approved / Changes Required

    If Changes Required, the implementer must fix all Critical and Important
    issues. Minor issues are advisory. After fixes, you will re-review.
```
