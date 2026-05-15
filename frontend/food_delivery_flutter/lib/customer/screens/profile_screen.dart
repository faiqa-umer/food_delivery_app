import 'package:flutter/material.dart';
import '/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isEditMode = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    fetchProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void fetchProfile() async {
    setState(() => isLoading = true);
    final response = await ApiService.getProfile();

    if (!mounted) return; 
    setState(() {
      isLoading = false;
      if (response["success"] == true && response["user"] != null) {
        user = response["user"];
        nameController.text = user!["name"] ?? "";
        phoneController.text = user!["phone"] ?? "";
      } else {
        user = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Failed to load profile"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void saveProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.updateProfile(
      name: name,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (response["success"] == true) {
      setState(() {
        user = response["user"];
        isEditMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response["message"] ?? "Failed to update profile"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void logout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    await ApiService.logout();
    if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFFF4D00),
        elevation: 0,
        actions: [
          if (!isEditMode && user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => isEditMode = true);
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("Profile not found"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchProfile,
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFFF4D00),
                              Colors.orange[400]!,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                (user!["name"] as String).isNotEmpty
                                    ? user!["name"][0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  color: Color(0xFFFF4D00),
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (!isEditMode) ...[
                              Text(
                                user!["name"] ?? "User",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user!["email"] ?? "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Profile Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode) ...[
                              const Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.phone),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFF4D00),
                                      ),
                                      child: const Text("Save Changes"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditMode = false;
                                          nameController.text =
                                              user!["name"] ?? "";
                                          phoneController.text =
                                              user!["phone"] ?? "";
                                        });
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Display Mode
                              _buildInfoCard(
                                icon: Icons.email,
                                label: "Email",
                                value: user!["email"] ?? "N/A",
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.phone,
                                label: "Phone",
                                value: user!["phone"] ?? "Not provided",
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.badge,
                                label: "User ID",
                                value: user!["user_id"] ?? "N/A",
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.verified,
                                label: "Role",
                                value: (user!["role"] ?? "customer")
                                    .toString()
                                    .toUpperCase(),
                              ),
                              const SizedBox(height: 30),
                              // Menu Items
                              _buildMenuCard(
                                icon: Icons.shopping_bag,
                                title: "My Orders",
                                onTap: () {
                                  // Navigate to orders screen
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildMenuCard(
                                icon: Icons.payment,
                                title: "Payment Methods",
                                onTap: () {
                                  // Navigate to payments screen
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildMenuCard(
                                icon: Icons.location_on,
                                title: "Saved Addresses",
                                onTap: () {
                                  // Navigate to addresses screen
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildMenuCard(
                                icon: Icons.notifications,
                                title: "Notifications",
                                onTap: () {
                                  // Navigate to notifications screen
                                },
                              ),
                            ],
                            const SizedBox(height: 30),
                            // Logout Button (always visible)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout, size: 18),
                                    SizedBox(width: 10),
                                    Text("Logout"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF4D00), size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF4D00)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
