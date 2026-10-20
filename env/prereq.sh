#!/usr/bin/env bash
# usage: env/prereq.sh <caller> [broker]
# Checks what the sandbox needs before anything starts: bubblewrap, an unprivileged user namespace for bubblewrap,
# and, with broker (the harness arm E), ssh-keygen for the broker's signatures. Prints one line naming the caller, what is missing and the fix, and exits 64; prints nothing when all is there.
caller=$1
if ! command -v bwrap >/dev/null; then
  echo "$caller: needs bubblewrap; install it, for example sudo apt-get install bubblewrap" >&2; exit 64
fi
if [ "${2:-}" = broker ] && ! command -v ssh-keygen >/dev/null; then
  echo "$caller: needs ssh-keygen, which signs the broker's records; install OpenSSH's client, for example sudo apt-get install openssh-client" >&2; exit 64
fi
if ! bwrap --unshare-user --ro-bind / / true 2>/dev/null; then
  echo "$caller: bubblewrap cannot create a user namespace; on Ubuntu 24.04 run sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0" >&2
  exit 64
fi
