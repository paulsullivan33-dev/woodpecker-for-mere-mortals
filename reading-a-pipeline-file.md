# Reading a Pipeline File

Outcome: you can take any
`.woodpecker.yaml` and say what will
run, in what order, with what tools,
and what happens if a step fails. The
fixture file from chapter 4 is the
specimen.

## The top level

A pipeline file is a map. The keys this
guide uses are `steps`, `when`,
`depends_on`'s home inside steps,
`environment`, and — named here,
taught as documented-only — `services`
and `matrix`. A file may also live as
one of several in a `.woodpecker/`
folder, in which case each file is a
**workflow** of one pipeline run, and
workflows too can depend on each other.

## A step, field by field

```yaml
  - name: test
    image: python:3.12
    commands:
      - python3 -m unittest -v
    depends_on: [build]
```

- **`name`** — how the step appears in
  logs and the web page. Keep it short
  and verb-y: `build`, `test`, `lint`,
  `package`. Log lines are prefixed
  with it, as chapter 4 showed.
- **`image`** — on container backends,
  the image whose filesystem and tools
  the step runs in. On the local
  backend, the program that runs the
  script (chapter 4's quirk). Either
  way, this field answers *where do the
  commands think they are*.
- **`commands`** — a list of shell
  lines, run in order, in the step's
  working folder (the workspace, or
  your folder under `exec --local`).
  The step fails at the first command
  that exits non-zero; later commands
  in that step do not run.
- **`depends_on`** — the ordering
  contract. A step with no `depends_on`
  may run as soon as its workflow
  starts, in parallel with its peers.
  Naming a dependency means *start only
  if that step finished successfully*.
  It is both a sequencing tool and a
  failure tool: chapter 6's drill
  depends on it.

Two more fields earn their place early:

- **`environment`** — a map of variables
  set for this step (or, at the top
  level, for all steps). Chapter 7 runs
  one and reads it back.
- **`when`** — conditions that decide
  whether the step (or whole workflow)
  runs at all: which event, which
  branch, which result so far. Also
  chapter 7, also run for real.

## The invisible first step

On a server, every workflow begins with
a step your file does not mention:
**clone**, which fetches the repository
at the exact commit that triggered the
run into the workspace. Under
`exec --local` there is nothing to
fetch — you are already standing in the
code — which is one of two reasons the
local run is a rehearsal rather than
the performance. The other reason is
chapter 4's: no container, no
isolation, your tools instead of the
image's.

## Order without depends_on

Steps without dependencies are not a
promise broken; they are parallel by
design, and on a multi-capacity agent
they genuinely overlap. If step B reads
what step A writes and B has no
`depends_on: [A]`, the pipeline is
wrong even when it usually passes —
the classic CI bug, and the reason the
fixture's `test` step names its
dependency even though a single local
run *looks* sequential.

The check for this chapter: pick up the
fixture's `.woodpecker-fail.yaml` and,
before chapter 6 runs it, predict —
which steps run, which does not, and
what the final exit code tells you.
