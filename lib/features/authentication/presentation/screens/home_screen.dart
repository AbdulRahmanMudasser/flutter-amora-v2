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
      _selectedEndDate = _selectedDay;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final fontScaleFactor = isLargeScreen ? 1.3 : 1.0;
    final dialogWidth = isLargeScreen ? screenWidth * 0.5 : screenWidth * 0.9;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: max((screenWidth - dialogWidth) / 2, 16),
            vertical: 16,
          ),
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: _getTextDirection(task == null ? 'Add Task' : 'Edit Task'),
                      child: Text(
                        task == null ? 'Add Task' : 'Edit Task',
                        style: GoogleFonts.montserrat(
                          fontSize: isLargeScreen ? 24 : 20,
                          color: AppTheme.deepRose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 24 : 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              prefixIcon: const Icon(Icons.task, color: AppTheme.roseGold),
                              filled: true,
                              fillColor: AppTheme.softPink.withValues(alpha: 0.2),
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
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * fontScaleFactor,
                              color: AppTheme.deepRose,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a task title';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          TextFormField(
                            controller: _detailsController,
                            decoration: InputDecoration(
                              labelText: 'Details',
                              prefixIcon: const Icon(Icons.description, color: AppTheme.roseGold),
                              filled: true,
                              fillColor: AppTheme.softPink.withValues(alpha: 0.2),
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
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * fontScaleFactor,
                              color: AppTheme.deepRose,
                            ),
                            maxLines: isLargeScreen ? 4 : 3,
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),
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
                                prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.roseGold),
                                filled: true,
                                fillColor: AppTheme.softPink.withValues(alpha: 0.2),
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
                                    ? DateFormat('MMMM d, y').format(_selectedEndDate!)
                                    : 'Select a date',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16 * fontScaleFactor,
                                  color: AppTheme.deepRose,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 24 : 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * fontScaleFactor,
                              color: AppTheme.roseGold,
                            ),
                          ),
                        ),
                        SizedBox(width: isLargeScreen ? 16 : 8),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.softPink.withValues(alpha: 0.4),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 24 : 16,
                              vertical: isLargeScreen ? 16 : 12,
                            ),
                          ),
                          child: Text(
                            task == null ? 'Add' : 'Update',
                            style: GoogleFonts.montserrat(
                              fontSize: 16 * fontScaleFactor,
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

  Future _deleteTask(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 600;
        return Dialog(
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? screenWidth * 0.3 : 16,
            vertical: 16,
          ),
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: _getTextDirection('Delete Task'),
                  child: Text(
                    'Delete Task',
                    style: GoogleFonts.montserrat(
                      fontSize: isLargeScreen ? 22 : 18,
                      color: AppTheme.deepRose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: isLargeScreen ? 24 : 16),
                Directionality(
                  textDirection: _getTextDirection('Are you sure you want to delete this task?'),
                  child: Text(
                    'Are you sure you want to delete this task?',
                    style: GoogleFonts.montserrat(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: AppTheme.deepRose,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 24 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.montserrat(
                          fontSize: isLargeScreen ? 16 : 14,
                          color: AppTheme.roseGold,
                        ),
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepRose,
                        foregroundColor: AppTheme.creamWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 24 : 16,
                          vertical: isLargeScreen ? 16 : 12,
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.montserrat(
                          fontSize: isLargeScreen ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.3
                : 16,
            vertical: 16,
          ),
        ),
      );
    }
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
    final isLargeScreen = screenWidth > 600;
    final fontScaleFactor = isLargeScreen ? 1.3 : 1.0;
    final verticalSpacing = screenHeight * (isLargeScreen ? 0.03 : 0.02);
    final horizontalPadding = screenWidth * (isLargeScreen ? 0.1 : 0.05);
    final taskItemPadding = screenWidth * (isLargeScreen ? 0.04 : 0.03);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Directionality(
          textDirection: _getTextDirection('Rozana Ke Kaam'),
          child: Text(
            'Rozana Ke Kaam',
            style: GoogleFonts.montserrat(
              fontSize: isLargeScreen ? 28 : 22,
              color: AppTheme.deepRose,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: AppTheme.creamWhite,
        elevation: 0,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
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
            image: AssetImage('assets/images/backgrounds/bg-1.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing * 0.5,
              ),
              decoration: BoxDecoration(
                color: AppTheme.creamWhite.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.roseGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.softPink.withValues(alpha: 0.3),
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
                    color: AppTheme.roseGold.withValues(alpha: 0.5),
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
                  outsideTextStyle: GoogleFonts.montserrat(color: AppTheme.vintageSepia.withValues(alpha: 0.5)),
                  weekendTextStyle: GoogleFonts.montserrat(color: AppTheme.deepRose),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.montserrat(
                    fontSize: isLargeScreen ? 20 : 16,
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
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    size: isLargeScreen ? 28 : 24,
                    color: AppTheme.roseGold,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    size: isLargeScreen ? 28 : 24,
                    color: AppTheme.roseGold,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.montserrat(color: AppTheme.deepRose),
                  weekendStyle: GoogleFonts.montserrat(color: AppTheme.deepRose),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: _getTextDirection('Tasks for ${DateFormat('MMMM d, y').format(_selectedDay)}'),
                    child: Text(
                      'Tasks for ${DateFormat('MMMM d, y').format(_selectedDay)}',
                      style: GoogleFonts.montserrat(
                        fontSize: isLargeScreen ? 20 : 16,
                        color: AppTheme.deepRose,
                        fontWeight: FontWeight.w600,
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
                        backgroundColor: AppTheme.roseGold.withValues(alpha: 0.2),
                        label: Text(
                          '$taskCount',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.deepRose,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.roseGold),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 12 : 8,
                          vertical: isLargeScreen ? 8 : 4,
                        ),
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 8 : 4,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: isLargeScreen ? 64 : 48,
                            color: AppTheme.roseGold.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: isLargeScreen ? 24 : 16),
                          Directionality(
                            textDirection: _getTextDirection('No tasks for this day'),
                            child: Text(
                              'No tasks for this day',
                              style: GoogleFonts.montserrat(
                                fontSize: isLargeScreen ? 20 : 16,
                                color: AppTheme.deepRose,
                              ),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 12 : 8),
                          Directionality(
                            textDirection: _getTextDirection('Tap + to add a new task'),
                            child: Text(
                              'Tap + to add a new task',
                              style: GoogleFonts.montserrat(
                                fontSize: isLargeScreen ? 16 : 14,
                                color: AppTheme.vintageSepia,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
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
                              color: AppTheme.deepRose.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: isLargeScreen ? 32 : 20),
                            child: Icon(
                              Icons.delete,
                              color: AppTheme.creamWhite,
                              size: isLargeScreen ? 28 : 24,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _deleteTask(task.id) != null;
                          },
                          child: Card(
                            color: task.isCompleted
                                ? AppTheme.creamWhite.withValues(alpha: 0.7)
                                : AppTheme.creamWhite.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: task.isCompleted
                                    ? AppTheme.vintageSepia.withValues(alpha: 0.5)
                                    : AppTheme.roseGold,
                                width: 1.5,
                              ),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.softPink.withValues(alpha: 0.3),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: taskItemPadding,
                                vertical: isLargeScreen ? 16 : 12,
                              ),
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => _toggleTaskCompletion(task),
                                activeColor: AppTheme.roseGold,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              title: Directionality(
                                textDirection: _getTextDirection(task.title),
                                child: Text(
                                  task.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    color: task.isCompleted
                                        ? AppTheme.vintageSepia
                                        : AppTheme.deepRose,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (task.details.isNotEmpty) ...[
                                    SizedBox(height: isLargeScreen ? 8 : 4),
                                    Directionality(
                                      textDirection: _getTextDirection(task.details),
                                      child: Text(
                                        task.details,
                                        style: GoogleFonts.montserrat(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          color: AppTheme.vintageSepia,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                        maxLines: isLargeScreen ? 3 : 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: isLargeScreen ? 8 : 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: isLargeScreen ? 16 : 12,
                                        color: AppTheme.vintageSepia,
                                      ),
                                      SizedBox(width: isLargeScreen ? 8 : 4),
                                      Directionality(
                                        textDirection: _getTextDirection(DateFormat('MMM d, y').format(task.endDate)),
                                        child: Text(
                                          DateFormat('MMM d, y').format(task.endDate),
                                          style: GoogleFonts.montserrat(
                                            fontSize: isLargeScreen ? 14 : 12,
                                            color: AppTheme.vintageSepia,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.person_outline,
                                        size: isLargeScreen ? 16 : 12,
                                        color: AppTheme.vintageSepia,
                                      ),
                                      SizedBox(width: isLargeScreen ? 8 : 4),
                                      Directionality(
                                        textDirection: _getTextDirection(task.editedBy),
                                        child: Text(
                                          task.editedBy.split('@')[0],
                                          style: GoogleFonts.montserrat(
                                            fontSize: isLargeScreen ? 14 : 12,
                                            color: AppTheme.vintageSepia,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppTheme.roseGold,
                                  size: isLargeScreen ? 28 : 24,
                                ),
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
        elevation: 4,
        tooltip: 'Add Task',
        child: Icon(
          Icons.add,
          color: AppTheme.creamWhite,
          size: isLargeScreen ? 32 : 28,
        ),
      ),
    );
  }
}

double max(double a, double b) => a > b ? a : b;