# Authentication API

Base URL: `http://localhost:8080/api`. The fixed nine application routes below keep their required methods and paths. Browser requests use credentialed HttpOnly cookies. Before the first unsafe request, the frontend calls `GET /csrf`, stores the returned `XSRF-TOKEN` cookie in the browser, and sends its value in `X-XSRF-TOKEN`.

Success responses use `{ "success": true, "message": "...", "data": ... }`, except logout (`204`) and `/home` (plain `{"message":"Welcome to Home Page"}`). Errors currently use `{ "success": false, "status": 400, "error": "...", "message": "...", "path": "...", "validationErrors": {...}, "timestamp": "..." }`. Duplicate registration returns `409`; rate limits return `429`.

## Routes

| Method | Path | Access | Body / result |
|---|---|---|---|
| POST | `/reg` | Public + CSRF | `{fullName,email,mobileNumber,phoneRegion,password,confirmPassword}`; `201` with safe user summary. Phone number must be valid and is stored as E.164. |
| POST | `/login` | Public + CSRF | `{identifier,password}`; identifier is email or international phone. Sets HttpOnly access cookie and returns expiry/profile, not the raw JWT. |
| POST | `/logout` | Authenticated + CSRF | Revokes current session and clears cookie; `204`. |
| POST | `/forgot-password` | Public + CSRF | `{identifier}`; returns a generic response whether account exists or not. |
| POST | `/verify-otp` | Public + CSRF | `{identifier,otp}`; success returns `data.recoveryToken`. OTP expires in 5 minutes; max 5 attempts. |
| POST | `/reset-password` | Recovery authorization + CSRF | `{recoveryToken,newPassword,confirmPassword}`; consumes authorization and revokes sessions. |
| PUT | `/change-password` | Authenticated + CSRF | `{currentPassword,newPassword,confirmPassword}`; verifies current password and revokes sessions. |
| GET | `/me` | Authenticated | Safe user profile fields. |
| GET | `/home` | Authenticated | `{ "message": "Welcome to Home Page" }`. |
| GET | `/csrf` | Public setup | Initializes the CSRF cookie; no application data. |

All password requests use an 8–100 character policy with uppercase, lowercase, number, and one of `@#$%^&+=!._-`. Errors must not expose password hashes, raw JWTs, OTPs, recovery tokens, or stack traces.

## Recovery delivery

Local profile writes the code to the backend console for manual development use. Outside that profile, delivery is disabled until an email/SMS provider is configured. The API remains account-enumeration resistant, so the generic response does not confirm actual delivery.
