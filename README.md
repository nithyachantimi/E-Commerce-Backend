# E-Commerce-Backend

## E-Commerce Authentication Backend

Java/Spring Boot authentication API for the E-Commerce project. It uses MySQL, Flyway migrations, HttpOnly JWT cookies, server-side session revocation, CSRF protection, international phone validation, and local-only console OTP delivery.

## Prerequisites

- Java 21 or newer
- MySQL running locally, with an existing `ecommerce_auth` database and least-privilege `ecommerce_app` account
- Review the database first. The startup migration creates tables; do not run it against a schema with unknown or existing data.

The repository does not contain database credentials. The startup script securely prompts for `SPRING_DATASOURCE_PASSWORD` if it is not already set. No database or user is created automatically.

## Start on Windows

For a double-click startup, open `run-ecommerce.bat` in this backend folder. It tries to start the existing `MySQL84` service if needed, then starts the backend and frontend in separate PowerShell windows, waits for both services, and opens the login page at `http://127.0.0.1:5174/login`. If Windows denies permission to start MySQL, start it from Windows Services and run the launcher again. Leave the backend and frontend windows open while using the app; close them to stop those services. The launcher never stops an unrelated process if an E-Commerce port is occupied.

The first backend launch asks for the MySQL `ecommerce_app` password without displaying it. You can choose to remember it encrypted for your Windows account (it is stored outside the project under `%LOCALAPPDATA%\ECommerceAuth`). Remove `ecommerce-app-password.dpapi` from that folder if the database password changes or you no longer want it remembered. The launcher does not create or alter MySQL databases or accounts.

Open PowerShell and run:

```powershell
Set-Location "C:\Users\u\Downloads\E Commerce\E-Commerce-Backend"
$env:SPRING_DATASOURCE_USERNAME = 'ecommerce_app'
.\start-backend.ps1
```

You may set `SPRING_DATASOURCE_PASSWORD` in the current PowerShell session before starting. Otherwise the script prompts without echoing the password. If `JWT_SECRET` is unset, the script generates one for this run; set a stable base64-encoded 32-byte value in your local environment if JWT sessions should survive backend restarts. For local OTP recovery, the script selects the `local` Spring profile; the generated code is written only to the backend console. Do not use that profile in production.

The app listens on `http://localhost:8080`. Swagger UI is at `http://localhost:8080/swagger-ui.html`.

## API

The required auth API paths are `POST /api/reg`, `POST /api/login`, `POST /api/logout`, `POST /api/forgot-password`, `POST /api/verify-otp`, `POST /api/reset-password`, `PUT /api/change-password`, `GET /api/me`, and `GET /api/home`. `GET /api/csrf` initializes the browser CSRF cookie; it is an additional setup endpoint. The frontend sends that cookie back in the `X-XSRF-TOKEN` header on unsafe requests.

## Current limits and verification

- Recovery delivery outside the `local` profile is disabled until an email/SMS provider is configured.
- Rate limits are in-memory and apply to one backend process.
- Build: `mvn -B -DskipTests package` succeeded on 2026-10-20. Automated tests were not run, per the user instruction.
- Database startup/migration and browser API flows have not been verified in this environment. Do not assume the schema is empty or that V1 has been applied.
- See [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) for the schema, architecture, routes, setup details, and verified status.
- [API contract](docs/api.md), [database schema/ER diagram](docs/database-schema.md), [troubleshooting](docs/troubleshooting.md), [requirements traceability](docs/requirements-traceability.md), and [Postman collection](postman/E-Commerce-Auth.postman_collection.json) are included.
