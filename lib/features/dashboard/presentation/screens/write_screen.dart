import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as dart_ui;
import 'package:amora/core/theme/theme.dart';
import 'dart:convert';

// Temporary WordStyle model (replace with data/models/word_style.dart if provided)
class WordStyle {
  final String word;
  final Color color;
  WordStyle(this.word, this.color);
}

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  File? _selectedImage;
  String? _selectedAssetImage;
  final List<String> _preloadedImages = [
    'assets/images/status/status-1.png',
    'assets/images/status/status-2.png',
    'assets/images/status/status-3.png',
    'assets/images/status/status-4.png',
    'assets/images/status/status-5.png',
    'assets/images/status/status-6.png',
    'assets/images/status/status-7.png',
    'assets/images/status/status-8.png',
    'assets/images/status/status-9.png',
    'assets/images/status/status-10.png',
  ];
  String _memoryName = '';
  String _editedBy = '';
  String _language = 'English';
  double _fontSize = 16.0;
  Offset _textPosition = const Offset(50, 50);
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // For preview
  final GlobalKey _saveBoundaryKey = GlobalKey(); // For saving
  List<WordStyle> _wordStyles = [];
  TextAlign _textAlign = TextAlign.left;
  bool _isSharing = false;

  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) || _language == 'Urdu'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedAssetImage = null;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null && _selectedAssetImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final boundary = _saveBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Failed to capture image: Render boundary is null');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: dart_ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to capture image: Image data is null');
      }
      final buffer = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final memoryDir = Directory('${directory.path}/memories');
      if (!await memoryDir.exists()) {
        await memoryDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String();
      final sanitizedMemoryName = _memoryName.isNotEmpty ? _memoryName.replaceAll(RegExp(r'[^\w\s-]'), '_') : 'memory';
      final fileName = '${sanitizedMemoryName}_$timestamp.png';
      final file = File('${memoryDir.path}/$fileName');
      await file.writeAsBytes(buffer);

      // Save metadata to memories_metadata.json
      final metadataFile = File('${directory.path}/memories_metadata.json');
      List<Map<String, dynamic>> metadataList = [];
      if (await metadataFile.exists()) {
        final metadataJson = await metadataFile.readAsString();
        metadataList = (jsonDecode(metadataJson) as List).cast<Map<String, dynamic>>();
      }

      metadataList.add({
        'name': _memoryName.isNotEmpty ? _memoryName : 'Memory',
        'date': timestamp,
        'imagePath': file.path,
        'editedBy': _editedBy.isNotEmpty ? _editedBy : 'Unknown',
      });

      await metadataFile.writeAsString(jsonEncode(metadataList));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved to ${memoryDir.path}',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving: $e',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareImage() async {
    if (_selectedImage == null && _selectedAssetImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Failed to share image: Render boundary is null');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: dart_ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to share image: Image data is null');
      }
      final buffer = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/memory_${DateTime.now().millisecondsSinceEpoch}.png')
          .writeAsBytes(buffer);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _memoryName.isNotEmpty ? _memoryName : 'Created with Amora',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sharing: $e',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _resetTextPosition() {
    setState(() {
      _textPosition = const Offset(50, 50);
    });
  }

  void _updateWordStyles(List<WordStyle> newStyles) {
    setState(() {
      _wordStyles = newStyles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.creamWhite,
                AppTheme.softPink.withValues(alpha: 0.4),
                AppTheme.roseGold.withValues(alpha: 0.2),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/backgrounds/bg-8.jpg'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : isTablet ? 24 : 32,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeaderSection(isMobile, isTablet),
                const SizedBox(height: 16),
                if (isMobile) _buildMobileLayout() else _buildTabletDesktopLayout(isTablet),
                _buildImagePreviewSection(screenSize, isMobile),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isMobile, bool isTablet) {
    return Column(
      children: [
        Text(
          'Mobahat Nama',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 24 : isTablet ? 28 : 32,
            color: AppTheme.deepRose,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: AppTheme.roseGold.withValues(alpha: 0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: isMobile ? 20 : 24,
              color: AppTheme.roseGold,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Divider(
                color: AppTheme.roseGold,
                thickness: 1.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.favorite,
              size: isMobile ? 20 : 24,
              color: AppTheme.roseGold,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInputField(
          label: 'Memory Name',
          onChanged: (value) => setState(() => _memoryName = value),
          isMobile: true,
        ),
        const SizedBox(height: 12),
        _buildInputField(
          label: 'Edited By',
          onChanged: (value) => setState(() => _editedBy = value),
          isMobile: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLanguageDropdown(true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextAlignToggle(true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFontSizeSlider(true),
        const SizedBox(height: 16),
        if (_wordStyles.isNotEmpty) _buildWordStylingInfo(true),
        const SizedBox(height: 16),
        _buildActionButtons(true),
        const SizedBox(height: 16),
        _buildPreloadedImagesSection(true),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(bool isTablet) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Memory Name',
                    onChanged: (value) => setState(() => _memoryName = value),
                    isMobile: false,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: 'Edited By',
                    onChanged: (value) => setState(() => _editedBy = value),
                    isMobile: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildLanguageDropdown(false)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextAlignToggle(false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFontSizeSlider(false),
                  const SizedBox(height: 16),
                  if (_wordStyles.isNotEmpty) _buildWordStylingInfo(false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButtons(false),
        const SizedBox(height: 16),
        _buildPreloadedImagesSection(false),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required Function(String) onChanged,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.roseGold, width: 1.5),
        color: AppTheme.creamWhite.withValues(alpha: 0.85),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.montserrat(
          fontSize: isMobile ? 14 : 16,
          color: AppTheme.vintageSepia,
        ),
        textDirection: _getTextDirection(label),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          isExpanded: true,
          value: _language,
          items: ['English', 'Urdu'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: isMobile ? 14 : 16,
                  color: AppTheme.vintageSepia,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _language = value!),
        ),
      ],
    );
  }

  Widget _buildTextAlignToggle(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Alignment',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ToggleButtons(
          isSelected: [
            _textAlign == TextAlign.left,
            _textAlign == TextAlign.center,
            _textAlign == TextAlign.right,
          ],
          onPressed: (index) {
            setState(() {
              _textAlign = index == 0
                  ? TextAlign.left
                  : index == 1
                  ? TextAlign.center
                  : TextAlign.right;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: AppTheme.roseGold,
          fillColor: AppTheme.softPink.withValues(alpha: 0.2),
          constraints: BoxConstraints(
            minHeight: isMobile ? 36 : 48,
            minWidth: isMobile ? 36 : 48,
          ),
          children: [
            Icon(Icons.format_align_left, size: isMobile ? 20 : 24),
            Icon(Icons.format_align_center, size: isMobile ? 20 : 24),
            Icon(Icons.format_align_right, size: isMobile ? 20 : 24),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size: ${_fontSize.round()}',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: _fontSize,
          min: 12,
          max: 32,
          onChanged: (value) => setState(() => _fontSize = value),
          activeColor: AppTheme.roseGold,
          inactiveColor: AppTheme.softPink,
        ),
      ],
    );
  }

  Widget _buildWordStylingInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Word Styling:',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap on words in the preview to change their color',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 12 : 14,
            color: AppTheme.vintageSepia,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: isMobile ? 8 : 12,
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.photo,
          label: 'Pick Image',
          onPressed: _pickImage,
          isMobile: isMobile,
          backgroundColor: AppTheme.deepRose,
        ),
        _buildActionButton(
          icon: Icons.save,
          label: 'Save',
          onPressed: _saveImage,
          isMobile: isMobile,
        ),
        _buildActionButton(
          icon: Icons.share,
          label: _isSharing ? 'Sharing...' : 'Share',
          onPressed: _isSharing ? null : _shareImage,
          isMobile: isMobile,
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isMobile,
    Color? backgroundColor,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: isMobile ? 18 : 20),
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.roseGold,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildPreloadedImagesSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preloaded Images:',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 14 : 16,
            color: AppTheme.deepRose.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: isMobile ? 90 : 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _preloadedImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAssetImage = _preloadedImages[index];
                    _selectedImage = null;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 4 : 6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAssetImage == _preloadedImages[index]
                            ? AppTheme.deepRose
                            : AppTheme.roseGold,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        _preloadedImages[index],
                        width: isMobile ? 70 : 90,
                        height: isMobile ? 90 : 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isMobile ? 70 : 90,
                            height: isMobile ? 90 : 110,
                            color: AppTheme.softPink.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.image,
                              size: isMobile ? 24 : 28,
                              color: AppTheme.roseGold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewSection(Size screenSize, bool isMobile) {
    final previewWidth = isMobile ? screenSize.width * 0.9 : screenSize.width * 0.85;
    final previewHeight = isMobile ? screenSize.height * 0.35 : screenSize.height * 0.4;

    return Container(
      height: previewHeight,
      constraints: BoxConstraints(maxWidth: previewWidth),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.roseGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.softPink.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Saving layer (excludes TextField)
            RepaintBoundary(
              key: _saveBoundaryKey,
              child: Stack(
                children: [
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  else if (_selectedAssetImage != null)
                    Image.asset(
                      _selectedAssetImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  else
                    Container(
                      color: AppTheme.softPink.withValues(alpha: 0.2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: isMobile ? 40 : 50,
                              color: AppTheme.roseGold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select an image to begin',
                              style: GoogleFonts.montserrat(
                                color: AppTheme.deepRose,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_wordStyles.isNotEmpty)
                    TextOverlayEditor(
                      wordStyles: _wordStyles,
                      onTextChanged: _updateWordStyles,
                      onWordTapped: _onWordTapped,
                      fontSize: _fontSize,
                      textAlign: _textAlign,
                      textDirection: _getTextDirection(
                        _wordStyles.map((ws) => ws.word).join(' '),
                      ),
                      textPosition: _textPosition,
                      onPositionChanged: (newPosition) {
                        setState(() {
                          _textPosition = newPosition;
                        });
                      },
                      resetTextPosition: _resetTextPosition,
                      isPreviewMode: true, // For saving
                    ),
                ],
              ),
            ),
            // Preview layer (includes TextField)
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Stack(
                children: [
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  else if (_selectedAssetImage != null)
                    Image.asset(
                      _selectedAssetImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  TextOverlayEditor(
                    wordStyles: _wordStyles,
                    onTextChanged: _updateWordStyles,
                    onWordTapped: _onWordTapped,
                    fontSize: _fontSize,
                    textAlign: _textAlign,
                    textDirection: _getTextDirection(
                      _wordStyles.map((ws) => ws.word).join(' '),
                    ),
                    textPosition: _textPosition,
                    onPositionChanged: (newPosition) {
                      setState(() {
                        _textPosition = newPosition;
                      });
                    },
                    resetTextPosition: _resetTextPosition,
                    isPreviewMode: false, // For editing
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onWordTapped(int index) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        currentColor: _wordStyles[index].color,
      ),
    );
    if (pickedColor != null) {
      setState(() {
        _wordStyles[index] = WordStyle(_wordStyles[index].word, pickedColor);
      });
    }
  }
}

// TextOverlayEditor widget with individual word coloring
class TextOverlayEditor extends StatelessWidget {
  final List<WordStyle> wordStyles;
  final Function(List<WordStyle>) onTextChanged;
  final Function(int) onWordTapped;
  final double fontSize;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Offset textPosition;
  final Function(Offset) onPositionChanged;
  final VoidCallback resetTextPosition;
  final bool isPreviewMode;

  const TextOverlayEditor({
    super.key,
    required this.wordStyles,
    required this.onTextChanged,
    required this.onWordTapped,
    required this.fontSize,
    required this.textAlign,
    required this.textDirection,
    required this.textPosition,
    required this.onPositionChanged,
    required this.resetTextPosition,
    required this.isPreviewMode,
  });

  @override
  Widget build(BuildContext context) {
    final previewWidth = MediaQuery.of(context).size.width * 0.9;
    final previewHeight = MediaQuery.of(context).size.height * 0.35;

    return Stack(
      children: [
        if (!isPreviewMode)
          Positioned(
            left: textPosition.dx,
            top: textPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                onPositionChanged(
                  Offset(
                    (textPosition.dx + details.delta.dx).clamp(0, previewWidth - 200),
                    (textPosition.dy + details.delta.dy).clamp(0, previewHeight - 50),
                  ),
                );
              },
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(color: AppTheme.roseGold),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (text) {
                    final words = text.split(' ').where((w) => w.isNotEmpty).toList();
                    final newStyles = words.asMap().entries.map((entry) {
                      final index = entry.key;
                      final word = entry.value;
                      return WordStyle(
                        word,
                        index < wordStyles.length ? wordStyles[index].color : Colors.black,
                      );
                    }).toList();
                    onTextChanged(newStyles);
                  },
                  style: GoogleFonts.montserrat(
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                  textAlign: textAlign,
                  textDirection: textDirection,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter text',
                  ),
                ),
              ),
            ),
          ),
        if (wordStyles.isNotEmpty)
          Positioned(
            left: textPosition.dx,
            top: textPosition.dy,
            child: SizedBox(
              width: 200,
              child: GestureDetector(
                behavior: isPreviewMode ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                onTap: isPreviewMode
                    ? null
                    : () {
                  // Approximate word tapping (simplified, improve with TextPainter if needed)
                  final text = wordStyles.map((ws) => ws.word).join(' ');
                  final words = text.split(' ');
                  // For simplicity, assume tap selects the first word (index 0)
                  // Enhance with TextPainter for precise word bounds if required
                  if (words.isNotEmpty) {
                    onWordTapped(0); // Trigger color picker for the first word
                  }
                },
                child: RichText(
                  text: TextSpan(
                    children: wordStyles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final style = entry.value;
                      return TextSpan(
                        text: '${style.word} ',
                        style: GoogleFonts.montserrat(
                          fontSize: fontSize,
                          color: style.color,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        recognizer: isPreviewMode
                            ? null
                            : (TapGestureRecognizer()..onTap = () => onWordTapped(index)),
                      );
                    }).toList(),
                  ),
                  textAlign: textAlign,
                  textDirection: textDirection,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Simple color picker dialog
class _ColorPickerDialog extends StatelessWidget {
  final Color currentColor;

  const _ColorPickerDialog({required this.currentColor});

  @override
  Widget build(BuildContext context) {
    Color selectedColor = currentColor;
    return AlertDialog(
      title: Text(
        'Pick a Color',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.black,
                Colors.white,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    selectedColor = color;
                    Navigator.of(context).pop(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == currentColor ? AppTheme.roseGold : Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: GoogleFonts.montserrat()),
        ),
      ],
    );
  }
}