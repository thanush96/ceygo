import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Profile"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           children: [
             const CircleAvatar(
               radius: 50,
               backgroundImage: AssetImage('assets/images/user.png'), // Placeholder
               child: Icon(Icons.person, size: 50, color: Colors.grey),
             ),
             const SizedBox(height: 16),
             const Text("John Doe", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
             const Text("john.doe@example.com", style: TextStyle(color: Colors.grey)),
             
             const SizedBox(height: 32),
             
             _ProfileTile(icon: Icons.person_outline, title: "Edit Profile", onTap: () {}),
             _ProfileTile(icon: Icons.history, title: "Booking History", onTap: () {}),
             _ProfileTile(icon: Icons.notifications_outlined, title: "Notifications", onTap: () {}),
             _ProfileTile(icon: Icons.language, title: "Language", onTap: () {}),
             _ProfileTile(icon: Icons.logout, title: "Logout", onTap: () => context.go('/')),
           ],
         ),
      ),
    ));
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
