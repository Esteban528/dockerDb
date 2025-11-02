# db-make

Make targets to run database containers.

## Commands

```

make mysql
make mongo
make mongorp
make postgres
make redis
make down

```

## Notes

- Each target runs `docker compose up` in its folder.
- `down` stops all containers.

# Deps
- `docker/podman`
- `gnumake`
