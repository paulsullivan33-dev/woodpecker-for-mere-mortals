# Installing Woodpecker

Outcome: three official binaries on
your machine, their checksums verified
against the release's own checksum
file, and three version lines that
prove they run. Everything in this
chapter was run in the guide's lab;
transcript `t00` is the evidence.

## What you are downloading

Woodpecker ships as three separate
single-file programs — you install the
pieces you need:

- `woodpecker-cli` — the command-line
  tool. Start here; chapters 4 to 7 need
  nothing else.
- `woodpecker-server` — the server.
- `woodpecker-agent` — the agent.

The lab used release **3.20.1**,
published 2026-10-29, from the project's
GitHub releases page
(`github.com/woodpecker-ci/woodpecker/releases`).
Each program comes as a tar archive per
platform, beside a `checksums.txt`
covering all of them. There are also
`.deb` and `.rpm` packages and container
images; this guide uses the plain
archives, because a single binary you
can inspect is the easiest install to
verify — and the only kind this
containerless lab could run.

## Download and verify

```bash
mkdir -p ~/woodpecker && cd ~/woodpecker
base=https://github.com/woodpecker-ci/woodpecker/releases/download/v3.20.1
curl -sLO $base/woodpecker-cli_linux_amd64.tar.gz
curl -sLO $base/woodpecker-server_linux_amd64.tar.gz
curl -sLO $base/woodpecker-agent_linux_amd64.tar.gz
curl -sLO $base/checksums.txt
grep -E "cli_linux_amd64|server_linux_amd64|agent_linux_amd64" \
  checksums.txt > sums.txt
sha256sum -c sums.txt
```

The check the reader can run is the
last line's output. The lab's was:

```text
woodpecker-agent_linux_amd64.tar.gz: OK
woodpecker-cli_linux_amd64.tar.gz: OK
woodpecker-server_linux_amd64.tar.gz: OK
```

An `OK` means the archive on your disk
hashes to exactly the value the project
published for it. Anything else means
do not proceed — delete and download
again. Each archive contains exactly
one file, the binary itself:

```bash
tar xzf woodpecker-cli_linux_amd64.tar.gz
tar xzf woodpecker-server_linux_amd64.tar.gz
tar xzf woodpecker-agent_linux_amd64.tar.gz
```

## The version check

```bash
./woodpecker-cli --version
./woodpecker-server --version
./woodpecker-agent --version
```

```text
woodpecker-cli version 3.20.1
woodpecker-server version 3.20.1
woodpecker-agent version 3.20.1
```

Three matching versions matter more
than three present files: the CLI, the
server and the agent speak protocols
that expect their peers to be close in
age, and this guide's transcripts mix
all three. Keep the trio from one
release, as the lab did.

Put the binaries somewhere on your
`PATH` if you will use them daily (a
`~/bin` folder is the usual choice), or
call them by path while you learn. One
habit worth setting now:

```bash
export WOODPECKER_DISABLE_UPDATE_CHECK=true
```

The CLI can check for newer releases;
naming the variable keeps lab-style
sessions — and transcripts — free of
update notices, and changes nothing
else.

## What you have not installed

No service has been started, nothing is
listening on any port, and no database
exists yet. The server arrives in
chapter 8, on purpose: Woodpecker's
most useful half — checking and running
pipelines — works with the CLI alone,
and that is where the next chapter
goes.
