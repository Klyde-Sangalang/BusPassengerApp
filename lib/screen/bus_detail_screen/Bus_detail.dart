import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../notifier/bus_notifier.dart';
import '../../notifier/userdata_notifier.dart';
import '../../services/notif_service.dart';

class BusDetailScreen extends HookConsumerWidget {
  final int selectedBus;

  const BusDetailScreen({super.key, required this.selectedBus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bus = ref.watch(busDataProvider);
    final user = ref.watch(userProvider.notifier);
    final notifiedLocations = useState<Set<String>>({});

    useEffect(() {
      ref.read(busDataProvider.notifier).loadBuses();
      ref.read(userProvider.notifier).loadUserData();
      return null;
    }, []);

    ref.read(busDataProvider.notifier).loadBuses();

    final filteredBus = bus[selectedBus];

    Future<void> notif() async {
      if (notifiedLocations.value.contains(filteredBus.currentDestination)) {
        await NotifyHelper().displayNotification(
          title: 'Bus Alert',
          body: 'Bus is currently at ${filteredBus.currentDestination}!',
        );

        notifiedLocations.value = {
          ...notifiedLocations.value..remove(filteredBus.currentDestination)
        };
      }
    }

    notif();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Details',
            style: GoogleFonts.acme(fontSize: 22, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.directions_bus_filled),
                      title: const Text('Bus Number'),
                      subtitle: Text(filteredBus.busNumber),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Driver'),
                      subtitle: Text(
                          '${filteredBus.firstName} ${filteredBus.lastName}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(filteredBus.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Current Destination'),
                      subtitle: Text(
                          filteredBus.currentDestination ?? 'Not Available'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Passengers'),
                      subtitle: Text(
                          '${filteredBus.passengers ?? 0} / ${filteredBus.maxPassengers ?? 0}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('Last Location'),
                      subtitle: Text(filteredBus.lastLocation ?? 'Unknown'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Route Destinations',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...filteredBus.destinations.map((destination) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.location_pin),
                    title: Text(destination),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        color: notifiedLocations.value.contains(destination)
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      onPressed: () async {
                        if (notifiedLocations.value.contains(destination)) {
                          notifiedLocations.value = {};
                        } else {
                          notifiedLocations.value = {destination};
                        }
                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
