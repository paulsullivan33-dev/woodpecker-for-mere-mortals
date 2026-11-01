# Your First Pipeline

Outcome: a pipeline file checked by the
linter, then executed on your own
machine — a build step and a test step
over a real (tiny) project, ending in a
passing run with exit code 0. No server,
no containers, no forge. Transcript
`t02` is the evidence; `t01` covers the
linting.

## The fixture project

The lab's project is deliberately
small, and lives in this guide's
repository at `woodpecker-lab/fixture/`:
`app.py` (two functions and a greeting)
and `test_app.py` (three unit tests).
Any small project of your own works the
same way; what matters is that its
checks are commands you can type.

## Step one: write the pipeline

A pipeline file is YAML. This is the
shape a Woodpecker *server* expects,
where each step names the container
image whose tools it will use:

```yaml
steps:
  - name: build
    image: python:3.12
    commands:
      - python3 --version
      - python3 -m py_compile app.py test_app.py
      - echo "build step finished"

  - name: test
    image: python:3.12
    commands:
      - python3 -m unittest -v
    depends_on: [build]
```

Two steps. `build` compiles both files
to prove they parse; `test` runs the
test suite, and declares with
`depends_on` that it is only worth
running after `build` has passed.
Chapter 5 reads this file properly.

## Step two: lint before you run

```bash
woodpecker-cli lint .woodpecker.yaml
```

```text
⚠️  .woodpecker.yaml has 2 warnings:
   ⚠️  Consider adding a `when` block with an `event` filter to this step or the entire workflow
```

Lint's warnings are advice, not
failure — the exit code was 0. This
one is the linter noticing the pipeline
will run on *every* event the forge
sends; chapter 7 is about those
filters. Chapter 6 shows what lint does
with a file that is actually wrong, and
with malformed YAML (a fatal error,
exit 1, with the parser's position
named). Lint first, always: it is the
cheapest CI run you will ever get.

## Step three: run it — and meet the local backend's quirk

```bash
woodpecker-cli exec --local --backend-engine local .woodpecker.yaml
```

The lab's first attempt produced the
guide's most instructive failure:

```text
# woodpecker
exec: "python:3.12": executable file not found in $PATH
```

Read it literally. On the **local
backend** there are no containers, so
the step's `image` is not pulled and
started — it is treated as **the name
of a program on this machine**, the
program that will run the step's
command script. There is no program
called `python:3.12` on the machine, so
the run dies before the first command.
The fix for local runs is to name a
program that exists — the shell:

```yaml
steps:
  - name: build
    image: bash
    commands:
      - python3 --version
      - python3 -m py_compile app.py test_app.py
      - echo "build step finished"
  # ... the test step, with image: bash too
```

That file is the fixture's
`.woodpecker-local.yaml`. Neither file
is a compromise of the other: the
container version is what a server with
the Docker backend wants, the `bash`
version is what your own machine wants,
and keeping both is recipe 2 in
chapter 11.

## Step four: the passing run

```bash
woodpecker-cli exec --local --backend-engine local .woodpecker-local.yaml
echo "exit=$?"
```

```text
[build:L0:0s] ▶  python3 --version
[build:L1:0s] Python 3.12.3
[build:L2:0s] ▶  python3 -m py_compile app.py test_app.py
[build:L3:0s] ▶  echo "build step finished"
[build:L4:0s] build step finished
[test:L0:0s] ▶  python3 -m unittest -v
[test:L1:0s] test_add (test_app.TestApp.test_add) ... ok
[test:L2:0s] test_add_negative (test_app.TestApp.test_add_negative) ... ok
[test:L3:0s] test_greeting (test_app.TestApp.test_greeting) ... ok
[test:L6:0s] Ran 3 tests in 0.000s
[test:L8:0s] OK
exit=0
```

Read the output's shape, because every
Woodpecker log shares it: each line is
prefixed with the step's name and a
line number, commands are echoed with
a `▶` before their output, and the
verdict is the process exit code —
**0**. The flags matter, and chapter 14
has the trap in full: `exec` with no
flags at all ran this same file in a
workspace that did not hold the
project, and the build failed on a
missing `app.py` (transcript `t06`).
`--local` says *run from this folder*;
`--backend-engine local` says *run on
this machine, not in containers*. Say
both, every time, for local runs.
