package com.solapur.turf.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Validates all required environment variables at application startup.
 *
 * Prevents the server from starting in an insecure or broken state
 * when critical configuration is missing or still holds placeholder values.
 *
 * Runs after the full application context is loaded (ApplicationReadyEvent),
 * so all beans are available — but before traffic is served.
 */
@Slf4j
@Component
public class EnvironmentValidator {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${razorpay.key.id:}")
    private String razorpayKeyId;

    @Value("${razorpay.key.secret:}")
    private String razorpayKeySecret;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${spring.mail.password:}")
    private String mailPassword;

    @Value("${spring.datasource.url:}")
    private String datasourceUrl;

    @Value("${spring.datasource.username:}")
    private String datasourceUsername;

    @Value("${spring.datasource.password:}")
    private String datasourcePassword;

    @Value("${spring.web.cors.allowed-origins:}")
    private String allowedOrigins;

    private final Environment environment;

    public EnvironmentValidator(Environment environment) {
        this.environment = environment;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void validateOnStartup() {
        List<String> errors   = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        // ── JWT Secret ─────────────────────────────────────────────────────
        if (isBlank(jwtSecret)) {
            errors.add("JWT_SECRET is not set");
        } else if (jwtSecret.length() < 32) {
            errors.add("JWT_SECRET is too short — minimum 32 characters required (64+ recommended)");
        } else if (jwtSecret.contains("CHANGE-ME") || jwtSecret.contains("your-") || jwtSecret.contains("default")) {
            errors.add("JWT_SECRET still holds a placeholder value — generate a real secret with: openssl rand -base64 64");
        }

        // ── Razorpay ───────────────────────────────────────────────────────
        if (isBlank(razorpayKeyId)) {
            errors.add("RAZORPAY_KEY_ID is not set");
        }
        if (isBlank(razorpayKeySecret)) {
            errors.add("RAZORPAY_KEY_SECRET is not set");
        }

        // Warn if using test keys — allow in non-prod profiles
        boolean isProd = isActiveProfile("prod") || isActiveProfile("production");
        if (!isBlank(razorpayKeyId) && razorpayKeyId.startsWith("rzp_test_")) {
            if (isProd) {
                errors.add("RAZORPAY_KEY_ID is a TEST key — production profile requires live keys (rzp_live_...)");
            } else {
                warnings.add("Using Razorpay TEST keys — remember to switch to live keys before production");
            }
        }

        // ── Database ───────────────────────────────────────────────────────
        if (isBlank(datasourceUrl)) {
            errors.add("DB_URL is not set");
        }
        if (isBlank(datasourceUsername)) {
            errors.add("DB_USERNAME is not set");
        }
        if (isBlank(datasourcePassword)) {
            errors.add("DB_PASSWORD is not set");
        } else if (datasourcePassword.equalsIgnoreCase("root") ||
                   datasourcePassword.equalsIgnoreCase("password") ||
                   datasourcePassword.equalsIgnoreCase("postgres")) {
            if (isProd) {
                errors.add("DB_PASSWORD uses a trivially weak value — change it before deploying to production");
            } else {
                warnings.add("DB_PASSWORD is a common default — use a strong password in production");
            }
        }

        // ── Email ──────────────────────────────────────────────────────────
        if (isBlank(mailUsername)) {
            warnings.add("SPRING_MAIL_USERNAME is not set — email notifications will not work");
        }
        if (isBlank(mailPassword)) {
            warnings.add("SPRING_MAIL_PASSWORD is not set — email notifications will not work");
        } else if (mailPassword.contains("your_") || mailPassword.contains("YOUR_")) {
            errors.add("SPRING_MAIL_PASSWORD still holds a placeholder value");
        }

        // ── CORS ───────────────────────────────────────────────────────────
        if (isBlank(allowedOrigins)) {
            errors.add("ALLOWED_ORIGINS is not set — API will reject all cross-origin requests");
        } else if (allowedOrigins.trim().equals("*")) {
            if (isProd) {
                errors.add("ALLOWED_ORIGINS is '*' — wildcard CORS is forbidden in production");
            } else {
                warnings.add("ALLOWED_ORIGINS is '*' — restrict to specific domains before production deployment");
            }
        }

        // ── Report ─────────────────────────────────────────────────────────
        if (!warnings.isEmpty()) {
            log.warn("=== ENVIRONMENT WARNINGS ({}) ===", warnings.size());
            warnings.forEach(w -> log.warn("  [WARN]  {}", w));
        }

        if (!errors.isEmpty()) {
            log.error("=== ENVIRONMENT VALIDATION FAILED ({} error(s)) ===", errors.size());
            errors.forEach(e -> log.error("  [ERROR] {}", e));
            log.error("Application cannot start safely with the above configuration errors.");
            log.error("Fix the above issues and restart. See .env.example for guidance.");

            // Hard-fail on production; warn-only on dev so developers aren't blocked
            if (isProd) {
                throw new IllegalStateException(
                    "Application startup aborted: " + errors.size() +
                    " environment configuration error(s) detected. Check the logs above.");
            } else {
                log.warn("NOT in production profile — continuing despite errors. DO NOT deploy this build.");
            }
        } else {
            log.info("=== Environment validation passed ({} warning(s)) ===", warnings.size());
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private boolean isActiveProfile(String profile) {
        String[] activeProfiles = environment.getActiveProfiles();
        for (String p : activeProfiles) {
            if (p.equalsIgnoreCase(profile)) return true;
        }
        return false;
    }
}
