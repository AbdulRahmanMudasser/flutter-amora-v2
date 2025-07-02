import 'dart:convert';
import 'dart:io';

import 'package:amora/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  DateTime get dateTime => DateTime.parse(date);
}

class ImageViewScreen extends StatelessWidget {
  final MemoryMetadata memory;

  const ImageViewScreen({super.key, required this.memory});

  Future<void> _shareMemory(BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(memory.imagePath)],
        text: '${memory.name}\nCreated with Amora',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing memory: $e', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final fontScaleFactor = isMobile ? 0.85 : 1.2;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.softPink,
        title: Directionality(
          textDirection: memory.name.contains(RegExp(r'[\u0600-\u06FF]'))
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Text(
            memory.name,
            style: GoogleFonts.montserrat(
              fontSize: 20 * fontScaleFactor,
              color: AppTheme.deepRose,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.deepRose),
            onPressed: () => _shareMemory(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(memory.imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: AppTheme.roseGold, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load image',
                    style: GoogleFonts.montserrat(color: AppTheme.deepRose),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MemoriesScreen extends StatefulWidget {
  final String email;

  const MemoriesScreen({super.key, required this.email});

  @override
  MemoriesScreenState createState() => MemoriesScreenState();
}

class MemoriesScreenState extends State<MemoriesScreen> {
  String _searchQuery = '';

  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'))
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Future<List<MemoryMetadata>> _loadMemories() async {
    final directory = await getApplicationDocumentsDirectory();
    final metadataFile = File('${directory.path}/memories_metadata.json');

    if (!await metadataFile.exists()) {
      return [];
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      final metadataList = (jsonDecode(metadataJson) as List)
          .map((item) => MemoryMetadata.fromJson(item))
          .toList();

      // Sort by date (newest first)
      metadataList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return metadataList.where((memory) {
          return memory.name.toLowerCase().contains(query) ||
              memory.editedBy.toLowerCase().contains(query) ||
              DateFormat('MMM dd, yyyy').format(memory.dateTime).toLowerCase().contains(query);
        }).toList();
      }

      // Verify images exist
      final validMetadata = <MemoryMetadata>[];
      for (var metadata in metadataList) {
        if (await File(metadata.imagePath).exists()) {
          validMetadata.add(metadata);
        }
      }
      return validMetadata;
    } catch (e) {
      debugPrint('Error loading memories: $e');
      return [];
    }
  }

  Future<void> _deleteMemory(BuildContext context, MemoryMetadata memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Directionality(
          textDirection: _getTextDirection('Delete Memory'),
          child: Text(
            'Delete Memory',
            style: GoogleFonts.montserrat(color: AppTheme.deepRose),
          ),
        ),
        content: Directionality(
          textDirection: _getTextDirection('Are you sure?'),
          child: Text(
            'Are you sure you want to delete "${memory.name}"?',
            style: GoogleFonts.montserrat(color: AppTheme.deepRose),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: AppTheme.roseGold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/memories_metadata.json');
      List<MemoryMetadata> metadataList = await _loadMemories();

      metadataList.removeWhere((item) => item.imagePath == memory.imagePath);
      await metadataFile.writeAsString(jsonEncode(metadataList));

      final imageFile = File(memory.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memory deleted', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.black,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: isMobile ? 60 : 80,
            color: AppTheme.roseGold,
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: _getTextDirection('No memories yet'),
            child: Text(
              'No memories yet',
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 20 : 24,
                color: AppTheme.deepRose,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: _getTextDirection('Create your first memory in the Write section!'),
            child: Text(
              'Create your first memory in the Write section!',
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 14 : 16,
                color: AppTheme.roseGold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(BuildContext context, MemoryMetadata memory, bool isMobile) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(memory.dateTime);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.roseGold, width: 1),
      ),
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.softPink.withValues(alpha: 0.2),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppTheme.roseGold,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.share, color: AppTheme.deepRose, size: isMobile ? 20 : 24),
                        onPressed: () async {
                          try {
                            await Share.shareXFiles(
                              [XFile(memory.imagePath)],
                              text: '${memory.name}\nCreated on $formattedDate',
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error sharing: $e', style: GoogleFonts.montserrat()),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[700], size: isMobile ? 20 : 24),
                        onPressed: () => _deleteMemory(context, memory),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: _getTextDirection(memory.name),
                  child: Text(
                    memory.name,
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 14 : 16,
                      color: AppTheme.deepRose,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: _getTextDirection('By ${memory.editedBy}'),
                  child: Text(
                    'By ${memory.editedBy}',
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 12 : 14,
                      color: AppTheme.roseGold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: _getTextDirection(formattedDate),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 12 : 14,
                      color: AppTheme.vintageSepia,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

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
                AppTheme.softPink.withValues(alpha: 0.2),
              ],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/backgrounds/bg-5.jpg'),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 14 : 16,
                    color: AppTheme.vintageSepia,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, editor, or date...',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: isMobile ? 14 : 16,
                      color: AppTheme.deepRose.withValues(alpha: 0.6),
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.roseGold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.roseGold),
                    ),
                    filled: true,
                    fillColor: AppTheme.creamWhite.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<MemoryMetadata>>(
                  future: _loadMemories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.roseGold),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: AppTheme.roseGold, size: 40),
                            const SizedBox(height: 16),
                            Directionality(
                              textDirection: _getTextDirection('Error loading memories'),
                              child: Text(
                                'Error loading memories',
                                style: GoogleFonts.montserrat(
                                  fontSize: isMobile ? 18 : 20,
                                  color: AppTheme.deepRose,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final memories = snapshot.data ?? [];

                    return CustomScrollView(
                      slivers: [
                        if (memories.isEmpty)
                          SliverFillRemaining(
                            child: _buildEmptyState(context, isMobile),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.all(isMobile ? 8 : 16),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                                crossAxisSpacing: isMobile ? 8 : 12,
                                mainAxisSpacing: isMobile ? 8 : 12,
                                childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
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
                                    child: _buildMemoryCard(context, memory, isMobile),
                                  );
                                },
                                childCount: memories.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}