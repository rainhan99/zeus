#!/usr/bin/env bash
# Zeus PreToolUse hook.
# Fires before Read, Edit, Write, and NotebookEdit tool calls. Injects a
# factual reminder about the brainstorming requirement via additionalContext.
#
# IMPORTANT: additionalContext must use factual statements, not imperative
# commands. Imperative text triggers Claude's prompt-injection defenses.

set -u

CONTEXT="Zeus plugin enforcement: new feature work requires an approved brainstorming spec before any file reads or code changes. The spec is produced by invoking the Skill tool with skill name 'zeus:brainstorming'. If no brainstorming spec has been approved for the current feature request, this file operation may be premature."

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$CONTEXT"
exit 0
