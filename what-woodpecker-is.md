# What Woodpecker Is

You have a project — a program, a
script, a small tool — and a set of
checks you run before you trust a
change: does it still compile, do its
tests pass, did anyone break the
packaging? Run by hand, those checks
depend on memory and mood. **Continuous
integration (CI)** replaces the mood
with a file: the checks are written
down, in order, in the project itself,
and a program runs them exactly as
written, every time, and keeps the
receipt.

**Woodpecker is a CI system you host
yourself.** A small server keeps the
list of projects and results and shows
them on a web page. One or more
**agents** — separate programs, often
on other machines — do the actual
running. The two talk over a dedicated
connection. The server learns that code
changed from a **forge**: the service
where the code lives, such as GitHub,
Gitea, GitLab or Bitbucket. When the
forge reports a push, the server reads
the pipeline file in that repository,
hands the work to an agent, and records
what happened, step by step.

The pipeline file is the heart of it.
It is a YAML file — conventionally
`.woodpecker.yaml` in the repository,
or several files in a `.woodpecker/`
folder — that names **steps**. Each
step names a container image and a list
of commands. On a typical installation
each step runs in a fresh container
built from that image, in a shared
**workspace** folder holding the
project's files. If every command in
every step exits with status 0, the
pipeline passes. The first non-zero
exit fails its step, and steps that
depend on it do not run. That is the
whole contract, and chapter 6 measures
it rather than asking you to believe
it.

## The warning, stated plainly

A CI server runs commands written in
repositories. That is not a side
effect; it is the product. Anyone who
can get a pipeline file into a
repository your server builds can run
code on your agent machines, with the
permissions those machines give it.
Woodpecker's own documentation is clear
about the trust this implies, and this
guide repeats it early because every
later choice depends on it:

- Connect only repositories whose
  authors you trust to run code on your
  hardware.
- Treat the agent secret and user
  tokens like passwords — they are
  passwords, in every way that matters.
- Prefer a server reachable only on
  your own network, or behind the
  forge's login, over one open to the
  internet.

## A first taste

You do not need the server to meet a
pipeline. The command-line tool can
check a pipeline file and run it on
your own machine. After installing
(chapter 3), in the lab's fixture
project:

```bash
woodpecker-cli lint .woodpecker-local.yaml
woodpecker-cli exec --local --backend-engine local .woodpecker-local.yaml
```

The second command is this guide's
chapter 4, and its output ends the way
every CI run should — with evidence:

```text
[test:L6:0s] Ran 3 tests in 0.000s
[test:L8:0s] OK
```

## Where Woodpecker came from

Woodpecker began as a community fork of
Drone, an earlier open CI system, and
is developed in the open under the
Apache and AGPL licences (the server is
AGPL-3.0). It is written in Go and
ships as single static binaries — one
for the server, one for the agent, one
for the CLI — which is why installing
it in chapter 3 is a download and a
checksum, not a package saga.

## What it is not

Woodpecker is not a build tool: it does
not know how to compile your project.
It runs *your* commands — the same
`make`, `npm`, `pytest` or shell lines
you would type — in order, in a clean
setting, and reports faithfully. It is
not a deployment service either,
although a pipeline step can deploy,
because a step can do anything a
command can do. And it is not a hosted
service: there is no Woodpecker cloud
waiting with open arms. The server in
chapter 8 is yours, on your machine,
which is precisely the appeal — and
precisely why the warning above is
yours to heed.
