// services/location_service.dart

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mediquick/core/utils/logger.dart';

/// Utility service for handling GPS location access and reverse geocoding.
class LocationService {
  /// Checks permissions and returns current GPS device position coordinates.
  static Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Layanan lokasi (GPS) tidak aktif.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin akses lokasi ditolak.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin akses lokasi ditolak secara permanen.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Converts GPS coordinates into a human-readable street address string.
  static Future<String> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return "Alamat tidak tersedia";

      final place = placemarks[0];

      return [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode
      ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
    } catch (e) {
      AppLogger.debug("Gagal mendapatkan alamat dari koordinat: $e");
      return "Alamat tidak tersedia";
    }
  }
}
