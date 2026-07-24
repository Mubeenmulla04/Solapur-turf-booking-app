package com.solapur.turf;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.cache.annotation.EnableCaching;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.solapur.turf.entity.User;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.enums.UserRole;
import com.solapur.turf.repository.UserRepository;
import com.solapur.turf.repository.UserWalletRepository;

import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootApplication
@EnableScheduling
@EnableAsync
@EnableCaching
public class SolapurTurfBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SolapurTurfBackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner loadData(UserRepository userRepository,
			UserWalletRepository walletRepository,
			PasswordEncoder passwordEncoder,
			JdbcTemplate jdbcTemplate) {
		return args -> {
			try {
				jdbcTemplate.execute("ALTER TABLE audit_logs DROP COLUMN IF EXISTS created_at;");
				jdbcTemplate.execute("ALTER TABLE audit_logs DROP COLUMN IF EXISTS updated_at;");
				// Drop NOT NULL on user_id — admin actions don't have a user_id
				jdbcTemplate.execute("ALTER TABLE audit_logs ALTER COLUMN user_id DROP NOT NULL;");
				// Drop NOT NULL on success — legacy rows may be missing it
				jdbcTemplate.execute("ALTER TABLE audit_logs ALTER COLUMN success DROP NOT NULL;");
				System.out.println("Cleaned up audit_logs table schema constraints");
			} catch (Exception e) {
				System.err.println("Error cleaning audit_logs: " + e.getMessage());
			}

			if (!userRepository.existsByEmail("admin@solapur.com")) {
				User admin = User.builder()
						.email("admin@solapur.com")
						.phone("0000000000")
						.fullName("System Administrator")
						.passwordHash(passwordEncoder.encode("admin123"))
						.role(UserRole.ADMIN)
						.isVerified(true)
						.build();

				User savedAdmin = userRepository.save(admin);
				walletRepository.save(UserWallet.builder().user(savedAdmin).build());
				System.out.println("Default Admin created: admin@solapur.com / admin123");
			} else {
				userRepository.findByEmail("admin@solapur.com").ifPresent(admin -> {
					if (!admin.isActive()) {
						admin.setActive(true);
						userRepository.save(admin);
						System.out.println("Activated Admin user: admin@solapur.com");
					}
				});
			}
		};
	}
}
