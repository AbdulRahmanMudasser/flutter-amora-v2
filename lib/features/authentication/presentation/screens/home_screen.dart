import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:amora/core/theme/theme.dart';
import '../../../dashboard/data/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime? _selectedEndDate;

  TextDirection _getTextDirection(String text) {
    bool isRtl = text.contains(RegExp(r'[\u0600-\u06FF]'));
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _showAddEditTaskDialog({TaskModel? task}) {
    if (task != null) {
      _titleController.text = task.title;
      _detailsController.text = task.details;
      _selectedEndDate = task.endDate;
    } else {
      _titleController.clear();
      _detailsController.clear();
      _selectedEndDate = _selectedDay; // Default to selected calendar day
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Directionality(
            textDirection: _getTextDirection(task == null ? 'Add Task' : 'Edit Task'),
            child: Text(
              task == null ? 'Add Task' : 'Edit Task',
              style: GoogleFonts.montserrat(
                fontSize: 18 * fontScaleFactor,
                color: AppTheme.deepRose,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.task, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                      filled: true,
                      fillColor: AppTheme.softPink.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
                      ),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 16 * fontScaleFactor, color: AppTheme.deepRose),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      prefixIcon: Icon(Icons.description, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                      filled: true,
                      fillColor: AppTheme.softPink.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
                      ),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 16 * fontScaleFactor, color: AppTheme.deepRose),
                    maxLines: 3,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedEndDate ?? _selectedDay,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppTheme.roseGold,
                                onPrimary: AppTheme.creamWhite,
                              ),
                              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedEndDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Icon(Icons.calendar_today, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                        filled: true,
                        fillColor: AppTheme.softPink.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
                        ),
                      ),
                      child: Text(
                        _selectedEndDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                            : 'Select a date',
                        style: GoogleFonts.montserrat(fontSize: 16 * fontScaleFactor, color: AppTheme.deepRose),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(fontSize: 14 * fontScaleFactor, color: AppTheme.roseGold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _selectedEndDate != null) {
                  final taskBox = await Hive.openBox<TaskModel>('tasks');
                  final taskId = task?.id ?? const Uuid().v4();
                  final newTask = TaskModel(
                    id: taskId,
                    title: _titleController.text,
                    details: _detailsController.text,
                    endDate: _selectedEndDate!,
                    editedBy: widget.email,
                    isCompleted: task?.isCompleted ?? false,
                  );
                  await taskBox.put(taskId, newTask);
                  Navigator.pop(context);
                  setState(() {}); // Refresh task list
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.roseGold,
                foregroundColor: AppTheme.creamWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppTheme.softPink.withOpacity(0.4),
              ),
              child: Text(
                task == null ? 'Add' : 'Update',
                style: GoogleFonts.montserrat(
                  fontSize: 14 * fontScaleFactor,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.creamWhite,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(String taskId) async {
    final taskBox = await Hive.openBox<TaskModel>('tasks');
    await taskBox.delete(taskId);
    setState(() {}); // Refresh task list
  }

  void _toggleTaskCompletion(TaskModel task) async {
    final taskBox = await Hive.openBox<TaskModel>('tasks');
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      details: task.details,
      endDate: task.endDate,
      editedBy: widget.email,
      isCompleted: !task.isCompleted,
    );
    await taskBox.put(task.id, updatedTask);
    setState(() {}); // Refresh task list
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final verticalSpacing = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Directionality(
          textDirection: _getTextDirection('Amora To-Do'),
          child: Text(
            'Amora To-Do',
            style: GoogleFonts.montserrat(
              fontSize: 22 * fontScaleFactor,
              color: AppTheme.deepRose,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: AppTheme.creamWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: AppTheme.roseGold, size: 24 * fontScaleFactor),
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: widget.email);
            },
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.creamWhite,
              AppTheme.softPink.withOpacity(0.4),
              AppTheme.roseGold.withOpacity(0.2),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg-1.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(horizontalPadding),
              decoration: BoxDecoration(
                color: AppTheme.creamWhite.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.roseGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.softPink.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  print('Selected day: $selectedDay, Focused day: $focusedDay'); // Debug
                  setState(() {
                    _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.roseGold.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.roseGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.deepRose, width: 2),
                  ),
                  selectedTextStyle: GoogleFonts.montserrat(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  defaultTextStyle: GoogleFonts.montserrat(color: AppTheme.deepRose),
                  outsideTextStyle: GoogleFonts.montserrat(color: AppTheme.vintageSepia.withOpacity(0.5)),
                  weekendTextStyle: GoogleFonts.montserrat(color: AppTheme.deepRose),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.montserrat(
                    fontSize: 18 * fontScaleFactor,
                    color: AppTheme.deepRose,
                    fontWeight: FontWeight.w600,
                  ),
                  formatButtonVisible: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppTheme.roseGold),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: GoogleFonts.montserrat(
                    color: AppTheme.roseGold,
                    fontSize: 14 * fontScaleFactor,
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),
            Expanded(
              child: ValueListenableBuilder<Box<TaskModel>>(
                valueListenable: Hive.box<TaskModel>('tasks').listenable(),
                builder: (context, box, _) {
                  final tasks = box.values
                      .where((task) => isSameDay(task.endDate, _selectedDay))
                      .toList()
                    ..sort((a, b) => a.endDate.compareTo(b.endDate));
                  if (tasks.isEmpty) {
                    return Center(
                      child: Directionality(
                        textDirection: _getTextDirection('No tasks for this day'),
                        child: Text(
                          'No tasks for this day',
                          style: GoogleFonts.montserrat(
                            fontSize: 16 * fontScaleFactor,
                            color: AppTheme.deepRose,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalSpacing * 0.5,
                        ),
                        child: Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: AppTheme.creamWhite),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTask(task.id),
                          child: Card(
                            color: AppTheme.creamWhite.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.softPink.withOpacity(0.3),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => _toggleTaskCompletion(task),
                                activeColor: AppTheme.roseGold,
                              ),
                              title: Directionality(
                                textDirection: _getTextDirection(task.title),
                                child: Text(
                                  task.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16 * fontScaleFactor,
                                    color: task.isCompleted ? AppTheme.vintageSepia : AppTheme.deepRose,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Directionality(
                                    textDirection: _getTextDirection(task.details),
                                    child: Text(
                                      task.details,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14 * fontScaleFactor,
                                        color: AppTheme.vintageSepia,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: _getTextDirection('End: ${DateFormat('yyyy-MM-dd').format(task.endDate)}'),
                                    child: Text(
                                      'End: ${DateFormat('yyyy-MM-dd').format(task.endDate)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12 * fontScaleFactor,
                                        color: AppTheme.vintageSepia,
                                      ),
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: _getTextDirection('Edited by: ${task.editedBy}'),
                                    child: Text(
                                      'Edited by: ${task.editedBy}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12 * fontScaleFactor,
                                        color: AppTheme.vintageSepia,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                onPressed: () => _showAddEditTaskDialog(task: task),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTaskDialog(),
        backgroundColor: AppTheme.roseGold,
        child: Icon(Icons.add, color: AppTheme.creamWhite, size: 24 * fontScaleFactor),
      ),
    );
  }
}