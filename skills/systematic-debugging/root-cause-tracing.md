# Root Cause Tracing

Bugs often manifest deep in the call stack — git init in the wrong directory, file created in the wrong location, database opened with the wrong path. The instinct is to fix where the error appears, but that's treating a symptom.

**Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

## The tracing process

### 1. Observe the symptom

```
Error: git init failed in /Users/dev/project/packages/core
```

### 2. Find immediate cause

What code directly causes this?

```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. Ask: what called this?

```
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → called by Session.initializeWorkspace()
  → called by Session.create()
  → called by test at Project.create()
```

### 4. Keep tracing up

What value was passed?

- `projectDir = ''` (empty string)
- Empty string as `cwd` resolves to `process.cwd()`
- That's the source code directory — not the intended temp directory

### 5. Find original trigger

Where did the empty string come from?

```typescript
const context = setupCoreTest(); // Returns { tempDir: '' }
Project.create('name', context.tempDir); // Accessed before beforeEach ran!
```

Root cause: top-level variable initialization accessing a value that isn't populated until `beforeEach`.

## Adding stack traces for instrumentation

When you can't trace manually, add diagnostic logging:

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });
  await execFileAsync('git', ['init'], { cwd: directory });
}
```

Use `console.error()` in tests — logger output may be suppressed.

Run and capture:

```bash
npm test 2>&1 | grep 'DEBUG git init'
```

Analyze stack traces: look for test file names, find the line number triggering the call, identify the pattern.

## Multi-component systems

For systems with multiple layers (CI → build → signing, API → service → database):

```bash
# Layer 1: Workflow
echo "=== Secrets available: ==="
echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

# Layer 2: Build script
echo "=== Env vars in build: ==="
env | grep IDENTITY || echo "IDENTITY not in environment"

# Layer 3: Signing
echo "=== Keychain state: ==="
security list-keychains
security find-identity -v
```

This reveals which layer fails: secrets → workflow ✓, workflow → build ✗.

## Key principle

```
Found immediate cause
  → Can trace one level up? → Trace backwards
    → Is this the source? → No → Keep tracing
    → Is this the source? → Yes → Fix at source
      → Add defense-in-depth at each layer
        → Bug structurally impossible
```

**NEVER fix just where the error appears.** Trace back to find the original trigger. Then add validation at every layer the data passes through (see `defense-in-depth.md`).
