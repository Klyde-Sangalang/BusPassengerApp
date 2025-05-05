import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/bus_model.dart';

class BusDataNotifier extends Notifier<List<Bus>> {
  @override
  List<Bus> build() => [];

  Future<void> loadBuses() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final buses = snapshot.docs.map((doc) {
      return Bus.fromMap(doc.data(), doc.id);
    }).toList();
    state = buses;
  }

  Future<List?> getPassengerNames(String busId) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(busId);
    final snapshot = await docRef.get();
    return snapshot.data()?['passengerNames'] as List<dynamic>?;
  }

  Future<void> addPassenger(String busId, String name) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(busId);
    await docRef.update({
      'passengerNames': FieldValue.arrayUnion([name]),
      'passengers': FieldValue.increment(1),
    });

    state = [
      for (final bus in state)
        if (bus.userId == busId)
          bus.copyWith(
            passengerNames: [...bus.passengerNames, name],
            passengers: (bus.passengers ?? 0) + 1,
          )
        else
          bus,
    ];
  }

  Future<void> removePassenger(String busId, String name) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(busId);
    await docRef.update({
      'passengerNames': FieldValue.arrayRemove([name]),
      'passengers': FieldValue.increment(-1),
    });
  }

  void clear() {
    state = [];
  }
}

final busDataProvider = NotifierProvider<BusDataNotifier, List<Bus>>(
  BusDataNotifier.new,
);
