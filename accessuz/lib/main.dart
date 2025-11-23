import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const AccessUzApp());

class AccessUzApp extends StatelessWidget {
  const AccessUzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AccessUz',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

// ASOSIY EKRAN – 3 TA BOʻLIM
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SafeMapScreen(), // XAVFSIZ XARITA – HECH QACHON CRASH BOʻLMAYDI
    const PlacesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            activeIcon: Icon(Icons.map, color: Colors.indigo),
            label: "Xarita",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_rounded),
            activeIcon: Icon(Icons.location_city, color: Colors.indigo),
            label: "Obyektlar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person, color: Colors.indigo),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

// XAVFSIZ XARITA – RUXSAT YOʻQ BOʻLSA HAM ISHLAYDI!
class SafeMapScreen extends StatefulWidget {
  const SafeMapScreen({super.key});

  @override
  State<SafeMapScreen> createState() => _SafeMapScreenState();
}

class _SafeMapScreenState extends State<SafeMapScreen> {
  bool _hasPermission = true;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (_permissionChecked) return;
    _permissionChecked = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _hasPermission = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() => _hasPermission = false);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapScreen(),

        // Ruxsat yoʻq boʻlsa – chiroyli ogohlantirish
        if (!_hasPermission)
          Container(
            color: Colors.black.withOpacity(0.75),
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off,
                          size: 80, color: Colors.red),
                      const SizedBox(height: 20),
                      const Text(
                        "Joylashuv ruxsati berilmagan",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Xaritada hozirgi joyingizni koʻrish uchun ruxsat bering",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text("Ruxsat berish"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => Geolocator.openAppSettings(),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _hasPermission = true),
                        child: const Text("Keyinroq",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// 1. XARITA BOʻLIMI – TOʻLIQ, HECH NIMA OʻZGARMADI!
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _center = const LatLng(41.311081, 69.240562); // Toshkent

  final List<Map<String, dynamic>> demoPlaces = [
    {
      "id": "1",
      "name": "Mega Planet Savdo Markazi",
      "lat": 41.322,
      "lng": 69.245,
      "rating": 4.8,
      "ramp": true,
      "wideDoor": true,
      "toilet": true,
      "lift": true,
      "parking": true,
      "type": "Savdo markazi"
    },
    {
      "id": "2",
      "name": "Alay Bozor",
      "lat": 41.298,
      "lng": 69.235,
      "rating": 1.5,
      "ramp": false,
      "wideDoor": false,
      "toilet": false,
      "lift": false,
      "parking": false,
      "type": "Bozor"
    },
    {
      "id": "3",
      "name": "Toshkent City Park",
      "lat": 41.315,
      "lng": 69.252,
      "rating": 4.2,
      "ramp": true,
      "wideDoor": true,
      "toilet": true,
      "lift": false,
      "parking": true,
      "type": "Bog'"
    },
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadDemoMarkers();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
    } catch (e) {
      // Ruxsat yoʻq boʻlsa – crash boʻlmaydi
    }
  }

  void _loadDemoMarkers() {
    for (var place in demoPlaces) {
      final hue = place["rating"] >= 4
          ? BitmapDescriptor.hueGreen
          : place["rating"] >= 2.5
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueRed;

      _markers.add(
        Marker(
          markerId: MarkerId(place["id"]),
          position: LatLng(place["lat"], place["lng"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () => _showPlaceDetails(place),
        ),
      );
    }
    setState(() {});
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(_getTypeIcon(place["type"]),
                        size: 40, color: Colors.indigo),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        place["name"],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text("${place["rating"]} (128 ta baho)",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const Divider(height: 40),
                _featureRow("Pandus", place["ramp"]),
                _featureRow("Keng eshik", place["wideDoor"]),
                _featureRow("Maxsus hojatxona", place["toilet"]),
                _featureRow("Lift", place["lift"]),
                _featureRow("Nogironlar uchun avtoturargoh", place["parking"]),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text("Yoʻnalish olish"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.indigo),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.rate_review),
                    label: const Text("Baholash va sharh qoldirish"),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String title, bool has) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(has ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: has ? Colors.green : Colors.red, size: 28),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "Savdo markazi":
        return Icons.shopping_bag;
      case "Bozor":
        return Icons.store;
      case "Bog'":
        return Icons.park;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AccessUz Xarita"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.my_location), onPressed: _getLocation),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip("Pandus", true),
                      _filterChip("Hojatxona", true),
                      _filterChip("Lift", false),
                      _filterChip("Reyting yuqori", true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label:
            const Text("Joy qoʻshish", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddPlaceScreen())),
      ),
    );
  }

  Widget _filterChip(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        selectedColor: Colors.indigo.withOpacity(0.2),
        checkmarkColor: Colors.indigo,
        onSelected: (_) {},
      ),
    );
  }
}

// QOLGAN BOʻLIMLAR – TOʻLIQ SAQLANDI
class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  final List<Map<String, dynamic>> places = const [
    {
      "name": "Mega Planet",
      "rating": 4.8,
      "distance": "1.2 km",
      "type": "Savdo markazi"
    },
    {
      "name": "Alay Bozor",
      "rating": 1.5,
      "distance": "2.5 km",
      "type": "Bozor"
    },
    {
      "name": "Toshkent City Park",
      "rating": 4.2,
      "distance": "800 m",
      "type": "Bog'"
    },
    {
      "name": "Ozbekiston Milliy Banki",
      "rating": 3.8,
      "distance": "1.8 km",
      "type": "Bank"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Obyektlar"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Joy nomini qidiring...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (ctx, i) {
                final p = places[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p["rating"] >= 4
                          ? Colors.green
                          : p["rating"] >= 2.5
                              ? Colors.orange
                              : Colors.red,
                      child: Text(p["rating"].toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${p["distance"]} • ${p["type"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Profil"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 80, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("User",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("user@accessuz.uz",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("Foydalanuvchi ID: UZ-2025-0481",
                style: TextStyle(color: Colors.grey)),
            const Divider(height: 50),
            _profileCard(
                "Kiritgan joylarim", Icons.add_location_alt, "47 ta joy"),
            _profileCard("Saqlangan joylar", Icons.bookmark, "12 ta"),
            _profileCard("Berilgan baholar", Icons.star_rate, "89 ta"),
            _profileCard("Ilova haqida", Icons.info, null,
                onTap: () => _showAboutDialog(context)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Hisobdan chiqish",
                    style: TextStyle(color: Colors.red)),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(String title, IconData icon, String? count,
      {VoidCallback? onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: count != null
            ? Text(count,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            : const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "AccessUz",
      applicationVersion: "1.0.0",
      applicationIcon:
          const Icon(Icons.accessible, size: 60, color: Colors.indigo),
      children: const [
        Text(
            "O‘zbekiston uchun birinchi nogironlar aravachasi kirish imkoniyati xaritasi"),
        SizedBox(height: 10),
        Text("Bizning maqsadimiz – har bir inson uchun shaharni qulay qilish"),
        SizedBox(height: 10),
        Text("© 2025 AccessUz jamoasi. Barcha huquqlar himoyalangan."),
      ],
    );
  }
}

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _nameController = TextEditingController();
  bool ramp = false,
      wideDoor = false,
      toilet = false,
      lift = false,
      parking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yangi joy qoʻshish")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Joy nomi",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Kirish imkoniyatlari:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
                title: const Text("Pandus bor"),
                value: ramp,
                onChanged: (v) => setState(() => ramp = v)),
            SwitchListTile(
                title: const Text("Keng eshik"),
                value: wideDoor,
                onChanged: (v) => setState(() => wideDoor = v)),
            SwitchListTile(
                title: const Text("Maxsus hojatxona"),
                value: toilet,
                onChanged: (v) => setState(() => toilet = v)),
            SwitchListTile(
                title: const Text("Lift mavjud"),
                value: lift,
                onChanged: (v) => setState(() => lift = v)),
            SwitchListTile(
                title: const Text("Nogironlar uchun avtoturargoh"),
                value: parking,
                onChanged: (v) => setState(() => parking = v)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Saqlash va xaritaga qoʻshish"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.indigo),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Joy muvaffaqiyatli qoʻshildi!")));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
