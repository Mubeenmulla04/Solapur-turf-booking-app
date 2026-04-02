package com.solapur.turf.config;

import com.solapur.turf.security.JwtAuthenticationFilter;
import com.solapur.turf.security.CustomUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                // ── Fully public auth endpoints ──────────────────────────
                .requestMatchers(HttpMethod.POST, "/api/auth/register").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/auth/refresh").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/auth/forgot-password/**").permitAll()
                // ── Auth endpoints that require a valid token ─────────────
                .requestMatchers(HttpMethod.POST,  "/api/auth/logout").authenticated()
                .requestMatchers(HttpMethod.GET,   "/api/auth/me").authenticated()
                .requestMatchers(HttpMethod.POST,  "/api/auth/change-password").authenticated()
                // ── Public browse/discovery endpoints ────────────────────
                .requestMatchers(HttpMethod.GET, "/api/turfs/**").permitAll()
                .requestMatchers("/api/tournaments/**").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/test/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/payments/webhook").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/files/**").permitAll()
                // ── API docs / Swagger ────────────────────────────────────
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                // ── Static resources & uploads ────────────────────────────
                .requestMatchers("/static/**", "/css/**", "/js/**", "/images/**", "/uploads/**").permitAll()
                // ── Slots: GET is public so users can browse availability ─
                .requestMatchers(HttpMethod.GET, "/api/slots/**").permitAll()
                // ── Admin-only endpoints ──────────────────────────────────
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                // ── Owner-only endpoints ──────────────────────────────────
                .requestMatchers(HttpMethod.POST,   "/api/turfs").hasRole("OWNER")
                .requestMatchers(HttpMethod.PUT,    "/api/turfs/**").hasRole("OWNER")
                .requestMatchers(HttpMethod.DELETE, "/api/turfs/**").hasRole("OWNER")
                .requestMatchers("/api/turfs/owner/**").hasRole("OWNER")
                .requestMatchers("/api/availability-slots/**").hasRole("OWNER")
                .requestMatchers("/api/settlements/**").hasRole("OWNER")
                // ── Authenticated user endpoints ──────────────────────────
                .requestMatchers("/api/users/me").authenticated()
                .requestMatchers("/api/bookings/**").authenticated()
                .requestMatchers("/api/teams/**").authenticated()
                .requestMatchers("/api/refunds/**").authenticated()
                .requestMatchers("/api/wallet/**").authenticated()
                // ── Catch-all ─────────────────────────────────────────────
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setExposedHeaders(Arrays.asList("Authorization", "Content-Type"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public CorsFilter corsFilter() {
        return new CorsFilter(corsConfigurationSource());
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
