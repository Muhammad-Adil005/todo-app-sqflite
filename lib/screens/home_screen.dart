import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_sqflite/database/database.dart';

import '../model/note_model.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget _buildNote(Note note, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        children: [
          ListTile(
            title: Text(
              note.title!,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(note.date!)} - ${note.priority}',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                note.status = value! ? 1 : 0;
                DatabaseHelper.instance.updateNote(note);
                _updateNoteList();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              activeColor: Theme.of(context).primaryColor,
              value: note.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AddNoteScreen(
                  updateNoteList: _updateNoteList(),
                  note: note,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.deepPurple,
            thickness: 2,
            height: 5.h,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNoteScreen(
                  updateNoteList: _updateNoteList,
                ),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _noteList,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final int completeNoteCount = snapshot.data!
                .where((Note note) => note.status == 1)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.h),
              // itemCount: 10,
              itemCount: int.parse(snapshot.data.length.toString()) + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Notes ',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '$completeNoteCount of ${snapshot.data.length}',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildNote(snapshot.data[index - 1], index);
              },
            );
          },
        ));
  }
}
