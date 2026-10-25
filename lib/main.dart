import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'account_type_page.dart';
import 'volunteer_home_page.dart';
import 'volunteer_registration_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ResQAI());
}

class ResQAI extends StatelessWidget {
  const ResQAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResQAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

   if (!snapshot.hasData) {
  return AccountTypePage(
  userPage: const LoginPage(),
  volunteerLoginPage: const LoginPage(),
);
}

return FutureBuilder<IdTokenResult>(
  future: snapshot.data!.getIdTokenResult(true),
  builder: (context, roleSnapshot) {
    if (roleSnapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (roleSnapshot.hasError) {
      return const HomePage();
    }
final claims = roleSnapshot.data?.claims ?? {};

// Admin comes first
if (claims['role'] == 'owner' || claims['admin'] == true) {
  return const OwnerDashboard();
}

// Check if this Firebase account is a Responder
return FutureBuilder<SharedPreferences>(
  future: SharedPreferences.getInstance(),
  builder: (context, prefsSnapshot) {
    if (prefsSnapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final prefs = prefsSnapshot.data;

    final user = snapshot.data;

final isRegisteredResponder = user != null &&
    prefs?.getBool('responder_registered_${user.uid}') == true;

if (user == null) {
 return AccountTypePage(
  userPage: LoginPage(),
  volunteerLoginPage: VolunteerRegistrationPage(),
);
}

if (isRegisteredResponder) {
  return const VolunteerHomePage();
}

return const HomePage();
}



    // Normal Firebase user
);
  },
);
  },
),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool locationEnabled = false;

  double? latitude;
  double? longitude;

  // ================= GET LOCATION =================

  Future<void> enableLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please turn ON Location/GPS and try again.',
          ),
        ),
      );

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission was denied.',
          ),
        ),
      );

      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is permanently denied. '
            'Please enable it from App Settings.',
          ),
        ),
      );

      await Geolocator.openAppSettings();
      return;
    }

    try {
      Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        locationEnabled = true;
        latitude = position.latitude;
        longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location found!\n'
            'Latitude: ${position.latitude.toStringAsFixed(5)}\n'
            'Longitude: ${position.longitude.toStringAsFixed(5)}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not get location: $e',
          ),
        ),
      );
    }
  }

  // ================= HOME PAGE =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              'ResQAI',
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
    icon: const CircleAvatar(
      radius: 16,
      child: Icon(
        Icons.person,
        size: 20,
      ),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    },
  ),

  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () async {
      await FirebaseAuth.instance.signOut();
    },
  ),
],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Emergency Response System',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Get help when you need it most.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            // ================= SOS =================

            SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                      title: const Text(
                        '🚨 Emergency SOS',
                      ),
                      content: const Text(
                        'Emergency assistance will be requested.\n\n'
                        'Your location can be shared with '
                        'emergency responders.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child:
                              const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'SOS request sent!',
                                ),
                              ),
                            );
                          },
                          child:
                              const Text('SEND SOS'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 45,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'SOS EMERGENCY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ================= SERVICES =================

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [

                ServiceCard(
                  icon: Icons.local_hospital,
                  title: 'Hospitals',
                  subtitle:
                      'Find available hospitals',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const HospitalPage(),
                      ),
                    );
                  },
                ),

                ServiceCard(
                  icon: Icons.bloodtype,
                  title: 'Blood',
                  subtitle:
                      'Check blood availability',
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BloodPage(),
                      ),
                    );
                  },
                ),

                ServiceCard(
                  icon:
                      Icons.volunteer_activism,
                  title: 'Donate Blood',
                  subtitle: 'Become a donor',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DonateBloodPage(),
                      ),
                    );
                  },
                ),

                ServiceCard(
                  icon: Icons.home,
                  title: 'Shelters',
                  subtitle:
                      'Find nearby shelters',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ShelterPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ================= REQUEST HELP =================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.sos),
                label: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Request Emergency Help',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RequestHelpPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ================= VOLUNTEER =================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.groups),
                label: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Volunteer / Help Others',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VolunteerRegistrationPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ================= LOCATION =================

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                title: const Text(
                  'Location Services',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  locationEnabled &&
                          latitude != null &&
                          longitude != null
                      ? 'Location detected'
                      : 'Enable location for nearby emergency services',
                ),
                trailing: Switch(
                  value: locationEnabled,
                  onChanged: (value) {
                    if (value) {
                      enableLocation();
                    } else {
                      setState(() {
                        locationEnabled = false;
                        latitude = null;
                        longitude = null;
                      });
                    }
                  },
                ),
              ),
            ),

            // ================= LOCATION DETAILS =================

            if (locationEnabled &&
                latitude != null &&
                longitude != null)
              Card(
                margin:
                    const EdgeInsets.only(top: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.gps_fixed,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Latitude: ${latitude!.toStringAsFixed(5)}\n'
                    'Longitude: ${longitude!.toStringAsFixed(5)}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================= SERVICE CARD =================

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 35,
                color: color,
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HOSPITAL PAGE =================

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitals = [
      {
        'name': 'City General Hospital',
        'distance': '2.1 km',
        'beds': '12 beds available',
        'icu': '3 ICU beds available',
        'emergency': 'Emergency Open',
      },
      {
        'name':
            'Government Medical Center',
        'distance': '4.5 km',
        'beds': '25 beds available',
        'icu': '5 ICU beds available',
        'emergency': 'Emergency Open',
      },
      {
        'name': 'LifeCare Hospital',
        'distance': '6.2 km',
        'beds': '8 beds available',
        'icu': '1 ICU bed available',
        'emergency': 'Emergency Open',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hospital Availability',
        ),
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.all(16),
        itemCount: hospitals.length,
        itemBuilder:
            (context, index) {
          final hospital =
              hospitals[index];

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 14,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(
                          Icons.local_hospital,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          hospital['name']!,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 12),

                  Text(
                    '📍 ${hospital['distance']}',
                  ),
                  Text(
                    '🛏 ${hospital['beds']}',
                  ),
                  Text(
                    '🏥 ${hospital['icu']}',
                  ),

                  const SizedBox(height: 8),

                  Text(
                    hospital['emergency']!,
                    style:
                        const TextStyle(
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          icon: const Icon(
                            Icons.call,
                          ),
                          label:
                              const Text('Call'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(
                          width: 8),
                      Expanded(
                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.navigation,
                          ),
                          label:
                              const Text(
                            'Navigate',
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= BLOOD PAGE =================

class BloodPage extends StatefulWidget {
  const BloodPage({super.key});

  @override
  State<BloodPage> createState() =>
      _BloodPageState();
}

class _BloodPageState
    extends State<BloodPage> {
  String selectedBlood = 'A+';

  final Map<String, int> bloodUnits = {
    'A+': 12,
    'A-': 4,
    'B+': 9,
    'B-': 3,
    'AB+': 5,
    'AB-': 2,
    'O+': 15,
    'O-': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Availability',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Select Blood Group',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  bloodUnits.keys.map(
                (group) {
                  return ChoiceChip(
                    label: Text(group),
                    selected:
                        selectedBlood ==
                            group,
                    onSelected: (_) {
                      setState(() {
                        selectedBlood =
                            group;
                      });
                    },
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(25),
                child: Center(
                  child: Column(
                    children: [

                      const Icon(
                        Icons.bloodtype,
                        size: 70,
                        color: Colors.red,
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        selectedBlood,
                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 5),

                      Text(
                        '${bloodUnits[selectedBlood]} '
                        'units currently available',
                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                icon: const Icon(
                  Icons.warning,
                ),
                label: const Text(
                  'Request Blood',
                ),
                onPressed: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Blood request created '
                        'for $selectedBlood',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DONATE BLOOD PAGE =================

class DonateBloodPage
    extends StatefulWidget {
  const DonateBloodPage({super.key});

  @override
  State<DonateBloodPage> createState() =>
      _DonateBloodPageState();
}

class _DonateBloodPageState
    extends State<DonateBloodPage> {
  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  String bloodGroup = 'A+';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Donate Blood',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            const Icon(
              Icons.volunteer_activism,
              size: 80,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              'Become a Blood Donor',
              style: TextStyle(
                fontSize: 23,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText: 'Full Name',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText:
                    'Phone Number',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: bloodGroup,
              decoration:
                  const InputDecoration(
                labelText:
                    'Blood Group',
                border:
                    OutlineInputBorder(),
              ),
              items: [
                'A+',
                'A-',
                'B+',
                'B-',
                'AB+',
                'AB-',
                'O+',
                'O-',
              ].map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    bloodGroup =
                        value;
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Thank you! Donor registration '
                        'submitted.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Register as Donor',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

// ================= SHELTER PAGE =================

class ShelterPage extends StatelessWidget {
  const ShelterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shelters = [
      'Government Emergency Shelter',
      'Community Relief Center',
      'Red Cross Relief Shelter',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Shelters',
        ),
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.all(16),
        itemCount: shelters.length,
        itemBuilder:
            (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.orange,
              ),
              title: Text(
                shelters[index],
              ),
              subtitle: Text(
                '${index + 2}.${index + 1} km away',
              ),
              trailing:
                  IconButton(
                icon: const Icon(
                  Icons.navigation,
                ),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= REQUEST HELP PAGE =================

class RequestHelpPage
    extends StatefulWidget {
  const RequestHelpPage({super.key});

  @override
  State<RequestHelpPage> createState() =>
      _RequestHelpPageState();
}

class _RequestHelpPageState
    extends State<RequestHelpPage> {
  String emergencyType =
      'Medical Emergency';

  final descriptionController =
      TextEditingController();
      Future<void> sendEmergencyRequest() async {
  try {
    final position = await Geolocator.getCurrentPosition();

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/emergency'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        'emergency_type': emergencyType,
        'description': descriptionController.text,
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency request sent successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error: ${response.statusCode}'),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Emergency Help',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              initialValue:
                  emergencyType,
              decoration:
                  const InputDecoration(
                labelText:
                    'Emergency Type',
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                'Medical Emergency',
                'Accident',
                'Fire',
                'Natural Disaster',
                'Missing Person',
                'Other',
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    emergencyType =
                        value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  descriptionController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                labelText:
                    'Describe the emergency',
                hintText:
                    'Tell us what happened...',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                title: const Text(
                  'Current Location',
                ),
                subtitle: const Text(
                  'Location will be attached '
                  'to the request',
                ),
                trailing:
                    IconButton(
                  icon: const Icon(
                    Icons.my_location,
                  ),
                  onPressed: () {},
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child:
                  ElevatedButton.icon(
                icon: const Icon(
                  Icons.send,
                ),
                label: const Text(
                  'Send Emergency Request',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
               onPressed: sendEmergencyRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}


// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

   try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text,
  );

  // Clear the login route; the root Firebase auth listener selects the home page.
  // Firebase authentication is successful.
// The root auth listener in main.dart will select the dashboard.
if (!mounted) return;

final user = FirebaseAuth.instance.currentUser;

if (user == null) {
  throw Exception('Login succeeded, but no current user was found.');
}

final prefs = await SharedPreferences.getInstance();

final isVolunteer =
    prefs.getBool('responder_registered_${user.uid}') == true;

if (!mounted) return;

if (isVolunteer) {
  Navigator.of(context).popUntil((route) => route.isFirst);
} else {
  Navigator.of(context).popUntil((route) => route.isFirst);
}
} on FirebaseAuthException catch (e) {
  String message = 'Login failed';

  if (e.code == 'user-not-found') {
    message = 'No account found with this email';
  } else if (e.code == 'wrong-password') {
    message = 'Incorrect password';
  } else if (e.code == 'invalid-credential') {
    message = 'Incorrect email or password';
  } else if (e.code == 'invalid-email') {
    message = 'Please enter a valid email';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
} finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 90,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  'ResQAI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Disaster Response & Volunteer Platform',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'LOGIN',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Create Account",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= REGISTER PAGE =================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await credential.user?.updateDisplayName(
        nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );
      // Clear the registration route; authStateChanges routes this account to HomePage.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.red,
              ),

              const SizedBox(height: 20),

              const Text(
                'Create your ResQAI Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : register,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= BLOCKED USERS PAGE =================

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blocked Users',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Users who are currently blocked from accessing ResQAI.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.block,
                  color: Colors.orange,
                  size: 32,
                ),

                title: const Text(
                  'No blocked users',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  'Blocked users will appear here.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ================= SYSTEM OVERVIEW PAGE =================

class SystemOverviewPage extends StatelessWidget {
  const SystemOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Overview'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ResQAI System Overview',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Overview of ResQAI account statistics.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Colors.blue,
                  size: 32,
                ),
                title: const Text(
                  'Registered Users',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Users registered in ResQAI',
                ),
                trailing: const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                title: const Text(
                  'Active Users',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Users currently allowed to access ResQAI',
                ),
                trailing: const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.block,
                  color: Colors.orange,
                  size: 32,
                ),
                title: const Text(
                  'Blocked Users',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Users currently disabled',
                ),
                trailing: const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ================= OWNER HOME PAGE =================

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResQAI'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),

          // OWNER PROFILE / CONTROL CENTER
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 20,
                color: Colors.red,
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) {
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'ResQAI Owner',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // MANAGE USERS
                            ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: Colors.red,
                              ),
                              title: const Text('Manage Users'),
                              subtitle: const Text(
                                'View and control registered users',
                              ),
                              onTap: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OwnerUsersPage(),
                                  ),
                                );
                              },
                            ),

                            // BLOCKED USERS
                            ListTile(
                              leading: const Icon(
                                Icons.block,
                                color: Colors.orange,
                              ),
                              title: const Text('Blocked Users'),
                              subtitle: const Text(
                                'View blocked accounts',
                              ),
                              onTap: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BlockedUsersPage(),
                                  ),
                                );
                              },
                            ),

                            // SYSTEM OVERVIEW
                            ListTile(
                              leading: const Icon(
                                Icons.analytics,
                                color: Colors.blue,
                              ),
                              title: const Text('System Overview'),
                              subtitle: const Text(
                                'View ResQAI system analytics',
                              ),
                              onTap: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SystemOverviewPage(),
                                  ),
                                );
                              },
                            ),

                            // ACCOUNT & SECURITY
                            ListTile(
                              leading: const Icon(
                                Icons.security,
                                color: Colors.green,
                              ),
                              title: const Text('Account & Security'),
                              subtitle: const Text(
                                'Manage owner account',
                              ),
                              onTap: () {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Account & Security will be added later.',
                                    ),
                                  ),
                                );
                              },
                            ),

                            const Divider(),

                            // LOGOUT
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text('Logout'),
                              onTap: () async {
                                Navigator.pop(context);
                                await FirebaseAuth.instance.signOut();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ================= OWNER HOME CONTENT =================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Disaster Response Control Center',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ================= STATISTICS =================

            Row(
              children: [
                Expanded(
                  child: _ownerStatCard(
                    icon: Icons.people,
                    title: 'Users',
                    value: '25',
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ownerStatCard(
                    icon: Icons.warning_rounded,
                    title: 'Active SOS',
                    value: '4',
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ownerStatCard(
                    icon: Icons.bloodtype,
                    title: 'Blood',
                    value: '12',
                    iconColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ownerStatCard(
                    icon: Icons.local_hospital,
                    title: 'Hospitals',
                    value: '8',
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= EMERGENCY ACTIVITY =================

            const Text(
              'Emergency Activity',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  _activityTile(
                    Icons.warning_rounded,
                    'Emergency Requests',
                    '4',
                  ),
                  _activityTile(
                    Icons.volunteer_activism,
                    'Active Volunteers',
                    '15',
                  ),
                  _activityTile(
                    Icons.home,
                    'Available Shelters',
                    '6',
                  ),
                  _activityTile(
                    Icons.bloodtype,
                    'Blood Requests',
                    '12',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= OWNER CONTROLS =================

            const Text(
              'Quick Owner Controls',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ownerActionCard(
                    context,
                    Icons.people,
                    'Manage Users',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OwnerUsersPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ownerActionCard(
                    context,
                    Icons.block,
                    'Blocked Users',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const BlockedUsersPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _ownerActionCard(
              context,
              Icons.analytics,
              'System Overview',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SystemOverviewPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  static Widget _ownerStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTIVITY TILE =================

  static Widget _activityTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.red,
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= OWNER ACTION CARD =================

  static Widget _ownerActionCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();

  File? profileImage;

  bool editingName = false;
  bool saving = false;

  DateTime? nameChangedAt;
  DateTime? photoChangedAt;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    nameController.text = user?.displayName ?? '';

    final savedImage = prefs.getString('profile_image');

    final savedNameDate = prefs.getString('name_changed_at');
    final savedPhotoDate = prefs.getString('photo_changed_at');

    if (!mounted) return;

    setState(() {
      if (savedImage != null && File(savedImage).existsSync()) {
        profileImage = File(savedImage);
      }

      if (savedNameDate != null) {
        nameChangedAt = DateTime.tryParse(savedNameDate);
      }

      if (savedPhotoDate != null) {
        photoChangedAt = DateTime.tryParse(savedPhotoDate);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool canChange(DateTime? changedAt) {
    if (changedAt == null) return true;

    final difference = DateTime.now().difference(changedAt);

    return difference.inDays >= 7;
  }

  int daysRemaining(DateTime changedAt) {
    final unlockDate = changedAt.add(const Duration(days: 7));
    final remaining = unlockDate.difference(DateTime.now()).inDays;

    return remaining < 1 ? 1 : remaining;
  }

  Future<void> chooseProfilePicture() async {
    if (!canChange(photoChangedAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can change your profile picture again in '
            '${daysRemaining(photoChangedAt!)} day(s).',
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final prefs = await SharedPreferences.getInstance();

    final changedTime = DateTime.now();

    await prefs.setString(
      'profile_image',
      pickedImage.path,
    );

    await prefs.setString(
      'photo_changed_at',
      changedTime.toIso8601String(),
    );

    if (!mounted) return;

    setState(() {
      profileImage = File(pickedImage.path);
      photoChangedAt = changedTime;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile picture updated. You can change it again after 7 days.',
        ),
      ),
    );
  }

  Future<void> saveName() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    if (!canChange(nameChangedAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can change your name again in '
            '${daysRemaining(nameChangedAt!)} day(s).',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();

      final changedTime = DateTime.now();

      await user?.updateDisplayName(name);

      await prefs.setString(
        'name_changed_at',
        changedTime.toIso8601String(),
      );

      if (!mounted) return;

      setState(() {
        nameChangedAt = changedTime;
        editingName = false;
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Name updated. You can change it again after 7 days.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update name: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final nameCanChange = canChange(nameChangedAt);
    final photoCanChange = canChange(photoChangedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ================= PROFILE PICTURE =================

            GestureDetector(
              onTap: chooseProfilePicture,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.red,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: photoCanChange
                          ? Colors.red
                          : Colors.grey,
                      child: Icon(
                        photoCanChange
                            ? Icons.camera_alt
                            : Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              photoCanChange
                  ? 'Tap to change profile picture'
                  : 'Profile picture locked for 7 days',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // ================= NAME =================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              readOnly: !editingName && nameCanChange,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter your name',

                suffixIcon: IconButton(
                  icon: Icon(
                    nameCanChange
                        ? (editingName
                            ? Icons.close
                            : Icons.edit)
                        : Icons.lock,
                  ),
                  onPressed: () {
                    if (!nameCanChange) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'You can change your name again in '
                            '${daysRemaining(nameChangedAt!)} day(s).',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      editingName = !editingName;
                    });
                  },
                ),
              ),
            ),

            if (!nameCanChange) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name locked. You can change it again in '
                  '${daysRemaining(nameChangedAt!)} day(s).',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ================= EMAIL =================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: TextEditingController(
                text: user?.email ?? '',
              ),
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // ================= SAVE =================

            if (editingName)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : saveName,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Save Name'),
                ),
              ),

            const SizedBox(height: 30),

            // ================= LOGOUT =================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Root auth listener returns to account selection.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}// ================= USER PROFILE PAGE =================

class ProfilePageBackup extends StatefulWidget {
  const ProfilePageBackup({super.key});

  @override
  State<ProfilePageBackup> createState() => _ProfilePageBackupState();
}

class _ProfilePageBackupState extends State<ProfilePageBackup> {
  final nameController = TextEditingController();

  File? profileImage;

  bool editingName = false;
  bool savingName = false;

  DateTime? nameChangedAt;
  DateTime? photoChangedAt;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    nameController.text = user?.displayName ?? '';

    final savedImagePath = prefs.getString('profile_image_path');

    if (savedImagePath != null && savedImagePath.isNotEmpty) {
      final file = File(savedImagePath);

      if (await file.exists()) {
        profileImage = file;
      }
    }

    final savedNameDate = prefs.getString('name_changed_at');
    final savedPhotoDate = prefs.getString('photo_changed_at');

    if (savedNameDate != null) {
      nameChangedAt = DateTime.tryParse(savedNameDate);
    }

    if (savedPhotoDate != null) {
      photoChangedAt = DateTime.tryParse(savedPhotoDate);
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool canChangeName() {
    if (nameChangedAt == null) {
      return true;
    }

    final difference = DateTime.now().difference(nameChangedAt!);

    return difference.inDays >= 7;
  }

  bool canChangePhoto() {
    if (photoChangedAt == null) {
      return true;
    }

    final difference = DateTime.now().difference(photoChangedAt!);

    return difference.inDays >= 7;
  }

  String getRemainingTime(DateTime changedAt) {
    final unlockTime = changedAt.add(const Duration(days: 7));
    final remaining = unlockTime.difference(DateTime.now());

    if (remaining.isNegative) {
      return 'You can change it now.';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    if (days > 0) {
      return 'Available in $days day(s) and $hours hour(s)';
    }

    return 'Available in $hours hour(s)';
  }

  Future<void> chooseProfilePicture() async {
    if (!canChangePhoto()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile picture cannot be changed yet.\n'
            '${getRemainingTime(photoChangedAt!)}',
          ),
        ),
      );
      return;
    }

    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'profile_image_path',
      pickedImage.path,
    );

    final now = DateTime.now();

    await prefs.setString(
      'photo_changed_at',
      now.toIso8601String(),
    );

    setState(() {
      profileImage = File(pickedImage.path);
      photoChangedAt = now;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated successfully.'),
      ),
    );
  }

  Future<void> saveName() async {
    if (!canChangeName()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Name cannot be changed yet.\n'
            '${getRemainingTime(nameChangedAt!)}',
          ),
        ),
      );
      return;
    }

    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      savingName = true;
    });

    try {
      await user.updateDisplayName(name);

      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();

      await prefs.setString(
        'name_changed_at',
        now.toIso8601String(),
      );

      if (!mounted) return;

      setState(() {
        nameChangedAt = now;
        editingName = false;
        savingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update name: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final nameUnlocked = canChangeName();
    final photoUnlocked = canChangePhoto();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // PROFILE PHOTO
            GestureDetector(
              onTap: chooseProfilePicture,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.red,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        photoUnlocked
                            ? Icons.camera_alt
                            : Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              photoUnlocked
                  ? 'Tap the picture to choose a photo'
                  : getRemainingTime(photoChangedAt!),
              style: TextStyle(
                color: photoUnlocked ? Colors.grey : Colors.orange,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // NAME
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              enabled: editingName && nameUnlocked,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),

                hintText: 'Enter your name',

                suffixIcon: IconButton(
                  icon: Icon(
                    !nameUnlocked
                        ? Icons.lock
                        : editingName
                            ? Icons.close
                            : Icons.edit,
                  ),

                  onPressed: () {
                    if (!nameUnlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Name cannot be changed yet.\n'
                            '${getRemainingTime(nameChangedAt!)}',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      editingName = !editingName;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                nameUnlocked
                    ? 'You can change your name.'
                    : getRemainingTime(nameChangedAt!),
                style: TextStyle(
                  fontSize: 14,
                  color: nameUnlocked
                      ? Colors.grey
                      : Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SAVE NAME BUTTON
            if (editingName && nameUnlocked)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: savingName ? null : saveName,
                  child: savingName
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Save Name'),
                ),
              ),

            const SizedBox(height: 25),

            // EMAIL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: TextEditingController(
                text: user?.email ?? '',
              ),
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 30),

            // ACCOUNT INFORMATION
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.green,
                ),
                title: const Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Your ResQAI account is protected by Firebase Authentication.',
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LOGOUT
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Root auth listener returns to account selection.
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OwnerUsersPage extends StatelessWidget {
  const OwnerUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ResQAI Users',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'View and control registered users.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),

              title: const Text(
                'Registered User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text('Active'),

              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'block') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Block user selected'),
                      ),
                    );
                  }

                  if (value == 'delete') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Delete user selected'),
                      ),
                    );
                  }
                },

                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('Block User'),
                  ),

                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete User'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}