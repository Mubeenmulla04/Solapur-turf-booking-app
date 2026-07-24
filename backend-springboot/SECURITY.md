# 🔒 Security Configuration Guide
**Solapur Turf Booking Backend**  
Last Updated: July 2026

---

## Table of Contents
1. [Quick Start Security Checklist](#quick-start-security-checklist)
2. [Environment Variables](#environment-variables)
3. [Security Architecture](#security-architecture)
4. [Filter Chain Order](#filter-chain-order)
5. [Rate Limiting](#rate-limiting)
6. [Authentication & JWT](#authentication--jwt)
7. [CORS Configuration](#cors-configuration)
8. [File Upload Security](#file-upload-security)
9. [Payment Webhook Security](#payment-webhook-security)
10. [Authorization Model](#authorization-model)
11. [Running Locally](#running-locally)
12. [Deploying to Production](#deploying-to-production)
13. [Generating Secrets](#generating-secrets)

---

## Quick Start Security Checklist

Run through this before every deployment:

```
[ ] Copy .env.example → .env and fill in all real values
[ ] JWT_SECRET is at least 64 random characters (use openssl command below)
[ ] RAZORPAY_KEY_ID uses rzp_live_... (not test keys)
[ ] DB_PASSWORD is strong and unique
[ ] ALLOWED_ORIGINS is set to your exact frontend domain (not *)
[ ] SPRING_MAIL_PASSWORD is a Gmail App Password (not your Gmail login)
[ ] Spring profile is set to 'prod' for production deployments
[ ] .env is in .gitignore and NOT committed to git
[ ] firebase-service-account.json is in .gitignore
[ ] google-drive-service-account.json is in .gitignore
```

---

## Environment Variables

All secrets are loaded from environment variables. **No secrets are ever hardcoded.**  
The application will **refuse to start in production** if any required variable is missing or holds a placeholder value.

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `JWT_SECRET` | JWT signing secret, min 32 chars | `openssl rand -base64 64` |
| `JWT_EXPIRATION` | Access token TTL in ms | `86400000` (24h) |
| `JWT_REFRESH_EXPIRATION` | Refresh token TTL in ms | `604800000` (7d) |
| `DB_URL` | PostgreSQL JDBC URL | `jdbc:postgresql://host:5432/db` |
| `DB_USERNAME` | Database user | `turf_app_user` |
| `DB_PASSWORD` | Database password | strong random password |
| `RAZORPAY_KEY_ID` | Razorpay key ID | `rzp_live_xxxx` |
| `RAZORPAY_KEY_SECRET` | Razorpay key secret | `xxxxxxxxxxxx` |
| `ALLOWED_ORIGINS` | CORS allowed origins (comma-separated) | `https://yourdomain.com` |
| `SPRING_MAIL_USERNAME` | Gmail address for sending emails | `app@yourdomain.com` |
| `SPRING_MAIL_PASSWORD` | Gmail App Password (16 chars) | `abcd efgh ijkl mnop` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | `8080` | HTTP port |
| `DDL_AUTO` | `update` | Hibernate DDL strategy |
| `DB_POOL_MAX` | `20` | HikariCP max pool size |
| `FIREBASE_CONFIG_PATH` | `firebase-service-account.json` | Firebase credentials path |
| `GOOGLE_DRIVE_FOLDER_ID` | — | Google Drive backup folder |
| `LOG_LEVEL_APP` | `INFO` | App log level |

---

## Security Architecture

```
Incoming Request
       │
       ▼
┌─────────────────────────────────┐
│  RazorpayWebhookFilter          │  ← Blocks non-Razorpay IPs on /webhook
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  SecurityHeadersFilter          │  ← Adds X-Frame-Options, CSP, HSTS, etc.
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  RateLimitingFilter             │  ← Bucket4j: 100/min default, 10/min auth
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  JwtAuthenticationFilter        │  ← Validates JWT, checks blacklist
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Spring Security AuthZ          │  ← @PreAuthorize role checks
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Controller + @Valid             │  ← Input validation on all DTOs
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Service Layer + AuthorizationUtil│ ← Ownership verification
└─────────────────────────────────┘
```

---

## Filter Chain Order

Filters execute in this exact order (first to last):

1. **RazorpayWebhookFilter** — IP whitelist for `/api/payments/webhook`
2. **SecurityHeadersFilter** — security response headers on every request
3. **RateLimitingFilter** — per-IP token bucket rate limiting
4. **JwtAuthenticationFilter** — JWT validation + blacklist check

---

## Rate Limiting

Implemented with **Bucket4j** token bucket algorithm, per IP address.

| Endpoint Pattern | Limit | Window |
|-----------------|-------|--------|
| `/api/auth/login` | 10 requests | 1 minute |
| `/api/auth/register` | 10 requests | 1 minute |
| `/api/auth/forgot-password/**` | 3 requests | 1 hour |
| All other `/api/**` endpoints | 100 requests | 1 minute |
| Static resources | Unlimited | — |

**429 Too Many Requests** is returned when the limit is exceeded.

---

## Authentication & JWT

### Token Lifecycle
```
Login → Access Token (24h) + Refresh Token (7d)
                │
                ▼ (expiry approaching)
         POST /api/auth/refresh
                │
                ▼
         New Access Token
                │
                ▼ (user logs out)
         POST /api/auth/logout
         → Token added to in-memory blacklist
         → Token rejected on all future requests
```

### JWT Requirements
- Algorithm: **HS256**
- Secret: minimum 32 characters, ideally 64 random bytes from `openssl rand -base64 64`
- Claims: `userId`, `role`, `sub` (email), `iat`, `exp`

### Password Policy
Enforced via `ChangePasswordRequest` validation:
- Minimum 8 characters, maximum 128
- Must contain: uppercase, lowercase, digit, special character (`@$!%*?&`)

---

## CORS Configuration

Allowed origins are read from the `ALLOWED_ORIGINS` environment variable (comma-separated).

```properties
# Development example:
ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.10:8080

# Production example:
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

**Never use `*` in production.** The `EnvironmentValidator` will log an error and abort startup in the `prod` profile if `ALLOWED_ORIGINS=*`.

Allowed HTTP methods: `GET, POST, PUT, PATCH, DELETE, OPTIONS`

---

## File Upload Security

All file uploads are validated by **`FileUploadValidator`** using **Apache Tika** for magic-byte detection — this cannot be bypassed by changing the file extension or `Content-Type` header.

### Rules Enforced
| Rule | Detail |
|------|--------|
| Max size | 10 MB per file |
| Turf images | JPEG, PNG, WEBP only |
| Documents | JPEG, PNG, WEBP, PDF |
| Filename | Random UUID — original name is never used |
| Extension | Must match Tika-detected MIME type |
| Path traversal | `..`, `/`, `\`, null bytes rejected |
| Batch limit | Max 10 images per upload request |

### File Access (FileController)
- `type` path variable validated against whitelist: `turfs`, `documents`, `avatars`
- `id` path variable must be valid UUID format
- `fileName` must match `^[a-f0-9\-]{36}\.(jpg|jpeg|png|webp|pdf)$`
- Path traversal check: resolved path must stay inside `uploads/` root
- `Content-Disposition` header set to prevent browser execution

---

## Payment Webhook Security

The `/api/payments/webhook` endpoint is protected by **`RazorpayWebhookFilter`**:

1. **IP Whitelist** — only requests from official Razorpay IPs are allowed
2. **Signature Header** — `X-Razorpay-Signature` must be present (absent = 400)
3. **Signature Verification** — HMAC-SHA256 verified in `PaymentService.handleWebhook()`
4. **Logging** — all blocked attempts logged with IP and User-Agent

### Updating Razorpay IPs
If Razorpay publishes new webhook IPs, update `RazorpayWebhookFilter.RAZORPAY_ALLOWED_IPS`:
```java
private static final Set<String> RAZORPAY_ALLOWED_IPS = Set.of(
    "54.187.174.169",
    // add new IPs here
);
```
Reference: https://razorpay.com/docs/webhooks/validate-test/#ip-addresses

---

## Authorization Model

### Role Hierarchy
```
ADMIN  → Full platform access
OWNER  → Manage own turfs, slots, bookings, pricing
USER   → Browse turfs, make bookings, manage own account
```

### Three-Layer Authorization
Every sensitive operation is protected at all three layers:

**Layer 1 — URL-level (SecurityConfig)**
```java
.requestMatchers("/api/admin/**").hasRole("ADMIN")
.requestMatchers("/api/owners/**").hasRole("OWNER")
```

**Layer 2 — Method-level (@PreAuthorize)**
```java
@PreAuthorize("hasRole('OWNER')")
public ResponseEntity<...> confirmBooking(...)
```

**Layer 3 — Service-level (AuthorizationUtil)**
```java
// Verifies the logged-in owner actually owns this specific turf
authorizationUtil.requireTurfOwnership(turfId, userDetails.getUser().getId());
```

### AuthorizationUtil Methods
| Method | Checks |
|--------|--------|
| `requireOwnerProfile(userId)` | User has a TurfOwner profile |
| `requireTurfOwnership(turfId, userId)` | User owns the specific turf |
| `requirePricingRuleOwnership(rule, userId)` | User owns the turf of the rule |

---

## Running Locally

### 1. Copy and fill the .env file
```powershell
Copy-Item .env.example .env
# Open .env and fill in all values
```

### 2. Generate a secure JWT secret
```powershell
# PowerShell (requires OpenSSL)
openssl rand -base64 64
# Paste the output as JWT_SECRET in your .env
```

### 3. Set local CORS origins
```
ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.X:8080
```
Replace `192.168.1.X` with your machine's LAN IP for Flutter device testing.

### 4. Start the application
```powershell
cd backend-springboot
./mvnw spring-boot:run
```

On startup, `EnvironmentValidator` will log warnings for any issues. Fix them before deploying.

---

## Deploying to Production

### 1. Set the Spring profile
```bash
export SPRING_PROFILES_ACTIVE=prod
```
In the `prod` profile, `EnvironmentValidator` will **abort startup** if:
- `JWT_SECRET` is too short or a placeholder
- `RAZORPAY_KEY_ID` is a test key
- `DB_PASSWORD` is a common weak password
- `ALLOWED_ORIGINS` is `*`

### 2. Use live Razorpay keys
```
RAZORPAY_KEY_ID=rzp_live_YOUR_KEY
RAZORPAY_KEY_SECRET=YOUR_SECRET
```

### 3. Use HTTPS
Set the HSTS header (already done by `SecurityHeadersFilter`). Ensure your reverse proxy (Nginx/Caddy) terminates TLS and forwards to port 8080.

### 4. Recommended Nginx snippet
```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass         http://localhost:8080;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

---

## Generating Secrets

### JWT Secret (recommended: 64 bytes)
```bash
# Linux / macOS / WSL
openssl rand -base64 64

# PowerShell (Windows)
[Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }))
```

### Database Password
```bash
openssl rand -base64 32
```

### Gmail App Password
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification
3. Go to https://myaccount.google.com/apppasswords
4. Create a new app password for "Mail"
5. Copy the 16-character password into `SPRING_MAIL_PASSWORD`

---

## Security Files Reference

| File | Purpose |
|------|---------|
| `config/SecurityConfig.java` | Filter chain, CORS, URL authorization rules |
| `config/EnvironmentValidator.java` | Startup environment checks |
| `security/JwtAuthenticationFilter.java` | JWT validation per request |
| `security/JwtService.java` | JWT generation and parsing |
| `security/RateLimitingFilter.java` | Bucket4j rate limiting |
| `security/SecurityHeadersFilter.java` | HTTP security response headers |
| `security/RazorpayWebhookFilter.java` | Webhook IP whitelist |
| `util/AuthorizationUtil.java` | Ownership verification helpers |
| `util/FileUploadValidator.java` | Tika magic-byte file validation |
| `exception/GlobalExceptionHandler.java` | Safe error responses |
| `.env.example` | Template for required environment variables |
| `.gitignore` | Ensures secrets are never committed |

---

## Reporting Security Issues

If you discover a security vulnerability, **do not open a public GitHub issue**.  
Email the development team directly with details of the vulnerability.

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

---

*This document should be reviewed and updated whenever security-relevant changes are made to the codebase.*
