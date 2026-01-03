# GL-REFIT (Golf League REFIT)

GL-REFIT modernizes the Timken Metallus Monday Night Golf League scoring system
using a structured, Power Query–driven architecture.

The project is organized around explicit data layers:

- **Raw** – Ingest match report files exactly as submitted
- **Staging** – Canonical, schema-locked normalization
- **Holes** – Hole-level explosion for analytics
- **Summary_New** – Season-level reporting tables
- **Engines** – (future) Handicap, standings, and rule logic

⚠️ **Important**
Engine development does **not** begin until all upstream layers pass the
v1.0 Audit Checklist.

See:
- [`docs/audit.md`](docs/audit.md) — authoritative readiness checklist
