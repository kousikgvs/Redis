# Redis + Python demo — setup

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- (Optional) Python 3.12 + `pip` if you want to run `code.py` outside Docker.

## Option A — quick test: run only Redis

Use this if you just want a Redis server to play with (e.g., from `redis-cli` on Windows or from `code.py` running locally):

```powershell
docker run -d --name redis -p 6379:6379 redis
```

- `-d` runs it in the background.
- `--name redis` gives the container a friendly name.
- `-p 6379:6379` opens host port 6379 → container port 6379.

Stop and remove it before moving to Option B (the port would clash):

```powershell
docker stop redis ; docker rm redis
```

## Option B — full stack: Redis + app together (recommended)

This builds the Python app image from the `Dockerfile` and starts both containers as defined in `docker-compose.yml`:

```powershell
docker compose up --build
```

- `--build` forces a rebuild so code changes in `code.py` are picked up.
- Add `-d` to run in the background: `docker compose up --build -d`.
- Compose waits for Redis's healthcheck to pass before starting the app.

### How config is layered

`docker-compose.yml` runtime values (e.g., `environment:`) **override** the defaults baked into the `Dockerfile` (`ENV ...`). The Dockerfile values are just fallbacks for when the image is run without Compose.

## Day-to-day commands

| Goal | Command |
|---|---|
| Start everything (background) | `docker compose up -d --build` |
| See app output | `docker compose logs app` |
| Tail logs live | `docker compose logs -f app` |
| List containers + status | `docker compose ps -a` |
| Rebuild after editing `code.py` | `docker compose up -d --build` |
| Run app once and remove | `docker compose run --rm app` |
| Stop everything (keep data) | `docker compose down` |
| Stop + wipe Redis data | `docker compose down -v` |
| Shell into the app container | `docker compose exec app sh` |
| Open redis-cli | `docker compose exec redis redis-cli` |

## Notes

- `code.py` runs once and exits — that's normal. Check `docker compose logs app` to see its output.
- Redis data is stored in the `redis-data` named volume and survives `docker compose down`. Use `down -v` to wipe it.
- The `app` container has no published ports — it talks to Redis over Docker's internal network using the hostname `redis`.