# Running the Server

Outcome: a Woodpecker server booted on
your machine, its web page and health
endpoint answering, its API behaving
exactly as a locked door should — and
one memorable refusal along the way.
Transcripts `t04` and `t06` are the
evidence. The lab ran the server on
the loopback test port 18082; a real
installation uses its own address and,
behind a reverse proxy, its public
name.

## Configuration is environment variables

The server takes no config file by
default; every setting is an
environment variable prefixed
`WOODPECKER_`. The lab's set is kept in
this guide's repository as
`woodpecker-lab/server-env.example.sh`,
with invented values. The load-bearing
ones:

```bash
export WOODPECKER_HOST=http://127.0.0.1:18082
export WOODPECKER_SERVER_ADDR=127.0.0.1:18082
export WOODPECKER_GRPC_ADDR=unix:///path/to/server-data/agent.sock
export WOODPECKER_DATABASE_DRIVER=sqlite3
export WOODPECKER_DATABASE_DATASOURCE=/path/to/server-data/woodpecker.sqlite
export WOODPECKER_AGENT_SECRET=an-invented-secret-of-your-own
```

`WOODPECKER_HOST` is the address the
outside world uses (links, OAuth
callbacks); `WOODPECKER_SERVER_ADDR`
is where the HTTP listener binds;
`WOODPECKER_GRPC_ADDR` is the agent
channel — a TCP port in most
installations, a unix socket in this
lab, which let one assigned test port
be the only TCP listener. The database
defaults to SQLite in a single file,
created where the datasource names it.

## The refusal: no forge, no server

Start the server with the settings
above but *without* any forge, and it
stops:

```text
{"level":"info","message":"Initializing Schema"}
{"level":"error","error":"can't setup globals: could not setup service manager: forge not configured","message":"error running server"}
```

Two things deserve naming. First, the
rule itself: a Woodpecker server
without a forge is considered
unconfigured, full stop — there is no
forge-less mode to fall back to,
because the forge is where users and
repositories come from. Second, a
trap for scripts: **the process exits
with code 0 anyway.** The lab measured
it. A startup script that trusts the
exit code will report success over a
dead server; check for the *listener*
(or the health endpoint below), never
the code. Chapter 14 keeps this one in
bold.

## Adding a forge — with placeholder values, honestly

The lab then configured a GitHub forge
with **invented** OAuth values:

```bash
export WOODPECKER_GITHUB=true
export WOODPECKER_GITHUB_CLIENT=lab-invented-client-id
export WOODPECKER_GITHUB_SECRET=lab-invented-client-secret
```

That is enough for the server to boot
— OAuth is only exercised when a human
actually logs in, which needs a real
application registered with the real
forge and a browser to approve it
(chapter 10). With the placeholder
forge the boot log reads:

```text
starting Woodpecker server with version '3.20.1'
starting grpc server ...
starting http server ...
```

and one warning worth understanding:
if `WOODPECKER_GRPC_SECRET` is unset,
the server generates a temporary one
per boot. Persist it in a real
installation, or agents and server will
disagree after every restart.

## Proving it is alive

Four requests, all in transcript
`t04` and wrapped by the lab's
`woodpecker-lab/check-server.sh`
(transcript `t06`):

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:18082/
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:18082/healthz
curl -s http://127.0.0.1:18082/api/version
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:18082/api/user
```

```text
200
204
{"source":"https://github.com/woodpecker-ci/woodpecker","version":"3.20.1"}
401
```

Read them as a set: `/` returns the web
application (its HTML title is simply
*Woodpecker*; `/login` serves the same
app, which draws the login screen
offering your forge). `/healthz`
returns **204**, no body — the
endpoint load balancers and supervisors
poll. `/api/version` answers without
authentication and names the version.
And `/api/user` *without a token*
returns **401 User not authorized**,
as does `/api/repos`: the API is there
and locked, which is the correct shape
of alive. One more public answer,
`/api/forges`, listed the configured
forge — `github`, pointing at
`https://github.com` — the placeholder
registration made visible.

The CLI agrees from its side: pointed
at this server without a configured
context, `woodpecker-cli info` fails
with *cli is not configured* — it wants
the login token that only a real forge
sign-in can mint. The lab leaves the
server exactly there: alive, locked,
and honest about what it still needs.
