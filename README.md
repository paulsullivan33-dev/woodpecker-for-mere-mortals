# Woodpecker for Mere Mortals

Every project has a moment of doubt: the
code works on your machine, but does it
work from a clean start, in order, with
nothing forgotten? **Continuous
integration** — CI — is the habit of
answering that question with a machine.
You write down the checks once, in a
file that lives with the project, and a
program runs them the same way every
time: build, then test, then report.

**Woodpecker** is a CI system you run
yourself. It is one small server program,
one agent program that does the work,
and a command-line tool — each a single
file you can download, check, and run.
It watches a **forge** (the place your
code lives, such as GitHub or Gitea),
and every time the code changes it runs
your written checks and shows you the
result in a web page. No account with a
CI company, no per-minute billing, and
the runs happen on machines you own.

One warning belongs at the front,
because everything else follows from
it: **a CI server is a code-execution
service by design.** Its whole job is to
take commands written in a repository
and run them. Connect only repositories
you trust, guard the server's secrets
and tokens the way you guard passwords,
and think twice before exposing one to
the open internet. Chapter 1 returns to
this; it is not fine print.

The lab behind this guide ran the real
thing: **Woodpecker 3.20.1** — the
official server, agent and CLI binaries,
checksum-verified — on a small Linux
machine **with no containers available**.
That constraint shaped the lab honestly.
The Docker machinery most Woodpecker
installations use could not run here,
so the guide proves what can be proved
without it: the CLI checking a pipeline
file and then *executing* a real
pipeline on the local machine — a build
step and a test step over a tiny Python
project, passing — then the same shape
of pipeline failing on purpose, so the
exit codes and the skipped steps are
measured, not described. Then the
server itself: booted on a test port
with its SQLite database, answering its
web page, its health endpoint and its
API, and an agent registering with it
in local mode over a socket.

What the lab could not do, it did not
fake. Connecting a real forge needs an
OAuth application registered with that
forge and a browser to approve it, so
the forge connection, repository
activation and webhook-triggered runs
are taught from the project's
documentation and labelled as such
wherever they appear. The server flatly
refuses to start without a forge
configured — the lab proved that too,
and chapter 8 shows the exact error.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What Woodpecker is**](what-woodpecker-is.md) —
  the mental model: checks written down
  once, run the same way every time, on
  your own machines
- [**The moving parts**](the-moving-parts.md) —
  server, agent, CLI, forge, pipeline
  file and database — and which part
  holds what
- [**Installing Woodpecker**](installing-woodpecker.md) —
  the three release downloads, the
  checksum check, and the version lines
  that prove they run
- [**Your first pipeline**](your-first-pipeline.md) —
  lint the file, then run it locally:
  a build step and a test step, passing,
  with the exit code to prove it
- [**Reading a pipeline file**](reading-a-pipeline-file.md) —
  steps, commands, images and
  `depends_on`, read line by line
- [**When pipelines fail**](when-pipelines-fail.md) —
  a step that exits 3, what the CLI
  reports, which later steps never run,
  and lint's strict mode
- [**Context, environment and filters**](context-environment-and-filters.md) —
  the `CI_` variables every step can
  read, the environment block, secrets
  in outline, and `when` filters that
  decide what runs at all
- [**Running the server**](running-the-server.md) —
  configuration by environment
  variables, the forge it insists on,
  and the page, health and API checks
  that prove it is alive
- [**Agents and backends**](agents-and-backends.md) —
  where pipelines actually execute:
  Docker, Kubernetes and the local
  backend, and an agent registering
  with the lab server
- [**Forges, repositories and webhooks**](forges-repositories-and-webhooks.md) —
  the documented-only heart of a real
  installation: OAuth, activating a
  repository, and runs that start
  themselves
- [**Recipes**](recipes.md) — a pre-push
  check, a two-file pattern for laptop
  and server, a nightly server health
  check, and a failure drill
- [**The neighbours**](the-neighbours.md) —
  GitHub Actions, GitLab CI, Jenkins,
  and Drone, the ancestor: what each
  does that Woodpecker doesn't, and
  vice versa
- [**Limits**](limits.md) — no forge, no
  server; a local backend with no
  isolation; exit codes that need
  reading carefully; and the parts of
  a real installation this lab could
  not prove
- [**Troubleshooting**](troubleshooting.md) —
  the forge error, the image that is
  not a program, the run that cannot
  find your files, and the traps this
  guide's lab fell into
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Running pipelines in Docker or
Kubernetes in this lab — the sandbox
has no containers, so those backends
are explained and labelled
documented-only, with the local backend
run for real instead. Registering a
real OAuth application with GitHub or
another forge — that needs your own
forge account and a browser; chapter 10
walks the documented path. Hosting a
public Woodpecker for other people's
repositories — a different risk profile,
and chapter 1's warning is the start of
why.

## How to use this guide

Read chapter 1 for the model and
chapter 2 before installing anything —
knowing which part holds what turns
later confusion into a named problem.
Chapters 3 and 4 get you a checked
pipeline run in one sitting, with no
server at all. Chapters 8 to 10 are the
server story. The lab's transcripts
live in `woodpecker-lab/transcripts/`;
its fixture project is
`woodpecker-lab/fixture/` and its
server check script is
`woodpecker-lab/check-server.sh`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [GitHub Actions for Mere Mortals](https://paulsullivan33-dev.github.io/github-actions-for-mere-mortals/)
- [Jenkins for Mere Mortals](https://paulsullivan33-dev.github.io/jenkins-for-mere-mortals/)
- [GitLab for Mere Mortals](https://paulsullivan33-dev.github.io/gitlab-for-mere-mortals/)
- [act for Mere Mortals](https://paulsullivan33-dev.github.io/act-for-mere-mortals/)
- [Dagger for Mere Mortals](https://paulsullivan33-dev.github.io/dagger-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/woodpecker-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/woodpecker-for-mere-mortals/blob/main/LICENSE-CODE).
