# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGAMA (A Generic App to Manage Anything) — a full-stack todo-list app with a Python FastAPI backend, Next.js frontend, deployed across AWS EKS and GCP GKE with TiDB as the database.

## Common Commands

### API (Python/FastAPI) — run from `api/`
- **Dev server**: `uvicorn app.main:app --reload` (port 8000)
- **Lint**: `ruff check .`
- **Format**: `ruff format .`
- **Dev dependencies**: `pip install -r requirements-dev.txt` (ruff 0.15.5)

### Frontend (Next.js) — run from `frontend/`
- **Dev server**: `npm run dev` (port 3000)
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Format check**: `npm run format:check`
- **Format fix**: `npm run format`
- **Install deps**: `npm ci`

### Infrastructure
- **Bootstrap all**: `cd scripts && ./bootstrap.sh`
- **Teardown all**: `cd scripts && ./destroy.sh`
- **Terraform**: run `terraform init && terraform apply` in `terraform/infra/` then `terraform/platform/`

## Architecture

```
┌─────────────────────┐         ┌──────────────────────┐
│  GKE (GCP)          │   VPN   │  EKS (AWS)           │
│  - Frontend (Next.js) ◄─────► │  - API (FastAPI)     │
│  - Grafana          │         │  - TiDB cluster      │
│  - Rancher          │         │  - Prometheus        │
└─────────────────────┘         └──────────────────────┘
```

- **Frontend → API**: Frontend uses server actions (`src/app/actions.ts`) for SSR to call the API via `API_URL` env var
- **API → TiDB**: Async SQLAlchemy with `aiomysql` driver connecting to TiDB (MySQL-compatible)
- **Monitoring**: FastAPI exposes `/metrics` (Prometheus format) via `prometheus-fastapi-instrumentator`; SLOs defined in `slo.md`

### API structure (`api/app/`)
- `main.py` — entry point, CORS setup, Prometheus instrumentation, startup seeding
- `config.py` — Pydantic Settings (`DATABASE_URL`, `ALLOWED_ORIGINS`, `APP_NAME`, `MAX_ITEMS`)
- `database.py` — async SQLAlchemy engine/session setup
- `routers/items.py` — CRUD endpoints under `/items` prefix + `/health`
- `models/item.py` — SQLAlchemy model (items table: id, value, state)
- `schemas/item.py` — Pydantic schemas (ItemCreate, ItemResponse, ItemState enum)

### Frontend structure (`frontend/src/`)
- `app/page.tsx` — async Server Component, fetches items at render time
- `app/actions.ts` — "use server" Server Actions for API communication (add/toggle/delete)
- `app/items.tsx` — Client Component for interactive item list UI
- `components/ui/` — shadcn/ui components (Radix UI primitives + Tailwind)
- Uses Tailwind CSS 4, TypeScript strict mode, path alias `@/*` → `src/*`

## CI/CD

- **api.yml**: On `api/**` changes → ruff format/lint checks → Docker build & push to `rusxl/agama-api:{sha}`
- **frontend.yml**: On `frontend/**` changes → prettier + eslint checks → Docker build & push to `rusxl/agama-frontend:{sha}`
- **deploy.yml**: After successful builds → updates K8s manifest image SHAs → auto-commits

## Key Environment Variables

| Variable | Service | Default |
|---|---|---|
| `DATABASE_URL` | API | `mysql+aiomysql://root:@tidb.db.svc.cluster.local:4000/agama` |
| `ALLOWED_ORIGINS` | API | `["http://localhost:3000"]` |
| `API_URL` | Frontend | `http://localhost:8000` |
