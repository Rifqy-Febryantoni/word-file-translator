# Words and Files Translator App (English to Indonesian only)

Aplikasi mobile sederhana untuk menerjemahkan teks bahasa Inggris ke bahasa Indonesia.
Bisa langsung ketik teks, atau upload file dari HP kamu.

---

## Fitur

- **Ketik langsung** - tulis teks bahasa Inggris dan langsung terjemahkan
- **Upload file TXT** - buka file teks dari penyimpanan HP
- **Upload file PDF** - ekstrak dan terjemahkan isi dokumen PDF
- **Upload gambar (JPG/PNG)** - baca tulisan dari foto secara otomatis (OCR)
- **Hasil bisa di-copy** - tekan dan tahan teks hasil terjemahan untuk menyalin

---

## Teknologi AI yang Digunakan

| Fitur | Teknologi | Koneksi |
|---|---|---|
| Baca tulisan dari gambar | Google ML Kit | Offline |
| Terjemahan | MyMemory API | Online |

> Untuk fitur terjemahan, HP perlu terhubung ke internet.
> Untuk baca gambar (OCR), bisa digunakan tanpa internet.

---

## Cara Pakai

1. **Buka aplikasi**
2. Pilih salah satu cara input:
   - Ketik teks langsung di kolom yang tersedia, **atau**
   - Tekan tombol **Upload File** dan pilih file TXT, PDF, atau gambar
3. Tekan tombol **Terjemahkan**
4. Hasil terjemahan akan muncul di bawah

---

## Batasan

- Maksimal **3000 karakter** per terjemahan
- Ukuran file maksimal **10MB**
- Format file yang didukung: `.txt`, `.pdf`, `.jpg`, `.jpeg`, `.png`
- PDF yang berupa hasil scan (gambar) tidak bisa dibaca, gunakan upload gambar sebagai gantinya
- Terjemahan hanya mendukung **Inggris ke Indonesia**

---

## Dibuat Dengan

- [Google ML Kit](https://developers.google.com/ml-kit) - OCR / baca teks dari gambar
- [MyMemory API](https://mymemory.translated.net) - layanan terjemahan gratis
- [Syncfusion PDF](https://www.syncfusion.com/flutter-widgets/flutter-pdf) - baca file PDF

---

## Struktur File

```
lib/
├── main.dart                    -> Tampilan utama aplikasi
├── translator_service.dart      -> Koneksi ke API terjemahan
└── file_extractor_service.dart  -> Proses baca TXT, PDF, dan gambar
```
