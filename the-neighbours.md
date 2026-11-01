# The Neighbours

Woodpecker sits in a busy field —
systems that run your checks for you.
These are characterisations from the
projects' own documentation and this
series' sister guides, not benchmarks;
the lab ran Woodpecker only.

## GitHub Actions: the hosted default

If your code lives on GitHub, Actions
is already there: workflows in
`.github/workflows/`, an enormous
marketplace of prebuilt steps, hosted
runners that appear on demand, billed
by the minute beyond a free allowance.
It asks nothing of your hardware and
gives back nothing to run yourself —
the runners are Microsoft's machines,
the queue is Microsoft's problem, and
so is the outage. Woodpecker's trade is
the mirror image: your machines, your
queue, your outage, and no meter. This
series' own guide teaches Actions in
full; many readers will honestly need
both — Actions for public projects,
Woodpecker for the ones that should
never leave the building.

## GitLab CI: the bundled engine

GitLab ships its CI inside the forge:
one product, one login, pipelines
defined in `.gitlab-ci.yml`, runners
you host or GitLab does. If your forge
is already GitLab, its CI is the
path of least resistance and a good
one. Woodpecker's counter-offer is
independence: it fronts *several*
forges with one CI, including forges
far lighter than GitLab itself, and
its server is one binary rather than a
platform.

## Jenkins: the veteran

Jenkins automated builds before "CI"
was a word in common use, and its
plugin universe can integrate with
nearly anything ever shipped. The
costs are weight and care: a JVM
service, plugins to curate, a
configuration surface measured in
acres. Woodpecker is what a Jenkins
user builds when they decide the
acres are the problem: fewer powers,
fewer knobs, a pipeline file a
newcomer can read whole. Readers
running serious Jenkins estates will
find migration paths in neither
direction trivial, and this guide does
not pretend otherwise.

## Drone: the ancestor

Woodpecker began as a fork of Drone,
and the family resemblance is in every
chapter of this guide — the pipeline
shape, the agent model, the clone step.
Drone continued commercially under its
new owners with its own licensing;
Woodpecker continued as the community
project, AGPL server and all, and is
where the open development energy of
that lineage now lives. A reader
choosing between them is choosing a
governance and licence story more than
a feature list.

## act and Dagger: the other answers

Two sister guides attack neighbouring
problems. **act** runs GitHub Actions
workflows locally in containers — a
rehearsal tool for someone else's CI,
where Woodpecker's `exec` is the
rehearsal for its own. **Dagger** turns
pipelines into code in a real
programming language, run through one
engine anywhere. Woodpecker's YAML is
less powerful than Dagger's code and
less borrowed than act's
compatibility — deliberately: a file a
mere mortal can read at a glance is
the feature.
