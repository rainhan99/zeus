#!/usr/bin/env bash
# Zeus UserPromptSubmit hook.
# Fires when the user submits a message. Injects a factual reminder about
# the zeus workflow into Claude's context via additionalContext.
#
# IMPORTANT: additionalContext must use factual statements, not imperative
# commands. Imperative text triggers Claude's prompt-injection defenses.

set -u

CONTEXT="Zeus plugin is active in this session. The zeus workflow requires that new feature requests (implement X, add Y, build Z, create something) go through a brainstorming phase before any code is written. The brainstorming phase is initiated by invoking the Skill tool with skill name 'zeus:brainstorming'. This applies in all modes including auto mode. Reading files to plan implementation counts as starting implementation. The skill routing table in the session context maps user intents to required skills."

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTEXT"
exit 0
