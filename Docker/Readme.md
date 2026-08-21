# Roboshop — Dockerized Microservices

A containerized deployment of the **Roboshop** e-commerce application: an 11-service microservices stack running on a single Docker host via Docker Compose. Each application service is built from its own Dockerfile; databases and the message broker run from official images, seeded on first startup.

This project migrates Roboshop from a VM-per-service (Terraform + Ansible) deployment to containers running on one EC2 instance.

## Architecture

The stack is a three-tier application: an Nginx frontend, a set of backend microservices, and a data layer.

| Service   | Tech          | Port  | Depends on                  |
|-----------|---------------|-------|-----------------------------|
| frontend  | Nginx         | 80    | catalogue, user, cart, shipping, payment |
| catalogue | NodeJS        | 8080  | mongodb                     |
| user      | NodeJS        | 8080  | mongodb, redis              |
| cart      | NodeJS        | 8080  | redis, catalogue            |
| shipping  | Java / Maven  | 8080  | mysql, cart                 |
| payment   | Python / uWSGI| 8080  | rabbitmq, user, cart        |
| mongodb   | MongoDB 7     | 27017 | —                           |
| redis     | Redis 7       | 6379  | —                           |
| mysql     | MySQL 8.0     | 3306  | —                           |
| rabbitmq  | RabbitMQ 3    | 5672  | —                           |

Only the frontend publishes a port to the host (`80:80`); everything else communicates internally over a shared Docker bridge network, resolving each other by service name.

## Prerequisites

- A Linux host with Docker and Docker Compose installed
- Port 80 open to inbound traffic (security group / firewall) if accessing remotely
- Roughly 20–30 GB of disk for images and volumes

## Running it

From the `Docker/` directory:

```bash
docker compose up -d --build
```

The first build takes a few minutes — the shipping service runs a full Maven build, and MySQL seeds its schema and master data on first startup.

Check status:

```bash
docker compose ps
```

Then open the site at `http://<host-ip>` and exercise the flows: browse the catalogue, register and log in, add items to the cart, and check out.

To stop everything and remove volumes (forces a clean re-seed on next start):

```bash
docker compose down -v
```

## How the pieces fit together

**Networking.** All services join a single user-defined bridge network named `roboshop`. Containers reach each other by service name (`mongodb`, `redis`, `catalogue`, etc.) rather than IP addresses, so no hardcoded IPs are needed. Connection targets are passed to the apps via `environment:` variables or baked into each Dockerfile's `ENV`.

**Data seeding.** MongoDB and MySQL both auto-run initialization scripts placed in their entrypoint init directory on first startup with an empty data volume:

- MongoDB: `master-data.js` is copied into `/docker-entrypoint-initdb.d/`, seeding the `catalogue` database with products.
- MySQL: `01-schema.sql`, `02-app-user.sql`, and `03-master-data.sql` are copied into `/docker-entrypoint-initdb.d/`. The numeric prefixes force alphabetical execution order, so the schema is created before the app user and master data that depend on it.

Init scripts only run when the data directory is empty. If you change a seed file, you must clear the volume (`docker compose down -v`) for it to re-run.

**Persistence.** MongoDB's data directory (`/data/db`) is mapped to a named volume so its data survives container restarts.

## Notes and known issues

- **MySQL version is pinned to `8.0`.** The floating `mysql:8` tag now resolves to 8.4, whose default `caching_sha2_password` auth plugin breaks the shipping service's older JDBC driver. Pinning to `8.0` keeps the driver and server compatible. This is a reminder that loose image tags drift over time — pin versions for reproducible builds.

- **Startup ordering race.** `depends_on` controls start *order*, not *readiness* — it does not wait for a dependency to finish initializing. On a fresh `up`, the shipping service can start before MySQL has finished seeding (MySQL's temporary init server does not accept external connections), and fail with "Connection refused." Node services self-heal via built-in retry loops; shipping may need a one-time `docker compose restart shipping` after MySQL is ready.

  The production-correct fix is a MySQL healthcheck combined with `depends_on: condition: service_healthy` on shipping.

## Repository layout

```
Docker/
├── docker-compose.yaml
├── catalogue/      # NodeJS + Dockerfile
├── user/           # NodeJS + Dockerfile
├── cart/           # NodeJS + Dockerfile
├── shipping/       # Java/Maven (pom.xml, src/) + Dockerfile
├── payment/        # Python/uWSGI (app/) + Dockerfile
├── frontend/       # Nginx (web/, nginx.conf) + Dockerfile
├── mongodb/        # master-data.js + Dockerfile
└── mysql/          # 01-schema.sql, 02-app-user.sql, 03-master-data.sql + Dockerfile
```