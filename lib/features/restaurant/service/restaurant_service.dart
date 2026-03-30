import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/restaurant_model.dart';
import '../model/restaurant_category_model.dart';
import '../model/menu_category_model.dart';
import '../model/menu_item_model.dart';
import '../model/menu_item_option_model.dart';
import '../model/restaurant_table_model.dart';
import '../model/restaurant_booking_model.dart';

class RestaurantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RestaurantCategory>> getRestaurantCategories() async {
    try {
      final response = await _supabase
          .from('restaurant_categories')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => RestaurantCategory.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurant categories: $e');
    }
  }

  Future<List<Restaurant>> getRestaurants({
    String? categoryId,
    String? sortBy,
    bool ascending = true,
    bool featuredOnly = false,
  }) async {
    try {
      dynamic query = _supabase
          .from('restaurants')
          .select('*')
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (featuredOnly) {
        query = query.eq('is_featured', true);
      }

      if (sortBy != null) {
        query = query.order(sortBy, ascending: ascending);
      } else {
        query = query.order('is_featured', ascending: false)
                   .order('average_rating', ascending: false);
      }

      final response = await query;

      return (response as List)
          .map((item) => Restaurant.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch restaurant: $e');
    }
  }

  Future<List<MenuCategory>> getMenuCategories(String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('is_active', true)
          .order('display_order');

      return (response as List)
          .map((item) => MenuCategory.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu categories: $e');
    }
  }

  Future<List<MenuItem>> getMenuItems({
    required String restaurantId,
    String? categoryId,
    bool popularOnly = false,
  }) async {
    try {
      dynamic query = _supabase
          .from('menu_items')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (popularOnly) {
        query = query.eq('is_popular', true);
      }

      query = query.order('display_order').order('name');

      final response = await query;

      return (response as List)
          .map((item) => MenuItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  Future<List<MenuItemOption>> getMenuItemOptions(String menuItemId) async {
    try {
      final response = await _supabase
          .from('menu_item_options')
          .select('*')
          .eq('menu_item_id', menuItemId)
          .order('option_type')
          .order('display_order');

      return (response as List)
          .map((item) => MenuItemOption.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu item options: $e');
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('average_rating', ascending: false);

      return (response as List)
          .map((item) => Restaurant.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  Future<List<MenuItem>> searchMenuItems(String restaurantId, String query) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('is_popular', ascending: false)
          .order('name');

      return (response as List)
          .map((item) => MenuItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  // TABLE BOOKING METHODS

  Future<List<RestaurantTable>> getRestaurantTables(String restaurantId) async {
    try {
      final response = await _supabase
          .from('restaurant_tables')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .order('table_number');

      return (response as List)
          .map((item) => RestaurantTable.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurant tables: $e');
    }
  }

  Future<List<RestaurantTable>> getAvailableTables({
    required String restaurantId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    int? minCapacity,
  }) async {
    try {
      // Get all tables for the restaurant
      final allTablesResponse = await _supabase
          .from('restaurant_tables')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true);

      List<RestaurantTable> allTables = (allTablesResponse as List)
          .map((item) => RestaurantTable.fromJson(item))
          .toList();

      // Filter by capacity if specified
      if (minCapacity != null) {
        allTables = allTables.where((table) => table.capacity >= minCapacity).toList();
      }

      // Get existing bookings for the date and time range
      final bookingsResponse = await _supabase
          .from('restaurant_bookings')
          .select('table_id')
          .eq('restaurant_id', restaurantId)
          .eq('booking_date', date.toIso8601String().split('T')[0])
          .gte('end_time', startTime.toIso8601String())
          .lte('start_time', endTime.toIso8601String())
          .not('status', 'eq', 'cancelled');

      List<String> bookedTableIds = (bookingsResponse as List)
          .map((booking) => booking['table_id'] as String)
          .toSet()
          .toList();

      // Return tables that are not booked
      return allTables
          .where((table) => !bookedTableIds.contains(table.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available tables: $e');
    }
  }

  Future<RestaurantBooking> createTableBooking({
    required String restaurantId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required int partySize,
    String? specialRequests,
    String? contactPhone,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if table is still available
      final availableTables = await getAvailableTables(
        restaurantId: restaurantId,
        date: bookingDate,
        startTime: startTime,
        endTime: endTime,
      );

      if (!availableTables.any((table) => table.id == tableId)) {
        throw Exception('Table is no longer available for the selected time');
      }

      // Check table capacity
      final table = availableTables.firstWhere((table) => table.id == tableId);
      if (partySize > table.capacity) {
        throw Exception('Party size exceeds table capacity (${table.capacity})');
      }

      final bookingData = {
        'user_id': userId,
        'restaurant_id': restaurantId,
        'table_id': tableId,
        'booking_date': bookingDate.toIso8601String().split('T')[0],
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'party_size': partySize,
        'special_requests': specialRequests,
        'contact_phone': contactPhone,
        'status': 'pending',
      };

      final response = await _supabase
          .from('restaurant_bookings')
          .insert(bookingData)
          .select()
          .single();

      final booking = RestaurantBooking.fromJson(response);

      // Send confirmation email asynchronously
      _sendBookingConfirmationEmail(
        bookingId: booking.id,
        userId: userId,
        restaurantId: restaurantId,
        tableId: tableId,
        bookingDate: bookingDate,
        startTime: startTime,
        partySize: partySize,
        specialRequests: specialRequests,
      ).catchError((error) {
        debugPrint('Failed to send restaurant booking confirmation email: $error');
        // Don't throw - email failure shouldn't fail the booking
      });

      return booking;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<void> _sendBookingConfirmationEmail({
    required String bookingId,
    required String userId,
    required String restaurantId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required int partySize,
    String? specialRequests,
  }) async {
    try {
      // Get user profile
      final profile = await _supabase
          .from('profiles')
          .select('full_name, email')
          .eq('id', userId)
          .single();

      // Get restaurant details
      final restaurant = await _supabase
          .from('restaurants')
          .select('name, address, phone')
          .eq('id', restaurantId)
          .single();

      // Get table details
      final table = await _supabase
          .from('restaurant_tables')
          .select('name')
          .eq('id', tableId)
          .single();

      // Format date and time
      final formattedDate = '${_getMonthName(bookingDate.month)} ${bookingDate.day}, ${bookingDate.year}';
      final formattedTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

      // Prepare email data
      final emailData = {
        'userName': profile['full_name'] ?? 'Valued Customer',
        'restaurantName': restaurant['name'],
        'bookingDate': formattedDate,
        'bookingTime': formattedTime,
        'tableName': table['name'] ?? 'Table',
        'partySize': partySize.toString(),
        'specialRequests': specialRequests ?? '',
        'restaurantAddress': restaurant['address'] ?? 'See restaurant details',
        'restaurantPhone': restaurant['phone'] ?? 'Contact via app',
        'bookingReference': bookingId.substring(0, 8).toUpperCase(),
      };

      // Call Supabase Edge Function to send email
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': profile['email'],
          'subject': 'Table Reservation Confirmed - ${restaurant['name']}',
          'template': 'restaurant-booking',
          'data': emailData,
        },
      );

      debugPrint('Restaurant booking confirmation email sent to ${profile['email']}');
    } catch (e) {
      debugPrint('Error sending restaurant booking confirmation email: $e');
      rethrow;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<List<RestaurantBooking>> getUserBookings({String? userId}) async {
    try {
      final currentUserId = userId ?? _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('restaurant_bookings')
          .select('''
            *,
            restaurant_tables!inner(table_number, capacity, table_type, location_description),
            restaurants!inner(name)
          ''')
          .eq('user_id', currentUserId)
          .order('booking_date', ascending: false)
          .order('start_time', ascending: false);

      return (response as List).map((item) {
        final booking = Map<String, dynamic>.from(item);
        
        // Add related data
        if (item['restaurant_tables'] != null) {
          booking['table'] = item['restaurant_tables'];
        }
        if (item['restaurants'] != null) {
          booking['restaurant_name'] = item['restaurants']['name'];
        }

        return RestaurantBooking.fromJson(booking);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<RestaurantBooking> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('restaurant_bookings')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .eq('user_id', userId) // Ensure user can only update their own bookings
          .select()
          .single();

      return RestaurantBooking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId: bookingId, status: 'cancelled');
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  /// Update payment information for a restaurant booking
  /// Added to support new payment fields (2026-03-21 schema update)
  Future<RestaurantBooking> updateBookingPayment({
    required String bookingId,
    required String transactionId,
    required String paymentStatus, // 'pending', 'paid', 'failed', 'refunded'
    required String paymentMethod,
    required String paymentReference,
    required double amountPaid,
    String currency = 'GHS',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('restaurant_bookings')
          .update({
            'transaction_id': transactionId,
            'payment_status': paymentStatus,
            'payment_method': paymentMethod,
            'payment_reference': paymentReference,
            'amount_paid': amountPaid,
            'currency': currency,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .eq('user_id', userId) // Ensure user can only update their own bookings
          .select()
          .single();

      return RestaurantBooking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update booking payment: $e');
    }
  }

  /// Get booking by payment reference
  /// Useful for payment callback verification
  Future<RestaurantBooking?> getBookingByPaymentReference(String paymentReference) async {
    try {
      final response = await _supabase
          .from('restaurant_bookings')
          .select()
          .eq('payment_reference', paymentReference)
          .maybeSingle();

      if (response == null) return null;
      return RestaurantBooking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch booking by payment reference: $e');
    }
  }

  Future<List<BookingTimeSlot>> getAvailableTimeSlots({
    required String restaurantId,
    required String tableId,
    required DateTime date,
  }) async {
    try {
      // Define standard time slots (2-hour slots from 10 AM to 10 PM)
      List<BookingTimeSlot> timeSlots = [];
      
      final baseDate = DateTime(date.year, date.month, date.day);
      for (int hour = 10; hour <= 20; hour += 2) {
        final startTime = baseDate.add(Duration(hours: hour));
        final endTime = startTime.add(const Duration(hours: 2));
        
        timeSlots.add(BookingTimeSlot(
          startTime: startTime,
          endTime: endTime,
          isAvailable: true,
        ));
      }

      // Get existing bookings for this table and date
      final bookingsResponse = await _supabase
          .from('restaurant_bookings')
          .select('start_time, end_time')
          .eq('table_id', tableId)
          .eq('booking_date', date.toIso8601String().split('T')[0])
          .not('status', 'eq', 'cancelled');

      List<Map<String, dynamic>> existingBookings = (bookingsResponse as List)
          .cast<Map<String, dynamic>>();

      // Mark unavailable time slots
      for (var slot in timeSlots) {
        for (var booking in existingBookings) {
          final bookingStart = DateTime.parse(booking['start_time']);
          final bookingEnd = DateTime.parse(booking['end_time']);
          
          // Check if time slots overlap
          if (slot.startTime.isBefore(bookingEnd) && slot.endTime.isAfter(bookingStart)) {
            timeSlots[timeSlots.indexOf(slot)] = slot.copyWith(
              isAvailable: false,
              unavailableReason: 'Already booked',
            );
            break;
          }
        }
      }

      return timeSlots;
    } catch (e) {
      throw Exception('Failed to fetch available time slots: $e');
    }
  }
}