# When Pipelines Fail

Outcome: you have watched a pipeline
fail on purpose, read its exit codes
correctly, and can make the linter
treat warnings as errors. Transcript
`t03` is the drill; `t01` has the lint
evidence.

## The drill

The fixture's fail file has three
steps: `build` (harmless), `test`
whose commands end in `exit 3`, and
`report`, which depends on `test`:

```yaml
  - name: test
    image: bash
    commands:
      - echo "running a check that fails on purpose"
      - exit 3
    depends_on: [build]

  - name: report
    image: bash
    commands:
      - echo "this step should not run after a failed test step"
    depends_on: [test]
```

Run locally, it produced:

```text
[build:L1:0s] build step finished
[test:L0:0s] ▶  echo "running a check that fails on purpose"
[test:L1:0s] running a check that fails on purpose
[test:L2:0s] ▶  exit 3
uuid=...: exit code 3
{"level":"fatal","error":"uuid=...: exit code 3", ...}
exit=1
```

Three facts to take from this, all
measured:

1. **The step's exit code survives.**
   The report names it exactly —
   `exit code 3` — so a script wrapping
   the CLI can still learn *how* the
   step failed from the message, even
   though…
2. **The CLI's own exit code is just
   1.** Any pipeline failure — step exit
   3 or step exit 127 — makes
   `woodpecker-cli exec` exit 1. Scripts
   must branch on *pass versus fail*
   from the CLI's code, and read the
   step's code from the output. Do not
   write a wrapper that expects the
   step's number to propagate; the lab
   proved it does not.
3. **Dependent steps are skipped, not
   failed.** `report` never appears in
   the log. Its echo line — written to
   announce itself — never prints. On
   the server the web page shows such
   steps as skipped, which is a
   different and kinder verdict than
   failure: the pipeline failed at
   `test`, and everything downstream is
   simply *not judged*.

## Lint, strictly

Chapter 4's lint run warned and passed.
Lint has a sterner mode, and a wrong
file to practise on. The fixture's
`.woodpecker-invalid.yaml` adds a key
that does not exist, `no_such_setting`:

```bash
woodpecker-cli lint .woodpecker-invalid.yaml        # exit 0, 2 warnings
woodpecker-cli lint --strict .woodpecker-invalid.yaml
```

```text
🔥 .woodpecker-invalid.yaml has 2 errors:
   ❌ steps.0  Additional property no_such_setting is not allowed
   ❌ Consider adding a `when` block with an `event` filter ...
exit=1
```

`--strict` promotes every warning to
an error — including the missing
`when` filter — which makes it the
right mode for a pre-push check
(recipe 1): a file that passes
`lint --strict` is a file whose
*shape* Woodpecker fully accepts.
Malformed YAML is sterner still and
needs no flag: the fixture's
`.woodpecker-badyaml.yaml` fails lint
outright with a fatal parser error
naming the position (`L2.C3-L3.C4`),
exit 1.

## Failure on the server

On the server the same rules wear
better clothes: the run is marked
failed, the failing step shows its log
with the exit code, dependents show as
skipped, and notifications and status
checks on the forge report the failure
where the pull request can see it.
Those server-side surfaces are
documented behaviour — the lab's
server never ran a repository pipeline
(chapter 10 explains why) — but the
*semantics* underneath them are the
ones this chapter measured locally:
non-zero fails the step, dependents
skip, and the number that matters is
preserved in the record.
