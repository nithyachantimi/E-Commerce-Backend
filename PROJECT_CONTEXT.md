# E-Commerce Authentication System — Project Context & Handover Document

> **Important**: This document reflects the actual implementation state as of **October 20, 2026**. Future AI agents and developers must read this document in its entirety before modifying the codebase.

---

## 1. Project Purpose & Current Implementation Status

### Purpose
A secure, enterprise-grade authentication system for an e-commerce platform built with a Java / Spring Boot backend, a React / Vite / Material UI frontend, and a MySQL relational database. The system handles customer registration, credential authentication, server-managed sessions with immediate revocation, multi-country phone number normalization, password recovery via OTP challenges, and authenticated password changes.

### Current Implementation Status
| Scope Item | Status | Details |
|---|---|---|
| **Frontend Architecture** | **Implemented** | React 19, Vite 8, JavaScript (`.jsx` / `.js`), Material UI 9, React Router 7. Production build succeeded on 2026-10-20 with route-level code splitting. |
| **Frontend Routes (7 of 7)** | **Complete** | 1. `/register`, 2. `/login`, 3. `/home`, 4. `/forgot-password`, 5. `/verify-otp`, 6. `/reset-password`, 7. `/change-password`. |
| **Theme System** | **Implemented; manual check pending** | Light and dark themes with a theme toggle and local preference persistence. |
| **International Phone Input** | **Implemented; build verified** | `react-international-phone` country metadata/formatting plus `libphonenumber-js/max` validation, with a searchable country/calling-code picker. Backend also validates and normalizes with Google libphonenumber. |
| **Backend REST APIs** | **Implemented; package compiled** | Nine required endpoints in `AuthController.java`, plus `GET /api/csrf` to initialize cookie-based CSRF protection. |
| **Database Migrations** | **Defined; DB state unverified** | Flyway V1 defines `users`, `user_sessions`, and `password_recovery_challenges`. Baseline-on-migrate is disabled so an unknown existing schema is not silently marked as migrated. |
| **Security Controls** | **Implemented; runtime flow unverified** | BCrypt(12), HttpOnly access cookie (`SameSite=Lax`), CSRF cookie/header checks, in-memory rate limiting, server-side session revocation tracking, and generic recovery response. |
| **Local Tooling** | **Partial** | Maven Wrapper and PowerShell startup scripts are present. Git is not available in the current agent environment. Backend startup asks for the database password using a secure prompt when the environment variable is unset. |
| **Automated Testing** | **Deferred** | Deferred per user instruction. No automated test suites were created or run. |

---

## 2. Instructions for Future AI Agents

Any future AI agent assisting with this codebase **MUST** follow these mandatory guidelines:

1. **Read this Document First**: Do not generate boilerplate or assume project structure without reviewing this context.
2. **Inspect Existing Repositories**: Check `git status`, existing files, branch tracking, and configuration in both `E-Commerce-Frontend` and `E-Commerce-Backend` before making changes.
3. **Preserve Existing Architecture**:
   - Maintain the separation: `E-Commerce-Frontend` for client code, `E-Commerce-Backend` for server code.
   - Do **NOT** introduce TypeScript, `.tsx` files, type annotations, or tsconfig files into the frontend. The project strictly uses standard JavaScript and `.jsx`.
   - Do **NOT** add Tailwind CSS unless explicitly requested by the user.
4. **Avoid Duplicating Functionality**:
   - Do not re-create authentication routes or rewrite existing services.
   - Reuse existing components (`AuthCard`, `FormInput`, `PasswordInput`, `PhoneNumberInput`, `PrimaryButton`, `ThemeToggle`, `ProtectedRoute`, `AlertBanner`).
5. **Verify the Code Directly**: Never assume a feature works without checking the source code and testing compilation or startup.
6. **Keep this Document Updated**: Update `PROJECT_CONTEXT.md` whenever routes, tables, APIs, or architectural decisions change.
7. **Strict Scope Discipline**: Implement only the features requested by the user for the specific milestone. Do not add shopping cart, product catalog, checkout, or payments until authorized.
8. **Automated Testing Restriction**: Do **NOT** generate automated test suites (Vitest, RTL, JUnit, MockMvc) unless the user explicitly requests them.

---

## 3. Technology Stack & Component Versions

### Frontend (`E-Commerce-Frontend`)
- **Runtime / Language**: ECMAScript 2024 / JavaScript (`.jsx` and `.js`), Vite 8.3.4
- **Core Libraries**: React 19.2.8, React DOM 19.2.8, React Router DOM 7.18.4
- **UI & Styling**: Material UI (`@mui/material` 9.5.0), Emotion (`@emotion/react`, `@emotion/styled`), Lucide React icons (1.59.0)
- **Networking**: Axios 1.20.0 with credentials and CSRF cookie/header handling
- **Phone input and validation**: `react-international-phone` 4.8.0 and `libphonenumber-js` 1.13.15
- **Build Output**: Standard ES modules bundled to `dist/`

### Backend (`E-Commerce-Backend`)
- **Runtime / Language**: Java 21+ (compiled with target release 21; exact installed JDK version not reverified here)
- **Framework**: Spring Boot 3.3.5
- **Security**: Spring Security 6.x, BCrypt (work factor 12)
- **Persistence**: Spring Data JPA, Hibernate, MySQL Connector/J 8.3.0
- **Database Migrations**: Flyway Core & Flyway MySQL 10.10.0
- **Token Management**: JJWT (Java JWT) 0.12.6
- **Phone Normalization**: Google `libphonenumber` 8.13.47
- **Validation**: Jakarta Bean Validation (`spring-boot-starter-validation`)
- **API Documentation**: Springdoc OpenAPI / Swagger UI 2.6.0
- **Build Tool**: Apache Maven 3.9.9 / Maven Wrapper (`mvnw.cmd`)

### Database
- Intended engine: MySQL 8 on `localhost:3306`.
- Intended database and least-privilege account names: `ecommerce_auth` and `ecommerce_app`.
- The current environment could not connect to `localhost:3306`; service-manager access was denied. Database existence, existing tables/data, and migration status remain unknown. Do not assume the schema is empty or run administrative SQL without reviewing it with the user.

---

## 4. Repository & Directory Structure

```
C:\Users\u\Downloads\E Commerce\
├── E-Commerce-Frontend/
│   ├── .env.example                # Safe environment placeholder (VITE_API_BASE_URL)
│   ├── .env                        # Local dev environment (gitignored)
│   ├── .gitignore                  # Ignores node_modules, dist, .env, logs
│   ├── index.html                  # HTML5 entry point with Inter font
│   ├── package.json                # Frontend dependencies & scripts
│   ├── vite.config.js              # Vite server configuration (port 5173)
│   ├── start-frontend.ps1          # One-click Windows PowerShell startup script
│   └── src/
│       ├── main.jsx                # Application mounting point
│       ├── App.jsx                 # Route definitions & top-level layout
│       ├── App.css / index.css     # Global CSS reset & custom utility variables
│       ├── api/
│       │   ├── axios.js            # Axios client with base URL & cookie credentials
│       │   └── authService.js      # Clean wrappers for all 9 REST endpoints
│       ├── context/
│       │   ├── AuthContext.jsx     # Authentication state, login, logout, me hydrate
│       │   ├── ThemeContext.jsx    # Light/Dark mode state & CSS variable sync
│       │   └── RecoveryContext.jsx # Holds reset authorization in memory only
│       ├── theme/
│       │   └── theme.js            # Material UI Light & Dark theme tokens
│       ├── components/
│       │   ├── AlertBanner.jsx     # Success / Error contextual alerts
│       │   ├── AuthCard.jsx        # Responsive authentication container
│       │   ├── FormInput.jsx       # Floating labeled text input with validation errors
│       │   ├── Navbar.jsx          # Responsive header with branding, user info, toggle
│       │   ├── PasswordInput.jsx   # Visibility toggle & strength indicator
│       │   ├── PhoneNumberInput.jsx# Searchable country selector, flags, dial codes
│       │   ├── PrimaryButton.jsx   # Styled action button with loading spinner
│       │   ├── ProtectedRoute.jsx  # Client-side guard checking AuthContext
│       │   └── ThemeToggle.jsx     # One-click Light/Dark theme switcher
│       └── pages/
│           ├── RegisterPage.jsx       # Page 1: /register
│           ├── LoginPage.jsx          # Page 2: /login
│           ├── HomePage.jsx           # Page 3: /home (Protected)
│           ├── ForgotPasswordPage.jsx # Page 4: /forgot-password
│           ├── VerifyOtpPage.jsx      # Page 5: /verify-otp
│           ├── ResetPasswordPage.jsx  # Page 6: /reset-password
│           ├── ChangePasswordPage.jsx # Page 7: /change-password (Protected)
│           └── NotFoundPage.jsx       # 404 Catch-all screen
│
└── E-Commerce-Backend/
    ├── pom.xml                     # Maven project descriptor & dependencies
    ├── mvnw.cmd                    # Windows Maven Wrapper
    ├── start-backend.ps1           # One-click Windows PowerShell startup script
    ├── .env.example                # Safe environment configuration template
    ├── PROJECT_CONTEXT.md          # This comprehensive handover document
    └── src/main/
        ├── java/com/ecommerce/auth/
        │   ├── AuthBackendApplication.java # Spring Boot main entry point
        │   ├── controller/
        │   │   └── AuthController.java     # REST Controller implementing 9 endpoints
        │   ├── dto/                        # Request & response transfer objects
        │   ├── entity/
        │   │   ├── User.java               # users table entity
        │   │   ├── UserSession.java        # user_sessions table entity
        │   │   └── PasswordRecoveryChallenge.java # OTP recovery challenges entity
        │   ├── repository/                 # Spring Data JPA repositories
        │   ├── security/
        │   │   ├── SecurityConfig.java     # Spring Security filter chain & CORS
        │   │   ├── JwtTokenProvider.java   # JWT parsing, signing, claim validation
        │   │   ├── JwtAuthenticationFilter.java # Cookie/Bearer token extractor
        │   │   └── UserPrincipal.java      # Spring Security UserDetails implementation
        │   └── service/
        │       ├── AuthService.java        # Registration, login, logout, password change
        │       ├── PasswordRecoveryService.java # OTP challenge creation & validation
        │       ├── PhoneValidationService.java  # libphonenumber E.164 normalization
        │       ├── InMemoryRateLimiter.java     # Rate-limiting guard
        │       └── LocalConsoleRecoveryCodeDelivery.java # Dev console OTP logger
        └── resources/
            ├── application.yml             # Spring Boot YAML configuration
            └── db/migration/
                └── V1__create_auth_schema.sql # Flyway baseline schema migration
```

---

## 5. Database Schema & Tables

The schema is managed strictly via **Flyway** (`V1__create_auth_schema.sql`). Hibernate is configured with `ddl-auto: validate`.

### 1. `users` Table
Stores customer credentials and identities. Plaintext passwords are never stored.
```sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mobile_e164 VARCHAR(20) NOT NULL UNIQUE,
    phone_region VARCHAR(10) NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    password_changed_at TIMESTAMP NULL,
    INDEX idx_user_email (email),
    INDEX idx_user_mobile (mobile_e164)
);
```

### 2. `user_sessions` Table
Enables instantaneous server-side session tracking and revocation for JWTs.
```sql
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    jti VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP NULL,
    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_jti (jti),
    INDEX idx_session_user (user_id)
);
```

### 3. `password_recovery_challenges` Table
Tracks recovery OTP challenges, expiration windows, attempt counts, and single-use reset authorization tokens.
```sql
CREATE TABLE password_recovery_challenges (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    otp_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    attempt_count INT DEFAULT 0,
    consumed_at TIMESTAMP NULL,
    delivery_channel VARCHAR(20) DEFAULT 'DEV_LOG',
    recovery_token_hash VARCHAR(255) NULL,
    recovery_expires_at TIMESTAMP NULL,
    CONSTRAINT fk_recovery_challenges_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_recovery_user (user_id),
    INDEX idx_recovery_expires (expires_at)
);
```

---

## 6. API Contract Reference

Base URL: `http://localhost:8080/api`

| Method | Endpoint | Access | Summary |
|---|---|---|---|
| `POST` | `/reg` | Public | Registers a new account with validated full name, email, mobile number, and password. |
| `POST` | `/login` | Public | Authenticates via email or international mobile number; creates session row and sets HttpOnly cookie. |
| `POST` | `/logout` | Authenticated | Revokes current session row (`revoked_at = NOW()`) and deletes the access cookie. |
| `POST` | `/forgot-password` | Public | Initiates OTP recovery; returns generic response to prevent account enumeration. |
| `POST` | `/verify-otp` | Public | Verifies 6-digit OTP code, enforces attempt limits, consumes OTP, and issues short-lived recovery token. |
| `POST` | `/reset-password` | Recovery Token | Validates recovery token, enforces password complexity, updates password hash, and revokes all active sessions. |
| `PUT` | `/change-password` | Authenticated | Verifies current password, updates to new password, and revokes active sessions. |
| `GET` | `/me` | Authenticated | Returns safe user profile data (`id`, `fullName`, `email`, `mobileE164`, `phoneRegion`). |
| `GET` | `/home` | Authenticated | Returns `{"message": "Welcome to Home Page"}`. |
| `GET` | `/csrf` | Public setup | Initializes the CSRF cookie used by the browser client. |

Swagger UI is accessible at: `http://localhost:8080/swagger-ui.html`
OpenAPI JSON Docs: `http://localhost:8080/v3/api-docs`

---

## 7. Authentication, Session & Security Implementation

1. **Password Hashing**: BCrypt with work factor 12 (`new BCryptPasswordEncoder(12)`).
2. **Token & Cookie Architecture**:
   - Access token lifetime: 15 minutes (`JWT_ACCESS_EXPIRATION_MS: 900000`).
   - Cookie properties: `HttpOnly=true`, `SameSite=Lax`, `Path=/`, `Secure=false` for local HTTP.
   - Browser automatically includes cookies with requests via `apiClient` (`withCredentials: true`).
3. **Session Revocation**:
   - Every issued JWT carries a unique UUID `jti` claim.
   - On every request, `JwtAuthenticationFilter` validates the signature, parses the `jti`, and queries `user_sessions`. If `revoked_at` is non-null or `expires_at` has passed, the request is immediately rejected (`401 Unauthorized`).
   - Logging out marks the active `jti` as revoked.
   - Changing or resetting passwords revokes **ALL** active sessions for that user ID.
4. **Account Enumeration Protection**:
   - `/api/forgot-password` always returns `200 OK` with: `"If an account exists, use the configured recovery delivery method to continue."`
5. **Local Development OTP Delivery**:
   - Under `SPRING_PROFILES_ACTIVE=local`, `LocalConsoleRecoveryCodeDelivery` prints the generated OTP to the backend console with a local-only warning. In production, this bean is inactive.
6. **CSRF**: `GET /api/csrf` initializes the `XSRF-TOKEN` cookie; Axios sends it as `X-XSRF-TOKEN` on unsafe requests. Runtime browser verification is still required.

---

## 8. Local Setup & Startup Instructions (Windows)

### Prerequisites Check
- **Java**: Java 21+ (`C:\Program Files\Java\jdk-25.0.4.1\bin`)
- **Node.js**: Node 20+ (`C:\Program Files\nodejs\node.exe`)
- **MySQL Server 8.0**: Running on port `3306`

### Step 1: Provision the MySQL Database
After reviewing the server and obtaining approval for any required database/user creation, run an administrator-approved SQL script. Use a newly chosen local password and never store it in the repository. Example placeholders only:
```sql
CREATE DATABASE IF NOT EXISTS ecommerce_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'ecommerce_app'@'localhost' IDENTIFIED BY '<choose-a-local-secret>';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, REFERENCES ON ecommerce_auth.* TO 'ecommerce_app'@'localhost';

FLUSH PRIVILEGES;
```

### Step 2: Start the Backend
Open a PowerShell terminal and run:
```powershell
Set-Location "C:\Users\u\Downloads\E Commerce\E-Commerce-Backend"
.\start-backend.ps1
```
*Flyway will automatically execute `V1__create_auth_schema.sql` on first boot.*

### Step 3: Start the Frontend
Open a second PowerShell terminal and run:
```powershell
Set-Location "C:\Users\u\Downloads\E Commerce\E-Commerce-Frontend"
.\start-frontend.ps1
```
*Open `http://localhost:5173` in your browser.*

---

## 9. Known Decisions, Tradeoffs & Next Steps

1. **Rate Limiting**: Currently implemented via an in-memory sliding window (`InMemoryRateLimiter`). Sufficient for local demonstration; multi-instance production will require Redis or API Gateway throttling.
2. **CSRF Protection**: Spring Security uses a double-submit CSRF cookie/header for the browser client. The interaction needs browser/runtime verification before relying on it.
3. **Commerce Functionality**: Product catalog, shopping cart, and payment processors are deliberately omitted in this milestone and should only be introduced in subsequent phases.

## Verification log (2026-10-20)

- Frontend production build: succeeded after route-level code splitting. The initial JavaScript bundle is about 417 kB; phone-input code is a separate 225 kB route chunk. Vite emitted no chunk-size warning.
- Frontend lint: completed with 3 warnings (Fast Refresh warnings in the three context modules); no errors.
- Backend package: `mvn -B -DskipTests package` succeeded and compiled 38 Java files after the main security changes. Automated test execution was skipped.
- Automated tests: not created or run, per the user’s testing override.
- Database TCP check: `localhost:3306` was unreachable. Database migration/startup and browser flows were not attempted. Final CORS default and Flyway baseline configuration adjustments were not followed by another backend package run.
- Git status/branch state: not verified because Git is unavailable in this environment.

## Guidance for future agents

Read this document before editing; inspect both repositories, Git status, configuration, and code instead of relying on this summary alone. Preserve existing work and the frontend/backend separation. Do not duplicate completed routes or services. Update this document whenever implementation changes and clearly distinguish verified behavior from plans. Work only on the next requested features. Automated tests remain deferred unless the user explicitly requests them. Do not apply migrations or create/alter databases or accounts without inspecting the current state and receiving the required approval.
