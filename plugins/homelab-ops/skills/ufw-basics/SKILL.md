---
name: ufw-basics
description: Configure ufw (Uncomplicated Firewall) on Ubuntu / Debian with a default-deny baseline, essential allows, logging, and safe enable sequence that won't lock you out over SSH. Use when setting up the first firewall rules on a new server or auditing an existing ruleset.
---

# ufw firewall baseline

`ufw` is the sensible default firewall for Ubuntu / Debian. It's a thin wrapper over iptables that makes the common cases readable.

## Lock-out prevention

Before enabling ufw, allow your SSH port. Forgetting this will kick you out the moment you enable it.

```sh
sudo ufw allow 22/tcp     # or your chosen port
sudo ufw status verbose   # dry-run view; verify BEFORE enabling
sudo ufw enable           # starts + enables on boot
```

## Default policy

Default deny inbound, allow outbound:

```sh
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

This is ufw's out-of-box default on a fresh install, but reassert it explicitly.

## Essential allows

```sh
# SSH (always first — already done above)
sudo ufw allow 22/tcp

# Web, if you run a reverse proxy
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# DNS (only if host is a resolver)
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
```

## Restricting by source

Only allow SSH from your home / office / VPN:

```sh
sudo ufw delete allow 22/tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
```

Or for a known IP list:

```sh
sudo ufw allow from 203.0.113.45 to any port 22
sudo ufw allow from 198.51.100.10 to any port 22
```

## Rate limiting (SSH brute-force protection)

ufw's built-in rate limiter blocks an IP that hits a port 6+ times in 30s:

```sh
sudo ufw limit 22/tcp
```

Use instead of plain `allow` for SSH if the port is reachable from the internet.

## Logging

```sh
sudo ufw logging on       # enable
sudo ufw logging medium   # level: off/low/medium/high/full
```

Logs land in `/var/log/ufw.log`. `medium` is the right balance for home-server scale.

## Common mistakes

- Enabling before allowing SSH → locked out. Use `ufw status` BEFORE `ufw enable` to sanity-check.
- Forgetting UDP for services that need it (DNS, WireGuard, mosh). UFW `allow 53` covers both TCP and UDP; `allow 53/tcp` only covers TCP.
- Rules out of order — ufw evaluates in the order they're added. List with `sudo ufw status numbered` and reorder with `sudo ufw delete <n>` + `sudo ufw insert <n> ...`.

## Inspect + tear down

```sh
sudo ufw status numbered    # current rules with line numbers
sudo ufw delete 3           # remove rule #3
sudo ufw reset              # nuke all rules (you'll re-add)
sudo ufw disable            # turn off, rules persist
```

## Docker caveat

Docker bypasses ufw by default — it inserts its own iptables rules. If you run Docker on the same host, either:
1. Use `DOCKER_OPTS="--iptables=false"` (breaks Docker networking) — not recommended
2. Use `ufw-docker` (https://github.com/chaifeng/ufw-docker) to integrate the two
3. Bind container ports to `127.0.0.1` and let a reverse proxy handle inbound

Option 3 is the simplest for a homelab.

## Golden rules

- ✅ Allow SSH before enabling.
- ✅ Default-deny inbound.
- ✅ `ufw limit` on SSH when reachable from the internet.
- ✅ `ufw status verbose` before and after every change.
- ✅ Log at medium level — useful without drowning the disk.
- ❌ Don't run ufw and firewalld / iptables-persistent simultaneously.
- ❌ Don't forget Docker circumvents ufw unless configured otherwise.

## Related skills

- `ssh-hardening` — pair with SSH key-only + fail2ban for defense in depth
- `systemd-service-authoring` — most services you're firewalling are systemd units
- `docker-compose-baseline` — loopback bind is the ufw-compatible pattern
