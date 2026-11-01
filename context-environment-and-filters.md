# Context, Environment and Filters

Outcome: you can read the context
Woodpecker hands every step, set your
own variables, and predict which steps
a `when` filter will quietly remove
from a run. Transcript `t03`'s second
half is the evidence.

## The CI_ variables

Every step runs with a set of
environment variables describing the
run, all prefixed `CI_`. The lab read
them back from inside a step:

```text
CI_PIPELINE_EVENT=manual
CI_PIPELINE_NUMBER=0
CI_PIPELINE_STATUS=success
CI_COMMIT_BRANCH=main
CI_WORKSPACE=/home/.../fixture
```

On a server run these carry the real
story — the triggering event (`push`,
`pull_request`, `tag`, `cron`,
`manual`), the commit, the repository,
the pipeline's number and URL — and
steps use them for everything from
naming an artifact after the commit to
refusing to deploy from a pull request.
Under `exec`, as the transcript shows,
the values are honest placeholders:
event `manual`, number 0. A step that
behaves differently per event will
therefore behave *manually* under
`exec` — remember that when a local
rehearsal surprises you.

## Your own variables: environment

The `environment` block sets variables
for one step, or for the whole file
when placed at the top level:

```yaml
  - name: show-context
    image: bash
    environment:
      GREETING: hello-from-the-pipeline
    commands:
      - echo "GREETING is $GREETING"
```

```text
[show-context:L1:0s] GREETING is hello-from-the-pipeline
```

Plain values only, in the file, for
everyone with the repository to read.
Anything that must stay secret does
not belong here — it belongs in the
next section's subject.

## Secrets, in outline

Woodpecker has a real secrets system:
values stored on the server (per
repository, organisation, or globally),
injected into steps that name them,
and masked in logs. The CLI can pass
ad-hoc secrets to `exec` with
`--secrets` or a secrets file. This
guide did **not** run the server-side
store — it needs an authenticated
repository the lab never had — so the
mechanics are documented-only here,
taught from the project's docs in
chapter 10's neighbourhood. The rules
that need no lab: a secret in a
pipeline file is not a secret; a
secret printed by a step is a secret
published; forks and pull requests
from strangers are exactly where
secrets must not flow, and Woodpecker's
event filters are part of how you
enforce that.

## when: the filter that removes steps

A `when` block attaches conditions to
a step or a whole workflow. The lab's
specimen:

```yaml
  - name: push-only
    image: bash
    when:
      event: push
    commands:
      - echo "this step only runs on push events"
```

Under `exec`, where the event is
`manual`, the transcript shows the
whole run — and `push-only` is simply
**absent**. No line, no "skipped"
marker in the CLI output; the step is
not in the run at all. Three lessons:

- Filters are silent. If a step matters,
  its absence must be something you
  check for, not something the tool
  announces.
- The linter's favourite warning —
  *consider adding a `when` block with
  an `event` filter* — is this chapter
  knocking: an unfiltered pipeline runs
  on every event, including events you
  may not want spending your machine.
- Common conditions beyond `event`
  (from the documentation): `branch`,
  `ref`, `status` (run only if earlier
  steps succeeded — or only if they
  failed, the classic *notify on
  failure* shape), `path` (run only
  when matching files changed), and
  `target` for deployments.

The check for this chapter: in the
fixture's `.woodpecker-env.yaml`, add
a step filtered to `event: manual`
and re-run. It should appear — the one
filter `exec` will always satisfy.
