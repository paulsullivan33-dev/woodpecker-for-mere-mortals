# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's project is an invented greeting program and its
   credentials are labelled inventions.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 13 names what the tool
   cannot do: a server that will not start without a forge,
   that same failure exiting with code 0, a local backend with
   no isolation whose image field is a program name, a CLI
   whose own exit code collapses every step failure to 1, lint
   that only advises unless run with --strict, and the whole
   forge-driven half of a real installation that this lab
   could not exercise.
8. **The ethics rule is in the text, early.** A CI server is a
   code-execution service by design, and the README and
   chapter 1 say so before any procedure depends on it:
   connect only repositories you trust to run code on your
   hardware, treat the agent secret and user tokens as the
   passwords they are, keep secrets out of pipeline files,
   and prefer a server on your own network over one exposed
   to the internet.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu 24.04 sandbox,
shared with other work while the lab ran. It has **no
containers** — no Docker or Podman daemon exists — and the lab
treated that as a fact to design around, not to hide.
Woodpecker **3.20.1** (release published 2026-10-29) was
installed from the official release archives
`woodpecker-cli_linux_amd64.tar.gz`,
`woodpecker-server_linux_amd64.tar.gz` and
`woodpecker-agent_linux_amd64.tar.gz`, each verified against
the release's own `checksums.txt` with `sha256sum -c`, and
run unmodified. All transcripts live in
`woodpecker-lab/transcripts/`; the fixture project and its
pipeline files are `woodpecker-lab/fixture/`, the check
script is `woodpecker-lab/check-server.sh`, and the lab's
server environment is kept, with its invented values, as
`woodpecker-lab/server-env.example.sh`. The server ran only
on the loopback test port 18082, with its agent channel on a
unix socket so that no other TCP port was needed; every lab
process was stopped afterwards and the port confirmed free.

Run for real, with transcripts as evidence:

- Versions of all three binaries (3.20.1 each), checksum
  verification of all three archives, and the release
  identity from the project's GitHub API (t00).
- Lint: the fixture pipeline passing with two `when`-filter
  warnings and exit 0; an unknown key producing warnings at
  exit 0 in default mode; the same file under `--strict`
  failing with exit 1; malformed YAML failing fatally with
  the parser position named, exit 1 (t01).
- A real local pipeline execution: the server-style file
  (image `python:3.12`) failing under the local backend with
  `executable file not found in $PATH`, proving the local
  backend treats `image` as a program name; the same steps
  with `image: bash` passing — build step (version,
  byte-compile) and test step (3 unit tests, OK), CLI exit 0
  (t02).
- A deliberately failing pipeline: the test step's `exit 3`
  reported verbatim in the output, the CLI itself exiting 1,
  and the dependent `report` step never appearing (t03).
- Context and filters: an `environment` variable read back
  inside its step; `CI_` variables showing `exec`'s honest
  placeholders (`CI_PIPELINE_EVENT=manual`, number 0); a
  `when: event: push` step silently absent from the manual
  run (t03).
- The server refusing to boot without a forge — exact error
  `forge not configured` — and, measured separately, exiting
  with code 0 despite that fatal error (t04). The server
  then booting with a GitHub forge configured with invented
  placeholder OAuth values, creating its SQLite database at
  the configured path, listening on 18082 only (t04).
- The running server answering: `/` and `/login` with 200
  and the Woodpecker page, `/healthz` with 204,
  `/api/version` with the version JSON, `/api/forges`
  listing the configured github forge, `/swagger/index.html`
  with 200, and `/api/user` and `/api/repos` with 401
  without a token; the CLI without a context failing
  against it as unconfigured (t04, t06).
- An agent starting with the local backend, connecting over
  the unix gRPC socket, and registering: its row read back
  from the server's own `agents` table — name lab-agent,
  platform linux/amd64, backend local, capacity 1, version
  3.20.1, last_contact advancing (t05).
- The flag trap, both halves: `exec --backend-engine local`
  without `--local` passing in place, and `exec` with no
  flags at all failing in a workspace that lacked the
  project files; plus the lab's `check-server.sh` run
  against the live server (t06).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- The Docker and Kubernetes backends, including container
  isolation, step images as toolchains, volumes, networks,
  privileged steps and services: the sandbox has no
  containers and no cluster.
- Forge OAuth end to end: registering a real OAuth
  application, browser login, `WOODPECKER_ADMIN` first-login
  behaviour, repository activation, webhook delivery and
  signature checking, triggered pipeline runs, commit
  statuses, cron pipelines, and repository trust flags.
  Chapter 10 is this material, labelled as such at its head.
- The server-side secrets store (repository, organisation
  and global secrets, log masking) and passing real secrets
  to pipelines; the guide teaches the rules and the CLI's
  `--secrets` surface from the documentation only.
- Matrix builds, deployment targets, agent labels steering
  real work (the lab's single agent idled), multi-agent
  queues, PostgreSQL and MySQL databases, TLS termination,
  and upgrades — including the 4.0 service-failure default
  change the lab's boot log announced.
- The neighbour systems of chapter 12 (GitHub Actions,
  GitLab CI, Jenkins, Drone, act, Dagger) — characterised,
  not run or benchmarked.

Fixtures are this guide's own and deliberately generic: a
two-function greeting program with three unit tests, an
intentionally failing pipeline whose only job is to fail,
invented secret strings labelled as inventions
(`lab-agent-secret-invented-123`, placeholder OAuth values),
loopback addresses and one test port. No real repository,
forge account, credential or organisation appears anywhere
in the lab.
