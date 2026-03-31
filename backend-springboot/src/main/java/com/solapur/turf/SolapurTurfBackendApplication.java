package com.solapur.turf;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.solapur.turf.entity.User;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.enums.UserRole;
import com.solapur.turf.repository.UserRepository;
import com.solapur.turf.repository.UserWalletRepository;

@SpringBootApplication
@EnableScheduling
public class SolapurTurfBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SolapurTurfBackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner loadData(UserRepository userRepository,
			UserWalletRepository walletRepository,
			PasswordEncoder passwordEncoder) {
		return args -> {
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
			}
		};
	}
}
