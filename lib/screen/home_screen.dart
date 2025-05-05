import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../notifier/auth_notifier.dart';
import '../notifier/bus_notifier.dart';
import 'auth_screen/login_screen.dart';
import 'bus_detail_screen/Bus_detail.dart';
import 'qr_scan.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final buses = ref.watch(busDataProvider);

    final searchQuery = useState('');
    final isSearching = useState(false);
    final selectedBus = useState<int>(0); // initially show the first bus route

    useEffect(() {
      ref.read(busDataProvider.notifier).loadBuses();
      return null;
    }, []);
    ref.read(busDataProvider.notifier).loadBuses();
    final filteredBuses = buses
        .where((bus) =>
            bus.busNumber.contains(searchQuery.value) ||
            bus.firstName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            bus.lastName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            bus.destinations.any((destination) => destination
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase())))
        .toList();

    Future<void> reloadBuses() async {
      ref.read(busDataProvider.notifier).loadBuses();
    }

    Future<void> signOut(BuildContext context) async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        title: isSearching.value
            ? TextField(
                onChanged: (query) {
                  searchQuery.value = query;
                },
                style: const TextStyle(color: Colors.black),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search buses...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              )
            : Text(
                "Bus Alert System",
                style: GoogleFonts.acme(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: isSearching.value
                ? const Icon(Icons.close)
                : const Icon(Icons.search),
            onPressed: () {
              isSearching.value = !isSearching.value;
              if (!isSearching.value) {
                searchQuery.value = '';
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.control_camera_rounded),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QrScanScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: reloadBuses,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (buses.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Route Preview",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0;
                                i <
                                    buses[selectedBus.value]
                                        .destinations
                                        .length;
                                i++) ...[
                              Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: (buses[selectedBus.value]
                                                .destinations[i] !=
                                            buses[selectedBus.value]
                                                .currentDestination)
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    buses[selectedBus.value].destinations[i],
                                    style: (buses[selectedBus.value]
                                                .destinations[i] !=
                                            buses[selectedBus.value]
                                                .currentDestination)
                                        ? const TextStyle(
                                            color: Colors.blue,
                                          )
                                        : const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                  ),
                                ],
                              ),
                              if (i !=
                                  buses[selectedBus.value].destinations.length -
                                      1)
                                Container(
                                  width: 40,
                                  height: 2,
                                  color: Colors.blue,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Show the arrival time of the selected bus
              const SizedBox(height: 20),
              if (buses.isNotEmpty) ...[
                Text(
                  "Arrived : ${buses[selectedBus.value].currentDestination} at ${buses[selectedBus.value].timeArrived}",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "Depart : ${buses[selectedBus.value].lastLocation} at ${buses[selectedBus.value].timeLeft}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],

              // List of buses
              SizedBox(
                  height: 450,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredBuses.length,
                    itemBuilder: (context, index) {
                      final bus = filteredBuses[index];

                      if (bus.destinations.length < 2) {
                        return const SizedBox.shrink(); // Don't show anything
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          title: Text('Bus Number: ${bus.busNumber}'),
                          subtitle:
                              Text('Driver: ${bus.firstName} ${bus.lastName}'),
                          onTap: () {
                            final realIndex = buses.indexOf(bus);
                            selectedBus.value = realIndex;
                            reloadBuses();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      BusDetailScreen(selectedBus: index)));
                            },
                          ),
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
