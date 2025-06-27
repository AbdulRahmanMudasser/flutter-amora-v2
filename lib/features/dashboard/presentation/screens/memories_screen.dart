import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/dashboard/presentation/screens/write_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

class ImageViewScreen extends StatelessWidget {
  final MemoryMetadata memory;

  const ImageViewScreen({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.softPink,
        title: Directionality(
          textDirection: memory.name.contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            memory.name,
            style: GoogleFonts.montserrat(
              fontSize: 20 * fontScaleFactor,
              color: AppTheme.deepRose,
            ),
          ),
        ),
      ),
      body: Center(
        child: Image.file(
          File(memory.imagePath),
          fit: BoxFit.contain,
          width: screenWidth,
          height: screenHeight,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Icon(Icons.error, color: AppTheme.roseGold, size: 50);
          },
        ),
      ),
    );
  }
}

class MemoriesScreen extends StatefulWidget {
  final String email;

  const MemoriesScreen({Key? key, required this.email}) : super(key: key);

  @override
  MemoriesScreenState createState() => MemoriesScreenState();
}

class MemoriesScreenState extends State<MemoriesScreen> {
  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr;
  }

  Future<List<MemoryMetadata>> _loadMemories() async {
    final directory = await getApplicationDocumentsDirectory();
    final metadataFile = File('${directory.path}/memories_metadata.json');
    if (!await metadataFile.exists()) {
      return [];
    }
    final metadataJson = await metadataFile.readAsString();
    final metadataList = (jsonDecode(metadataJson) as List)
        .map((item) => MemoryMetadata.fromJson(item))
        .toList();
    final amoraDir = Directory('${directory.path}/memories/amora_images');
    final validMetadata = <MemoryMetadata>[];
    for (var metadata in metadataList) {
      if (await File(metadata.imagePath).exists()) {
        validMetadata.add(metadata);
      } else {
        debugPrint('Image not found: ${metadata.imagePath}');
      }
    }
    return validMetadata;
  }

  Future<void> _deleteMemory(BuildContext context, MemoryMetadata memory) async {
    final directory = await getApplicationDocumentsDirectory();
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
    metadataList.removeWhere((item) => item.imagePath == memory.imagePath);
    try {
      await metadataFile.writeAsString(jsonEncode(metadataList));
      final imageFile = File(memory.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Memory deleted', style: GoogleFonts.montserrat())),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      debugPrint('Error deleting memory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete memory', style: GoogleFonts.montserrat())),
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
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/bg-5.jpg'
              ),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: FutureBuilder<List<MemoryMetadata>>(
            future: _loadMemories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.roseGold));
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Directionality(
                    textDirection: _getTextDirection('Error loading memories'),
                    child: Text(
                      'Error loading memories',
                      style: GoogleFonts.montserrat(
                        fontSize: 18 * fontScaleFactor,
                        color: AppTheme.deepRose,
                      ),
                    ),
                  ),
                );
              }
        
              final memories = snapshot.data!;
              return SingleChildScrollView(
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
                            'assets/images/otp.jpg',
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
                        textDirection: _getTextDirection('Your Cherished Memories'),
                        child: Text(
                          'Your Cherished Memories',
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
                      SizedBox(height: verticalSpacing),
                      Image.asset(
                        'assets/images/misc/floral-divider.png',
                        width: screenWidth * 0.8,
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      if (memories.isEmpty)
                        Directionality(
                          textDirection: _getTextDirection('No memories yet. Create one in the Write section!'),
                          child: Text(
                            'No memories yet. Create one in the Write section!',
                            style: GoogleFonts.montserrat(
                              fontSize: 18 * fontScaleFactor,
                              color: AppTheme.deepRose,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 600 ? 3 : 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: memories.length,
                          itemBuilder: (context, index) {
                            final memory = memories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewScreen(memory: memory),
                                  ),
                                );
                              },
                              child: Card(
                                color: AppTheme.softPink.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppTheme.roseGold, width: 1.5),
                                ),
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: Image.file(
                                              File(memory.imagePath),
                                              fit: BoxFit.cover,
                                              height: screenHeight * 0.3,
                                              width: screenWidth * 0.85,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return Icon(Icons.error, color: AppTheme.roseGold);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: Icon(Icons.delete, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Directionality(
                                                      textDirection: _getTextDirection('Delete Memory'),
                                                      child: Text(
                                                        'Delete Memory',
                                                        style: GoogleFonts.montserrat(
                                                          color: AppTheme.deepRose,
                                                        ),
                                                      ),
                                                    ),
                                                    content: Directionality(
                                                      textDirection: _getTextDirection('Are you sure you want to delete "${memory.name}"?'),
                                                      child: Text(
                                                        'Are you sure you want to delete "${memory.name}"?',
                                                        style: GoogleFonts.montserrat(
                                                          color: AppTheme.deepRose,
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          'Cancel',
                                                          style: GoogleFonts.montserrat(
                                                            color: AppTheme.roseGold,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await _deleteMemory(context, memory);
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          'Delete',
                                                          style: GoogleFonts.montserrat(
                                                            color: AppTheme.roseGold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(screenWidth * 0.02),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Directionality(
                                            textDirection: _getTextDirection(memory.name),
                                            child: Text(
                                              memory.name,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14 * fontScaleFactor,
                                                color: AppTheme.deepRose,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Directionality(
                                            textDirection: _getTextDirection('Edited by: ${memory.editedBy}'),
                                            child: Text(
                                              'Edited by: ${memory.editedBy}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12 * fontScaleFactor,
                                                color: AppTheme.roseGold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Directionality(
                                            textDirection: _getTextDirection('Date: ${memory.date.split('T')[0]}'),
                                            child: Text(
                                              'Date: ${memory.date.split('T')[0]}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12 * fontScaleFactor,
                                                color: AppTheme.roseGold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to Write Screen', style: GoogleFonts.montserrat())),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteScreen(email: widget.email)),
          );
        },
        backgroundColor: AppTheme.roseGold,
        child: Icon(
          Icons.add,
          color: AppTheme.creamWhite,
          size: 24 * fontScaleFactor,
        ),
      ),
    );
  }
}