import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child("users");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ✅ Register User Manually (Save to Firebase Database)
  void registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Check if email already exists
      DatabaseEvent event =
          await _dbRef.orderByChild("email").equalTo(email).once();
      if (event.snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email already registered! Please log in.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Generate unique user ID manually
      String userId = _dbRef.push().key!;

      // ✅ Store user data in Firebase Realtime Database
      await _dbRef.child(userId).set({
        "uid": userId,
        "name": name,
        "email": email,
        "password": password, // 🔹 Not recommended for production (hash it)
        "created_at": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );

      // ✅ Navigate to Login Page
      Navigator.pushReplacement(
        context,
        PageTransition(type: PageTransitionType.fade, child: LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  // ✅ Google Sign-In (Without FirebaseAuth)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      // ✅ Check if Google email already exists
      DatabaseEvent event =
          await _dbRef.orderByChild("email").equalTo(googleUser.email).once();
      if (event.snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Google account already registered! Please log in.")),
        );
        return;
      }

      String userId = _dbRef.push().key!; // Generate a unique ID

      // ✅ Save Google User Data in Firebase Database
      await _dbRef.child(userId).set({
        "uid": userId,
        "name": googleUser.displayName ?? "",
        "email": googleUser.email,
        "created_at": DateTime.now().toIso8601String(),
      });

      Navigator.pushReplacement(
        context,
        PageTransition(type: PageTransitionType.fade, child: LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Create Account",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_nameController, "Full Name", Icons.person),
                  SizedBox(height: 10),
                  _buildTextField(
                      _emailController, "Email Address", Icons.email),
                  SizedBox(height: 10),
                  _buildTextField(_passwordController, "Password", Icons.lock,
                      isPassword: true),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: registerUser,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Or sign up with",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("assets/google.png", signInWithGoogle),
                      SizedBox(width: 20),
                      _buildSocialButton("assets/facebook.png", () {}),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade, child: LoginPage()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(assetPath, width: 50, height: 50),
    );
  }
}
