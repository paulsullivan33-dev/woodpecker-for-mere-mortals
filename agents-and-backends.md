# Agents and Backends

Outcome: an agent registered with the
lab server, its record read back from
the server's own database, and a clear
picture of the three backends and what
each one isolates. Transcript `t05` is
the evidence.

## Starting the lab agent

The agent needs three things: where
the server's gRPC channel is, the
shared secret, and which backend to
run. With the server from chapter 8
already up:

```bash
WOODPECKER_SERVER=unix:///path/to/server-data/agent.sock \
WOODPECKER_AGENT_SECRET=lab-agent-secret-invented-123 \
WOODPECKER_BACKEND=local \
WOODPECKER_HOSTNAME=lab-agent \
WOODPECKER_AGENT_CONFIG_FILE=/path/to/server-data/agent.conf \
  ./woodpecker-agent
```

Its log's summary line is the whole
chapter in one record:

```text
{"version":"3.20.1","backend":"local","platform":"linux/amd64","parallel workflows":1,"message":"starting Woodpecker agent"}
```

`WOODPECKER_AGENT_CONFIG_FILE` deserves
its sentence: left unset, the agent
expects to persist its identity in
`/etc/woodpecker/agent.conf`, and the
lab's first attempt logged an error
when that folder did not exist. A
stateless agent (empty config path)
re-registers on every start and
unregisters when it stops; a persisted
identity survives restarts. Name the
file somewhere writable and the error
goes away.

## The proof lives in the database

The agent does not merely claim to
have connected. The server's SQLite
database holds an `agents` row, which
the lab read back (token column not
shown):

```text
{'id': 1, 'name': 'lab-agent', 'platform': 'linux/amd64',
 'backend': 'local', 'capacity': 1, 'version': '3.20.1',
 'last_contact': 1793502706, 'last_work': 0}
```

`last_contact` kept advancing while the
agent idled: registered, healthy, and
waiting for work that — without an
activated repository — would never
come. That is the honest state of the
lab's server half: the full skeleton,
server and agent shaking hands, with
no forge-driven pipeline ever run
through it.

## The three backends, honestly

- **Docker** (the default, and what
  most installations use). Every step
  is a container from its `image`; the
  image is the toolchain, the container
  is the isolation, and a step can
  damage nothing outside its workspace
  and volumes. Needs a Docker daemon on
  the agent machine — the lab had none,
  so this backend is documented-only in
  this guide.
- **Kubernetes.** Steps become pods;
  the cluster provides isolation and
  scheduling. Documented-only here for
  the same reason, squared.
- **Local.** Steps run as the agent's
  own user, on the agent machine, with
  its tools — the backend chapters 4
  to 7 exercised through `exec`, and
  this chapter through a registered
  agent. Its isolation story is *none*,
  which is sometimes exactly right (a
  build machine of your own, running
  your own repositories) and never
  right for strangers' code. Chapter
  1's warning applies to this backend
  at full strength.

Agents also carry **labels** — tags
that pipeline files can require (a
`platform: linux/arm64` need, a
`gpu=true` need) so work lands only on
agents that fit it — and a **capacity**,
how many workflows one agent runs at
once. Both are set on the agent and
visible in its record; the lab's
single idle agent shows the defaults.

Placement advice, plainly: server and
agent may share a machine happily at
household scale; the moment the code
stops being only yours, the agent —
the part that executes — is the part
to move onto hardware you can afford
to distrust.
