# The Moving Parts

By the end of this chapter you can name
every part of a Woodpecker installation
and say which part holds what — the
skill that turns "CI is broken" into a
sentence with a subject.

## The forge

The **forge** is where code lives:
GitHub, Gitea, Forgejo, GitLab,
Bitbucket and friends. Woodpecker does
not store your code. It asks the forge
who you are (login happens *through*
the forge, using OAuth), which
repositories you may see, and it asks
the forge to notify it — a **webhook**,
an HTTP call from forge to server —
when a push or a pull request arrives.
No forge, no server: chapter 8 shows
the server refusing to start without
one, with the error to prove it.

## The server

The **server** is the coordinator. It
serves the web page and the API, keeps
every pipeline's record, holds the
queue of waiting work, and stores its
state in a database — SQLite by
default, in one file; PostgreSQL and
MySQL are documented alternatives. It
is configured entirely through
environment variables, a fact chapter 8
uses heavily. The server does not run
your commands. Ever. That is the
agent's job, and the separation is a
safety property: the machine holding
the queue and the web page need not be
the machine executing repository code.

## The agent

The **agent** connects to the server
over gRPC — a persistent connection the
agent opens, so agents can sit behind
firewalls that allow outgoing traffic.
It announces its platform, its capacity
(how many pipelines at once) and its
**backend**, then takes work from the
queue. Chapter 9 registers a real agent
against the lab server and reads its
record out of the server's own
database: name, platform
`linux/amd64`, backend `local`, version
`3.20.1`.

## The backend

The **backend** is how an agent runs
steps. Three matter:

- **Docker** — the usual choice. Each
  step is a container from the step's
  named image; isolation comes free and
  the image *is* the toolchain.
- **Kubernetes** — each step becomes a
  pod in a cluster.
- **Local** — steps run directly on the
  agent's machine, as the agent's user,
  with no container at all. Fast and
  honest about having no isolation. This
  guide's lab runs this backend, and
  chapter 4 shows its one great quirk:
  the step's `image` field is treated
  as the name of a program on the
  machine.

## The pipeline file and the workspace

A **pipeline** is one run. Its
definition is the pipeline file in the
repository — one YAML file, or a folder
of them when a project needs several
workflows. A run proceeds in
**workflows** (roughly: files) made of
**steps**. Before your steps, Woodpecker
adds a **clone** step that fetches the
code into the **workspace**, a folder
shared by every step of the workflow —
which is why the build step's output
files are still there for the test
step.

## The CLI

The **command-line tool**,
`woodpecker-cli`, is this guide's
workhorse. It talks to a server (list
repositories, read pipeline logs,
manage settings) and it works without
one: `lint` checks a pipeline file
against the schema, and `exec` runs a
pipeline locally. That offline half is
what lets chapters 4 to 7 prove things
before any server exists.

## Who holds what

| Part | Holds | Never holds |
| --- | --- | --- |
| Forge | the code, your identity, webhooks | pipeline results |
| Server | the queue, the records, the web page, the database | your code, the running of steps |
| Agent | the execution, the step logs as they happen | the long-term record |
| Backend | the isolation story (or its absence) | the pipeline definition |
| CLI | your local checks and runs | any state at all |

Check your model: if the web page
vanishes, which part fell over? The
server. If pipelines queue forever with
none running? No agent is connected, or
none matches. If a step cannot find a
tool it needs? The backend and the
step's image. The rest of the guide is
those three sentences, expanded.
