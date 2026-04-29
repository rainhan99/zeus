#!/usr/bin/env bash
# Zeus PreToolUse hook.
# Fires before Edit, Write, and NotebookEdit tool calls. Injects a factual
# reminder about the brainstorming requirement via additionalContext.
#
# IMPORTANT: additionalContext must use factual statements, not imperative
# commands. Imperative text triggers Claude's prompt-injection defenses.

set -u

CONTEXT="Zeus plugin enforcement: code modifications for new features require an approved brainstorming spec. The spec is produced by invoking the Skill tool with skill name 'zeus:brainstorming'. If no brainstorming spec has been approved for the current feature request, this code change may be premature. Auto mode and bypass mode do not exempt this requirement."

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$CONTEXT"
exit 0
