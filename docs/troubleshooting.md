# Local troubleshooting (Windows)

- **Backend asks for a password:** enter the password configured for the local `ecommerce_app` database account. The prompt does not echo it. Do not add it to source files or commit `.env` files.
- **Database connection refused:** verify the MySQL service is running and listening on `localhost:3306`; confirm the database/account were deliberately provisioned. This project does not create them automatically.
- **Flyway reports an existing or incompatible schema:** stop. Inspect `flyway_schema_history`, table definitions, and data before changing anything. Do not drop tables or baseline the database to silence the error.
- **Hibernate schema validation fails:** compare the actual database columns and constraints with V1 and the JPA entities. Resolve through a reviewed migration; do not turn on automatic Hibernate DDL.
- **Browser reports a CORS or 403 error on POST/PUT:** start the frontend at `http://localhost:5173`, keep that exact origin in `CORS_ALLOWED_ORIGINS`, and confirm the `GET /api/csrf` request succeeds and the browser sends `X-XSRF-TOKEN`.
- **Login stops working after a backend restart:** when the startup script generates an ephemeral JWT secret, old JWTs stop validating. Set a stable local `JWT_SECRET` if preserving sessions across restarts is desired.
- **Recovery code is not delivered:** in local development, inspect the backend console while the `local` Spring profile is active. Outside local, delivery is intentionally disabled until a provider is configured.
- **Port already in use:** inspect listeners on 8080 (backend) and 5173 (frontend), then stop only the process you recognize.
- **Build commands:** frontend `npm.cmd run build`; backend `mvn.cmd -DskipTests package`. Automated test execution is deferred by the user instruction.
