# Lab Guide — Exploring a Live AWS Web Application

**Level:** Intermediate  
**Duration:** 60–90 minutes  
**Focus:** PHP Web App + Linux + MySQL

---

## File Index

| File | Purpose |
|------|---------|
| `lab_master.json` | Master config — lab metadata, credentials mapping, exercise list, validation checks |
| `ex01_access_webapp.md` | Exercise 1 — Open and verify the web app in browser |
| `ex02_insert_records.md` | Exercise 2 — Insert and delete records via the PHP app |
| `ex03_ssh_connect.md` | Exercise 3 — SSH into EC2 and verify the instance |
| `ex04_explore_webserver.md` | Exercise 4 — Explore Apache, PHP, app files, UserData log |
| `ex05_mysql_queries.md` | Exercise 5 — Connect to RDS and run SQL queries |
| `ex06_services_logs.md` | Exercise 6 — Check running services, ports, logs, memory |
| `ex07_challenge.md` | Exercise 7 — Challenge: insert via CLI, verify in web app |

---

## Lab Flow

```
Ex01 (Browser)
    ↓
Ex02 (Insert via App)
    ↓
Ex03 (SSH into EC2)
    ↓
Ex04 (Explore Files & Apache)
    ↓
Ex05 (MySQL CLI Queries)
    ↓
Ex06 (Services & Logs)
    ↓
Ex07 (Challenge: CLI Insert → verify in App)
```

---

## Credentials Needed by Learner

All values come from the CloudFormation Outputs tab / CloudLabs panel:

- `WebAppURL` — browser URL for the PHP app
- `EC2ElasticIP` — public IP of EC2
- `SSHCommand` — ready-to-run SSH command
- `LinuxUsername` / `LinuxPassword` — SSH and RDP login
- `RDSEndpoint` — MySQL hostname
- `DBPassword` — MySQL password for `dbadmin`

---

## Validation Checks (for CloudLabs)

Two automated checks are defined in `lab_master.json`:

1. **chk01** — At least one record in `users` table (after Ex02)
2. **chk02** — A record with `name = 'LabTest'` exists (after Ex07)
