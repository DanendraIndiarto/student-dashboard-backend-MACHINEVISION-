# Student Dashboard API (Intern Task 1)

Backend REST API, skema database, dan dokumentasi Postman untuk aplikasi **Student Dashboard**, dibangun menggunakan **PostgreSQL 16**, **Directus**, dan **Node-RED** di atas container **Docker**.

Repository ini merupakan implementasi sisi backend dari spesifikasi frontend [studentDashboard-InternTask1](https://github.com/queennurhafizah/studentDashboard-InternTask1).

## Arsitektur & Tech Stack
- **Database:** PostgreSQL 16 (penyimpanan data relasional, constraint integritas, & agregasi statistik)
- **Headless CMS / Admin Panel:** Directus (manajemen Data Model & monitoring data)
- **API Gateway & Business Logic:** Node-RED (routing HTTP, validasi payload, query SQL, & handler CORS)
- **Containerization:** Docker
- **API Documentation:** Postman Collection v2.1

```text
[ Frontend App ] ──(HTTP / JSON)──> [ Node-RED (:1880) ] ──(SQL)──> [ PostgreSQL 16 ]
                                                                          ▲
                                    [ Directus CMS (:8055) ] ─────────────┘
```

## Struktur Repository
```text
├── schema.sql                                      # Skema database PostgreSQL (tabel, index, & seed data)
├── nodered-flows.json                              # Flow endpoint REST API Node-RED
├── Student_Dashboard_API.postman_collection.json   # Dokumentasi Postman lengkap dengan Saved Examples
└── README.md                                       # Dokumentasi proyek
```

## Struktur Database

### 1. `app_settings` (Singleton)
Menyimpan profil admin dan konfigurasi informasi sekolah (dibatasi hanya 1 baris data dengan `id = 1`).

| Kolom | Tipe Data | Constraint | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | `PRIMARY KEY`, `DEFAULT 1`, `CHECK (id = 1)` | ID tunggal konfigurasi |
| `admin_name` | `VARCHAR(100)` | `NOT NULL` | Nama admin pada sapaan dashboard |
| `admin_email` | `VARCHAR(100)` | `NOT NULL` | Email admin |
| `school_name` | `VARCHAR(150)` | `NOT NULL` | Nama sekolah |
| `academic_year` | `VARCHAR(20)` | `NOT NULL` | Tahun ajaran aktif (contoh: `2026/2027`) |
| `semester` | `VARCHAR(10)` | `NOT NULL`, `CHECK ('Ganjil', 'Genap')` | Semester aktif |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu pembaruan terakhir |

### 2. `students`
Menyimpan seluruh data siswa beserta constraint keunikan NIS dan index pencarian (`nama`, `kelas`, `status`).

| Kolom | Tipe Data | Constraint | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY`, `DEFAULT uuid_generate_v4()` | ID unik siswa |
| `nis` | `VARCHAR(30)` | `NOT NULL`, `UNIQUE` | Nomor Induk Siswa (tidak boleh ganda) |
| `nama` | `VARCHAR(150)` | `NOT NULL` | Nama lengkap siswa |
| `kelas` | `VARCHAR(30)` | `NOT NULL` | Kelas siswa (contoh: `XII RPL 1`) |
| `jenis_kelamin` | `VARCHAR(15)` | `NOT NULL`, `CHECK ('Laki-laki', 'Perempuan')` | Jenis kelamin siswa |
| `status` | `VARCHAR(15)` | `NOT NULL`, `DEFAULT 'Aktif'`, `CHECK ('Aktif', 'Tidak Aktif')` | Status keaktifan siswa |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu data dibuat |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu pembaruan terakhir |

## Daftar Endpoint API
Base URL: `http://localhost:1880/nendra/dashboard`

| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| `GET` | `/overview` | Sapaan admin, 4 kartu statistik, 5 siswa teratas, & daftar siswa tidak aktif |
| `GET` | `/students` | Daftar siswa dengan *search* & *server-side pagination* (`?page=1&limit=5&search=`) |
| `POST` | `/students` | Menambahkan data siswa baru (validasi wajib isi & anti-duplikat NIS) |
| `PATCH` | `/students/:id` | Memperbarui data siswa berdasarkan `id` (UUID) |
| `DELETE` | `/students/:id` | Menghapus data siswa berdasarkan `id` (UUID) |
| `GET` | `/settings` | Mengambil pengaturan profil admin dan sekolah |
| `PATCH` | `/settings` | Menyimpan perubahan pengaturan profil admin dan sekolah |

## Spesifikasi Request & Response

### 1. `GET /overview`
Mengembalikan ringkasan sapaan, statistik siswa, 5 siswa teratas, dan daftar siswa tidak aktif (`200 OK`):

```json
{
  "success": true,
  "data": {
    "greeting": {
      "admin_name": "Danendra Athallah",
      "school_name": "SMK Telkom Malang",
      "academic_year": "2026/2027",
      "semester": "Ganjil"
    },
    "stats": {
      "total_siswa": 6,
      "siswa_perempuan": 3,
      "siswa_laki_laki": 3,
      "total_kelas": 4
    },
    "top_students": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "nis": "24251001",
        "nama": "Assyafa Dhiya Hayyanudy",
        "kelas": "XII RPL 1",
        "jenis_kelamin": "Perempuan",
        "status": "Aktif"
      }
    ],
    "inactive_students": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440006",
        "nis": "24251006",
        "nama": "Budi Santoso",
        "kelas": "XII RPL 2",
        "jenis_kelamin": "Laki-laki",
        "status": "Tidak Aktif"
      }
    ]
  }
}
```

### 2. `GET /students?page=1&limit=5&search=`
- **Query Params:**
  - `page` *(opsional, default: `1`)* — Nomor halaman
  - `limit` *(opsional, default: `5`)* — Jumlah baris per halaman (`5` atau `10`)
  - `search` *(opsional)* — Pencarian berdasarkan `nama`, `nis`, `kelas`, atau `jenis_kelamin`
- **Response (`200 OK`):**

```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "nis": "24251001",
      "nama": "Assyafa Dhiya Hayyanudy",
      "kelas": "XII RPL 1",
      "jenis_kelamin": "Perempuan",
      "status": "Aktif"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 5,
    "total_items": 6,
    "total_pages": 2
  }
}
```

### 3. `POST /students`
- **Request Body (`application/json`):**

```json
{
  "nis": "24251015",
  "nama": "Raka Pratama",
  "kelas": "XII RPL 1",
  "jenis_kelamin": "Laki-laki",
  "status": "Aktif"
}
```

- **Response Sukses (`201 Created`):**

```json
{
  "success": true,
  "message": "Data siswa berhasil ditambahkan",
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "nis": "24251015",
    "nama": "Raka Pratama",
    "kelas": "XII RPL 1",
    "jenis_kelamin": "Laki-laki",
    "status": "Aktif"
  }
}
```

- **Error Validasi / Duplikat NIS (`400 Bad Request`):**

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "nis": "NIS sudah terdaftar pada siswa lain"
  }
}
```

### 4. `PATCH /students/:id`
- **Request Body (`application/json`):**

```json
{
  "nis": "24251015",
  "nama": "Raka Pratama Putra",
  "kelas": "XII RPL 2",
  "jenis_kelamin": "Laki-laki",
  "status": "Tidak Aktif"
}
```

- **Response Sukses (`200 OK`):**

```json
{
  "success": true,
  "message": "Data siswa berhasil diperbarui",
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "nis": "24251015",
    "nama": "Raka Pratama Putra",
    "kelas": "XII RPL 2",
    "jenis_kelamin": "Laki-laki",
    "status": "Tidak Aktif"
  }
}
```

### 5. `DELETE /students/:id`
- **Response Sukses (`200 OK`):**

```json
{
  "success": true,
  "message": "Data siswa berhasil dihapus"
}
```

### 6. `GET /settings` & `PATCH /settings`
- **Request Body (`PATCH`):**

```json
{
  "admin_name": "Danendra Athallah",
  "admin_email": "danendra@smktelkom-mlg.sch.id",
  "school_name": "SMK Telkom Malang",
  "academic_year": "2026/2027",
  "semester": "Genap"
}
```

- **Response Sukses (`200 OK`):**

```json
{
  "success": true,
  "message": "Pengaturan berhasil disimpan",
  "data": {
    "admin_name": "Danendra Athallah",
    "admin_email": "danendra@smktelkom-mlg.sch.id",
    "school_name": "SMK Telkom Malang",
    "academic_year": "2026/2027",
    "semester": "Genap"
  }
}
```

## Panduan Setup & Verifikasi

### 1. Setup Backend (Server)
1. Pastikan container Docker **PostgreSQL**, **Directus**, dan **Node-RED** berjalan aktif (`docker ps`).
2. Jalankan query SQL pada `schema.sql` ke database PostgreSQL.
3. Buka **Directus (`http://localhost:8055`) → Settings → Data Model**, lalu aktifkan tabel `app_settings` (centang **Singleton**) dan `students`.
4. Import `nodered-flows.json` ke **Node-RED (`http://localhost:1880`)**, sesuaikan kredensial node PostgreSQL, lalu klik **Deploy**.

### 2. Verifikasi & Integrasi Frontend (Postman)
1. Import `Student_Dashboard_API.postman_collection.json` ke **Postman**.
2. Buka tab **Variables** pada collection tersebut:
   - `base_url`: `http://localhost:1880` *(atau ubah ke `http://<IP_SERVER_BACKEND>:1880` jika diakses melalui jaringan LAN/Wi-Fi)*.
   - `api_prefix`: `nendra/dashboard`
3. Verifikasi seluruh endpoint (`GET /overview`, CRUD `/students`, validasi NIS duplikat `400 Bad Request`, serta `GET/PATCH /settings`). Seluruh request sudah dilengkapi **Saved Examples** agar contoh response tetap terbaca saat offline.

---
**Author:** Danendra Athallah Indiarto — Magang Backend Developer Machine Vision (SMK Telkom Malang)
