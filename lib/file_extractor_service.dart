import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileExtractorService {
  

  static Future<String> extractFromTxt(String filePath) async {
    try {
      final file = File(filePath);


      if (!await file.exists()) {
        return 'Error: File tidak ditemukan';
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        return 'Error: File terlalu besar (maksimal 5MB)';
      }

      final content = await file.readAsString();
      return content.trim();
    } catch (e) {
      return 'Error: Gagal membaca file TXT';
    }
  }

  static Future<String> extractFromPdf(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return 'Error: File tidak ditemukan';
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return 'Error: File PDF terlalu besar (maksimal 10MB)';
      }

      final bytes = await file.readAsBytes();

      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();

      document.dispose();

      if (text.trim().isEmpty) {
        return 'Error: PDF tidak mengandung teks yang bisa dibaca.\n'
            'Kemungkinan PDF berisi gambar scan — coba upload sebagai gambar.';
      }

      return text.trim();
    } catch (e) {
      return 'Error: Gagal membaca file PDF';
    }
  }

  static Future<String> extractFromImage(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return 'Error: File tidak ditemukan';
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return 'Error: Gambar terlalu besar (maksimal 10MB)';
      }

      final extension = filePath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'bmp', 'gif', 'webp'].contains(extension)) {
        return 'Error: Format gambar tidak didukung';
      }

      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final inputImage = InputImage.fromFilePath(filePath);

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      final result = recognizedText.text.trim();

      if (result.isEmpty) {
        return 'Error: Tidak ada teks yang terdeteksi pada gambar';
      }

      return result;
    } catch (e) {
      return 'Error: Gagal memproses gambar OCR';
    }
  }

  static Future<String> extractText(String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'txt':
        return await extractFromTxt(filePath);
      case 'pdf':
        return await extractFromPdf(filePath);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'bmp':
      case 'webp':
        return await extractFromImage(filePath);
      default:
        return 'Error: Format file tidak didukung.\n'
            'Gunakan: TXT, PDF, JPG, atau PNG';
    }
  }
}