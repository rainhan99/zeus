# Condition-Based Waiting

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.

**Core principle:** Wait for the actual condition you care about, not a guess about how long it takes.

## When to use

- Tests have arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`)
- Tests are flaky (pass sometimes, fail under load)
- Tests timeout when run in parallel
- Waiting for async operations to complete

Don't use when testing actual timing behavior (debounce, throttle intervals) — but document WHY the timeout is needed.

## Core pattern

```typescript
// Bad: guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// Good: waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

## Quick patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for count | `waitFor(() => items.length >= 5)` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10)` |

## Generic implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();
  while (true) {
    const result = condition();
    if (result) return result;
    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }
    await new Promise(r => setTimeout(r, 10));
  }
}
```

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Polling too fast (`setTimeout(check, 1)`) | Poll every 10ms — balances responsiveness and CPU |
| No timeout (loop forever) | Always include timeout with clear error message |
| Stale data (cache state before loop) | Call getter inside loop for fresh data each iteration |

## When arbitrary timeout IS correct

```typescript
// Tool ticks every 100ms — need 2 ticks to verify partial output
await waitForEvent(manager, 'TOOL_STARTED');  // First: wait for condition
await new Promise(r => setTimeout(r, 200));    // Then: wait for timed behavior
// 200ms = 2 ticks at 100ms intervals — documented and justified
```

Requirements for justified arbitrary timeouts:
1. First wait for the triggering condition
2. Timeout based on known timing (not guessing)
3. Comment explaining WHY
