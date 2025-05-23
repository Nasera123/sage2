Baik, ini adalah versi PRD yang telah dimodifikasi untuk fokus pada aplikasi frontend saja, tanpa database backend atau sinkronisasi cloud. Penyimpanan data akan dilakukan secara lokal di perangkat pengguna.

---

**Dokumen Kebutuhan Produk (PRD)**

**Nama Proyek:** SAGE (Edisi Lokal)
**Kategori:** Aplikasi Mobile Pencatat Digital Lokal (Local Note-Taking Application)

## 1. Ringkasan Produk (Apa dan Mengapa)

### 1.1 Ikhtisar
Dokumen ini mendefinisikan kebutuhan untuk aplikasi pencatat digital bernama SAGE (Edisi Lokal). Aplikasi ini memungkinkan pengguna untuk membuat, mengedit, dan mengorganisasi catatan **langsung di perangkat mobile mereka**. SAGE dikembangkan sebagai solusi komprehensif untuk manajemen catatan dengan fitur-fitur seperti editor teks kaya, pengelolaan tag, folder untuk organisasi, dan pengaturan buku untuk catatan terstruktur, dengan semua data disimpan secara lokal.

### 1.2 Latar Belakang dan Konteks
Di era digital yang serba cepat, kebutuhan akan aplikasi pencatat yang efisien dan fleksibel tetap tinggi. Banyak pengguna membutuhkan platform untuk menyimpan ide, catatan, dan informasi penting dengan akses cepat di perangkat mereka. Aplikasi pencatat yang ada saat ini sering kali memiliki keterbatasan dalam hal kemampuan organisasi atau format konten, atau mungkin memaksa penggunaan cloud yang tidak selalu diinginkan pengguna yang memprioritaskan privasi atau penggunaan offline.

SAGE (Edisi Lokal) hadir untuk memenuhi kebutuhan ini dengan menawarkan pengalaman pencatatan komprehensif yang memadukan kekuatan editor teks kaya (rich text), organisasi yang fleksibel melalui tag dan folder, **dengan penyimpanan data yang sepenuhnya lokal di perangkat pengguna.**

## 2. Kriteria Keberhasilan / Dampak

### 2.1 Metrik untuk Mengukur Keberhasilan
- **Akuisisi Pengguna**: Jumlah unduhan aplikasi.
- **Retensi Pengguna**: Persentase pengguna yang kembali menggunakan aplikasi setelah 7 dan 30 hari.
- **Engagement**: Rata-rata jumlah catatan yang dibuat per pengguna per bulan.
- **Ketahanan Produk**: Jumlah crash per 1000 sesi pengguna.
- **Penggunaan Fitur Utama**: Persentase pengguna yang menggunakan fitur tag, folder, dan buku.

### 2.2 Metrik yang Perlu Dipantau
- **Performa Aplikasi**: Waktu muat untuk editor catatan dan daftar catatan.
- **Penggunaan Penyimpanan Lokal**: Ukuran rata-rata catatan dan total penggunaan penyimpanan aplikasi di perangkat.
- **Stabilitas Aplikasi**: Frekuensi aplikasi berhenti mendadak atau error.

## 3. Tim

- **Product Manager**: [Nama]
- **UI/UX Designer**: [Nama]
- **Frontend Developer (Flutter)**: [Nama]
- **QA Engineer**: [Nama]

## 4. Desain Solusi

### 4.1 Kebutuhan Fungsional

#### Manajemen Pengguna (Lokal)
- Pengguna dapat mempersonalisasi aplikasi (misalnya, nama pengguna lokal untuk tampilan, avatar lokal).
- Tidak ada proses registrasi atau login berbasis server. Identitas pengguna terikat pada instalasi aplikasi di perangkat.

#### Manajemen Catatan (Lokal)
- Pengguna dapat membuat catatan baru dengan judul dan konten.
- Pengguna dapat mengedit catatan dengan editor teks kaya (rich text editor).
- Pengguna dapat menyisipkan gambar (disimpan lokal), daftar, dan format teks dalam catatan.
- Pengguna dapat menghapus catatan (memindahkan ke tempat sampah lokal).
- Pengguna dapat memulihkan catatan dari tempat sampah lokal.
- Pengguna dapat menghapus catatan secara permanen dari perangkat.

#### Organisasi Catatan (Lokal)
- Pengguna dapat membuat dan mengelola folder untuk mengategorikan catatan di penyimpanan lokal.
- Pengguna dapat membuat dan menetapkan tag ke catatan untuk pengorganisasian lintas kategori.
- Pengguna dapat mencari catatan berdasarkan judul, konten, tag, atau folder di dalam data lokal.
- Pengguna dapat melihat daftar semua catatan, difilter berdasarkan folder atau tag.

#### Fitur Buku (Lokal)
- Pengguna dapat membuat buku untuk mengorganisir catatan terkait.
- Pengguna dapat menambahkan dan menghapus halaman (catatan) dalam buku.
- Pengguna dapat mengatur urutan halaman dalam buku.
- Pengguna dapat menetapkan gambar sampul untuk buku (gambar disimpan lokal).

#### Fitur Media (Lokal)
- Pengguna dapat menyisipkan dan mengelola gambar dalam catatan (gambar disimpan lokal bersama catatan).
- Pengguna dapat menyematkan dan mendengarkan file musik yang ada di perangkat saat menulis catatan (akses ke pustaka musik lokal, tidak menyimpan musik dalam aplikasi).

#### Ekspor dan Impor Data (Opsional, untuk Backup)
- Pengguna dapat mengekspor semua data catatan (termasuk struktur folder, tag) ke satu file backup lokal (misalnya, format JSON atau ZIP).
- Pengguna dapat mengimpor data catatan dari file backup yang sebelumnya dibuat.

#### Pengaturan Aplikasi
- Pengguna dapat mengubah tema aplikasi (terang/gelap).
- Pengguna dapat mengatur preferensi bahasa.

### 4.2 Kebutuhan Non-Fungsional
- **Keamanan**: Data pengguna di perangkat harus dilindungi sejauh mungkin oleh mekanisme keamanan sistem operasi. Jika memungkinkan, enkripsi data lokal dapat dipertimbangkan.
- **Performa**: Aplikasi harus merespon input pengguna dalam waktu kurang dari 200ms.
- **Skalabilitas Lokal**: Aplikasi harus mampu menangani hingga 10.000 catatan per pengguna (tergantung kapasitas penyimpanan perangkat).
- **Stabilitas**: Aplikasi harus stabil dan minim crash.
- **Kompatibilitas**: Aplikasi harus berjalan pada perangkat Android dan iOS terbaru.

## 5. Implementasi

### 5.1 Dokumen Desain Teknis
Aplikasi SAGE (Edisi Lokal) menggunakan arsitektur berbasis Flutter:
- **Frontend**: Flutter dengan GetX untuk state management.
- **Penyimpanan Lokal**: Menggunakan solusi penyimpanan lokal di Flutter (misalnya, SQLite, Hive, atau penyimpanan file langsung) untuk data catatan, tag, folder, dan metadata media. Gambar akan disimpan dalam direktori aplikasi yang aman.

#### Komponen Utama:
1.  **Modul Note Editor**:
    *   Editor teks kaya menggunakan Flutter Quill.
    *   Dukungan untuk format teks, daftar, dan penyisipan gambar lokal.
    *   Penyimpanan perubahan secara otomatis ke penyimpanan lokal.

2.  **Modul Organisasi**:
    *   Pengelolaan folder (CRUD operasi di penyimpanan lokal).
    *   Pengelolaan tag (CRUD operasi di penyimpanan lokal).
    *   Fungsi pencarian dan filter pada data lokal.

3.  **Modul Buku**:
    *   Pembuatan dan pengelolaan buku (struktur disimpan lokal).
    *   Organisasi halaman (referensi ke catatan).

4.  **Modul Media**:
    *   Manajemen gambar (penyimpanan dan pengambilan gambar dari/ke penyimpanan lokal).
    *   Akses ke pemutar musik lokal perangkat (jika diizinkan).

5.  **Modul Manajemen Data Lokal**:
    *   Logika untuk menyimpan, mengambil, memperbarui, dan menghapus data dari penyimpanan lokal (SQLite, Hive, dll.).
    *   (Opsional) Fungsi untuk ekspor dan impor data.

### 5.2 Rencana Pengujian dan QA

#### Unit Testing
- Pengujian komponen individu dan fungsi inti aplikasi (misalnya, logika editor, fungsi CRUD untuk catatan/folder/tag pada mock storage).
- Pengujian validasi input dan logika bisnis.

#### Integration Testing
- Pengujian integrasi antar modul frontend dan dengan lapisan penyimpanan lokal.
- Pengujian alur kerja penyimpanan dan pengambilan data.

#### End-to-End Testing
- Alur pengguna dari pembukaan aplikasi pertama kali hingga pembuatan, pengeditan, pengorganisasian, dan penghapusan catatan.
- Pengujian fitur ekspor dan impor (jika diimplementasikan).

#### Performance Testing
- Kinerja aplikasi dengan jumlah catatan yang besar di penyimpanan lokal.
- Waktu respons dan efisiensi memori pada berbagai perangkat.
- Pengujian penggunaan ruang penyimpanan.

## 6. Dampak
Implementasi SAGE (Edisi Lokal) akan memberikan solusi pencatatan yang modern, efisien, dan privat bagi pengguna. Aplikasi ini akan membantu pengguna mengorganisir informasi mereka secara lebih baik, dengan semua data tersimpan aman **di perangkat mereka sendiri**. Ini memberikan kontrol penuh kepada pengguna atas data mereka.

Risiko potensial termasuk **kehilangan data jika perangkat rusak atau hilang** (jika pengguna tidak melakukan backup eksternal melalui fitur ekspor), dan **batasan penyimpanan pada perangkat pengguna**.
Mitigasi dapat mencakup **penyediaan fitur ekspor/impor data yang mudah digunakan** untuk backup manual oleh pengguna, dan pengoptimalan penggunaan penyimpanan lokal.

## 7. Catatan
- Implementasi awal akan fokus pada fitur inti pencatatan dan organisasi dengan penyimpanan lokal.
- Fitur ekspor/impor data sangat direkomendasikan untuk ditambahkan guna mitigasi risiko kehilangan data.
- Fitur penyematan audio (selain akses ke pemutar musik lokal) dan video dipertimbangkan untuk pengembangan masa depan, dengan memperhatikan implikasi penyimpanan lokal.
- Aplikasi ini sepenuhnya offline, tidak ada fungsionalitas yang bergantung pada koneksi internet kecuali untuk pembaruan aplikasi itu sendiri.

---