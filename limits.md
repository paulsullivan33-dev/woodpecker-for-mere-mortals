# Limits

What Woodpecker cannot do, stated as
plainly as chapter 1 stated what it
can. Items the lab measured say so;
the rest are the project's documented
shape.

- **No forge, no server.** The server
  refuses to start without a forge
  configured — measured, with the
  error in transcript `t04`. There is
  no standalone mode, no local user
  database, no way to practise the web
  page without at least registering a
  forge. The CLI's offline half is the
  only forge-free Woodpecker there is.
- **A dishonest exit code at startup.**
  On that fatal configuration error the
  server process still exits 0 —
  measured. Supervisors and scripts
  must judge the server by its health
  endpoint, never by its exit status.
- **The local backend has no
  isolation.** Steps run as the agent's
  user, on the agent's machine, with
  its filesystem and network. The
  `image` field there is a program
  name, not a container — measured in
  chapter 4. Use this backend for your
  own code on your own machines; it is
  not a sandbox and does not claim to
  be.
- **exec is a rehearsal, not the
  performance.** Local runs use your
  tools, your folder, and placeholder
  context (event `manual`, pipeline
  number 0 — measured in transcript
  `t03`). A pipeline that passes under
  `exec` can still fail on the server:
  different image contents, a clean
  clone, real event filters. Chapter
  11's recipe 1 exists because of this
  gap, not despite it.
- **The step's exit code does not
  propagate through the CLI.** A step
  exiting 3 makes `exec` exit 1 —
  measured. The real number survives
  in the output text and in the
  server's records, but wrapper scripts
  get one bit: pass, or fail.
- **Lint advises more than it
  enforces — unless told.** Warnings
  (a missing `when` filter, and in
  default mode even a misspelled key)
  exit 0. Only `--strict` turns the
  linter into a gate — measured in
  transcript `t01`.
- **Secrets and strangers need
  governing.** Woodpecker provides the
  mechanisms — repository trust flags,
  event filters, secret scoping — but
  the policy is yours. The tool will
  faithfully run a pipeline you should
  not have connected; chapter 1's
  warning is a limit of the tool as
  much as of the reader.
- **One database, honestly sized.**
  SQLite-by-default is a household and
  small-team answer. Larger
  installations move to PostgreSQL or
  MySQL (documented), and the web
  page's comfort scales with the
  agents behind it, not with hope.
- **Behaviour is still moving.** The
  lab's boot log carries the project's
  own notice that a service-failure
  default changes in the coming 4.0 —
  a reminder that a young, actively
  developed tool will occasionally
  change a default under an upgrade.
  Pin versions (the lab pinned
  3.20.1), read release notes, and let
  `lint` speak before the server does.
- **What this guide could not prove**
  is itself a limit of the guide, and
  it is listed in `criteria.md`:
  Docker and Kubernetes backends,
  forge OAuth, activated repositories,
  webhook-triggered runs, the secrets
  store, services and matrix builds —
  all documented-only here.
