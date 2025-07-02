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
  CalendarFormat _calendarFormat = CalendarFormat.week;
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
      _selectedEndDate = _selectedDay;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth * 0.85; // Optimized for mobile
    final verticalPadding = 12.0;
    final verticalSpacing = 10.0;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: (screenWidth - dialogWidth) / 2, vertical: 12),
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: screenHeight * 0.75),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: verticalPadding,
                  right: verticalPadding,
                  top: verticalPadding,
                  bottom: MediaQuery.of(context).viewInsets.bottom + verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: _getTextDirection(task == null ? 'Add Task' : 'Edit Task'),
                      child: Text(
                        task == null ? 'Add Task' : 'Edit Task',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: AppTheme.deepRose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              prefixIcon: Icon(Icons.task, color: AppTheme.roseGold, size: 18),
                              filled: true,
                              fillColor: AppTheme.softPink.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.deepRose, width: 1.8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepRose),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a task title';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: verticalSpacing),
                          TextFormField(
                            controller: _detailsController,
                            decoration: InputDecoration(
                              labelText: 'Details',
                              prefixIcon: Icon(Icons.description, color: AppTheme.roseGold, size: 18),
                              filled: true,
                              fillColor: AppTheme.softPink.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.deepRose, width: 1.8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepRose),
                            maxLines: 2,
                          ),
                          SizedBox(height: verticalSpacing),
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
                                  _selectedEndDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                  );
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                prefixIcon: Icon(Icons.calendar_today, color: AppTheme.roseGold, size: 18),
                                filled: true,
                                fillColor: AppTheme.softPink.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppTheme.deepRose, width: 1.8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                              child: Text(
                                _selectedEndDate != null
                                    ? DateFormat('MMM d, y').format(_selectedEndDate!)
                                    : 'Select a date',
                                style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepRose),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.roseGold),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.roseGold,
                            foregroundColor: AppTheme.creamWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            task == null ? 'Add' : 'Update',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.creamWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _deleteTask(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: _getTextDirection('Delete Task'),
                  child: Text(
                    'Delete Task',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: AppTheme.deepRose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Directionality(
                  textDirection: _getTextDirection('Are you sure you want to delete this task?'),
                  child: Text(
                    'Are you sure you want to delete this task?',
                    style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.deepRose),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.roseGold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepRose,
                        foregroundColor: AppTheme.creamWhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete ?? false) {
      final taskBox = await Hive.openBox<TaskModel>('tasks');
      await taskBox.delete(taskId);
      if (mounted) setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: _getTextDirection('Task deleted successfully'),
            child: Text(
              'Task deleted successfully',
              style: GoogleFonts.montserrat(color: AppTheme.creamWhite),
            ),
          ),
          backgroundColor: AppTheme.deepRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
    }
    return shouldDelete;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalSpacing = screenHeight * 0.015;
    final horizontalPadding = screenWidth * 0.04;
    final taskItemPadding = screenWidth * 0.02;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Directionality(
          textDirection: _getTextDirection('Rozana Ke Kaam'),
          child: Text(
            'Rozana Ke Kaam',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: AppTheme.deepRose,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: AppTheme.creamWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.creamWhite.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.roseGold, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.softPink.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
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
                      border: Border.all(color: AppTheme.deepRose, width: 1.8),
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
                      fontSize: 14,
                      color: AppTheme.deepRose,
                      fontWeight: FontWeight.w600,
                    ),
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(color: AppTheme.roseGold),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: GoogleFonts.montserrat(color: AppTheme.roseGold, fontSize: 12),
                    leftChevronIcon: const Icon(Icons.chevron_left, size: 20, color: AppTheme.roseGold),
                    rightChevronIcon: const Icon(Icons.chevron_right, size: 20, color: AppTheme.roseGold),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.montserrat(color: AppTheme.deepRose, fontSize: 12),
                    weekendStyle: GoogleFonts.montserrat(color: AppTheme.deepRose, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: _getTextDirection(
                          'Tasks for ${DateFormat('MMM d, y').format(_selectedDay)}',
                        ),
                        child: Text(
                          'Tasks for ${DateFormat('MMM d, y').format(_selectedDay)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: AppTheme.deepRose,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<Box<TaskModel>>(
                      valueListenable: Hive.box<TaskModel>('tasks').listenable(),
                      builder: (context, box, _) {
                        final taskCount = box.values
                            .where((task) => isSameDay(task.endDate, _selectedDay))
                            .length;
                        return Chip(
                          backgroundColor: AppTheme.roseGold.withOpacity(0.2),
                          label: Text(
                            '$taskCount',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.deepRose,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppTheme.roseGold),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Container(
                child: ValueListenableBuilder<Box<TaskModel>>(
                  valueListenable: Hive.box<TaskModel>('tasks').listenable(),
                  builder: (context, box, _) {
                    final tasks = box.values.where((task) => isSameDay(task.endDate, _selectedDay)).toList()
                      ..sort((a, b) => a.endDate.compareTo(b.endDate));

                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 40,
                              color: AppTheme.roseGold.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Directionality(
                              textDirection: _getTextDirection('No tasks for this day'),
                              child: Text(
                                'No tasks for this day',
                                style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.deepRose),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Directionality(
                              textDirection: _getTextDirection('Tap + to add a new task'),
                              child: Text(
                                'Tap + to add a new task',
                                style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.vintageSepia),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: verticalSpacing * 2,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: taskItemPadding * 0.5),
                          child: Dismissible(
                            key: Key(task.id),
                            background: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.deepRose.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(Icons.delete, color: AppTheme.creamWhite, size: 20),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _deleteTask(task.id) ?? false;
                            },
                            child: Card(
                              color: task.isCompleted
                                  ? AppTheme.creamWhite.withOpacity(0.7)
                                  : AppTheme.creamWhite.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: task.isCompleted
                                      ? AppTheme.vintageSepia.withOpacity(0.5)
                                      : AppTheme.roseGold,
                                  width: 1.2,
                                ),
                              ),
                              elevation: 3,
                              shadowColor: AppTheme.softPink.withOpacity(0.3),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: taskItemPadding,
                                  vertical: 8,
                                ),
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (value) => _toggleTaskCompletion(task),
                                  activeColor: AppTheme.roseGold,
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                title: Directionality(
                                  textDirection: _getTextDirection(task.title),
                                  child: Text(
                                    task.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: task.isCompleted ? AppTheme.vintageSepia : AppTheme.deepRose,
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.details.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Directionality(
                                        textDirection: _getTextDirection(task.details),
                                        child: Text(
                                          task.details,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: AppTheme.vintageSepia,
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: AppTheme.vintageSepia),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Directionality(
                                            textDirection: _getTextDirection(
                                              DateFormat('MMM d, y').format(task.endDate),
                                            ),
                                            child: Text(
                                              DateFormat('MMM d, y').format(task.endDate),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: AppTheme.vintageSepia,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.person_outline, size: 12, color: AppTheme.vintageSepia),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Directionality(
                                            textDirection: _getTextDirection(task.editedBy),
                                            child: Text(
                                              task.editedBy.split('@')[0],
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: AppTheme.vintageSepia,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit, color: AppTheme.roseGold, size: 20),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTaskDialog(),
        backgroundColor: AppTheme.roseGold,
        elevation: 3,
        tooltip: 'Add Task',
        child: Icon(Icons.add, color: AppTheme.creamWhite, size: 24),
      ),
    );
  }
}

double max(double a, double b) => a > b ? a : b;
