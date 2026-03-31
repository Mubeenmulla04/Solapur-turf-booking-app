# 🏟️ Solapur Turf Booking Ecosystem

A high-performance, full-stack platform for sports facility management, turf bookings, team formation, and tournament hosting.

---

## 🚀 Quick Start (Running the App)

### 1. Backend (Spring Boot)
The backend service handles REST APIs, JWT authentication, and Razorpay integration.

**Prerequisites:** Java 17+, PostgreSQL.

```bash
cd backend-springboot
# Ensure local database 'turf_db' exists
./mvnw spring-boot:run
```

### 2. Mobile App (Flutter)
The cross-platform mobile application for Players, Turf Owners, and Admins.

**Prerequisites:** Flutter SDK 3.10+, Android Studio/Xcode.

```bash
cd solapur_turf_app
flutter pub get
# ⚠️ Update LAN IP in lib/core/constants/app_constants.dart
flutter run
```

---

## 🏗️ Architecture & Tech Stack

### 🔙 Backend (Java/Spring Boot)
- **Framework:** Spring Boot 3.4.0 (Robust, scalable)
- **Security:** Spring Security with JWT (Stateless OAuth2 style)
- **Persistence:** Hibernate/ORM over PostgreSQL
- **Logic:** Feature-driven Service layer for Bookings, Teams, Tournaments
- **Payments:** Razorpay Java SDK for order creation and verification
- **Validation:** Jakarta / Spring Boot Validation

### 📱 Frontend (Flutter/Dart)
- **Framework:** Flutter (Material 3 Adaptive Design)
- **State Mgmt:** Riverpod 2.6 (Highly reactive, typed providers)
- **Navigation:** GoRouter (Declarative, conditional redirects)
- **Async:** Dio + Pretty Dio Logger (Intercepted network calls)
- **UI:** Custom design tokens, glassmorphic elements, gap-utility spacing

---

## ✨ Features Breakdown

### 👤 User Roles & Dashboard
- **PLAYER:** Dashboard with "Quick Connect" teams and "Active Tickets" booking pass.
- **OWNER:** Full business KPI suite (Revenue stats, settlement tracking, listing mgmt).
- **ADMIN:** Central control for audit logs, global settings, platform-wide stats.

### 💳 Modern Booking Engine
- **Hybrid Payments:** Choose between Full Online or Offline/Cash with a ₹50 advance.
- **Real-time Availability:** Prevent double-booking for the same turf and time slot.
- **Digital Passes:** Confirmations come with beautiful, ticket-style layouts.

### 🏆 Social Teams & Competition
- **Squad Building:** Create teams, share 8-character invite codes, and manage rosters.
- **Tournament Engine:** Owners can create leagues; teams register/pay directly through the app.

---

## 🛠️ Project Structure

```text
.
├── backend-springboot/      # Java Spring Boot REST API
│   ├── src/main/java/       # Entities, Controllers, Services, DTOs
│   └── src/main/resources/  # Database migration & security config
├── solapur_turf_app/        # Flutter Mobile App
│   ├── lib/core/            # Global UI, Network, and Utils
│   └── lib/features/        # Domain-driven features (Auth, Booking, Owner)
├── database/                # PostgreSQL Schema & Indexes
└── README.md                # Project documentation
```

---

## ⚙️ Configuration & Environment

### 1. Database (PostgreSQL)
Ensure your `application.properties` matches your local setup:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/turf_db
spring.datasource.username=postgres
spring.datasource.password=your_password
```

### 2. Network (Flutter)
When running on physical devices, update your PC's LAN IP in `solapur_turf_app/lib/core/constants/app_constants.dart`:
```dart
static const String _deviceUrl = 'http://192.168.X.X:8080/api'; 
```

---

## � Troubleshooting

### Port 8080 Conflict
If the backend fails to start because port 8080 is Busy:
```powershell
# PowerShell command to kill the existing process
Get-NetTCPConnection -LocalPort 8080 -State Listen | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

### Connection Timeout (Mobile)
- Ensure your Phone and PC are on the **Same WiFi**.
- Check if your Windows Firewall is blocking Port 8080.
- Verify the `_deviceUrl` in `app_constants.dart` matches your current IP.

---

## 📜 Technical Details
- **Auth:** Stateless JWT Token with 24h expiry.
- **Currency:** INR (₹)
- **Booking Rule:** Minimum ₹50 advance required for offline bookings.
- **Audit Logs:** Track all Admin and System actions for accountability.

Developed with ❤️ for the Solapur Sports Community.