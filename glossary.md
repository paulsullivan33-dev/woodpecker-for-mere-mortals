# Glossary

**Agent** — the Woodpecker program
that executes pipelines. It connects
to the server, announces its platform,
capacity and backend, and takes work
from the queue.

**Backend** — how an agent runs steps:
Docker (a container per step),
Kubernetes (a pod per step), or local
(directly on the agent's machine, with
no isolation).

**CI (continuous integration)** — the
practice of running a project's
written checks automatically on every
change, and keeping the result.

**Clone step** — the automatic first
step of a server workflow, which
fetches the repository at the
triggering commit into the workspace.

**depends_on** — a step's declaration
that it may start only after the named
steps have succeeded. Also orders the
run; dependents of a failed step are
skipped.

**Event** — what triggered a pipeline:
`push`, `pull_request`, `tag`,
`cron`, or `manual`. Steps and
workflows can filter on it with
`when`.

**exec** — the CLI subcommand that
runs a pipeline locally, without a
server. With `--local` and
`--backend-engine local` it rehearses
a pipeline on your own machine.

**Forge** — the service hosting the
code and the identities: GitHub,
Gitea, Forgejo, GitLab, Bitbucket. A
Woodpecker server cannot start
without one.

**gRPC** — the protocol of the
persistent connection between agents
and server. The agent dials it, which
is why agents work behind firewalls.

**Health endpoint** — an HTTP path
(`/healthz` on Woodpecker) that
answers 204 when the server is up. The
honest way to check a server, since
its startup failures can exit 0.

**Image** — on container backends,
the container image a step runs in —
its toolchain and filesystem. On the
local backend, the name of a program
on the machine that runs the step's
script.

**Lint** — the CLI subcommand that
checks a pipeline file against the
schema without running it. Warnings
exit 0; `--strict` makes them errors.

**Pipeline** — one complete run of a
repository's pipeline files,
triggered by one event, made of
workflows made of steps.

**Secret** — a value stored on the
server and injected into steps that
name it, masked in logs, and never
written in the pipeline file itself.

**Step** — one named unit of a
workflow: an image, a list of
commands, an optional dependency list.
A step fails at its first command
that exits non-zero.

**Webhook** — an HTTP call the forge
makes to the server when something
happens in a repository. Activation
plants one; its signed secret is how
the server knows the call is genuine.

**when** — the condition block on a
step or workflow: event, branch,
status, path and more. A step whose
`when` does not match is not in the
run at all — silently.

**Workflow** — one pipeline file's
worth of steps. Several files in a
`.woodpecker/` folder form one
pipeline of several workflows.

**Workspace** — the folder shared by
all steps of a workflow, holding the
cloned code, so one step's files are
the next step's starting point.
