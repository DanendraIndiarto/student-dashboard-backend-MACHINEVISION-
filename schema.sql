CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS app_settings (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    admin_name VARCHAR(100) NOT NULL,
    admin_email VARCHAR(100) NOT NULL,
    school_name VARCHAR(150) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    semester VARCHAR(10) NOT NULL CHECK (semester IN ('Ganjil', 'Genap')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO app_settings (id, admin_name, admin_email, school_name, academic_year, semester)
VALUES (1, 'Danendra Athallah', 'admin@smktelkom-mlg.sch.id', 'SMK Telkom Malang', '2026/2027', 'Ganjil')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nis VARCHAR(30) NOT NULL UNIQUE,
    nama VARCHAR(150) NOT NULL,
    kelas VARCHAR(30) NOT NULL,
    jenis_kelamin VARCHAR(15) NOT NULL CHECK (jenis_kelamin IN ('Laki-laki', 'Perempuan')),
    status VARCHAR(15) NOT NULL DEFAULT 'Aktif' CHECK (status IN ('Aktif', 'Tidak Aktif')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_students_nama ON students (nama);
CREATE INDEX IF NOT EXISTS idx_students_kelas ON students (kelas);
CREATE INDEX IF NOT EXISTS idx_students_status ON students (status);
