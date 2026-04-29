#!/usr/bin/env bash
# Zeus PreToolUse hook.
# Fires before Edit and Write tool calls. Injects a brief reminder about
# the brainstorming-before-code requirement. Lightweight and stateless —
# always allows the tool call but keeps the zeus workflow in the agent's
# attention.
#
# This is the "second layer" of enforcement. The first layer is the
# SessionStart injection of using-zeus/SKILL.md. Together they ensure
# the agent cannot silently skip brainstorming even in auto mode.

set -u

REMINDER="[ZEUS ENFORCEMENT] You are about to modify code. Before writing ANY code for a new feature, you MUST have invoked zeus:brainstorming and received user approval on the spec. If you have not done this yet, STOP NOW and invoke the Skill tool with skill 'zeus:brainstorming'. Auto mode and bypass mode do NOT exempt you from this requirement."

# Allow the tool call but inject the reminder as the reason
printf '{"decision":"allow","reason":"%s"}\n' "$REMINDER"
exit 0
