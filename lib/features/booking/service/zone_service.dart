import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ZoneService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getEventZonesWithAvailability(String eventId, DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    final response = await supabase
        .rpc('get_zones_availability', params: {
          'p_event_id': eventId,
          'p_booking_date': dateStr,
        });

    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getBookedSeatsCount(String zoneId) async {
    final response = await supabase
        .from('bookings')
        .select('quantity')
        .eq('zone_id', zoneId)
        .eq('status', 'confirmed');

    if (response.isEmpty) return 0;

    return response
        .map((data) => data['quantity'] as int)
        .reduce((sum, quantity) => sum + quantity);
  }
} 