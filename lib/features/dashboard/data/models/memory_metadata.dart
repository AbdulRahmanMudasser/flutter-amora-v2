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