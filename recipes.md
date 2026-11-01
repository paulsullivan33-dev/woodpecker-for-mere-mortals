# Recipes

Outcome: four working habits, each
built from steps this guide ran for
real — except where a recipe crosses
into the documented-only server half,
which is said on the spot.

## Recipe 1: the pre-push check

Before pushing a change to a pipeline
file, make your own machine say what
the server will say:

```bash
woodpecker-cli lint --strict .woodpecker.yaml && \
woodpecker-cli exec --local --backend-engine local .woodpecker-local.yaml
```

`lint --strict` proves the shape
(chapter 6: warnings promoted to
errors, exit 1 on any complaint). The
local `exec` proves the commands, on
your tools. What it cannot prove is
the container run itself — different
image, different machine — so treat a
green pre-push as *the file and the
logic are right*, not *the run is
guaranteed*. Fully run in the lab:
transcripts `t01`, `t02`.

## Recipe 2: the two-file pattern

Keep both shapes of a pipeline and let
each do what it is good at:

- `.woodpecker.yaml` — the server's
  file, real images (`python:3.12`),
  real event filters.
- `.woodpecker-local.yaml` — the same
  steps with `image: bash` (or the
  interpreter program your machine
  offers), used only by `exec`.

When you change steps, change both in
the same commit; the local file is a
translation, not a fork, and it rots
if it drifts. The fixture ships
exactly this pair (with the fail and
env variants beside them) — the lab
ran the pattern, transcripts `t02`
and `t03`.

## Recipe 3: the nightly server check

A Woodpecker server should be asked,
regularly, whether it is still alive —
and the asking must not trust exit
codes, for chapter 8's reason. The
lab's script asks the three questions
that matter:

```bash
woodpecker-lab/check-server.sh http://127.0.0.1:18082
```

```text
GET http://127.0.0.1:18082/ (web UI)
  status=200 content_type=text/html; charset=UTF-8
GET http://127.0.0.1:18082/healthz (health endpoint)
  status=204 (204 means healthy)
GET http://127.0.0.1:18082/api/version
{"source":"https://github.com/woodpecker-ci/woodpecker","version":"3.20.1"}
GET http://127.0.0.1:18082/api/user without a token (must refuse)
  status=401 (401 means the door is locked)
```

Run it from cron, alert on any answer
that differs, and note the fourth
question doing quiet work: a server
that answers `/api/user` with anything
but 401 has a worse problem than
downtime. The script was run against
the lab server — transcript `t06`.

## Recipe 4: the failure drill

Teach anyone who will read CI results
what failure looks like, using a
pipeline that cannot hurt anything:

```bash
woodpecker-cli exec --local --backend-engine local .woodpecker-fail-local.yaml
echo "exit=$?"
```

Show them the three measured facts
from chapter 6: the step's `exit code
3` named in the output, the CLI's own
`exit=1`, and the dependent `report`
step that never appears. Then ask them
to predict the result of moving
`report`'s dependency — the drill
teaches `depends_on` better than any
diagram in this guide. Run in the lab:
transcript `t03`.

## Recipe 5: learn a feature on the fixture first

Every new pipeline idea — a `when`
filter, an environment block, a matrix
(the last is documented-only in this
guide) — gets tried on the tiny
fixture project before it touches a
real repository. The fixture's three
tests run in a second; a real
project's suite may run in twenty
minutes, and the mistake costs the
same to make in both. This is the
method the lab itself used, and the
reason `woodpecker-lab/fixture/`
exists in this guide's repository for
you to copy.
