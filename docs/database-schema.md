# Database schema

Flyway manages the schema in `src/main/resources/db/migration/V1__create_auth_schema.sql`. Hibernate validates the schema at startup. The database itself was not inspected during this implementation session, so do not run the migration against an existing database until its tables and data are reviewed.

```mermaid
erDiagram
    users ||--o{ user_sessions : owns
    users ||--o{ password_recovery_challenges : requests

    users {
        BIGINT id PK
        VARCHAR full_name
        VARCHAR email UK
        VARCHAR mobile_e164 UK
        VARCHAR phone_region
        VARCHAR password_hash
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP password_changed_at
    }
    user_sessions {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR jti UK
        TIMESTAMP created_at
        TIMESTAMP expires_at
        TIMESTAMP revoked_at
    }
    password_recovery_challenges {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR otp_hash
        TIMESTAMP created_at
        TIMESTAMP expires_at
        INT attempt_count
        TIMESTAMP consumed_at
        VARCHAR delivery_channel
        VARCHAR recovery_token_hash
        TIMESTAMP recovery_expires_at
    }
```

## Table purposes

- `users` stores normalized unique email, canonical E.164 phone number, region, and BCrypt password hash.
- `user_sessions` stores each JWT session identifier (`jti`) and its expiry/revocation timestamps. Raw JWTs are not stored.
- `password_recovery_challenges` stores OTP and recovery-authorization hashes, expiry, attempt count, and one-time-use state. Raw OTPs are delivered only by the configured adapter and are never persisted.

Each child table references `users.id` with `ON DELETE CASCADE`. Unique indexes enforce email, phone, and JTI uniqueness. The migration creates tables only; provisioning database/users is a separate administrative action.
