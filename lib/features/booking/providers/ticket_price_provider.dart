import 'package:a_play/features/booking/service/ticket_price.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ticketPriceProvider = FutureProvider.family<double, String>((ref, eventId) async {
  final supabase = Supabase.instance.client;

  final price = await TicketPriceService().getTicketPrice(eventId);

  return price;
});

