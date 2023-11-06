import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_sqflite/database/database.dart';
import 'package:todo_app_sqflite/screens/home_screen.dart';

import '../model/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  AddNoteScreen({this.note, this.updateNoteList});
  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String priority = 'Low';
  String btnText = 'Add Note';
  String titleText = 'Add Note';

  DateTime _date = DateTime.now();

  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyy');
  List<String> _priorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
    // Call updateNoteList if it's not null
    if (widget.updateNoteList != null) {
      widget.updateNoteList!();
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('$_title, $_date, $priority');

      Note note = Note(title: _title, date: _date, priority: priority);

      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;

        DatabaseHelper.instance.updateNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      }
      // Call updateNoteList if it's not null
      if (widget.updateNoteList != null) {
        widget.updateNoteList!();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      priority = widget.note!.priority!;

      setState(() {
        btnText = "Update Note";
        titleText = "Update Note";
      });
    } else {
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  titleText,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.sp),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 18.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please enter a note title'
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.sp),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 18.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.sp,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                ),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            //color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(
                              fontSize: 18.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (input) => priority == null
                              ? 'Please Select a priority level'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              priority = value.toString();
                            });
                          },
                          value: priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.h),
                        height: 60.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          child: Text(
                            btnText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                            ),
                          ),
                          onPressed: _submit,
                        ),
                      ),
                      widget.note != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20.sp),
                              height: 60.sp,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                child: Text(
                                  "Delete Note",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                  ),
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink(),
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
