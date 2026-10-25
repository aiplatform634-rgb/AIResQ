import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  bool availableForEmergency = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism),
            SizedBox(width: 10),
            Text(
              'ResQAI Responder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
  icon: const Icon(Icons.logout),
  tooltip: 'Sign Out',
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
  },
),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= WELCOME =================
              const Text(
                'Welcome, Responder 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Help people who need emergency assistance.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // ================= VOLUNTEER ID =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD32F2F),
                      Color(0xFFFF5252),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Responder ID',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Text(
                      'RSQ-000001',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Keep your ResQAI ID safe.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ================= AVAILABILITY =================
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  value: availableForEmergency,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      availableForEmergency = value;
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: availableForEmergency
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    child: Icon(
                      availableForEmergency
                          ? Icons.check
                          : Icons.pause,
                      color: availableForEmergency
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  title: const Text(
                    'Available for Emergency Response',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    availableForEmergency
                        ? 'You can receive emergency requests'
                        : 'You are currently unavailable',
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ================= EMERGENCY REQUESTS =================
              const Text(
                'Emergency Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Request 1
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Colors.red,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Medical Emergency',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2.5 km away',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'HIGH',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Person needs urgent medical assistance.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Request declined',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('DENY'),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Request accepted',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('ACCEPT'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= QUICK ACTIONS =================
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _quickAction(
                      icon: Icons.location_on,
                      title: 'My Location',
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.history,
                      title: 'My History',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _quickAction(
                      icon: Icons.people,
                      title: 'My Team',
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.person,
                      title: 'My Profile',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ================= INFO =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Emergency requests will be matched with you based on your services, location, availability and emergency type.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Together, we respond faster.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================= QUICK ACTION CARD =================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [

            Icon(
              icon,
              color: Colors.red,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}