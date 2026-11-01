# Troubleshooting

Each entry is a symptom the lab
actually met, its cause, and the check
that separates it from its neighbours.
Documented-only faults say so.

## "forge not configured" and the server simply stops

**Symptom:** the server logs
`Initializing Schema`, then the error
`could not setup service manager: forge not configured`,
and nothing listens.

**Cause:** no forge is configured. The
server has no forge-less mode
(chapter 8).

**Fix:** set one forge family
completely — for GitHub,
`WOODPECKER_GITHUB=true` plus client
ID and secret — and restart. And do
not let a startup script judge by exit
code: this failure exits **0**. Judge
by the socket:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:18082/healthz
# 204 means the server is genuinely up
```

## exec: "python:3.12": executable file not found in $PATH

**Symptom:** a local `exec` run dies
before the first command, naming the
step's image.

**Cause:** on the local backend,
`image` is the name of a program on
this machine, not a container to pull
(chapter 4). No program bears that
name.

**Fix:** for local runs, use a local
variant of the pipeline whose `image`
is a program that exists — `bash`,
`sh`, or a language interpreter — as
in `.woodpecker-local.yaml`. Keep the
container file for the server
(recipe 2).

## The run cannot find files that plainly exist

**Symptom:** `exec` with no flags
fails in the build step —
`No such file or directory: 'app.py'` —
in a folder where `app.py` is sitting
in front of you.

**Cause:** without `--local`, the run
executes in a workspace that does not
hold your working files (transcript
`t06`, run B). Naming
`--backend-engine local` alone happened
to run in place in the lab (run A);
no-flags auto-detect did not.

**Fix:** always run local pipelines
with both flags, the combination the
lab verified end to end:

```bash
woodpecker-cli exec --local --backend-engine local .woodpecker-local.yaml
```

## The step that never appears in the output

**Symptom:** a step is missing from an
`exec` log entirely — not failed, not
skipped-labelled, absent.

**Cause:** a `when` filter removed it.
Under `exec` the event is `manual`, so
an `event: push` step (the lab's
`push-only`) silently vanishes
(chapter 7). On the server the same
absence means the filter did not match
the real event, branch or path.

**Fix:** read the step's `when` block
against the run's actual context
(`CI_PIPELINE_EVENT` and friends), and
test filters on the fixture before
blaming the server.

## A dependent step "should have run" after a failure

**Symptom:** a later step shows as
skipped after an earlier failure, and
someone expected it to run anyway —
the notify step is the classic case.

**Cause:** `depends_on` means *run
only if this succeeded*. Chapter 6's
drill is built on it.

**Fix:** for steps that must run on
failure — notifications, cleanup —
the documented shape is a `when:
status: failure` condition rather than
a success dependency. (Documented
behaviour; the lab measured the
success-dependency half.)

## The agent logs an error about /etc/woodpecker/agent.conf

**Symptom:** `could not persist agent config at '/etc/woodpecker/agent.conf'`
in the agent's log, though it starts.

**Cause:** the agent's default identity
file lives under `/etc/woodpecker`,
which does not exist or is not
writable in your setup.

**Fix:** point `WOODPECKER_AGENT_CONFIG_FILE`
at a file in a folder the agent owns —
or set it empty for a stateless agent
that re-registers each start, knowing
it will also unregister at shutdown.

## Lint passes a file the server would frown at

**Symptom:** `lint` exits 0 on a file
with a misspelled key.

**Cause:** lint's default mode reports
schema complaints as warnings, and
warnings exit 0 (transcript `t01`).

**Fix:** gate with `lint --strict` in
your pre-push check (recipe 1), and
read warnings even when you do not:
the *when-filter* warning in
particular is lint telling you the
pipeline will run on events you have
not chosen.
