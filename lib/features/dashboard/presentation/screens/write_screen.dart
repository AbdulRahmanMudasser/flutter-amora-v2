import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:undo/undo.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/presentation/widgets/custom_text_field.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class MemoryMetadata {
  final String name;
  final String date;
  final String imagePath;
  final String editedBy;

  MemoryMetadata({
    required this.name,
    required this.date,
    required this.imagePath,
    required this.editedBy,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    'imagePath': imagePath,
    'editedBy': editedBy,
  };

  factory MemoryMetadata.fromJson(Map<String, dynamic> json) => MemoryMetadata(
    name: json['name'],
    date: json['date'],
    imagePath: json['imagePath'],
    editedBy: json['editedBy'],
  );
}

class WriteScreen extends StatefulWidget {
  final String email;

  const WriteScreen({Key? key, required this.email}) : super(key: key);

  @override
  WriteScreenState createState() => WriteScreenState();
}

class WriteScreenState extends State<WriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _textController = TextEditingController();
  String? _selectedImage;
  String _editedBy = 'Wife';
  Color _selectedColor = Colors.black;
  double _textSize = 18;
  TextAlign _textAlign = TextAlign.center;
  bool _hasShadow = true;
  bool _isBold = false;
  bool _isItalic = false;
  double _textRotation = 0;
  String? _selectedFilter = 'None';
  Offset _textPosition = const Offset(0, 0);
  bool _isPreviewMode = false;
  bool _isFormattingExpanded = true;
  final ChangeStack _undoStack = ChangeStack();
  final ImagePicker _picker = ImagePicker();
  final List<String> _backgroundImages = List.generate(
    10,
        (index) => 'assets/images/status/status-${index + 1}.png',
  );

  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr;
  }

  void _resetTextPosition() {
    setState(() {
      _textPosition = const Offset(0, 0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text position reset to center', style: GoogleFonts.montserrat())),
    );
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_saveState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _textController.removeListener(_saveState);
    _textController.dispose();
    super.dispose();
  }

  void _saveState() {
    _undoStack.add(Change(
      _textController.text,
          () => _textController.text = _textController.text,
          (oldValue) => _textController.text = oldValue,
    ));
  }

  Future<void> _pickImageFromGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Picking image...', style: GoogleFonts.montserrat())),
    );
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final amoraDir = Directory('${directory.path}/memories/amora_images');
      if (!await amoraDir.exists()) {
        await amoraDir.create(recursive: true);
      }
      final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${amoraDir.path}/$fileName');
      setState(() {
        _selectedImage = savedImage.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected!', style: GoogleFonts.montserrat())),
      );
    }
  }

  Future<void> _saveMemory() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saving memory...', style: GoogleFonts.montserrat())),
    );
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final amoraDir = Directory('${directory.path}/memories/amora_images');
      if (!await amoraDir.exists()) {
        await amoraDir.create(recursive: true);
      }

      final imageFile = File(_selectedImage!);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('Failed to decode image: $_selectedImage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image', style: GoogleFonts.montserrat())),
        );
        return;
      }

      if (_selectedFilter == 'Sepia') {
        image = img.sepia(image);
      } else if (_selectedFilter == 'Grayscale') {
        image = img.grayscale(image);
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();
      final codec = await ui.instantiateImageCodec(img.encodeJpg(image));
      final frame = await codec.getNextFrame();
      canvas.drawImage(frame.image, Offset.zero, Paint());

      final textSpan = TextSpan(
        text: _textController.text,
        style: GoogleFonts.montserrat(
          fontSize: _textSize,
          color: _selectedColor,
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
          shadows: _hasShadow
              ? [
            Shadow(
              blurRadius: 4,
              color: AppTheme.roseGold.withOpacity(0.5),
              offset: const Offset(1, 1),
            ),
          ]
              : null,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: _textAlign,
        textDirection: _getTextDirection(_textController.text),
      );
      textPainter.layout(maxWidth: imageWidth * 0.8);
      canvas.translate(_textPosition.dx + imageWidth / 2, _textPosition.dy + imageHeight / 2);
      canvas.rotate(_textRotation * 3.14159 / 180);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      final picture = recorder.endRecording();
      final uiImage = await picture.toImage(image.width, image.height);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('Failed to convert image to bytes');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image', style: GoogleFonts.montserrat())),
        );
        return;
      }
      final fileName = 'memory_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = File('${amoraDir.path}/$fileName');
      await savedImage.writeAsBytes(byteData.buffer.asUint8List());
      debugPrint('Image saved to: ${savedImage.path}');

      final metadataFile = File('${directory.path}/memories_metadata.json');
      List<MemoryMetadata> metadataList = [];
      if (await metadataFile.exists()) {
        try {
          final metadataJson = await metadataFile.readAsString();
          metadataList = (jsonDecode(metadataJson) as List)
              .map((item) => MemoryMetadata.fromJson(item))
              .toList();
        } catch (e) {
          debugPrint('Error reading metadata: $e');
        }
      }
      final metadata = MemoryMetadata(
        name: _nameController.text,
        date: DateTime.now().toIso8601String(),
        imagePath: savedImage.path,
        editedBy: _editedBy,
      );
      metadataList.add(metadata);
      try {
        await metadataFile.writeAsString(jsonEncode(metadataList));
        debugPrint('Metadata saved to: ${metadataFile.path}');
      } catch (e) {
        debugPrint('Error writing metadata: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save metadata', style: GoogleFonts.montserrat())),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Memory saved!', style: GoogleFonts.montserrat())),
      );
      Navigator.pushReplacementNamed(context, '/main', arguments: widget.email);
    } else {
      debugPrint('Save failed: Invalid form or no image selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and fill all fields', style: GoogleFonts.montserrat())),
      );
    }
  }

  Future<void> _shareMemory() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing memory...', style: GoogleFonts.montserrat())),
    );
    if (_selectedImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final tempFile = File('${directory.path}/temp_share.png');
      final imageFile = File(_selectedImage!);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('Failed to decode image for sharing: $_selectedImage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share image', style: GoogleFonts.montserrat())),
        );
        return;
      }

      if (_selectedFilter == 'Sepia') {
        image = img.sepia(image);
      } else if (_selectedFilter == 'Grayscale') {
        image = img.grayscale(image);
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();
      final codec = await ui.instantiateImageCodec(img.encodeJpg(image));
      final frame = await codec.getNextFrame();
      canvas.drawImage(frame.image, Offset.zero, Paint());
      final textSpan = TextSpan(
        text: _textController.text,
        style: GoogleFonts.montserrat(
          fontSize: _textSize,
          color: _selectedColor,
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
          shadows: _hasShadow
              ? [
            Shadow(
              blurRadius: 4,
              color: AppTheme.roseGold.withOpacity(0.5),
              offset: const Offset(1, 1),
            ),
          ]
              : null,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: _textAlign,
        textDirection: _getTextDirection(_textController.text),
      );
      textPainter.layout(maxWidth: imageWidth * 0.8);
      canvas.translate(_textPosition.dx + imageWidth / 2, _textPosition.dy + imageHeight / 2);
      canvas.rotate(_textRotation * 3.14159 / 180);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      final picture = recorder.endRecording();
      final uiImage = await picture.toImage(image.width, image.height);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('Failed to convert image to bytes for sharing');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share image', style: GoogleFonts.montserrat())),
        );
        return;
      }
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(tempFile.path)], text: 'A memory from Amora: ${_nameController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Memory shared!', style: GoogleFonts.montserrat())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final verticalSpacing = screenHeight * 0.015;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg-6.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.25,
                    maxWidth: screenWidth * 0.85,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.roseGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.softPink.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/write.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          color: AppTheme.softPink.withOpacity(0.2),
                          child: Icon(
                            Icons.favorite,
                            size: screenWidth * 0.15,
                            color: AppTheme.roseGold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing * 2),
                Directionality(
                  textDirection: _getTextDirection('Write Your Heart'),
                  child: Text(
                    'Write Your Heart',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 26 * fontScaleFactor,
                      color: AppTheme.deepRose,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: AppTheme.roseGold.withOpacity(0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: verticalSpacing * 2),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Memory Name',
                        controller: _nameController,
                        prefixIcon: Icon(Icons.edit, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a memory name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: verticalSpacing),
                      DropdownButton<String>(
                        value: _editedBy,
                        items: ['Wife', 'Husband']
                            .map((role) => DropdownMenuItem(value: role, child: Text(role, style: GoogleFonts.montserrat())))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _editedBy = value!;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Role set to $value', style: GoogleFonts.montserrat())),
                          );
                        },
                        style: GoogleFonts.montserrat(
                          fontSize: 16 * fontScaleFactor,
                          color: AppTheme.deepRose,
                        ),
                        dropdownColor: AppTheme.creamWhite,
                      ),
                      SizedBox(height: verticalSpacing),
                      if (!_isPreviewMode) ...[
                        Image.asset(
                          'assets/images/misc/floral-divider.png',
                          width: screenWidth * 0.8,
                        ),
                        SizedBox(height: verticalSpacing),
                        Directionality(
                          textDirection: _getTextDirection('Text Formatting ${_isFormattingExpanded ? '▼' : '▲'}'),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isFormattingExpanded = !_isFormattingExpanded;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFormattingExpanded ? 'Formatting expanded' : 'Formatting collapsed',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Text Formatting ${_isFormattingExpanded ? '▼' : '▲'}',
                              style: GoogleFonts.montserrat(
                                fontSize: 16 * fontScaleFactor,
                                color: AppTheme.roseGold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        if (_isFormattingExpanded) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.format_bold,
                                  color: _isBold ? AppTheme.roseGold : AppTheme.deepRose,
                                  size: 20 * fontScaleFactor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isBold = !_isBold;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Bold ${_isBold ? 'enabled' : 'disabled'}', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.format_italic,
                                  color: _isItalic ? AppTheme.roseGold : AppTheme.deepRose,
                                  size: 20 * fontScaleFactor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isItalic = !_isItalic;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Italic ${_isItalic ? 'enabled' : 'disabled'}', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  _hasShadow ? Icons.format_color_text : Icons.format_color_reset,
                                  color: AppTheme.roseGold,
                                  size: 20 * fontScaleFactor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _hasShadow = !_hasShadow;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Shadow ${_hasShadow ? 'enabled' : 'disabled'}', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.format_align_left, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: () {
                                  setState(() {
                                    _textAlign = TextAlign.left;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Text aligned left', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.format_align_center, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: () {
                                  setState(() {
                                    _textAlign = TextAlign.center;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Text aligned center', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.format_align_right, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: () {
                                  setState(() {
                                    _textAlign = TextAlign.right;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Text aligned right', style: GoogleFonts.montserrat())),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Directionality(
                                textDirection: _getTextDirection('Text Size: ${_textSize.round()}'),
                                child: Text(
                                  'Text Size: ${_textSize.round()}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14 * fontScaleFactor,
                                    color: AppTheme.deepRose,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Slider(
                                value: _textSize,
                                min: 12,
                                max: 36,
                                divisions: 24,
                                label: _textSize.round().toString(),
                                activeColor: AppTheme.roseGold,
                                inactiveColor: AppTheme.softPink,
                                onChanged: (value) {
                                  setState(() {
                                    _textSize = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Directionality(
                                textDirection: _getTextDirection('Rotation: ${_textRotation.round()}°'),
                                child: Text(
                                  'Rotation: ${_textRotation.round()}°',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14 * fontScaleFactor,
                                    color: AppTheme.deepRose,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Slider(
                                value: _textRotation,
                                min: 0,
                                max: 360,
                                divisions: 360,
                                label: _textRotation.round().toString(),
                                activeColor: AppTheme.roseGold,
                                inactiveColor: AppTheme.softPink,
                                onChanged: (value) {
                                  setState(() {
                                    _textRotation = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          Wrap(
                            spacing: 10,
                            children: [
                              ChoiceChip(
                                label: Text('Black', style: GoogleFonts.montserrat(color: Colors.white)),
                                selected: _selectedColor == Colors.black,
                                selectedColor: AppTheme.roseGold,
                                backgroundColor: Colors.black,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedColor = Colors.black);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Color set to Black', style: GoogleFonts.montserrat())),
                                    );
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text('White', style: GoogleFonts.montserrat(color: Colors.black)),
                                selected: _selectedColor == Colors.white,
                                selectedColor: AppTheme.roseGold,
                                backgroundColor: Colors.white,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedColor = Colors.white);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Color set to White', style: GoogleFonts.montserrat())),
                                    );
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text('Blush Pink', style: GoogleFonts.montserrat(color: Colors.black)),
                                selected: _selectedColor == const Color(0xFFFFB6C1),
                                selectedColor: AppTheme.roseGold,
                                backgroundColor: const Color(0xFFFFB6C1),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedColor = const Color(0xFFFFB6C1));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Color set to Blush Pink', style: GoogleFonts.montserrat())),
                                    );
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text('Burgundy', style: GoogleFonts.montserrat(color: Colors.white)),
                                selected: _selectedColor == const Color(0xFF800020),
                                selectedColor: AppTheme.roseGold,
                                backgroundColor: const Color(0xFF800020),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedColor = const Color(0xFF800020));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Color set to Burgundy', style: GoogleFonts.montserrat())),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: ['None', 'Sepia', 'Grayscale']
                                .map((filter) => DropdownMenuItem(value: filter, child: Text(filter, style: GoogleFonts.montserrat())))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Filter set to $value', style: GoogleFonts.montserrat())),
                              );
                            },
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * fontScaleFactor,
                              color: AppTheme.deepRose,
                            ),
                            dropdownColor: AppTheme.creamWhite,
                          ),
                          SizedBox(height: verticalSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.undo, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: _undoStack.canUndo
                                    ? () {
                                  setState(() {
                                    _undoStack.undo();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Undo', style: GoogleFonts.montserrat())),
                                  );
                                }
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(Icons.redo, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: _undoStack.canRedo
                                    ? () {
                                  setState(() {
                                    _undoStack.redo();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Redo', style: GoogleFonts.montserrat())),
                                  );
                                }
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(Icons.preview, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: () {
                                  setState(() {
                                    _isPreviewMode = !_isPreviewMode;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isPreviewMode ? 'Preview mode enabled' : 'Preview mode disabled',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: verticalSpacing),
                          Image.asset(
                            'assets/images/misc/floral-divider.png',
                            width: screenWidth * 0.8,
                          ),
                          SizedBox(height: verticalSpacing),
                        ],
                      ],
                      SizedBox(height: verticalSpacing),
                      ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        child: Text(
                          'Pick from Gallery',
                          style: GoogleFonts.montserrat(
                            fontSize: 16 * fontScaleFactor,
                            color: AppTheme.creamWhite,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      SizedBox(
                        height: screenHeight * 0.1,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _backgroundImages.length,
                          itemBuilder: (context, index) {
                            final image = _backgroundImages[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = image;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Background image selected', style: GoogleFonts.montserrat())),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedImage == image ? AppTheme.roseGold : Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    return const Icon(Icons.error, color: AppTheme.roseGold);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      if (_selectedImage != null)
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.5,
                            maxWidth: screenWidth * 0.95,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.roseGold, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ColorFiltered(
                                  colorFilter: _selectedFilter == 'Sepia'
                                      ? const ColorFilter.matrix([
                                    0.393, 0.769, 0.189, 0, 0,
                                    0.349, 0.686, 0.168, 0, 0,
                                    0.272, 0.534, 0.131, 0, 0,
                                    0, 0, 0, 1, 0,
                                  ])
                                      : _selectedFilter == 'Grayscale'
                                      ? const ColorFilter.matrix([
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0, 0, 0, 1, 0,
                                  ])
                                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                  child: _selectedImage!.startsWith('assets/')
                                      ? Image.asset(
                                    _selectedImage!,
                                    fit: BoxFit.contain,
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.5,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Icon(Icons.error, color: AppTheme.roseGold);
                                    },
                                  )
                                      : Image.file(
                                    File(_selectedImage!),
                                    fit: BoxFit.contain,
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.5,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Icon(Icons.error, color: AppTheme.roseGold);
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: _textPosition.dx + screenWidth * 0.475,
                                  top: _textPosition.dy + screenHeight * 0.25,
                                  child: _isPreviewMode
                                      ? Transform.rotate(
                                    angle: _textRotation * 3.14159 / 180,
                                    child: Directionality(
                                      textDirection: _getTextDirection(_textController.text.isEmpty ? 'Your Text' : _textController.text),
                                      child: Text(
                                        _textController.text.isEmpty ? 'Your Text' : _textController.text,
                                        textAlign: _textAlign,
                                        textDirection: _getTextDirection(_textController.text.isEmpty ? 'Your Text' : _textController.text),
                                        style: GoogleFonts.montserrat(
                                          fontSize: _textSize,
                                          color: _selectedColor,
                                          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                                          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                                          shadows: _hasShadow
                                              ? [
                                            Shadow(
                                              blurRadius: 4,
                                              color: AppTheme.roseGold.withOpacity(0.5),
                                              offset: const Offset(1, 1),
                                            ),
                                          ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                  )
                                      : GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        final newX = _textPosition.dx + details.delta.dx;
                                        final newY = _textPosition.dy + details.delta.dy;
                                        final maxWidth = screenWidth * 0.95 / 2;
                                        final maxHeight = screenHeight * 0.5 / 2;
                                        _textPosition = Offset(
                                          newX.clamp(-maxWidth, maxWidth),
                                          newY.clamp(-maxHeight, maxHeight),
                                        );
                                      });
                                    },
                                    onDoubleTap: _resetTextPosition,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.8,
                                        minWidth: screenWidth * 0.3,
                                        minHeight: screenHeight * 0.05,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppTheme.roseGold, width: 1.5),
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppTheme.creamWhite.withOpacity(0.8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.softPink.withOpacity(0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                        vertical: screenHeight * 0.015,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Transform.rotate(
                                            angle: _textRotation * 3.14159 / 180,
                                            child: TextField(
                                              controller: _textController,
                                              textAlign: _textAlign,
                                              style: GoogleFonts.montserrat(
                                                fontSize: _textSize,
                                                color: _selectedColor,
                                                fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                                                fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                                                shadows: _hasShadow
                                                    ? [
                                                  Shadow(
                                                    blurRadius: 4,
                                                    color: AppTheme.roseGold.withOpacity(0.5),
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ]
                                                    : null,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Your Text',
                                                hintStyle: GoogleFonts.montserrat(
                                                  color: AppTheme.roseGold.withOpacity(0.5),
                                                  fontSize: _textSize,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                              textDirection: _getTextDirection(_textController.text),
                                              maxLines: null,
                                              maxLength: 200,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 2,
                                            right: 2,
                                            child: Icon(
                                              Icons.drag_indicator,
                                              color: AppTheme.roseGold,
                                              size: 24 * fontScaleFactor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveMemory,
                            child: Text(
                              'Save',
                              style: GoogleFonts.montserrat(
                                fontSize: 16 * fontScaleFactor,
                                color: AppTheme.creamWhite,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _shareMemory,
                            child: Text(
                              'Share',
                              style: GoogleFonts.montserrat(
                                fontSize: 16 * fontScaleFactor,
                                color: AppTheme.creamWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}