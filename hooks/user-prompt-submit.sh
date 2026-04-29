#!/usr/bin/env bash
# Zeus UserPromptSubmit hook.
# Fires when the user submits a message. Injects a brief reminder about
# the zeus workflow — brainstorming before code, skills before action.
# This is the "earliest" enforcement layer: it fires before the agent
# even starts thinking about the user's request.

set -u

REMINDER="[ZEUS WORKFLOW] Before responding to this message, check the zeus skill routing table (injected at session start). If the user is requesting new code work, you MUST invoke the Skill tool with 'zeus:brainstorming' BEFORE reading files, exploring code, or writing code. This is mandatory in ALL modes including auto mode."

printf '{"decision":"allow","reason":"%s"}\n' "$REMINDER"
exit 0
