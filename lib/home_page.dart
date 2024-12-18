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
    {'name': 'Natural Language Processing', 'credits': 6},
    {'name': 'Image Processing And Recognition', 'credits': 8},
    {'name': 'Intelligent Robotic Science', 'credits': 10},
    {'name': 'Computer Vision', 'credits': 6},
    {'name': 'Deep Learning', 'credits': 12},
    {'name': 'Programming Language', 'credits': 10},
  ];

  int totalCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalCredits();
  }

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
            colors: [Colors.teal.shade700, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 30),
              _buildEnrollmentOptions(),
              SizedBox(height: 20),
              _buildSubjectGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // Header section with welcome text and dynamic user ID display
  Widget _buildHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.teal.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, Student!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your ID: ${widget.userId}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enrollment options buttons (Enroll Now, View Enrolled Subjects)
  Widget _buildEnrollmentOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton('Enroll Now', Colors.teal, Icons.add, () => _showCatalog('Enroll')),
        _buildActionButton('View Enrolled', Colors.orangeAccent, Icons.book, () => _showCatalog('Enrolled Subjects')),
      ],
    );
  }

  // Custom button with dynamic design and action
  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Subject Grid section for showing subjects
  Widget _buildSubjectGrid() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _enroll(subjects[index]['name'], subjects[index]['credits']),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 40, color: Colors.teal),
                    SizedBox(height: 10),
                    Text(
                      subjects[index]['name'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Credits: ${subjects[index]['credits']}',
                      style: TextStyle(fontSize: 14, color: Colors.teal.shade600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
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
