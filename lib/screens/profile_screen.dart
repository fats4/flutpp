import 'package:flutpp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 20),
            Text('Email: ${user?.email ?? ""}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Role: ${user?.role == UserRole.admin ? "Admin" : "User"}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: () async {
                await authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
