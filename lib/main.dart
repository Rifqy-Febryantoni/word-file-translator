import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'translator_service.dart';
import 'file_extractor_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EN → ID Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TranslatorPage(),
    );
  }
}

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _inputController = TextEditingController();

  String _result = '';
  String _fileName = '';
  bool _isLoading = false;
  bool _isExtracting = false;


  Future<void> _pickAndExtractFile() async {
    try {

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );


      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;


      if (file.path == null) {
        _showSnackbar('Gagal mendapatkan path file');
        return;
      }

      setState(() {
        _isExtracting = true;
        _fileName = file.name;
        _inputController.clear();
        _result = '';
      });


      final extractedText =
          await FileExtractorService.extractText(file.path!);


      if (extractedText.startsWith('Error:')) {
        _showSnackbar(extractedText);
        setState(() {
          _isExtracting = false;
          _fileName = '';
        });
        return;
      }

      setState(() {
        _inputController.text = extractedText;
        _isExtracting = false;
      });
    } catch (e) {
      _showSnackbar('Gagal memilih file');
      setState(() => _isExtracting = false);
    }
  }


  Future<void> _translate() async {
    final text = _inputController.text.trim();

    if (text.isEmpty) {
      _showSnackbar('Masukkan teks atau upload file terlebih dahulu');
      return;
    }


    if (text.length > 3000) {
      _showSnackbar('Teks terlalu panjang (maksimal 3000 karakter)');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final translated = await TranslatorService.translate(text);

    setState(() {
      _result = translated;
      _isLoading = false;
    });
  }


  void _clear() {
    _inputController.clear();
    setState(() {
      _result = '';
      _fileName = '';
    });
  }


  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '🌐 EN → ID Translator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            OutlinedButton.icon(
              onPressed: _isExtracting ? null : _pickAndExtractFile,
              icon: _isExtracting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(
                _isExtracting
                    ? 'Mengekstrak teks...'
                    : 'Upload File (TXT, PDF, JPG, PNG)',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),


            if (_fileName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.insert_drive_file,
                      size: 14, color: Colors.indigo),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _fileName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.indigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),


            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.language,
                                color: Colors.indigo, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'English',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                    
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _inputController,
                          builder: (_, value, __) => Text(
                            '${value.text.length}/3000',
                            style: TextStyle(
                              fontSize: 11,
                              color: value.text.length > 3000
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _inputController,
                      maxLines: 6,
                      maxLength: 3000,
                      decoration: const InputDecoration(
                        hintText: 'Ketik teks atau upload file di atas...',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        counterText: '', // sembunyikan counter bawaan
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _translate,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.translate),
                    label:
                        Text(_isLoading ? 'Menerjemahkan...' : 'Terjemahkan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flag, color: Colors.red, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Indonesian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 100),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _result.isEmpty
                          ? const Text(
                              'Hasil terjemahan muncul di sini...',
                              style: TextStyle(color: Colors.grey),
                            )
                          : SelectableText(
                              _result,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'OCR: Google ML Kit (offline) • Translate: MyMemory API (online)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}