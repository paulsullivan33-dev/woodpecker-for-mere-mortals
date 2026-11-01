# Forges, Repositories and Webhooks

This whole chapter is **documented-only**:
it describes, from Woodpecker's own
documentation, the half of a real
installation the lab could not run.
Registering an OAuth application needs
an account at a real forge and a
browser to approve the sign-in; the lab
had neither, and faked neither. What
the lab *did* prove is everything
around this chapter — the server booting
with a forge configured, the forge
listed by its API, the agent waiting
for work (chapters 8 and 9). Read this
chapter as the map between those two
proven shores.

## Registering the OAuth application

On your forge, you create an OAuth
application owned by you (or your
organisation). Two values come back —
a client ID and a client secret — and
one value goes in from your side: the
authorization callback URL, which is
your server's address with the path
`/authorize` (for GitHub-style forges,
per the documentation). Those values
become the server's environment:

```bash
export WOODPECKER_GITHUB=true
export WOODPECKER_GITHUB_CLIENT=<the client id from your forge>
export WOODPECKER_GITHUB_SECRET=<the client secret from your forge>
```

GitHub, Gitea, Forgejo, GitLab and
Bitbucket each have their own variable
family (`WOODPECKER_GITEA_*`,
`WOODPECKER_GITLAB_*`, ...) and the
same shape. Restart the server and the
forge appears — as the lab's
placeholder did in `/api/forges`.

## Logging in, and what login grants

The web page's login button sends you
to the forge, which asks whether
Woodpecker may act with the permissions
the application requested (reading your
repositories, adding webhooks to the
ones you activate). Approving returns
you to the server, logged in as your
forge identity. There are no
Woodpecker-local user accounts to
manage; the forge *is* the account
system — which is also why chapter 8's
server refuses to exist without one.
Users named in `WOODPECKER_ADMIN`
become server administrators on their
first login.

## Activating a repository

From the web page (or the CLI, once
you hold a token from that login), you
**activate** a repository. Activation
does two things: the server records
the repository and generates a webhook
secret for it, and — via the forge's
API — a **webhook** is planted in the
repository's settings, pointing at
your server. From then on the forge
calls that webhook on every push, pull
request, tag and similar event; the
server checks the call's signature
against the secret, reads the pipeline
files at that commit, applies any
repository-level settings (trusted
flags govern the dangerous powers:
volume mounts, privileged steps,
network access), and queues the run
for an agent.

Deactivating is the mirror: webhook
removed, record kept for history.
Repositories can also be gated by
**filters** on the server (only
organisations or names you list) and
by required configuration approval for
forks — the controls that keep
chapter 1's warning operational
rather than aspirational.

## What a triggered run looks like

Push → webhook → the server queues a
pipeline whose `CI_` variables now
carry the real commit, branch and
event → an agent takes it, clones,
runs the workflows, streams logs back
→ the server stores the record and, if
configured, reports the result back to
the forge as a commit status, visible
beside the pull request. Cron
pipelines (a schedule stored per
repository, run by the server's cron
service the boot log announced) and
manual re-runs from the web page join
the same queue. Every element of that
chain except the forge's half was
exercised somewhere in this guide's
lab; the chain as a whole is the part
your own forge account completes.
