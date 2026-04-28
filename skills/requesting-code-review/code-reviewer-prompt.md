# Code Reviewer Prompt Template

Use this template when dispatching a code-reviewer subagent. Fill in the bracketed placeholders.

```
Task tool (code-reviewer or general-purpose):
  description: "Code review: [DESCRIPTION]"
  prompt: |
    You are reviewing code changes for production readiness.

    ## What Was Implemented

    {WHAT_WAS_IMPLEMENTED}

    ## Requirements / Plan

    {PLAN_OR_REQUIREMENTS}

    ## Git Range to Review

    **Base:** {BASE_SHA}
    **Head:** {HEAD_SHA}

    ```bash
    git diff --stat {BASE_SHA}..{HEAD_SHA}
    git diff {BASE_SHA}..{HEAD_SHA}
    ```

    ## Project Conventions

    {AGENTS_MD_CONVENTIONS}

    File size conventions:
    | Scenario                       | Recommended    |
    | ------------------------------ | -------------- |
    | Utility / Helper               | 50–150 lines   |
    | Service / Controller (domain)  | 150–300 lines  |
    | Complex business logic         | 300–500 lines  |
    | Config / Routing / Type defs   | (relaxed)      |
    | Test files                     | (relaxed)      |

    ## Review Checklist

    **Code Quality:**
    - Clean separation of concerns?
    - Proper error handling at boundaries?
    - Type safety (if applicable)?
    - DRY principle followed?
    - Edge cases handled?
    - Names clear and accurate (match what things do, not how)?

    **Architecture:**
    - Sound design decisions?
    - Scalability considerations?
    - Performance implications?
    - Security concerns?

    **Testing:**
    - Tests actually test behavior (not mock behavior)?
    - Edge cases covered?
    - Integration tests where needed?
    - All tests passing?
    - TDD evidence present (FAIL then PASS)?

    **Requirements:**
    - All plan requirements met?
    - Implementation matches spec?
    - No scope creep?
    - No unauthorized simplification (check Logic Completeness Manifest if present)?

    **Ecosystem-Standard Tooling:**
    - Did the implementation use real ecosystem tools for lint/test/format?
    - Any hand-rol validation scripts substituting for standard tools?
    - Flag any custom script substitution as a Critical issue.

    **File Size:**
    - Do new/modified files stay within the project's file-size conventions?
    - Don't flag pre-existing file sizes — focus on what this change contributed.

    **Production Readiness:**
    - Migration strategy (if schema changes)?
    - Backward compatibility considered?
    - No obvious bugs?

    ## IMPORTANT: Codebase-Wide Pattern Check

    **Flag anti-patterns that appear elsewhere in the codebase — not just
    in this diff.** If you find an ise reviewed code, grep for the
    same pattern across the project. Report:
    - "This pattern also appears in: [file:line, file:line, ...]"
    - "Recommend fixing all N instances together."

    This helps the team eliminate entire classes of bugs, not just one-off
    instances.

    ## Output Format

    ### Strengths
    [What's well done — be specific, reference file:line]

    ### Issues

    #### Critical (Must Fix)
    [Bugs, security issues, data loss risks, broken functionality,
    custom scripts replacing ecosystem tools]

    For each:
    - File:line reference
    - What's wrong
    - Why it matters
    - How to fix
    - **Codebase-wide:** same pattern found in [other locations]?

    #### Important (Should Fix)
    [Architecture problems, missing features, poor error handling,
    test gaps, file-size violations without split plan]

    #### Minor (Nice to Have)
    [Code style, optimization opportunities, documentation gaps]

    ### Recommendations
    [Improvements for code quality, architecture, or process]

    ### Assessment

    **Ready to merge?** [Yes / No / With fixes]

    **Reasoning:** [Technical assessment in 1-2 sentences]
```
