#!/usr/bin/env bash
# Zeus Stop hook.
# Fires when the agent is about to end its turn. Injects a reminder about
# the session-handoff requirement (G7). Advisory only — does not block.
#
# A blocking Stop hook would prevent the agent from ever finishing simple
# tasks (questions, quick fixes). Instead, this hook reminds the agent to
# check whether a handoff memo is needed before ending.

set -u

REMINDER="[ZEUS G7 CHECK] Before ending this session, verify: if you performed code work in this session, have you produced a handoff memo via zeus:session-handoff? G7 requires a clean handoff state. If this was just a question or quick task with no code changes, you may proceed."

printf '{"decision":"allow","reason":"%s"}\n' "$REMINDER"
exit 0
