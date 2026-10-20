# Requirements traceability

| Requirement | Implementation | Status / verification |
|---|---|---|
| Seven frontend pages | `E-Commerce-Frontend/src/pages` and React Router | Present; production build succeeds. Manual UI flow remains unverified. |
| Registration and login | `/register`, `/login`, `AuthController`, `AuthService` | Implemented; DB and browser integration not verified. |
| Email and international phone | `PhoneNumberInput`, `libphonenumber-js/max`, `PhoneValidationService` | Implemented; browser build succeeds; runtime examples not manually checked. |
| Protected home/profile | `ProtectedRoute`, JWT filter, `/api/me`, `/api/home` | Implemented; runtime authorization not verified. |
| Logout and revocation | `AuthService.logout`, `user_sessions` | Implemented; end-to-end behavior not verified. |
| Recovery and OTP | `PasswordRecoveryService`, `/forgot-password`, `/verify-otp`, `/reset-password` | Implemented; local console adapter exists; delivery is disabled outside local profile; manual flow not verified. |
| Change password | `/change-password`, `PUT /api/change-password` | Implemented; manual flow not verified. |
| Cookies, CSRF, CORS | `SecurityConfig`, `/api/csrf`, Axios client | Implemented; Maven package succeeded before final config-only adjustments; browser/CORS flow not verified. |
| MySQL/Flyway schema | V1 migration and JPA entities | Migration defined; database state and migration application not verified. |
| OpenAPI | Springdoc dependency | Configuration present; Swagger endpoint not runtime checked. |
| Automated tests | Deferred by user add-on | No tests or testing framework added/run. |
| Postman collection | `postman/E-Commerce-Auth.postman_collection.json` | Included; requests require local CSRF init and local DB/app setup. |
| ER/schema guide | `docs/database-schema.md` | Included. |
| Context handover | `PROJECT_CONTEXT.md` | Included and updated with verified/unverified status. |
