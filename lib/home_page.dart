import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'enrollment_model.dart';

class HomePage extends StatefulWidget {
  final int userId;
  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> subjects = [
    {'name': 'Mathematics', 'credits': 6},
    {'name': 'Physics', 'credits': 8},
    {'name': 'Computer Science', 'credits': 6},
    {'name': 'History', 'credits': 4},
    {'name': 'DSA', 'credits': 10},
  ];

  int totalCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalCredits();
  }

  // Load total credits from the database to show the current enrollment
  Future<void> _loadTotalCredits() async {
    List<Map<String, dynamic>> enrollments = await _getEnrollments();
    int credits = enrollments.fold<int>(0, (sum, enrollment) {
      return sum + (enrollment['credits'] as int);
    });
    setState(() {
      totalCredits = credits;
    });
  }

  Future<void> _enroll(String subject, int credits) async {
    if (totalCredits + credits > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot enroll for more than 24 credits')),
      );
    } else {
      Enrollment enrollment = Enrollment(userId: widget.userId, subject: subject, credits: credits);
      await DatabaseHelper.instance.insertEnrollment(enrollment.toMap());
      setState(() {
        totalCredits += credits;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getEnrollments() async {
    return await DatabaseHelper.instance.queryEnrollments(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Your Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'User ID: ${widget.userId}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () => _showCatalog('Enroll'),
                    child: Text('Enroll Now', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () => _showCatalog('Enrolled Subjects'),
                    child: Text('View Enrolled Subjects', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCatalog(String type) async {
    if (type == 'Enroll') {
      if (totalCredits >= 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have reached the maximum credit limit')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Subjects'),
            content: Column(
              children: subjects.map((subject) {
                return ListTile(
                  title: Text(subject['name']),
                  subtitle: Text('Credits: ${subject['credits']}'),
                  onTap: () => _enroll(subject['name'], subject['credits']),
                );
              }).toList(),
            ),
          );
        },
      );
    } else {
      List<Map<String, dynamic>> enrollments = await _getEnrollments();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enrolled Subjects'),
            content: Column(
              children: enrollments.map((enrollment) {
                return ListTile(
                  title: Text(enrollment['subject']),
                  subtitle: Text('Credits: ${enrollment['credits']}'),
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }
}
