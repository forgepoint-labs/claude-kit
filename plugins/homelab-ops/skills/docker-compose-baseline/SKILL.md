---
name: docker-compose-baseline
description: Author a docker-compose.yml for a self-hosted service with healthchecks, resource limits, restart policies, named volumes, user bridge networks, and explicit logging. Use when adding a new service to a homelab compose file or hardening an existing one.
---

# docker-compose baseline for self-hosted services

A production-shaped `docker-compose.yml` service block that's safe to run unattended on a Raspberry Pi or Ubuntu server.

## Template

```yaml
services:
  <name>:
    image: <registry>/<image>:<pinned-tag>   # never :latest
    container_name: <name>
    restart: unless-stopped
    user: "1000:1000"                         # never root
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    env_file:
      - .env                                   # gitignored
    ports:
      - "127.0.0.1:8080:8080"                 # bind loopback, publish via reverse proxy
    volumes:
      - <name>-data:/data                      # named volume, not a bind
      - ./config/<name>.yaml:/etc/<name>.yaml:ro
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  <name>-data:

networks:
  homelab:
    driver: bridge
```

## Decisions baked in

- **`restart: unless-stopped`** - survives host reboot, but manual stops stick.
- **`user: "1000:1000"`** - never root. If the image refuses to run as non-root, it's either misconfigured or not safe for a home server.
- **`127.0.0.1:8080:8080`** - bind to loopback; expose to the network via a reverse proxy (Caddy / Traefik / Nginx) that handles TLS + auth.
- **Named volumes over bind mounts** - survive recreate, back up with `docker run --rm -v <vol>:/data busybox tar ...`.
- **`healthcheck`** - compose and Traefik use this to route only to healthy containers.
- **`deploy.resources.limits`** - Pi / single-host compose still honors these. Prevents a runaway container from OOMing the host.
- **`logging: json-file` with rotation** - avoids filling `/var/lib/docker` with years of logs.

## Reverse proxy

The loopback-only port pattern assumes a reverse proxy on the same host:

```yaml
caddy:
  image: caddy:2-alpine
  ports: ["80:80", "443:443"]
  volumes:
    - caddy-data:/data
    - ./Caddyfile:/etc/caddy/Caddyfile:ro
  networks: [homelab]
```

All services on the `homelab` bridge network are reachable by Caddy via DNS using their `container_name`.

## Secrets

- `.env` for non-sensitive config
- For real secrets (API keys), use Docker Secrets or a sidecar that sources from a password manager - never commit a `.env` with secrets

## Golden rules

- ✅ Pin image tags. `:latest` breaks at 3am.
- ✅ Run as non-root (`user:`).
- ✅ Named volumes, not scattered bind mounts.
- ✅ Healthcheck on every service.
- ✅ Resource limits on every service.
- ✅ Loopback bind + reverse proxy - don't expose services directly to the LAN.
- ❌ Don't use `privileged: true` unless you really, really must. If you must, document why.

## Related skills

- `systemd-service-authoring` - run docker-compose as a systemd unit (`docker compose up -d` in an `ExecStart`)
- `ssh-hardening` - before exposing anything, lock down SSH
- `ufw-basics` - firewall layer in front of Docker
