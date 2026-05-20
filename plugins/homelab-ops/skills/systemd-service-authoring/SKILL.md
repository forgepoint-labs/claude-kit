---
name: systemd-service-authoring
description: Write a production-grade systemd unit file with Restart policy, hardening (NoNewPrivileges, ProtectSystem), user sandboxing, and journal logging. Use when the user wants to run a long-running process as a service on Linux.
---

# Author a production systemd service

Use when the user has a binary / script they want to run as a long-running Linux service.

## Decision questions (ask first)

1. **Binary path** (absolute)
2. **Run as what user?** Prefer a dedicated non-root user.
3. **Needs network?** (most do)
4. **Needs write access to what paths?** (enumerate - the hardening options below deny by default)
5. **Should it restart on failure?** (almost always yes)

## Template - `/etc/systemd/system/<name>.service`

```ini
[Unit]
Description=<What this service does>
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<svc-user>
Group=<svc-user>
WorkingDirectory=/var/lib/<name>
ExecStart=/usr/local/bin/<binary> --flag value
Restart=on-failure
RestartSec=5s
# Logging to journal (systemctl status / journalctl -u <name>)
StandardOutput=journal
StandardError=journal

# Hardening - remove any line that blocks a real requirement
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictSUIDSGID=true
LockPersonality=true
# List specific writable paths (delete if none):
ReadWritePaths=/var/lib/<name> /var/log/<name>

[Install]
WantedBy=multi-user.target
```

## Install + enable

```sh
sudo useradd --system --home /var/lib/<name> --shell /usr/sbin/nologin <svc-user>
sudo mkdir -p /var/lib/<name> /var/log/<name>
sudo chown <svc-user>:<svc-user> /var/lib/<name> /var/log/<name>

sudo systemctl daemon-reload
sudo systemctl enable --now <name>.service
sudo systemctl status <name>
journalctl -u <name> -f
```

## Golden rules

- ✅ Use `Type=simple` unless the binary specifically needs `notify` or `forking`.
- ✅ Always prefer a dedicated system user over `root`.
- ✅ Start with `ProtectSystem=strict` and loosen only with explicit `ReadWritePaths=`.
- ✅ Use `Restart=on-failure` over `always` - `always` masks crash loops.
- ❌ Don't use `User=root` unless you're genuinely doing privileged work; `CAP_*` is almost always a better fit.
- ❌ Don't log to a custom file - let `journalctl` handle it; you get rotation, structured logs, and remote forwarding for free.
