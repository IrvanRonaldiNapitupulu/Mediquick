# MediQuick 🏥

MediQuick adalah aplikasi kesehatan mobile berbasis Flutter yang dirancang untuk memberikan akses cepat dan terintegrasi terhadap berbagai layanan kesehatan digital. Aplikasi ini menghubungkan masyarakat, apotek, dan penyedia layanan kesehatan dalam satu ekosistem yang aman, responsif, dan mudah digunakan.

Aplikasi ini menggunakan arsitektur **Clean Architecture (Decoupled REST API)** dengan backend PHP server dan Flutter client.

---

## 🌟 Fitur Utama Aplikasi

MediQuick menyediakan fitur yang dikelompokkan berdasarkan hak akses pengguna (*Multi-Role*):

### 👤 1. Peran Pengguna (User / Pasien)
- **Apotek Online & Katalog Produk**: Pencarian obat dan produk kesehatan, penyaringan berdasarkan kategori/jenis, sistem keranjang belanja, checkout, serta pembayaran otomatis via **Midtrans Payment Gateway**.
- **Konsultasi & Chat Realtime**: Fitur obrolan langsung antara pasien dan pihak apotek untuk konsultasi obat dan ketersediaan stok.
- **Edukasi Kesehatan**: Akses artikel kesehatan terkini dan video edukasi pertolongan pertama.
- **Kelas & Kuis Interaktif**: Pembelajaran mandiri seputar kesehatan lengkap dengan modul dan kuis evaluasi.
- **Layanan Ambulans Darurat**: Deteksi lokasi GPS pengguna (*Geolocator & Reverse Geocoding*) untuk menemukan unit ambulans terdekat.

### 🏪 2. Peran Mitra Apotek (Pharmacy Role)
- **Dashboard Toko**: Monitoring ringkasan penjualan, riwayat pesanan masuk, dan obrolan pelanggan.
- **Manajemen Produk**: Tambah, edit, update stok, dan hapus katalog produk obat.
- **Pengolahan Pesanan**: Update status transaksi pembayaran dan pengiriman pesanan.

### 🛡️ 3. Peran Administrator (Admin Role)
- **Dashboard Statistik System**: Ringkasan jumlah pengguna, apotek terdaftar, total transaksi, dan modul edukasi.
- **Manajemen Mitra Apotek**: Pendaftaran dan verifikasi akun apotek baru.
- **Kelola Modul & Artikel**: Manajemen konten edukasi dan kuis interaktif secara terpusat.

---

## 🛠️ Tech Stack & Modul Utama

- **Frontend Framework**: Flutter 3.x (Dart 3 with Sound Null Safety)
- **State Management**: Provider Pattern
- **Network & REST API**: HTTP Package dengan `ApiClient` terpusat
- **Backend Architecture**: Decoupled PHP REST API (Server: `https://mediquick.my.id`)
- **Payment Gateway**: Midtrans Snap SDK / WebView Integration
- **Geolocation Service**: Geolocator & Geocoding
- **Penyimpanan Lokal**: Shared Preferences & Secure Storage

---

## 🚀 Petunjuk Instalasi & Setup Guide

Ikuti langkah-langkah berikut untuk menjalankan project MediQuick di lingkungan lokal Anda:

### 1. Prasyarat Sistem (Prerequisites)
Pastikan perangkat pengembangan Anda sudah terinstall:
- **Flutter SDK**: v3.19.0 atau yang lebih baru ([Panduan Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: ^3.7.2
- **Android Studio** atau **VS Code** (dengan Ekstensi Flutter & Dart)
- **Android Emulator** / **Perangkat HP Android** (USB Debugging aktif)

### 2. Kloning Repository
Buka terminal dan jalankan perintah berikut:
```bash
git clone https://github.com/KatoPrak/MediquickFinall.git
cd mediquick-main
```

### 3. Install Dependensi Project
Jalankan perintah ini untuk mengunduh semua paket dependensi yang dibutuhkan:
```bash
flutter pub get
```

### 4. Konfigurasi API Endpoint & Environment
Buka file `lib/core/constants/api_constants.dart` untuk memastikan endpoint backend sudah mengarah ke server yang aktif:
```dart
class ApiConstants {
  static const String baseUrl = 'https://mediquick.my.id';
  // Endpoint lainnya dikonfigurasi secara otomatis
}
```

### 5. Menjalankan Aplikasi (Development Mode)
Pastikan emulator Android sudah berjalan atau HP Android terhubung via kabel USB:
```bash
flutter run
```

### 6. Build Release APK (Production)
Untuk menghasilkan berkas instalan APK Android rilis:
```bash
flutter build apk --release
```
Berkas APK hasil build akan tersimpan di lokasi: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📁 Struktur Arsitektur Project

Proyek ini menerapkan **Clean Architecture & Separation of Concerns** untuk memudahkan pemeliharaan kode:

```
lib/
├── core/                   # Infrastruktur & Utility Terpusat
│   ├── constants/          # Constants API URL & App Config
│   ├── network/            # ApiClient terpusat, CorsConfig, & Exception
│   ├── security/           # InputSanitizer, InputValidator, & SecureStorage
│   ├── theme/              # Centralized AppTheme, Warna, & Style
│   └── utils/              # AppLogger terstruktur
├── models/                 # Data Models (User, Product, Order, Chat, dll)
├── services/               # Layer API Calls ke Backend PHP
├── providers/              # Layer Management State (Provider)
├── screens/                # Tampilan Halaman (UI Screen)
│   ├── account/            # Kelola Profil & Edit Akun
│   ├── admin/              # Dashboard & Fitur Admin
│   ├── ambulance/          # Halaman Ambulans & GPS
│   ├── apotek/             # Katalog & Detail Produk User
│   ├── apotek_role/        # Fitur Mitra Apotek
│   ├── auth/               # Login, Register, Lupa Password
│   ├── dashboard/          # Home Dashboard User
│   ├── edukasi/            # Artikel & Video Edukasi
│   ├── kelas/              # Kursus & Kuis Interaktif
│   └── payment/            # Checkout & Payment WebView
├── widgets/                # Reusable Component UI Widgets
└── main.dart               # Entry Point Utama Aplikasi
```

---

## 🔒 Standar Keamanan & Best Practices (OWASP Top 10)

MediQuick menerapkan prinsip dasar keamanan aplikasi web & mobile modern:
1. **Transport Layer Security (HTTPS)**: Penegakan enkripsi SSL/TLS pada seluruh jalur komunikasi API.
2. **Sanitasi & Validasi Input**: Menggunakan `InputSanitizer` dan `InputValidator` untuk mencegah Cross-Site Scripting (XSS) dan SQL Injection.
3. **Penyimpanan Sesi Aman**: Manajemen token dan data pengguna melalui `SecureStorageService` dengan fitur penanganan otomatis *Unauthorized* (`HTTP 401`).
4. **Konfigurasi CORS Aman**: Implementasi whitelisting domain dan penanganan `OPTIONS Preflight` pada client dan backend REST API.

---

## 👥 Pengembang & Kontributor Project

Terima kasih kepada tim pengembang dan kontributor yang membangun proyek MediQuick:

| NIM | Nama Pengembang |
| :--- | :--- |
| **4342201040** | Nabilla Meisya Firrandra |
| **4342201042** | Irvan Ronaldi Napitupulu |
| **4342201043** | Zahra Zen Marbun |
| **4342201047** | Neha Nabillah Putri Hasibuan |
| **4342201054** | Hammam Abror Rofif |

- **Praktikan Hands-On / Lead Developer**: IrvanRonaldiNapitupulu ([@IrvanRonaldiNapitupulu](https://github.com/KatoPrak))
- **Program Certification**: CFDA (Fullstack Developer Certification)
- **Repositori Utama**: [IrvanRonaldiNapitupulu/MediquickFinall](https://github.com/IrvanRonaldiNapitupulu/MediquickFinall)

---

### 📄 Lisensi
Hak Cipta © 2026 MediQuick Team.