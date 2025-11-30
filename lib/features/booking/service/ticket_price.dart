import 'package:supabase_flutter/supabase_flutter.dart';

class TicketPriceService {
  final supabase = Supabase.instance.client;

  Future<double> getTicketPrice(String eventId) async {
    final response = await supabase
        .from('zones')
        .select('min_price: price')
        .eq('event_id', eventId)
        .limit(1)
        .single();

    return response['min_price'] as double;
  }
}

