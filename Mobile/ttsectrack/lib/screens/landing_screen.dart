import 'package:flutter/material.dart';
import 'live_tracking_screen.dart';
import 'account_screen.dart';
import 'my_moves_screen.dart';
import '../repositories/location_repository.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('lib/assets/images/MobitraLogo.png'),
                  ),
                  SizedBox(height: 12),
                  Text('Logged In User', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Live Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiveTrackingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('My Moves'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyMovesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const LandingScreenBody(),
    );
  }
}

class LandingScreenBody extends StatefulWidget {
  const LandingScreenBody({super.key});

  @override
  State<LandingScreenBody> createState() => _LandingScreenBodyState();
}

class _LandingScreenBodyState extends State<LandingScreenBody> {
  final LocationRepository _locationRepository = LocationRepository();
  int _movesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovesCount();
  }

  Future<void> _loadMovesCount() async {
    setState(() {
      _isLoading = true;
    });
    final count = await _locationRepository.getMovesCount();
    if (mounted) {
      setState(() {
        _movesCount = count;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadMovesCount();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator()
                  : StatCard(
                      title: 'Moves',
                      value: _movesCount.toString(),
                      icon: Icons.directions_run,
                      color: Colors.blueAccent,
                      fullWidth: true,
                    ),

              const SizedBox(height: 60),

              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.map, size: 72, color: Colors.blueAccent),
                      SizedBox(height: 12),
                      Text(
                        'Map Preview',
                        style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your latest tracked route will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
