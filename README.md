# Student Dashboard API (Intern Task 1)

Dokumentasi & kontrak REST API untuk **Student Dashboard** dengan prefix `/nendra/dashboard`, dibangun menggunakan **PostgreSQL 16**, **Directus**, dan **Node-RED** di atas container **Docker**[cite: 3].

Repository ini merupakan implementasi sisi backend dari spesifikasi frontend [studentDashboard-InternTask1](https://github.com/queennurhafizah/studentDashboard-InternTask1).

## Cara Pakai (Untuk Tim Frontend)
1. Import file `Student Dashboard API (Intern Task 1).postman_collection.json` ke **Postman**[cite: 3].
2. Buka tab **Variables** pada Collection ini[cite: 3].
3. Sesuaikan nilai `base_url` (gunakan `http://localhost:1880` jika di lokal, atau ganti dengan IP/domain server backend)[cite: 3].
4. Pastikan variabel `api_prefix` bernilai `nendra/dashboard` (tanpa garis miring di depan) agar tidak terjadi double slash (`//`)[cite: 3].
5. Semua request menggunakan variabel `{{base_url}}/{{api_prefix}}` secara otomatis[cite: 3].

## Arsitektur & Tech Stack
- **Database:** PostgreSQL 16 (penyimpanan data relasional, constraint integritas, & agregasi statistik)
- **Headless CMS / Admin Panel:** Directus (manajemen Data Model & monitoring data)
- **API Gateway & Business Logic:** Node-RED (routing HTTP, validasi payload, query SQL, & handler CORS)
- **Containerization:** Docker
- **API Documentation:** Postman Collection v2.1[cite: 3]

```text
[ Frontend App ] ──(HTTP / JSON)──> [ Node-RED (:1880) ] ──(SQL)──> [ PostgreSQL 16 ]
                                                                          ▲
                                    [ Directus CMS (:8055) ] ─────────────┘
```

## Struktur Repository
```text
├── schema.sql                                                      # Skema database PostgreSQL (tabel, index, & seed data)
├── nodered-flows.json                                              # Flow endpoint REST API Node-RED
├── Student Dashboard API (Intern Task 1).postman_collection.json   # Dokumentasi Postman Collection v2.1
└── README.md                                                       # Dokumentasi proyek
```

## Struktur Database

### 1. `app_settings` (Singleton)
Menyimpan informasi pengguna (`admin_name`, `admin_email`) dan informasi sekolah (`school_name`, `academic_year`, `semester`) dengan batasan hanya 1 baris data (`id = 1`)[cite: 3].

| Kolom | Tipe Data | Constraint | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `INT` | `PRIMARY KEY`, `DEFAULT 1`, `CHECK (id = 1)` | ID tunggal konfigurasi |
| `admin_name` | `VARCHAR(100)` | `NOT NULL` | Nama admin pada sapaan dashboard |
| `admin_email` | `VARCHAR(100)` | `NOT NULL` | Email admin |
| `school_name` | `VARCHAR(150)` | `NOT NULL` | Nama sekolah |
| `academic_year` | `VARCHAR(20)` | `NOT NULL` | Tahun ajaran aktif (contoh: `2026/2027`)[cite: 3] |
| `semester` | `VARCHAR(10)` | `NOT NULL`, `CHECK ('Ganjil', 'Genap')` | Semester aktif |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu pembaruan terakhir |

### 2. `students`
Menyimpan seluruh data siswa beserta constraint keunikan NIS dan index pencarian (`nama`, `kelas`, `status`).

| Kolom | Tipe Data | Constraint | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY`, `DEFAULT uuid_generate_v4()` | ID unik siswa[cite: 3] |
| `nis` | `VARCHAR(30)` | `NOT NULL`, `UNIQUE` | Nomor Induk Siswa (tidak boleh duplikat)[cite: 3] |
| `nama` | `VARCHAR(150)` | `NOT NULL` | Nama lengkap siswa |
| `kelas` | `VARCHAR(30)` | `NOT NULL` | Kelas siswa (contoh: `XII RPL 1`)[cite: 3] |
| `jenis_kelamin` | `VARCHAR(15)` | `NOT NULL`, `CHECK ('Laki-laki', 'Perempuan')` | Jenis kelamin siswa |
| `status` | `VARCHAR(15)` | `NOT NULL`, `DEFAULT 'Aktif'`, `CHECK ('Aktif', 'Tidak Aktif')` | Status keaktifan siswa |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu data dibuat |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Waktu pembaruan terakhir |

## Daftar Endpoint API
Base URL: `http://localhost:1880/nendra/dashboard`[cite: 3]

### 1. Dashboard
Endpoint untuk halaman utama Dashboard (sapaan admin, statistik, 5 siswa teratas, dan siswa tidak aktif)[cite: 3].

| Method | Endpoint | Nama Request di Postman | Deskripsi |
| :--- | :--- | :--- | :--- |
| `GET` | `/overview` | **Get Dashboard Overview** | Mengambil sapaan admin (nama, tahun ajaran, semester), 4 kartu statistik, 5 siswa teratas, dan daftar siswa Tidak Aktif[cite: 3]. |

### 2. Data Siswa
CRUD Data Siswa beserta fitur pencarian (*search*) dan *pagination* (5 atau 10 baris)[cite: 3].

| Method | Endpoint | Nama Request di Postman | Deskripsi |
| :--- | :--- | :--- | :--- |
| `GET` | `/students` | **Get All Students (Search & Pagination)** | Mengambil daftar siswa dengan server-side pagination (`5` atau `10` baris) dan pencarian berdasarkan `nama`, `nis`, `kelas`, atau `jenis_kelamin`[cite: 3]. |
| `POST` | `/students` | **Create Student** | Menambahkan data siswa baru (semua field wajib diisi & NIS tidak boleh duplikat; otomatis menyimpan `student_id` ke variabel Postman)[cite: 3]. |
| `PATCH` | `/students/:id` | **Update Student** | Memperbarui data siswa berdasarkan UUID pada variabel `{{student_id}}`[cite: 3]. |
| `DELETE` | `/students/:id` | **Delete Student** | Menghapus data siswa berdasarkan UUID pada variabel `{{student_id}}`[cite: 3]. |

### 3. Pengaturan
Endpoint untuk membaca dan menyimpan pengaturan informasi admin dan sekolah[cite: 3].

| Method | Endpoint | Nama Request di Postman | Deskripsi |
| :--- | :--- | :--- | :--- |
| `GET` | `/settings` | **Get Settings** | Mengambil informasi pengguna (`admin_name`, `admin_email`) dan informasi sekolah[cite: 3]. |
| `PATCH` | `/settings` | **Update Settings** | Menyimpan perubahan informasi admin dan sekolah[cite: 3]. |

## Spesifikasi Request & Response

### 1. `GET /overview`
Mengembalikan ringkasan sapaan admin, 4 kartu statistik, 5 siswa teratas, dan daftar siswa Tidak Aktif (`200 OK`)[cite: 3]:

```json
{
  "success": true,
  "data": {
    "greeting": {
      "admin_name": "Danendra Indiarto",
      "school_name": "SMK Telkom Malang",
      "academic_year": "2026/2027",
      "semester": "Genap"
    },
    "stats": {
      "total_siswa": 5,
      "siswa_perempuan": 1,
      "siswa_laki_laki": 4,
      "total_kelas": 5
    },
    "top_students": [
      {
        "id": "6e2ea91e-2e4d-4b83-bd7f-e74067a95ba8",
        "nis": "24251002",
        "nama": "Danendra Athallah Indiarto",
        "kelas": "XII RPL 1",
        "jenis_kelamin": "Laki-laki",
        "status": "Aktif"
      },
      {
        "id": "4a6e5b25-164e-4814-9825-1b3049fc86c0",
        "nis": "24251004",
        "nama": "Raka Pratama",
        "kelas": "XII TKJ 1",
        "jenis_kelamin": "Laki-laki",
        "status": "Aktif"
      },
      {
        "id": "0ad897ed-1637-4d2e-893b-e86b8936909d",
        "nis": "24251006",
        "nama": "Budi Santoso",
        "kelas": "XII RPL 2",
        "jenis_kelamin": "Laki-laki",
        "status": "Tidak Aktif"
      },
      {
        "id": "67301e4d-0e35-4c1c-82d0-0dfb643bec0c",
        "nis": "24251001",
        "nama": "Assyafa Dhiya Hayyanudy",
        "kelas": "X RPL 6",
        "jenis_kelamin": "Perempuan",
        "status": "Aktif"
      },
      {
        "id": "b59a0411-e6fd-428c-b097-46a3ab56b286",
        "nis": "24251015",
        "nama": "Qomuna Illahia",
        "kelas": "XII RPL 4",
        "jenis_kelamin": "Laki-laki",
        "status": "Aktif"
      }
    ],
    "inactive_students": [
      {
        "id": "0ad897ed-1637-4d2e-893b-e86b8936909d",
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

### 2. `GET /students?page={{page}}&limit={{limit}}&search={{search_query}}`
- **Query Parameters:**
  - `page` *(default: `1`)* — Nomor halaman[cite: 3]
  - `limit` *(default: `5`)* — Jumlah baris per halaman: `5` atau `10`[cite: 3]
  - `search` *(default: `""`)* — Pencarian berdasarkan nama, NIS, kelas, atau jenis kelamin[cite: 3]
- **Response (`200 OK`):**

```json
{
  "success": true,
  "data": [
    {
      "id": "6e2ea91e-2e4d-4b83-bd7f-e74067a95ba8",
      "nis": "24251002",
      "nama": "Danendra Athallah Indiarto",
      "kelas": "XII RPL 1",
      "jenis_kelamin": "Laki-laki",
      "status": "Aktif"
    },
    {
      "id": "4a6e5b25-164e-4814-9825-1b3049fc86c0",
      "nis": "24251004",
      "nama": "Raka Pratama",
      "kelas": "XII TKJ 1",
      "jenis_kelamin": "Laki-laki",
      "status": "Aktif"
    },
    {
      "id": "0ad897ed-1637-4d2e-893b-e86b8936909d",
      "nis": "24251006",
      "nama": "Budi Santoso",
      "kelas": "XII RPL 2",
      "jenis_kelamin": "Laki-laki",
      "status": "Tidak Aktif"
    },
    {
      "id": "67301e4d-0e35-4c1c-82d0-0dfb643bec0c",
      "nis": "24251001",
      "nama": "Assyafa Dhiya Hayyanudy",
      "kelas": "X RPL 6",
      "jenis_kelamin": "Perempuan",
      "status": "Aktif"
    },
    {
      "id": "b59a0411-e6fd-428c-b097-46a3ab56b286",
      "nis": "24251015",
      "nama": "Qomuna Illahia",
      "kelas": "XII RPL 4",
      "jenis_kelamin": "Laki-laki",
      "status": "Aktif"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 5,
    "total_items": 5,
    "total_pages": 1
  }
}
```

### 3. `POST /students`
- **Request Body (`application/json`):**[cite: 3]

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
    "id": "b59a0411-e6fd-428c-b097-46a3ab56b286",
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

### 4. `PATCH /students/{{student_id}}`
- **Request Body (`application/json`):**[cite: 3]

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
    "id": "b59a0411-e6fd-428c-b097-46a3ab56b286",
    "nis": "24251015",
    "nama": "Raka Pratama Putra",
    "kelas": "XII RPL 2",
    "jenis_kelamin": "Laki-laki",
    "status": "Tidak Aktif"
  }
}
```

### 5. `DELETE /students/{{student_id}}`
- **Response Sukses (`200 OK`):**

```json
{
  "success": true,
  "message": "Data siswa berhasil dihapus"
}
```

### 6. `GET /settings` & `PATCH /settings`
- **Request Body `PATCH` (`application/json`):**[cite: 3]

```json
{
  "admin_name": "Danendra Indiarto",
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
    "admin_name": "Danendra Indiarto",
    "admin_email": "danendra@smktelkom-mlg.sch.id",
    "school_name": "SMK Telkom Malang",
    "academic_year": "2026/2027",
    "semester": "Genap"
  }
}
```

## Postman Collection Variables
| Variabel | Default Value | Keterangan |
| :--- | :--- | :--- |
| `base_url` | `http://localhost:1880` | Host & port server Node-RED[cite: 3] |
| `api_prefix` | `nendra/dashboard` | Prefix endpoint API (gunakan tanpa `/` di awal agar tidak double slash) |
| `auth_token` | `<STATIC_TOKEN_DIRECTUS>` | Bearer Token autentikasi Directus[cite: 3] |
| `student_id` | `6e2ea91e-2e4d-4b83-bd7f-e74067a95ba8` | UUID siswa aktif (otomatis diperbarui oleh test script saat `Create Student` sukses `201`)[cite: 3] |
| `page` | `1` | Halaman default pagination[cite: 3] |
| `limit` | `5` | Jumlah baris default (`5` atau `10`)[cite: 3] |
| `search_query` | `""` | Kata kunci pencarian siswa[cite: 3] |

## Panduan Setup Backend
1. Pastikan container Docker **PostgreSQL**, **Directus**, dan **Node-RED** aktif (`docker ps`).
2. Jalankan query SQL pada `schema.sql` ke database PostgreSQL.
3. Buka **Directus (`http://localhost:8055`) → Settings → Data Model**, lalu aktifkan tabel `app_settings` (centang **Singleton**) dan `students`.
4. Import `nodered-flows.json` ke **Node-RED (`http://localhost:1880`)**, sesuaikan kredensial node PostgreSQL, lalu klik **Deploy**.

---
**Author:** Danendra Athallah Indiarto — Magang Backend Developer MACHINE VISION (SMK Telkom Malang)
