import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;

  const CustomDrawer({super.key, required this.userName, required this.userEmail});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String profilePic = "assets/profile.jpg"; // Default profile pic

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child("users");

  @override
  void initState() {
    super.initState();
    _fetchUserProfilePic();
  }

  Future<void> _fetchUserProfilePic() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      _databaseRef.child(userId).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            profilePic = data["profilePic"] ??
                "assets/profile.jpg"; // Load profile pic if available
          });
        }
      }).catchError((error) {
        print("Error fetching profile pic: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(profilePic),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(Icons.home, "Home", () {
                  Navigator.pushReplacementNamed(context, "/home");
                }),
                _buildDrawerItem(Icons.drafts, "Drafts", () {
                  Navigator.pushNamed(context, "/drafts");
                }),
                _buildDrawerItem(Icons.contacts, "Recipients", () {
                  Navigator.pushNamed(context, "/recipients");
                }),
                _buildDrawerItem(Icons.notifications, "Notifications", () {
                  Navigator.pushNamed(context, "/notifications");
                }),
                _buildDrawerItem(Icons.lock, "Privacy & Security", () {
                  Navigator.pushNamed(context, "/privacy");
                }),
                _buildDrawerItem(Icons.settings, "App Settings", () {
                  Navigator.pushNamed(context, "/settings");
                }),
                _buildDrawerItem(Icons.help, "Help & Support", () {
                  Navigator.pushNamed(context, "/help");
                }),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
