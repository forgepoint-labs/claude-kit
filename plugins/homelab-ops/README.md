# homelab-ops

Practical patterns for running a Raspberry Pi / Ubuntu Server homelab. Every skill assumes:

- Target: Raspberry Pi 4/5 running Ubuntu Server 24.04+ (should also work on any Debian-family distro)
- SSH access to the host
- `sudo` available

## Skills

- `systemd-service-authoring` — write a production-grade `systemd` unit (Restart policies, hardening options, user sandboxing)
- `docker-compose-baseline` — compose file conventions for self-hosted services (healthchecks, resource limits, restart policies, networks)
- `podman-quadlet` — declarative container management via Quadlet files (Podman + systemd)
- `ssh-hardening` — disable password auth, key-only, fail2ban basics, port change tradeoffs
- `ufw-basics` — firewall rules that don't lock you out
- `unattended-upgrades` — safe auto-patching for headless servers
