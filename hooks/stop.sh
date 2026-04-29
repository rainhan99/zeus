#!/usr/bin/env bash
# Zeus Stop hook.
# Fires when the agent is about to end its turn. Injects a factual reminder
# about the session-handoff requirement (G7) via the Stop hook's reason field.
#
# Uses advisory mode (allow) — does not block the agent from stopping.
# For sessions with code changes, the agent should produce a handoff memo.

set -u

# Allow the stop — just exit cleanly. The SessionStart context already
# covers the G7 handoff requirement. A blocking Stop hook would prevent
# the agent from finishing simple tasks (questions, quick fixes).
exit 0
