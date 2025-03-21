import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'navigationdrawer.dart';
import 'schedule_capsule.dart';
import 'AI_Assistant.dart';
import 'my_diary.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  bool isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      userEmail = user.email;

      try {
        DatabaseEvent event = await _databaseRef.child(uid).once();
        if (event.snapshot.value != null) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            userName = userData["name"] ?? "User";
            isLoading = false;
          });
        } else {
          setState(() {
            userName = "User";
            isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          userName = "User";
          isLoading = false;
        });
      }
    }
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: userName ?? "User",
        userEmail: userEmail ?? "Not Available",
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 30),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/logo.png"),
                      radius: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "${getGreeting()}, ${userName ?? 'User'} 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildFeatureCard(Icons.schedule, "Schedule Capsule", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ScheduleCapsuleScreen()));
                      }),
                      _buildFeatureCard(Icons.smart_toy, "AI Assistant", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AIMessageAssistantPage()));
                      }),
                      _buildFeatureCard(Icons.book, "My Diary", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyDiaryScreen()));
                      }),
                      _buildFeatureCard(Icons.history, "View History", () {
                        // Add navigation when View History screen is implemented
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {},
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
