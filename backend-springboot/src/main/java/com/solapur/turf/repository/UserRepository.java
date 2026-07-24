package com.solapur.turf.repository;

import com.solapur.turf.entity.User;
import com.solapur.turf.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);

    Optional<User> findByPhone(String phone);

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);

    List<User> findByFcmTokenIsNotNull();

    List<User> findByRoleAndFcmTokenIsNotNull(UserRole role);
}
