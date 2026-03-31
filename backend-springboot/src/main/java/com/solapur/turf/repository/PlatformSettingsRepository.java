package com.solapur.turf.repository;

import com.solapur.turf.entity.PlatformSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface PlatformSettingsRepository extends JpaRepository<PlatformSettings, UUID> {
    default PlatformSettings getSettings() {
        return findAll().stream().findFirst().orElseGet(() -> save(new PlatformSettings()));
    }
}
